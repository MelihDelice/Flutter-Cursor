import 'dart:convert';
import 'dart:math';

enum GameStatus {
  waiting,
  playing,
  showingResults,
  finished,
}

enum PlayerRole {
  host,
  guest,
}

class MultiplayerGame {
  final String gameId;
  final String hostId;
  final String? guestId;
  final GameStatus status;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, int> playerScores;
  final Map<String, int> playerAnswers;
  final DateTime createdAt;

  MultiplayerGame({
    required this.gameId,
    required this.hostId,
    this.guestId,
    required this.status,
    required this.questions,
    required this.currentQuestionIndex,
    required this.playerScores,
    required this.playerAnswers,
    required this.createdAt,
  });

  factory MultiplayerGame.create({
    required String hostId,
    required List<Question> questions,
  }) {
    return MultiplayerGame(
      gameId: generateGameId(),
      hostId: hostId,
      status: GameStatus.waiting,
      questions: questions,
      currentQuestionIndex: 0,
      playerScores: {hostId: 0},
      playerAnswers: {},
      createdAt: DateTime.now(),
    );
  }

  static String generateGameId() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String result = '';
    
    // 6 haneli alpha-numeric kod oluştur
    for (int i = 0; i < 6; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    
    return result;
  }

  MultiplayerGame copyWith({
    String? gameId,
    String? hostId,
    String? guestId,
    GameStatus? status,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, int>? playerScores,
    Map<String, int>? playerAnswers,
    DateTime? createdAt,
  }) {
    return MultiplayerGame(
      gameId: gameId ?? this.gameId,
      hostId: hostId ?? this.hostId,
      guestId: guestId ?? this.guestId,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      playerScores: playerScores ?? this.playerScores,
      playerAnswers: playerAnswers ?? this.playerAnswers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'hostId': hostId,
      'guestId': guestId,
      'status': status.toString(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'playerScores': playerScores,
      'playerAnswers': playerAnswers,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MultiplayerGame.fromJson(Map<String, dynamic> json) {
    try {
      return MultiplayerGame(
        gameId: json['gameId']?.toString() ?? '',
        hostId: json['hostId']?.toString() ?? '',
        guestId: json['guestId']?.toString(),
        status: GameStatus.values.firstWhere(
          (e) => e.toString() == json['status']?.toString(),
          orElse: () => GameStatus.waiting,
        ),
        questions: (json['questions'] as List?)
            ?.map((q) => Question.fromJson(Map<String, dynamic>.from(q)))
            .toList() ?? [],
        currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
        playerScores: (json['playerScores'] as Map?)
            ?.map((key, value) => MapEntry(key.toString(), value as int? ?? 0)) ?? {},
        playerAnswers: (json['playerAnswers'] as Map?)
            ?.map((key, value) => MapEntry(key.toString(), value as int? ?? 0)) ?? {},
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('MultiplayerGame.fromJson Error: $e');
      print('JSON Data: $json');
      rethrow;
    }
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      return Question(
        id: json['id'] as int? ?? 0,
        question: json['question']?.toString() ?? '',
        options: (json['options'] as List?)
            ?.map((option) => option.toString())
            .toList() ?? [],
        correctAnswer: json['correctAnswer'] as int? ?? 0,
      );
    } catch (e) {
      print('Question.fromJson Error: $e');
      print('JSON Data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
} 