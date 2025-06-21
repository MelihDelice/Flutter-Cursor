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
  final List<String> playerIds;
  final GameStatus status;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, int> playerScores;
  final Map<String, int> playerAnswers;
  final Map<String, String> playerNames;
  final DateTime createdAt;
  final String category;
  final DateTime? questionStartTime;
  final int questionTimeLimit;
  final int maxPlayers;

  MultiplayerGame({
    required this.gameId,
    required this.hostId,
    required this.playerIds,
    required this.status,
    required this.questions,
    required this.currentQuestionIndex,
    required this.playerScores,
    required this.playerAnswers,
    required this.playerNames,
    required this.createdAt,
    required this.category,
    this.questionStartTime,
    this.questionTimeLimit = 8,
    this.maxPlayers = 150,
  });

  factory MultiplayerGame.create({
    required String hostId,
    required String hostName,
    required List<Question> questions,
    required String category,
    int maxPlayers = 150,
  }) {
    return MultiplayerGame(
      gameId: generateGameId(),
      hostId: hostId,
      playerIds: [hostId],
      status: GameStatus.waiting,
      questions: questions,
      currentQuestionIndex: 0,
      playerScores: {hostId: 0},
      playerAnswers: {},
      playerNames: {hostId: hostName},
      createdAt: DateTime.now(),
      category: category,
      questionStartTime: null,
      questionTimeLimit: 8,
      maxPlayers: maxPlayers,
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
    List<String>? playerIds,
    GameStatus? status,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, int>? playerScores,
    Map<String, int>? playerAnswers,
    Map<String, String>? playerNames,
    DateTime? createdAt,
    String? category,
    DateTime? questionStartTime,
    int? questionTimeLimit,
    int? maxPlayers,
  }) {
    return MultiplayerGame(
      gameId: gameId ?? this.gameId,
      hostId: hostId ?? this.hostId,
      playerIds: playerIds ?? this.playerIds,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      playerScores: playerScores ?? this.playerScores,
      playerAnswers: playerAnswers ?? this.playerAnswers,
      playerNames: playerNames ?? this.playerNames,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      questionStartTime: questionStartTime ?? this.questionStartTime,
      questionTimeLimit: questionTimeLimit ?? this.questionTimeLimit,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'hostId': hostId,
      'playerIds': playerIds,
      'status': status.toString(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'playerScores': playerScores,
      'playerAnswers': playerAnswers,
      'playerNames': playerNames,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'questionStartTime': questionStartTime?.toIso8601String(),
      'questionTimeLimit': questionTimeLimit,
      'maxPlayers': maxPlayers,
    };
  }

  factory MultiplayerGame.fromJson(Map<String, dynamic> json) {
    try {
      return MultiplayerGame(
        gameId: json['gameId']?.toString() ?? '',
        hostId: json['hostId']?.toString() ?? '',
        playerIds: (json['playerIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
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
        playerNames: (json['playerNames'] as Map?)
            ?.map((key, value) => MapEntry(key.toString(), value.toString())) ?? {},
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        category: json['category']?.toString() ?? 'Tümü',
        questionStartTime: json['questionStartTime'] != null
            ? DateTime.tryParse(json['questionStartTime'].toString())
            : null,
        questionTimeLimit: json['questionTimeLimit'] as int? ?? 8,
        maxPlayers: json['maxPlayers'] as int? ?? 150,
      );
    } catch (e) {
      print('MultiplayerGame.fromJson Error: $e');
      print('JSON Data: $json');
      rethrow;
    }
  }

  // Oyuna katılma kontrolü
  bool canJoin() {
    return playerIds.length < maxPlayers && status == GameStatus.waiting;
  }

  // Oyuncuları listeleme
  int get playerCount => playerIds.length;

  // Oyuncunun host olup olmadığını kontrol etme
  bool isHost(String playerId) => hostId == playerId;

  // Oyuncunun oyunda olup olmadığını kontrol etme
  bool isPlayerInGame(String playerId) => playerIds.contains(playerId);

  // En yüksek puanlı oyuncuyu bul (kendisi hariç)
  MapEntry<String, int>? getTopOpponent(String currentPlayerId) {
    final opponents = playerScores.entries
        .where((entry) => entry.key != currentPlayerId)
        .toList();
    
    if (opponents.isEmpty) return null;
    
    opponents.sort((a, b) => b.value.compareTo(a.value));
    return opponents.first;
  }

  // Oyuncu ismini al
  String getPlayerName(String playerId) {
    return playerNames[playerId] ?? 'Bilinmeyen';
  }
}

class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.category = 'Genel',
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
        category: json['category']?.toString() ?? 'Genel',
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
      'category': category,
    };
  }
} 