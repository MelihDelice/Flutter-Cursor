import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import 'multiplayer_game_screen.dart';

class JoinGameScreen extends StatefulWidget {
  final String playerName;
  
  const JoinGameScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _gameIdController = TextEditingController();
  bool _isGameIdEntered = false;

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
    
    // TextField listener ekle
    _gameIdController.addListener(() {
      final isEntered = _gameIdController.text.trim().isNotEmpty;
      print('Game ID entered: ${_gameIdController.text.trim()}, isEntered: $isEntered');
      setState(() {
        _isGameIdEntered = isEntered;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gameIdController.dispose();
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
                  'Oyuna Bağlan',
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
                  child: Consumer<MultiplayerProvider>(
                    builder: (context, multiplayerProvider, child) {
                      return _buildJoinGameSection(multiplayerProvider);
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

  Widget _buildJoinGameSection(MultiplayerProvider multiplayerProvider) {
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
              Icons.join_full,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Arkadaşının Oyununa Katıl',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Referans kodunu girerek oyuna katıl',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
              height: 1.4,
              fontFamily: 'Ubuntu',
            ),
          ),
          const SizedBox(height: 32),
          
          // Referans kodu girişi
          TextField(
            controller: _gameIdController,
            decoration: InputDecoration(
              hintText: 'Referans kodu girin',
              hintStyle: const TextStyle(
                color: Color(0xFFBDC3C7),
                fontSize: 16,
                fontFamily: 'Ubuntu',
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4ECDC4),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.gamepad,
                color: Color(0xFF4ECDC4),
                size: 24,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu',
            ),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
          ),
          
          const SizedBox(height: 32),
          
          // Oyuna katıl butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGameIdEntered 
                    ? const Color(0xFF4ECDC4) 
                    : const Color(0xFFBDC3C7),
                foregroundColor: Colors.white,
                elevation: _isGameIdEntered ? 6 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: _isGameIdEntered 
                    ? const Color(0xFF4ECDC4).withOpacity(0.3) 
                    : Colors.transparent,
              ),
              onPressed: _isGameIdEntered
                  ? () => _joinGame(multiplayerProvider)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Oyuna Katıl',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontFamily: 'Ubuntu',
                      shadows: _isGameIdEntered ? [
                        const Shadow(
                          color: Colors.white24,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ] : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Yükleniyor göstergesi
          if (multiplayerProvider.isLoading)
            const Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Oyuna bağlanılıyor...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _joinGame(MultiplayerProvider multiplayerProvider) async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) return;
    
    await multiplayerProvider.joinGame(gameId, widget.playerName);
    
    // Başarılı bağlantı durumunda oyun ekranına geç
    if (multiplayerProvider.successMessage != null && 
        multiplayerProvider.currentGameId != null) {
      // Kısa bir gecikme ile oyun ekranına geç
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MultiplayerGameScreen(
                gameId: multiplayerProvider.currentGameId!,
              ),
            ),
          );
        }
      });
    }
  }
} 