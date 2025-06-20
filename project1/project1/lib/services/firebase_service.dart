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
      
      _messageController?.add('Firebase bağlantısı başarılı!');
    } catch (e) {
      final errorMsg = 'Firebase bağlantı hatası: $e';
      _messageController?.add(errorMsg);
      print('Firebase Error: $e');
      throw Exception(errorMsg);
    }
  }

  Future<void> createGame(List<Question> questions) async {
    try {
      final game = MultiplayerGame.create(
        hostId: playerId,
        questions: questions,
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

  Future<void> joinGame(String gameId) async {
    try {
      _messageController?.add('Oyuna katılmaya çalışılıyor: $gameId');
      
      // Oyunun var olup olmadığını kontrol et
      final snapshot = await _database.child('games').child(gameId).get();
      
      if (!snapshot.exists) {
        _messageController?.add('Oyun bulunamadı: $gameId');
        return;
      }

      _messageController?.add('Oyun bulundu, veri işleniyor...');
      
      final dynamic rawData = snapshot.value;
      _messageController?.add('Ham veri alındı: ${rawData.runtimeType}');
      
      // Veri tipini güvenli şekilde dönüştür
      Map<String, dynamic> gameData;
      if (rawData is Map) {
        gameData = rawData.map((key, value) => MapEntry(key.toString(), value));
      } else {
        throw Exception('Beklenmeyen veri formatı: ${rawData.runtimeType}');
      }
      
      _messageController?.add('Oyun verisi dönüştürüldü: ${gameData.keys}');
      
      final game = MultiplayerGame.fromJson(gameData);
      _messageController?.add('Oyun nesnesi oluşturuldu: ${game.gameId}');
      
      if (game.guestId != null) {
        _messageController?.add('Oyun dolu: ${game.guestId}');
        return;
      }

      _messageController?.add('Misafir olarak katılım sağlanıyor...');
      
      // Misafir olarak katıl
      final updatedGame = game.copyWith(
        guestId: playerId,
        playerScores: {...game.playerScores, playerId: 0},
      );

      await _database.child('games').child(gameId).update(updatedGame.toJson());
      
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
      
      // Her iki oyuncu da cevap verdiğinde skorları güncelle
      if (updatedAnswers.length >= 2) {
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
      
      // Sonraki soruya geç veya oyunu bitir
      final nextQuestionIndex = currentQuestionIndex + 1;
      final isGameFinished = nextQuestionIndex >= questions.length;
      
      final updatedGame = game.copyWith(
        playerScores: updatedScores,
        playerAnswers: {}, // Cevap verilerini temizle
        currentQuestionIndex: nextQuestionIndex,
        status: isGameFinished ? GameStatus.finished : GameStatus.playing,
      );
      
      await _database.child('games').child(gameId).update(updatedGame.toJson());
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
      
      if (game.hostId != playerId) {
        _messageController?.add('Sadece oyun sahibi oyunu başlatabilir');
        return;
      }
      
      if (game.guestId == null) {
        _messageController?.add('Oyuncu bekleniyor');
        return;
      }

      final updatedGame = game.copyWith(status: GameStatus.playing);
      await _database.child('games').child(gameId).update(updatedGame.toJson());
      
      _messageController?.add('Oyun başlatıldı!');
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
      
      if (game.hostId == playerId) {
        // Host ayrıldı, oyunu sil
        await _database.child('games').child(gameId).remove();
      } else if (game.guestId == playerId) {
        // Guest ayrıldı
        final updatedScores = Map<String, int>.from(game.playerScores);
        updatedScores.remove(playerId);
        
        final updatedGame = game.copyWith(
          guestId: null,
          playerScores: updatedScores,
        );
        
        await _database.child('games').child(gameId).update(updatedGame.toJson());
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

  void dispose() {
    _gameSubscription?.cancel();
    _gameController?.close();
    _messageController?.close();
  }
} 