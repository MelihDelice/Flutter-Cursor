import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/question.dart';

class GameProvider extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _highScore = 0;
  bool _isGameActive = false;
  bool _isAnswering = false;
  int? _selectedAnswer;
  int? _correctAnswer;
  bool _shouldAnimateNextQuestion = false;
  String _selectedCategory = 'Tümü';
  
  // Zaman sınırlı mod için
  int _timeLeft = 60; // 60 saniye
  Timer? _timer;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  
  // Ses efektleri
  AudioPlayer? _audioPlayer;
  AudioPlayer? _backgroundMusicPlayer;
  AudioPlayer? _countdownPlayer;
  bool _soundEnabled = true;
  bool _isTensionMusicPlaying = false;

  List<Question> get questions => _questions;
  List<Question> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get highScore => _highScore;
  bool get isGameActive => _isGameActive;
  bool get isAnswering => _isAnswering;
  int? get selectedAnswer => _selectedAnswer;
  int? get correctAnswer => _correctAnswer;
  bool get shouldAnimateNextQuestion => _shouldAnimateNextQuestion;
  int get timeLeft => _timeLeft;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  bool get soundEnabled => _soundEnabled;
  String get selectedCategory => _selectedCategory;
  
  List<String> get categories {
    if (_questions.isEmpty) return ['Tümü'];
    final Set<String> categorySet = _questions.map((q) => q.category).toSet();
    final List<String> categories = ['Tümü'] + categorySet.toList();
    categories.sort();
    return categories;
  }
  
  double get successRate {
    if (_correctAnswers + _wrongAnswers == 0) return 0.0;
    return (_correctAnswers / (_correctAnswers + _wrongAnswers)) * 100;
  }

  Question? get currentQuestion => _currentQuestions.isNotEmpty && _currentQuestionIndex < _currentQuestions.length 
      ? _currentQuestions[_currentQuestionIndex] 
      : null;

  GameProvider() {
    _loadHighScore();
    _loadSoundSettings();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    _backgroundMusicPlayer = AudioPlayer();
    _countdownPlayer = AudioPlayer();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }

  Future<void> _loadSoundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    notifyListeners();
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', _highScore);
  }

  Future<void> _saveSoundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
  }

  Future<void> loadQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      _questions = data.map((json) => Question.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Sorular yüklenirken hata oluştu: $e');
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void startNewGame({String? category}) {
    if (category != null) {
      _selectedCategory = category;
    }
    
    // Kategori seçimine göre soruları filtrele
    if (_selectedCategory == 'Tümü') {
      _currentQuestions = List.from(_questions);
    } else {
      _currentQuestions = _questions.where((q) => q.category == _selectedCategory).toList();
    }
    
    _currentQuestions.shuffle(Random());
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _timeLeft = 60;
    _isGameActive = true;
    _isAnswering = false;
    _selectedAnswer = null;
    _correctAnswer = null;
    _shouldAnimateNextQuestion = false;
    
    // Timer'ı başlat
    _startTimer();
    
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        
        // Son 10 saniyede gerilim müziği çal
        if (_timeLeft <= 10 && !_isTensionMusicPlaying && _soundEnabled) {
          _playTensionMusic();
        }
        
        // Son 5 saniyede beep sesi çal
        if (_timeLeft <= 5 && _soundEnabled) {
          _playCountdownBeep();
        }
        
        notifyListeners();
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _stopTensionMusic();
    _isGameActive = false;
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
    }
    notifyListeners();
  }

  void answerQuestion(int selectedAnswer) async {
    if (!_isGameActive || currentQuestion == null || _isAnswering) return;

    _isAnswering = true;
    _selectedAnswer = selectedAnswer;
    _correctAnswer = currentQuestion!.correctAnswer;
    
    // Ses efekti çal
    if (_soundEnabled) {
      if (selectedAnswer == currentQuestion!.correctAnswer) {
        await _playCorrectSound();
      } else {
        await _playWrongSound();
      }
    }
    
    notifyListeners();

    // 1.5 saniye bekle ve sonraki soruya geç
    await Future.delayed(const Duration(milliseconds: 1500));

    if (selectedAnswer == currentQuestion!.correctAnswer) {
      _score++;
      _correctAnswers++;
    } else {
      _wrongAnswers++;
    }

    _currentQuestionIndex++;
    _isAnswering = false;
    _selectedAnswer = null;
    _correctAnswer = null;
    _shouldAnimateNextQuestion = true;
    
    // Yeni soru yoksa oyunu bitir
    if (_currentQuestionIndex >= _currentQuestions.length) {
      _endGame();
    }
    
    notifyListeners();
    
    // Animasyon tetikleyicisini sıfırla
    Future.delayed(const Duration(milliseconds: 100), () {
      _shouldAnimateNextQuestion = false;
      notifyListeners();
    });
  }

  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer?.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Doğru ses efekti çalınamadı: $e');
    }
  }

  Future<void> _playWrongSound() async {
    try {
      await _audioPlayer?.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Yanlış ses efekti çalınamadı: $e');
    }
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveSoundSettings();
    notifyListeners();
  }

  void resetGame() {
    _timer?.cancel();
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _timeLeft = 60;
    _isGameActive = false;
    _isAnswering = false;
    _selectedAnswer = null;
    _correctAnswer = null;
    _shouldAnimateNextQuestion = false;
    notifyListeners();
  }

  Future<void> resetHighScore() async {
    _highScore = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('highScore');
    notifyListeners();
  }

  Future<void> _playTensionMusic() async {
    if (_isTensionMusicPlaying) return;
    
    try {
      _isTensionMusicPlaying = true;
      await _backgroundMusicPlayer?.play(AssetSource('sounds/tension.mp3'));
      await _backgroundMusicPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Gerilim müziği çalınamadı: $e');
      _isTensionMusicPlaying = false;
    }
  }

  void _stopTensionMusic() {
    _backgroundMusicPlayer?.stop();
    _isTensionMusicPlaying = false;
  }

  Future<void> _playCountdownBeep() async {
    try {
      await _countdownPlayer?.play(AssetSource('sounds/countdown_beep.mp3'));
    } catch (e) {
      print('Geri sayım beep sesi çalınamadı: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer?.dispose();
    _backgroundMusicPlayer?.dispose();
    _countdownPlayer?.dispose();
    super.dispose();
  }
} 