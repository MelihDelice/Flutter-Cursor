import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _questionController;
  late AnimationController _optionController;
  late AnimationController _imageController;
  late AnimationController _correctController;
  late AnimationController _wrongController;
  late Animation<double> _questionAnimation;
  late Animation<double> _optionAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _correctAnimation;
  late Animation<double> _wrongAnimation;

  @override
  void initState() {
    super.initState();
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _correctController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _wrongController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeInOut),
    );
    _optionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _optionController, curve: Curves.easeInOut),
    );
    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.elasticOut),
    );
    _correctAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.bounceOut),
    );
    _wrongAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wrongController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionController.dispose();
    _imageController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitConfirmation(context),
      child: Scaffold(
        backgroundColor: const Color(0xFF87CEEB), // Açık mavi cartoon gökyüzü
        appBar: AppBar(
          title: const Text(
            '🎮 VersusMind 🎮',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Row(
                  children: [
                    // Zamanlayıcı
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTimeColor(gameProvider.timeLeft),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${gameProvider.timeLeft}s',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Skor
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${gameProvider.score}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Kategori
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(gameProvider.selectedCategory),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(gameProvider.selectedCategory),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gameProvider.selectedCategory,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            if (!gameProvider.isGameActive) {
              return _buildGameOverScreen(context, gameProvider);
            }

            final currentQuestion = gameProvider.currentQuestion;
            if (currentQuestion == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6B6B),
                ),
              );
            }

            // Animasyonları sadece yeni soru geldiğinde başlat
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (gameProvider.shouldAnimateNextQuestion) {
                _questionController.reset();
                _optionController.reset();
                _imageController.reset();
                Future.delayed(const Duration(milliseconds: 50), () {
                  _questionController.forward();
                  _optionController.forward();
                  _imageController.forward();
                });
              } else if (!_questionController.isAnimating && !_optionController.isAnimating) {
                _questionController.forward();
                _optionController.forward();
                _imageController.forward();
              }
            });

            return _buildQuestionScreen(context, gameProvider, currentQuestion);
          },
        ),
      ),
    );
  }

  Color _getTimeColor(int timeLeft) {
    if (timeLeft > 30) return const Color(0xFF4ECDC4);
    if (timeLeft > 15) return const Color(0xFFFFD93D);
    return const Color(0xFFFF6B6B);
  }

  Widget _buildQuestionScreen(BuildContext context, GameProvider gameProvider, currentQuestion) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (gameProvider.currentQuestionIndex + 1) / gameProvider.currentQuestions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Question number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${gameProvider.currentQuestionIndex + 1}/${gameProvider.currentQuestions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Question image (if exists)
              if (currentQuestion.imageUrl != null) ...[
                AnimatedBuilder(
                  animation: _imageAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _imageAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            currentQuestion.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF8F9FA),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Color(0xFFADB5BD),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Resim Yükleniyor...',
                                        style: TextStyle(
                                          color: Color(0xFFADB5BD),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              
              // Question text
              AnimatedBuilder(
                animation: _questionAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _questionAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: currentQuestion.imageUrl != null ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Options - Full screen height
              Expanded(
                child: AnimatedBuilder(
                  animation: _optionAnimation,
                  builder: (context, child) {
                    return ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final delay = index * 0.1;
                        
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _optionController,
                              curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: _buildOptionButton(
                              context,
                              gameProvider,
                              currentQuestion,
                              index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, GameProvider gameProvider, currentQuestion, int index) {
    final isSelected = gameProvider.selectedAnswer == index;
    final isCorrect = gameProvider.correctAnswer == index;
    final isWrong = isSelected && !isCorrect;
    
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE9ECEF);
    Color textColor = const Color(0xFF2C3E50);
    Color iconColor = const Color(0xFF6C757D);
    
    if (gameProvider.isAnswering) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF4ECDC4);
        borderColor = const Color(0xFF4ECDC4);
        textColor = Colors.white;
        iconColor = Colors.white;
      } else if (isWrong) {
        backgroundColor = const Color(0xFFFF6B6B);
        borderColor = const Color(0xFFFF6B6B);
        textColor = Colors.white;
        iconColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFFFFD93D);
      borderColor = const Color(0xFFFFD93D);
      textColor = const Color(0xFF2C3E50);
      iconColor = const Color(0xFF2C3E50);
    }
    
    return GestureDetector(
      onTap: gameProvider.isAnswering ? null : () {
        gameProvider.answerQuestion(index);
        // Animasyon başlat
        if (index == currentQuestion.correctAnswer) {
          _correctController.reset();
          _correctController.forward();
        } else {
          _wrongController.reset();
          _wrongController.forward();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            // Şık harfi
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: gameProvider.isAnswering && (isCorrect || isWrong) 
                        ? Colors.white 
                        : const Color(0xFF2C3E50),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Şık metni
            Expanded(
              child: Text(
                currentQuestion.options[index],
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Animasyonlu ikonlar
            if (gameProvider.isAnswering && isCorrect)
              AnimatedBuilder(
                animation: _correctController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _correctAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4ECDC4),
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            if (gameProvider.isAnswering && isWrong)
              AnimatedBuilder(
                animation: _wrongController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _wrongAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cancel,
                        color: Color(0xFFFF6B6B),
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameProvider gameProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 OYUN BİTTİ! 🎉',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD93D), size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Skorunuz: ${gameProvider.score}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFF6B6B), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'En Yüksek Skor: ${gameProvider.highScore}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('✅ Doğru', gameProvider.correctAnswers, const Color(0xFF4ECDC4)),
                        _buildStatCard('❌ Yanlış', gameProvider.wrongAnswers, const Color(0xFFFF6B6B)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Başarım: ${gameProvider.successRate.toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                        (route) => false,
                      );
                    },
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ANA MENÜYE DÖN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyundan Çık'),
          content: const Text('Oyundan çıkmak istediğinizden emin misiniz? İlerlemeniz kaybolacak.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Oyunu sonlandır
                final gameProvider = Provider.of<GameProvider>(context, listen: false);
                gameProvider.resetGame();
              },
              child: const Text('Çık'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tümü':
        return const Color(0xFF6C63FF);
      case 'Coğrafya':
        return const Color(0xFF4ECDC4);
      case 'Fen':
        return const Color(0xFF45B7D1);
      case 'Matematik':
        return const Color(0xFFFF6B6B);
      case 'Tarih':
        return const Color(0xFFFFD93D);
      case 'Spor':
        return const Color(0xFF96CEB4);
      case 'Genel':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tümü':
        return Icons.all_inclusive;
      case 'Coğrafya':
        return Icons.public;
      case 'Fen':
        return Icons.science;
      case 'Matematik':
        return Icons.calculate;
      case 'Tarih':
        return Icons.history_edu;
      case 'Spor':
        return Icons.sports_soccer;
      case 'Genel':
        return Icons.quiz;
      default:
        return Icons.category;
    }
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 