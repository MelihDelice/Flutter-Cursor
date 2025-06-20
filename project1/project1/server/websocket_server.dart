import 'dart:io';
import 'dart:convert';
import 'dart:async';

class GameServer {
  final Map<String, WebSocket> _clients = {};
  final Map<String, Map<String, dynamic>> _games = {};
  final HttpServer _server;

  GameServer(this._server) {
    _server.listen(_handleRequest);
    print('Game server started on port ${_server.port}');
  }

  void _handleRequest(HttpRequest request) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
        print('New client connected');
        
        webSocket.listen(
          (data) => _handleMessage(webSocket, data),
          onError: (error) => _handleError(webSocket, error),
          onDone: () => _handleDisconnect(webSocket),
        );
      }).catchError((error) {
        print('WebSocket upgrade error: $error');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('WebSocket upgrade failed')
          ..close();
      });
    } else {
      // CORS headers for browser compatibility
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
      
      if (request.method == 'OPTIONS') {
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
        return;
      }
      
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('WebSocket upgrade required')
        ..close();
    }
  }

  void _handleMessage(WebSocket webSocket, dynamic data) {
    try {
      final message = jsonDecode(data);
      final type = message['type'];
      final playerId = message['playerId'];

      switch (type) {
        case 'create_game':
          _handleCreateGame(webSocket, playerId, message);
          break;
        case 'join_game':
          _handleJoinGame(webSocket, playerId, message);
          break;
        case 'submit_answer':
          _handleSubmitAnswer(webSocket, playerId, message);
          break;
        case 'start_game':
          _handleStartGame(webSocket, playerId, message);
          break;
        case 'leave_game':
          _handleLeaveGame(webSocket, playerId, message);
          break;
        default:
          _sendError(webSocket, 'Unknown message type: $type');
      }
    } catch (e) {
      _sendError(webSocket, 'Invalid message format: $e');
    }
  }

  void _handleCreateGame(WebSocket webSocket, String playerId, Map<String, dynamic> message) {
    final gameData = message['game'];
    final gameId = gameData['gameId'];
    
    _clients[playerId] = webSocket;
    _games[gameId] = gameData;
    
    print('Game created: $gameId by player: $playerId');
    
    _sendMessage(webSocket, {
      'type': 'message',
      'text': 'Oyun başarıyla oluşturuldu!',
    });
    
    _broadcastGameUpdate(gameId);
  }

  void _handleJoinGame(WebSocket webSocket, String playerId, Map<String, dynamic> message) {
    final gameId = message['gameId'];
    
    if (!_games.containsKey(gameId)) {
      _sendError(webSocket, 'Oyun bulunamadı');
      return;
    }
    
    final game = _games[gameId]!;
    if (game['guestId'] != null) {
      _sendError(webSocket, 'Oyun dolu');
      return;
    }
    
    _clients[playerId] = webSocket;
    game['guestId'] = playerId;
    game['playerScores'][playerId] = 0;
    
    print('Player $playerId joined game $gameId');
    
    _sendMessage(webSocket, {
      'type': 'message',
      'text': 'Oyuna başarıyla katıldın!',
    });
    
    _broadcastGameUpdate(gameId);
  }

  void _handleSubmitAnswer(WebSocket webSocket, String playerId, Map<String, dynamic> message) {
    final gameId = message['gameId'];
    final answerIndex = message['answerIndex'];
    
    if (!_games.containsKey(gameId)) {
      _sendError(webSocket, 'Oyun bulunamadı');
      return;
    }
    
    final game = _games[gameId]!;
    game['playerAnswers'][playerId] = answerIndex;
    
    // Her iki oyuncu da cevap verdiğinde sonraki soruya geç
    if (game['playerAnswers'].length >= 2) {
      final currentQuestionIndex = game['currentQuestionIndex'];
      final questions = game['questions'] as List;
      
      // Skorları güncelle
      for (final entry in game['playerAnswers'].entries) {
        final playerId = entry.key;
        final answerIndex = entry.value;
        final currentQuestion = questions[currentQuestionIndex];
        final correctAnswer = currentQuestion['correctAnswer'];
        
        if (answerIndex == correctAnswer) {
          game['playerScores'][playerId] = (game['playerScores'][playerId] ?? 0) + 1;
        }
      }
      
      // Cevap verilerini temizle
      game['playerAnswers'].clear();
      
      // Sonraki soruya geç
      if (currentQuestionIndex + 1 < questions.length) {
        game['currentQuestionIndex'] = currentQuestionIndex + 1;
      } else {
        // Oyun bitti
        game['status'] = 'GameStatus.finished';
      }
    }
    
    _broadcastGameUpdate(gameId);
  }

  void _handleStartGame(WebSocket webSocket, String playerId, Map<String, dynamic> message) {
    final gameId = message['gameId'];
    
    if (!_games.containsKey(gameId)) {
      _sendError(webSocket, 'Oyun bulunamadı');
      return;
    }
    
    final game = _games[gameId]!;
    if (game['hostId'] != playerId) {
      _sendError(webSocket, 'Sadece oyun sahibi oyunu başlatabilir');
      return;
    }
    
    if (game['guestId'] == null) {
      _sendError(webSocket, 'Oyuncu bekleniyor');
      return;
    }
    
    game['status'] = 'GameStatus.playing';
    
    print('Game $gameId started');
    
    _broadcastGameUpdate(gameId);
  }

  void _handleLeaveGame(WebSocket webSocket, String playerId, Map<String, dynamic> message) {
    final gameId = message['gameId'];
    
    if (_games.containsKey(gameId)) {
      final game = _games[gameId]!;
      
      if (game['hostId'] == playerId) {
        // Host ayrıldı, oyunu sil
        _games.remove(gameId);
        print('Game $gameId removed (host left)');
      } else if (game['guestId'] == playerId) {
        // Guest ayrıldı
        game['guestId'] = null;
        game['playerScores'].remove(playerId);
        print('Guest left game $gameId');
      }
      
      _broadcastGameUpdate(gameId);
    }
    
    _clients.remove(playerId);
  }

  void _handleError(WebSocket webSocket, error) {
    print('WebSocket error: $error');
  }

  void _handleDisconnect(WebSocket webSocket) {
    final playerId = _clients.entries
        .where((entry) => entry.value == webSocket)
        .firstOrNull?.key;
    
    if (playerId != null) {
      _clients.remove(playerId);
      print('Client disconnected: $playerId');
      
      // Oyuncunun bulunduğu oyunları temizle
      _games.removeWhere((gameId, game) {
        if (game['hostId'] == playerId || game['guestId'] == playerId) {
          print('Game $gameId removed (player disconnected)');
          return true;
        }
        return false;
      });
    }
  }

  void _broadcastGameUpdate(String gameId) {
    if (!_games.containsKey(gameId)) return;
    
    final game = _games[gameId]!;
    final gameUpdate = {
      'type': 'game_update',
      'game': game,
    };
    
    final hostId = game['hostId'];
    final guestId = game['guestId'];
    
    if (_clients.containsKey(hostId)) {
      _sendMessage(_clients[hostId]!, gameUpdate);
    }
    
    if (guestId != null && _clients.containsKey(guestId)) {
      _sendMessage(_clients[guestId]!, gameUpdate);
    }
  }

  void _sendMessage(WebSocket webSocket, Map<String, dynamic> message) {
    try {
      webSocket.add(jsonEncode(message));
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _sendError(WebSocket webSocket, String error) {
    _sendMessage(webSocket, {
      'type': 'error',
      'text': error,
    });
  }

  void close() {
    _server.close();
    for (final client in _clients.values) {
      client.close();
    }
    print('Game server stopped');
  }
}

void main() async {
  try {
    final server = await HttpServer.bind('localhost', 8080);
    final gameServer = GameServer(server);
    
    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) {
      print('\nShutting down server...');
      gameServer.close();
      exit(0);
    });
  } catch (e) {
    print('Failed to start server: $e');
    exit(1);
  }
} 