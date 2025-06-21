import 'package:flutter/foundation.dart';
import '../models/multiplayer_game.dart';
import '../services/firebase_service.dart';

class MultiplayerProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  
  MultiplayerGame? _currentGame;
  String? _currentGameId;
  PlayerRole? _playerRole;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  MultiplayerGame? get currentGame => _currentGame;
  String? get currentGameId => _currentGameId;
  PlayerRole? get playerRole => _playerRole;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get playerId => _service.playerId;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _clearMessages();
      notifyListeners();
      
      await _service.initialize();
      _service.gameStream.listen(_onGameUpdate);
      _service.messageStream.listen(_onMessage);
      
      _isConnected = true;
      // Firebase bağlantısı başarılı - mesaja gerek yok, sadece bağlantı durumu yeterli
    } catch (e) {
      _errorMessage = 'Firebase bağlantı hatası: $e';
      _isConnected = false;
      print('MultiplayerProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onGameUpdate(MultiplayerGame game) {
    _currentGame = game;
    _currentGameId = game.gameId;
    
    if (game.hostId == _service.playerId) {
      _playerRole = PlayerRole.host;
    } else if (game.guestId == _service.playerId) {
      _playerRole = PlayerRole.guest;
    }
    
    _isConnected = true;
    _clearMessages();
    notifyListeners();
  }

  void _onMessage(String message) {
    if (message.contains('Bağlantı kuruldu')) {
      _isConnected = true;
      _successMessage = message;
    } else if (message.contains('Bağlantı kesildi') || message.contains('Bağlantı hatası') || message.contains('Bağlantı kurulamadı')) {
      _isConnected = false;
      _errorMessage = message;
    } else if (message.contains('Hata') || message.contains('error')) {
      _errorMessage = message;
    } else {
      _successMessage = message;
    }
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  Future<void> createGame(List<Question> questions) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();

    try {
      final gameId = MultiplayerGame.generateGameId();
      _currentGameId = gameId;
      
      // Oyunu hemen oluştur ve ayarla
      _currentGame = MultiplayerGame.create(
        hostId: playerId,
        questions: questions,
      );
      _playerRole = PlayerRole.host;
      
      await _service.createGame(questions);
      _successMessage = 'Oyun oluşturuldu! Referans kodunu arkadaşlarınla paylaş.';
    } catch (e) {
      _errorMessage = 'Oyun oluşturma hatası: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGame(String gameId) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();

    try {
      await _service.joinGame(gameId);
      _currentGameId = gameId;
      _playerRole = PlayerRole.guest;
      _successMessage = 'Oyuna katıldın!';
    } catch (e) {
      _errorMessage = 'Oyuna katılma hatası: $e';
      print('MultiplayerProvider JoinGame Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(int answerIndex) async {
    if (_currentGameId == null) return;

    try {
      await _service.submitAnswer(_currentGameId!, answerIndex);
    } catch (e) {
      _errorMessage = 'Cevap gönderme hatası: $e';
      notifyListeners();
    }
  }

  Future<void> startGame() async {
    if (_currentGameId == null || _playerRole != PlayerRole.host) return;

    _isLoading = true;
    _clearMessages();
    notifyListeners();

    try {
      await _service.startGame(_currentGameId!);
      _successMessage = 'Oyun başlatıldı!';
    } catch (e) {
      _errorMessage = 'Oyun başlatma hatası: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGame() async {
    if (_currentGameId == null) return;

    try {
      await _service.leaveGame(_currentGameId!);
      _resetGame();
    } catch (e) {
      _errorMessage = 'Oyundan çıkma hatası: $e';
      notifyListeners();
    }
  }

  void _resetGame() {
    _currentGame = null;
    _currentGameId = null;
    _playerRole = null;
    _clearMessages();
    notifyListeners();
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
} 