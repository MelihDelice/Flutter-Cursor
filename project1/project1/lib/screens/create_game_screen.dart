import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/game_provider.dart';
import '../models/multiplayer_game.dart';
import 'multiplayer_game_screen.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

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
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Geri butonu
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF6C63FF),
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black54,
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
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: Color(0xFF6C63FF),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Yeni Oyun Oluştur',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Arkadaşlarınla birlikte oynayabileceğin bir oyun oluştur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Firebase bağlantı durumu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                multiplayerProvider.isConnected 
                    ? Icons.wifi 
                    : Icons.wifi_off,
                color: multiplayerProvider.isConnected 
                    ? Colors.green 
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                multiplayerProvider.isConnected ? 'Bağlı' : 'Bağlantı Yok',
                style: TextStyle(
                  color: multiplayerProvider.isConnected 
                      ? Colors.green 
                      : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Durum mesajı
          if (multiplayerProvider.errorMessage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    multiplayerProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          ElevatedButton(
            onPressed: multiplayerProvider.isLoading
                ? null
                : () => _createGame(multiplayerProvider, gameProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: multiplayerProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Oyun Oluştur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCreatedSection(MultiplayerProvider multiplayerProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Oyun Oluşturuldu!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Referans kodunu arkadaşlarınla paylaş',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Referans kodu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Referans Kodu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _gameId ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_gameId != null && _gameId!.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: _gameId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Referans kodu kopyalandı!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.copy,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Paylaş butonu
          ElevatedButton.icon(
            onPressed: () => _shareGameCode(),
            icon: const Icon(Icons.share),
            label: const Text('Paylaş'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Oyuna başla butonu
          ElevatedButton.icon(
            onPressed: () => _startGame(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oyuna Başla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGame(MultiplayerProvider multiplayerProvider, GameProvider gameProvider) async {
    // Rastgele sorular seç
    final questions = gameProvider.questions.take(10).toList();
    questions.shuffle();
    
    // Multiplayer oyun için soruları dönüştür
    final multiplayerQuestions = questions.map((q) => Question(
      id: q.id,
      question: q.question,
      options: q.options,
      correctAnswer: q.correctAnswer,
    )).toList();
    
    await multiplayerProvider.createGame(multiplayerQuestions);
    
    if (multiplayerProvider.successMessage != null) {
      setState(() {
        _gameId = multiplayerProvider.currentGameId;
        _isGameCreated = true;
      });
    }
  }

  void _shareGameCode() {
    final message = 'Quiz oyununa katılmak için bu referans kodunu kullan: $_gameId';
    Share.share(message, subject: 'Quiz Oyunu Daveti');
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