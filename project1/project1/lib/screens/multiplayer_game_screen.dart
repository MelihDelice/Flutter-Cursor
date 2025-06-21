import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../models/multiplayer_game.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String gameId;
  
  const MultiplayerGameScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  int _lastQuestionIndex = -1;

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
    return WillPopScope(
      onWillPop: () => _showExitConfirmation(context),
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<MultiplayerProvider>(
            builder: (context, multiplayerProvider, child) {
              final game = multiplayerProvider.currentGame;
              
              if (game == null) {
                return _buildLoadingScreen();
              }
              
              if (game.status == GameStatus.waiting) {
                return _buildWaitingScreen(multiplayerProvider, game);
              }
              
              if (game.status == GameStatus.playing) {
                return _buildGameScreen(multiplayerProvider, game);
              }
              
              if (game.status == GameStatus.finished) {
                return _buildGameOverScreen(multiplayerProvider, game);
              }
              
              return _buildLoadingScreen();
            },
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Oyun yükleniyor...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen(MultiplayerProvider multiplayerProvider, MultiplayerGame game) {
    final isHost = multiplayerProvider.playerRole == PlayerRole.host;
    final hasGuest = game.guestId != null;
    
    return Column(
      children: [
        // Üst bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showExitConfirmation(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Oyun: ${game.gameId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'Bekleniyor',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Ana içerik
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
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
                  Icons.people,
                  color: Color(0xFF6C63FF),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isHost ? 'Oyuncu Bekleniyor' : 'Oyun Başlatılmayı Bekliyor',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isHost 
                      ? 'Arkadaşın oyuna katıldığında oyunu başlatabilirsin'
                      : 'Oyun sahibi oyunu başlattığında oyun başlayacak',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Oyuncu durumu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlayerStatus('Sen', true, isHost ? 'Host' : 'Misafir'),
                    _buildPlayerStatus('Rakip', hasGuest, hasGuest ? 'Bağlandı' : 'Bekleniyor'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                if (isHost) ...[
                  ElevatedButton(
                    onPressed: hasGuest ? () => multiplayerProvider.startGame() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasGuest ? const Color(0xFF6C63FF) : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      hasGuest ? 'Oyunu Başlat' : 'Oyuncu Bekleniyor...',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Oyun sahibi oyunu başlatmayı bekliyor...',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildGameScreen(MultiplayerProvider multiplayerProvider, MultiplayerGame game) {
    if (game.questions.isEmpty || game.currentQuestionIndex >= game.questions.length) {
      return _buildGameOverScreen(multiplayerProvider, game);
    }
    
    // Soru değiştiğinde state'i sıfırla
    if (_lastQuestionIndex != game.currentQuestionIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedAnswer = null;
            _isAnswerSubmitted = false;
            _lastQuestionIndex = game.currentQuestionIndex;
          });
        }
      });
    }
    
    final currentQuestion = game.questions[game.currentQuestionIndex];
    final playerScore = game.playerScores[multiplayerProvider.playerId] ?? 0;
    final opponentScore = game.playerScores.entries
        .where((entry) => entry.key != multiplayerProvider.playerId)
        .firstOrNull?.value ?? 0;
    
    return Column(
      children: [
        // Üst bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showExitConfirmation(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreDisplay('Sen', playerScore),
                    _buildScoreDisplay('Rakip', opponentScore),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${game.currentQuestionIndex + 1}/${game.questions.length}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
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
                    // Soru
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Şıklar
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final option = currentQuestion.options[index];
                          final isSelected = _selectedAnswer == index;
                          final isCorrect = index == currentQuestion.correctAnswer;
                          final isWrong = _isAnswerSubmitted && isSelected && !isCorrect;
                          
                          Color backgroundColor = Colors.grey[100]!;
                          Color borderColor = Colors.grey[300]!;
                          
                          if (_isAnswerSubmitted) {
                            if (isCorrect) {
                              backgroundColor = Colors.green.withOpacity(0.1);
                              borderColor = Colors.green;
                            } else if (isWrong) {
                              backgroundColor = Colors.red.withOpacity(0.1);
                              borderColor = Colors.red;
                            }
                          } else if (isSelected) {
                            backgroundColor = const Color(0xFF6C63FF).withOpacity(0.1);
                            borderColor = const Color(0xFF6C63FF);
                          }
                          
                          return GestureDetector(
                            onTap: _isAnswerSubmitted ? null : () {
                              setState(() {
                                _selectedAnswer = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: _isAnswerSubmitted && isCorrect 
                                            ? Colors.green 
                                            : _isAnswerSubmitted && isWrong 
                                                ? Colors.red 
                                                : const Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cevap gönder butonu
                    if (!_isAnswerSubmitted) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedAnswer == null ? null : () {
                            _submitAnswer(multiplayerProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cevabı Gönder',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Cevabın gönderildi, diğer oyuncu bekleniyor...',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen(MultiplayerProvider multiplayerProvider, MultiplayerGame game) {
    final playerScore = game.playerScores[multiplayerProvider.playerId] ?? 0;
    final opponentScore = game.playerScores.entries
        .where((entry) => entry.key != multiplayerProvider.playerId)
        .firstOrNull?.value ?? 0;
    
    // Oyuncu ayrılma durumunu kontrol et
    final isPlayerLeft = game.guestId == null && game.currentQuestionIndex < game.questions.length;
    
    final isWinner = playerScore > opponentScore;
    final isDraw = playerScore == opponentScore;
    
    return Column(
      children: [
        // Üst bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _leaveGame(multiplayerProvider),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Oyun Bitti',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  'Bitti',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Sonuç
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
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
                Icon(
                  isWinner ? Icons.emoji_events : isDraw ? Icons.handshake : Icons.sentiment_dissatisfied,
                  color: isWinner ? Colors.amber : isDraw ? Colors.blue : Colors.grey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isPlayerLeft 
                      ? 'Rakip Oyundan Ayrıldı' 
                      : isWinner 
                          ? 'Tebrikler! Kazandın!' 
                          : isDraw 
                              ? 'Berabere!' 
                              : 'Kaybettin!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPlayerLeft 
                        ? Colors.orange 
                        : isWinner 
                            ? Colors.amber 
                            : isDraw 
                                ? Colors.blue 
                                : Colors.grey,
                  ),
                ),
                if (isPlayerLeft) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Oyun sonlandırıldı',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                // Skorlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFinalScoreDisplay('Sen', playerScore, isWinner),
                    _buildFinalScoreDisplay('Rakip', opponentScore, !isWinner && !isDraw),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ana menüye dön butonu
                ElevatedButton(
                  onPressed: () => _leaveGame(multiplayerProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ana Menüye Dön',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildPlayerStatus(String name, bool isConnected, String status) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.grey[300],
          ),
          child: Icon(
            isConnected ? Icons.person : Icons.person_off,
            color: isConnected ? Colors.white : Colors.grey[600],
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: isConnected ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(String name, int score) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalScoreDisplay(String name, int score, bool isWinner) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.amber : const Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }

  void _submitAnswer(MultiplayerProvider multiplayerProvider) {
    if (_selectedAnswer == null) return;
    
    setState(() {
      _isAnswerSubmitted = true;
    });
    
    multiplayerProvider.submitAnswer(_selectedAnswer!);
  }

  void _leaveGame(MultiplayerProvider multiplayerProvider) {
    multiplayerProvider.leaveGame();
    Navigator.pop(context);
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyundan Çık'),
          content: const Text('Oyundan çıkmak istediğinizden emin misiniz? Oyun sonlandırılacak.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Multiplayer oyundan çık
                final multiplayerProvider = Provider.of<MultiplayerProvider>(context, listen: false);
                multiplayerProvider.leaveGame();
              },
              child: const Text('Çık'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
} 