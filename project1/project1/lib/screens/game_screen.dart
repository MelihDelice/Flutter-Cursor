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
  late AnimationController _clockShakeController;
  late Animation<double> _questionAnimation;
  late Animation<double> _optionAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _correctAnimation;
  late Animation<double> _wrongAnimation;
  late Animation<double> _clockShakeAnimation;

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
    _clockShakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    _clockShakeAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _clockShakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionController.dispose();
    _imageController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _clockShakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitConfirmation(context),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mainbackground.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Geri butonu
                    GestureDetector(
                      onTap: () => _showExitConfirmation(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎮 VersusMind 🎮',
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Consumer<GameProvider>(
                            builder: (context, gameProvider, child) {
                              return Text(
                                gameProvider.selectedCategory,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        return Container(
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
                              const Icon(Icons.check_circle, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${gameProvider.correctAnswers}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Ana içerik
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (!gameProvider.isGameActive) {
                      return _buildGameOverScreen(gameProvider);
                    } else {
                      return _buildGameContent(gameProvider);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTimeColor(int timeLeft) {
    if (timeLeft > 45) return const Color(0xFF4ECDC4); // Yeşil - çok zaman var
    if (timeLeft > 30) return const Color(0xFF45B7D1); // Mavi - yeterli zaman
    if (timeLeft > 15) return const Color(0xFFFFD93D); // Sarı - dikkat
    if (timeLeft > 5) return const Color(0xFFFF8C42);  // Turuncu - az zaman
    return const Color(0xFFFF6B6B); // Kırmızı - çok az zaman
  }

  Widget _buildGameContent(GameProvider gameProvider) {
    final currentQuestion = gameProvider.currentQuestion;
    if (currentQuestion == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Süre çemberi - ortada
          Center(
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                // Son 10 saniye kala çalar saat animasyonu başlat
                if (gameProvider.timeLeft <= 10 && gameProvider.timeLeft > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_clockShakeController.isAnimating) {
                      _clockShakeController.repeat(reverse: true);
                    }
                  });
                } else {
                  _clockShakeController.stop();
                }

                return Container(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dış çember - süre göstergesi
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: gameProvider.timeLeft / 60.0, // 60 saniye toplam süre
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTimeColor(gameProvider.timeLeft),
                          ),
                        ),
                      ),
                      // İç kısım - saat resmi (arka plan olmadan)
                      AnimatedBuilder(
                        animation: _clockShakeAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _clockShakeAnimation.value,
                            child: Container(
                              width: 60,
                              height: 60,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/clock_time.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        size: 30,
                                        color: Color(0xFF4ECDC4),
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
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Kompakt soru kartı
          Expanded(
            child: _buildQuestionScreen(context, gameProvider, currentQuestion),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(BuildContext context, GameProvider gameProvider, currentQuestion) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Sabit boyutlu soru kartı
          Container(
            width: double.infinity,
            height: 120, // Sabit yükseklik
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                currentQuestion.question,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Ubuntu',
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4, // Maksimum 4 satır
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Sabit boyutlu şıklar
          Expanded(
            child: ListView.separated(
              itemCount: currentQuestion.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _FixedSizeOptionButton(
                  text: currentQuestion.options[index],
                  isSelected: gameProvider.selectedAnswer == index,
                  isCorrect: gameProvider.isAnswering && gameProvider.correctAnswer == index,
                  isWrong: gameProvider.isAnswering && gameProvider.selectedAnswer == index && gameProvider.correctAnswer != index,
                  onTap: () {
                    if (!gameProvider.isAnswering) {
                      gameProvider.answerQuestion(index);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(GameProvider gameProvider) {
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

class _FixedSizeOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _FixedSizeOptionButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE9ECEF);
    Color textColor = const Color(0xFF2D3748);
    FontWeight fontWeight = FontWeight.w500;
    if (isCorrect) {
      backgroundColor = const Color(0xFF4ECDC4);
      borderColor = const Color(0xFF4ECDC4);
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isWrong) {
      backgroundColor = const Color(0xFFFF6B6B);
      borderColor = const Color(0xFFFF6B6B);
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isSelected) {
      backgroundColor = const Color(0xFFF6F6F6);
      borderColor = const Color(0xFF4ECDC4);
      textColor = const Color(0xFF2D3748);
      fontWeight = FontWeight.bold;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 70, // Sabit yükseklik
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: fontWeight,
                fontFamily: 'Ubuntu',
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Maksimum 2 satır
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
} 