import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/game_provider.dart';
import '../models/multiplayer_game.dart' as mg;
import '../models/question.dart' as q;
import 'multiplayer_game_screen.dart';

class CreateGameScreen extends StatefulWidget {
  final String playerName;
  
  const CreateGameScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _gameId;
  bool _isGameCreated = false;
  String _selectedCategory = 'Tümü';
  mg.GameMode _selectedGameMode = mg.GameMode.normal;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/mainbackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Geri butonu
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF4ECDC4),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Başlık
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Oyun Oluştur',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontFamily: 'Ubuntu',
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // İçerik
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Consumer2<MultiplayerProvider, GameProvider>(
                    builder: (context, multiplayerProvider, gameProvider, child) {
                      if (!_isGameCreated) {
                        return _buildCreateGameSection(multiplayerProvider, gameProvider);
                      } else {
                        return _buildGameCreatedSection(multiplayerProvider);
                      }
                    },
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGameSection(MultiplayerProvider multiplayerProvider, GameProvider gameProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Yeni Oyun',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),
          
          // Oyun modu seçimi
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'Normal',
                  subtitle: '8s',
                  icon: Icons.timer,
                  color: const Color(0xFF4ECDC4),
                  isSelected: _selectedGameMode == mg.GameMode.normal,
                  onTap: () => setState(() => _selectedGameMode = mg.GameMode.normal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  title: 'Hızlı',
                  subtitle: '80s',
                  icon: Icons.flash_on,
                  color: const Color(0xFFFF6B6B),
                  isSelected: _selectedGameMode == mg.GameMode.speed,
                  onTap: () => setState(() => _selectedGameMode = mg.GameMode.speed),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Kategori seçimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4ECDC4)),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w500,
                ),
                items: gameProvider.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Oyun oluştur butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: multiplayerProvider.isLoading
                  ? null
                  : () => _createGame(multiplayerProvider, gameProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD93D),
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFFFFD93D).withOpacity(0.3),
              ),
              child: multiplayerProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Oyun Oluştur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontFamily: 'Ubuntu',
                            shadows: [
                              const Shadow(
                                color: Colors.white24,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE9ECEF),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : const Color(0xFFBDC3C7),
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : const Color(0xFF2C3E50),
                fontFamily: 'Ubuntu',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color.withOpacity(0.7) : const Color(0xFF7F8C8D),
                fontFamily: 'Ubuntu',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCreatedSection(MultiplayerProvider multiplayerProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oyun Oluşturuldu!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Oyun odası hazırlandı. Şimdi oyuna geçebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
              height: 1.4,
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 32),
          
          // Referans kodu
          if (_gameId != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Referans Kodu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _gameId!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 2,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _gameId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Referans kodu kopyalandı!'),
                              backgroundColor: Color(0xFF4ECDC4),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Oyuna geç butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _startGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Oyun Odasına Geç',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      shadows: [
                        const Shadow(
                          color: Colors.white24,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGame(MultiplayerProvider multiplayerProvider, GameProvider gameProvider) async {
    // Kategori seçimine göre soruları filtrele
    List<q.Question> filteredQuestions;
    if (_selectedCategory == 'Tümü') {
      filteredQuestions = List.from(gameProvider.questions);
    } else {
      filteredQuestions = gameProvider.questions.where((question) => question.category == _selectedCategory).toList();
    }
    
    // Rastgele sorular seç
    filteredQuestions.shuffle();
    final questions = filteredQuestions.take(10).toList();
    
    // Multiplayer oyun için soruları dönüştür
    final multiplayerQuestions = questions.map((question) => 
      // multiplayer_game.dart'taki Question sınıfını kullan
      mg.Question(
        id: question.id,
        question: question.question,
        options: question.options,
        correctAnswer: question.correctAnswer,
        category: question.category,
      )).toList();
    
    await multiplayerProvider.createGame(multiplayerQuestions, _selectedCategory, widget.playerName, _selectedGameMode);
    
    if (multiplayerProvider.successMessage != null) {
      setState(() {
        _gameId = multiplayerProvider.currentGame?.gameId ?? multiplayerProvider.currentGameId;
        _isGameCreated = true;
      });
    }
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

  void _startGame() {
    if (_gameId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerGameScreen(gameId: _gameId!),
        ),
      );
    }
  }
} 