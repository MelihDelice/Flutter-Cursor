import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../models/multiplayer_game.dart';

class MultiplayerService {
  static const String _serverUrl = 'ws://localhost:8080'; // HTTP upgrade için doğru format
  WebSocketChannel? _channel;
  String? _playerId;
  StreamController<MultiplayerGame>? _gameController;
  StreamController<String>? _messageController;
  
  final _uuid = Uuid();

  // Singleton pattern
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  String get playerId => _playerId ??= _uuid.v4();

  Stream<MultiplayerGame> get gameStream => _gameController?.stream ?? 
      Stream.empty();

  Stream<String> get messageStream => _messageController?.stream ?? 
      Stream.empty();

  Future<void> initialize() async {
    _gameController = StreamController<MultiplayerGame>.broadcast();
    _messageController = StreamController<String>.broadcast();
  }

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      
      // Bağlantı başarılı mesajı
      _messageController?.add('Bağlantı kuruldu');
      
      _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (error) {
          print('WebSocket error: $error');
          _messageController?.add('Bağlantı hatası: $error');
          _channel = null;
        },
        onDone: () {
          print('WebSocket connection closed');
          _messageController?.add('Bağlantı kesildi');
          _channel = null;
        },
      );
    } catch (e) {
      print('Connection error: $e');
      _messageController?.add('Bağlantı kurulamadı: $e');
      _channel = null;
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      final type = message['type'];
      
      switch (type) {
        case 'game_update':
          final gameData = message['game'];
          final game = MultiplayerGame.fromJson(gameData);
          _gameController?.add(game);
          break;
        case 'message':
          _messageController?.add(message['text']);
          break;
        case 'error':
          _messageController?.add('Hata: ${message['text']}');
          break;
      }
    } catch (e) {
      _messageController?.add('Mesaj işleme hatası: $e');
    }
  }

  Future<void> createGame(List<Question> questions) async {
    if (_channel == null) {
      _messageController?.add('Bağlantı kurulmamış');
      return;
    }

    final game = MultiplayerGame.create(
      hostId: playerId,
      questions: questions,
    );

    final message = {
      'type': 'create_game',
      'playerId': playerId,
      'game': game.toJson(),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> joinGame(String gameId) async {
    if (_channel == null) {
      _messageController?.add('Bağlantı kurulmamış');
      return;
    }

    final message = {
      'type': 'join_game',
      'playerId': playerId,
      'gameId': gameId,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> submitAnswer(String gameId, int answerIndex) async {
    if (_channel == null) {
      _messageController?.add('Bağlantı kurulmamış');
      return;
    }

    final message = {
      'type': 'submit_answer',
      'playerId': playerId,
      'gameId': gameId,
      'answerIndex': answerIndex,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> startGame(String gameId) async {
    if (_channel == null) {
      _messageController?.add('Bağlantı kurulmamış');
      return;
    }

    final message = {
      'type': 'start_game',
      'playerId': playerId,
      'gameId': gameId,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Future<void> leaveGame(String gameId) async {
    if (_channel == null) {
      _messageController?.add('Bağlantı kurulmamış');
      return;
    }

    final message = {
      'type': 'leave_game',
      'playerId': playerId,
      'gameId': gameId,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  void dispose() {
    _channel?.sink.close();
    _gameController?.close();
    _messageController?.close();
  }
} 