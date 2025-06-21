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
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      category: json['category'] ?? 'Genel',
    );
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