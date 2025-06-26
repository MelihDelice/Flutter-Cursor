import 'dart:convert';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/multiplayer_game.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _playerId;
  StreamController<MultiplayerGame>? _gameController;
  StreamController<String>? _messageController;
  StreamSubscription<DatabaseEvent>? _gameSubscription;
  Timer? _questionTimer;
  Timer? _speedModeTimer;
  
  final _uuid = Uuid();

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  String get playerId => _playerId ??= _uuid.v4();

  Stream<MultiplayerGame> get gameStream => _gameController?.stream ?? 
      Stream.empty();

  Stream<String> get messageStream => _messageController?.stream ?? 
      Stream.empty();

  Future<void> initialize() async {
    try {
      _gameController = StreamController<MultiplayerGame>.broadcast();
      _messageController = StreamController<String>.broadcast();
      
      _messageController?.add('Firebase başlatılıyor...');
      
      // Basit test bağlantısı
      _messageController?.add('Database test ediliyor...');
      
      // Sadece okuma testi yap
      await _database.child('test').get();
      
      // Firebase bağlantısı başarılı - mesaja gerek yok, sadece bağlantı durumu yeterli
    } catch (e) {
      final errorMsg = 'Firebase bağlantı hatası: $e';
      _messageController?.add(errorMsg);
      print('Firebase Error: $e');
      throw Exception(errorMsg);
    }
  }

  Future<void> createGame(List<Question> questions, String category, String hostName, String gameId, [GameMode gameMode = GameMode.normal]) async {
    try {
      final game = MultiplayerGame(
        gameId: gameId,
        hostId: playerId,
        playerIds: [playerId],
        status: GameStatus.waiting,
        questions: questions,
        currentQuestionIndex: 0,
        playerScores: {playerId: 0},
        playerAnswers: {},
        playerNames: {playerId: hostName},
        createdAt: DateTime.now(),
        category: category,
        questionStartTime: null,
        questionTimeLimit: 8,
        maxPlayers: 150,
        gameMode: gameMode,
        speedModeRemainingTime: gameMode == GameMode.speed ? 80 : null,
      );

      _messageController?.add('Oyun oluşturuluyor: ${game.gameId}');

      // Firebase'e oyunu kaydet
      await _database.child('games').child(game.gameId).set(game.toJson());
      
      _messageController?.add('Oyun Firebase\'e kaydedildi');
      
      // Oyun değişikliklerini dinle
      _listenToGame(game.gameId);
      
      _messageController?.add('Oyun başarıyla oluşturuldu!');
    } catch (e) {
      final errorMsg = 'Oyun oluşturma hatası: $e';
      _messageController?.add(errorMsg);
      print('CreateGame Error: $e');
      throw Exception(errorMsg);
    }
  }

  Future<void> joinGame(String gameId, String playerName) async {
    try {
      _messageController?.add('Oyuna katılmaya çalışılıyor: $gameId');
      
      // Oyunun var olup olmadığını kontrol et
      final snapshot = await _database.child('games').child(gameId).get();
      
      if (!snapshot.exists) {
        _messageController?.add('Oyun bulunamadı: $gameId');
        return;
      }

      final dynamic rawData = snapshot.value;
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        throw Exception('Beklenmeyen veri formatı: ${rawData.runtimeType}');
      }
      
      final game = MultiplayerGame.fromJson(gameData);
      
      // Oyuncunun zaten oyunda olup olmadığını kontrol et
      if (game.isPlayerInGame(playerId)) {
        _messageController?.add('Zaten oyundasın');
        _listenToGame(gameId);
        return;
      }

      // Oyuna katılabilir mi kontrol et
      if (!game.canJoin()) {
        _messageController?.add('Oyun dolu (${game.playerCount}/${game.maxPlayers}) veya başlamış');
        return;
      }

      _messageController?.add('Oyuna katılım sağlanıyor...');
      
      // Oyuncuları güncelle - sadece gerekli alanları güncelle
      final updatedPlayerIds = [...game.playerIds, playerId];
      final updates = <String, dynamic>{
        'playerIds': updatedPlayerIds,
        'playerScores/$playerId': 0,
        'playerNames/$playerId': playerName,
      };

      await _database.child('games').child(gameId).update(updates);
      
      _messageController?.add('Oyun güncellendi, dinleme başlatılıyor...');
      
      // Oyun değişikliklerini dinle
      _listenToGame(gameId);
      
      _messageController?.add('Oyuna başarıyla katıldın!');
    } catch (e) {
      final errorMsg = 'Oyuna katılma hatası: $e';
      _messageController?.add(errorMsg);
      print('JoinGame Error: $e');
      throw Exception(errorMsg);
    }
  }

  Future<void> submitAnswer(String gameId, int answerIndex) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get();
      if (!snapshot.exists) return;

      final dynamic rawData = snapshot.value;
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        throw Exception('Beklenmeyen veri formatı: ${rawData.runtimeType}');
      }
      
      final game = MultiplayerGame.fromJson(gameData);
      
      // Cevabı kaydet
      final updatedAnswers = {...game.playerAnswers, playerId: answerIndex};
      final updatedGame = game.copyWith(playerAnswers: updatedAnswers);
      
      await _database.child('games').child(gameId).update(updatedGame.toJson());
      
      // Hızlı modda: cevap verildiğinde hemen sonraki soruya geç
      // Normal modda: tüm oyuncular cevap verdiğinde skorları güncelle
      if (game.gameMode == GameMode.speed) {
        await _processAnswers(gameId, updatedGame);
      } else if (updatedAnswers.length >= game.playerCount) {
        _questionTimer?.cancel(); // Timer'ı iptal et
        await _processAnswers(gameId, updatedGame);
      }
    } catch (e) {
      _messageController?.add('Cevap gönderme hatası: $e');
    }
  }

  Future<void> _processAnswers(String gameId, MultiplayerGame game) async {
    try {
      final currentQuestionIndex = game.currentQuestionIndex;
      final questions = game.questions;
      
      if (currentQuestionIndex >= questions.length) return;
      
      final currentQuestion = questions[currentQuestionIndex];
      final playerAnswers = game.playerAnswers;
      
      // Skorları güncelle
      final updatedScores = Map<String, int>.from(game.playerScores);
      
      for (final entry in playerAnswers.entries) {
        final playerId = entry.key;
        final answerIndex = entry.value;
        
        if (answerIndex == currentQuestion.correctAnswer) {
          updatedScores[playerId] = (updatedScores[playerId] ?? 0) + 1;
        }
      }
      
      // Önce sonuçları göster (2 saniye)
      final showingResultsGame = game.copyWith(
        playerScores: updatedScores,
        status: GameStatus.showingResults,
      );
      
      await _database.child('games').child(gameId).update(showingResultsGame.toJson());
      
      // 2 saniye bekle
      await Future.delayed(const Duration(seconds: 2));
      
      // Sonraki soruya geç veya oyunu bitir
      final nextQuestionIndex = currentQuestionIndex + 1;
      final isGameFinished = nextQuestionIndex >= questions.length;
      
      final finalGame = game.copyWith(
        playerScores: updatedScores,
        playerAnswers: {}, // Cevap verilerini temizle
        currentQuestionIndex: nextQuestionIndex,
        status: isGameFinished ? GameStatus.finished : GameStatus.playing,
        questionStartTime: isGameFinished ? null : DateTime.now(),
      );
      
      await _database.child('games').child(gameId).update(finalGame.toJson());
      
      // Yeni soru için timer başlat (oyun bitmemişse)
      if (!isGameFinished) {
        _startQuestionTimer(gameId, game.questionTimeLimit);
      }
    } catch (e) {
      _messageController?.add('Skor güncelleme hatası: $e');
    }
  }

  Future<void> startGame(String gameId) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get();
      if (!snapshot.exists) return;

      final dynamic rawData = snapshot.value;
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        throw Exception('Beklenmeyen veri formatı: ${rawData.runtimeType}');
      }
      
      final game = MultiplayerGame.fromJson(gameData);
      
      if (!game.isHost(playerId)) {
        _messageController?.add('Sadece oyun sahibi oyunu başlatabilir');
        return;
      }
      
      if (game.playerCount < 2) {
        _messageController?.add('En az 2 oyuncu gerekiyor (Şu an: ${game.playerCount})');
        return;
      }

      // Oyunu başlat ve ilk soru için timer'ı ayarla
      final now = DateTime.now();
      final updatedGame = game.copyWith(
        status: GameStatus.playing,
        questionStartTime: now,
      );
      await _database.child('games').child(gameId).update(updatedGame.toJson());
      
      // Timer başlat (mod'a göre)
      if (game.gameMode == GameMode.speed) {
        _startSpeedModeTimer(gameId);
      } else {
        _startQuestionTimer(gameId, game.questionTimeLimit);
      }
      
      _messageController?.add('Oyun başlatıldı! (${game.playerCount} oyuncu)');
    } catch (e) {
      _messageController?.add('Oyun başlatma hatası: $e');
    }
  }

  Future<void> leaveGame(String gameId) async {
    try {
      _gameSubscription?.cancel();
      
      final snapshot = await _database.child('games').child(gameId).get();
      if (!snapshot.exists) return;

      final dynamic rawData = snapshot.value;
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        throw Exception('Beklenmeyen veri formatı: ${rawData.runtimeType}');
      }
      
      final game = MultiplayerGame.fromJson(gameData);
      
      // Oyun devam ediyorsa, oyunu sonlandır
      if (game.status == GameStatus.playing) {
        final updatedGame = game.copyWith(status: GameStatus.finished);
        await _database.child('games').child(gameId).update(updatedGame.toJson());
        _messageController?.add('Oyuncu ayrıldı, oyun sonlandırıldı');
      }
      
      if (game.isHost(playerId)) {
        // Host ayrıldı, oyunu sil
        await _database.child('games').child(gameId).remove();
        _messageController?.add('Oyun sahibi ayrıldı, oyun silindi');
      } else if (game.isPlayerInGame(playerId)) {
        // Oyuncu ayrıldı
        final updatedPlayerIds = game.playerIds.where((id) => id != playerId).toList();
        final updatedScores = Map<String, int>.from(game.playerScores);
        updatedScores.remove(playerId);
        
        final updatedGame = game.copyWith(
          playerIds: updatedPlayerIds,
          playerScores: updatedScores,
          status: updatedPlayerIds.length < 2 ? GameStatus.finished : game.status,
        );
        
        await _database.child('games').child(gameId).update(updatedGame.toJson());
        _messageController?.add('Oyundan ayrıldın (${updatedPlayerIds.length} oyuncu kaldı)');
      }
    } catch (e) {
      _messageController?.add('Oyundan çıkma hatası: $e');
    }
  }

  void _listenToGame(String gameId) {
    _gameSubscription?.cancel();
    
    _gameSubscription = _database.child('games').child(gameId).onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          try {
            final dynamic rawData = event.snapshot.value;
            
            // Veri tipini güvenli şekilde dönüştür
            Map<String, dynamic> gameData;
            if (rawData is Map) {
              gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
            } else {
              _messageController?.add('Beklenmeyen veri formatı: ${rawData.runtimeType}');
              return;
            }
            
            final game = MultiplayerGame.fromJson(gameData);
            _gameController?.add(game);
          } catch (e) {
            _messageController?.add('Oyun verisi işleme hatası: $e');
            print('ListenToGame Error: $e');
          }
        } else {
          _messageController?.add('Oyun bulunamadı veya silindi');
        }
      },
      onError: (error) {
        _messageController?.add('Oyun dinleme hatası: $error');
        print('ListenToGame Stream Error: $error');
      },
    );
  }

  void _startQuestionTimer(String gameId, int timeLimit) {
    _questionTimer?.cancel();
    
    _questionTimer = Timer(Duration(seconds: timeLimit), () {
      _handleQuestionTimeout(gameId);
    });
  }

  Future<void> _handleQuestionTimeout(String gameId) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get();
      if (!snapshot.exists) return;

      final dynamic rawData = snapshot.value;
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        return;
      }
      
      final game = MultiplayerGame.fromJson(gameData);
      
      // Oyun durumu kontrol et
      if (game.status != GameStatus.playing) return;
      
      // Zaman doldu, skorları güncelle (cevap vermeyenler puan alamaz)
      await _processAnswers(gameId, game);
    } catch (e) {
      _messageController?.add('Zaman aşımı işleme hatası: $e');
    }
  }

  void _startSpeedModeTimer(String gameId) {
    _speedModeTimer?.cancel();
    
    // Her saniye güncelle
    _speedModeTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final snapshot = await _database.child('games').child(gameId).get();
        if (snapshot.exists) {
          final gameData = Map<String, dynamic>.from(snapshot.value as Map);
          final game = MultiplayerGame.fromJson(gameData);
          
          if (game.speedModeRemainingTime != null && game.speedModeRemainingTime! > 0) {
            // Süreyi 1 azalt
            final updatedGame = game.copyWith(
              speedModeRemainingTime: game.speedModeRemainingTime! - 1,
            );
            await _database.child('games').child(gameId).update(updatedGame.toJson());
          } else {
            // Süre bitti, oyunu sonlandır
            timer.cancel();
            final finishedGame = game.copyWith(status: GameStatus.finished);
            await _database.child('games').child(gameId).update(finishedGame.toJson());
            _messageController?.add('Süre doldu! Oyun bitti.');
          }
        }
      } catch (e) {
        print('Speed mode timer error: $e');
        timer.cancel();
      }
    });
  }

  void dispose() {
    _questionTimer?.cancel();
    _speedModeTimer?.cancel();
    _gameSubscription?.cancel();
    _gameController?.close();
    _messageController?.close();
  }
} 