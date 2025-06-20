import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import 'multiplayer_game_screen.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

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
                  'Oyuna Bağlan',
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
            Icons.join_full,
            color: Color(0xFF6C63FF),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Arkadaşının Oyununa Katıl',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Referans kodunu girerek oyuna katıl',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Referans kodu girişi
          TextField(
            controller: _gameIdController,
            onChanged: (value) {
              print('TextField onChanged: $value');
              setState(() {
                _isGameIdEntered = value.trim().isNotEmpty;
              });
            },
            decoration: InputDecoration(
              labelText: 'Referans Kodu',
              hintText: 'Örn: 1234567890',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: const Icon(
                Icons.code,
                color: Color(0xFF6C63FF),
              ),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          
          // Debug bilgisi (geliştirme sırasında)
          if (true) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Debug: isEntered=$_isGameIdEntered, isLoading=${multiplayerProvider.isLoading}, text="${_gameIdController.text.trim()}"',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Hata mesajları
          if (multiplayerProvider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Hata:',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    multiplayerProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          if (multiplayerProvider.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                multiplayerProvider.successMessage!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Oyuna katıl butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: multiplayerProvider.isLoading || !_isGameIdEntered
                  ? null
                  : () => _joinGame(multiplayerProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGameIdEntered && !multiplayerProvider.isLoading 
                    ? const Color(0xFF6C63FF) 
                    : Colors.grey,
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
                  : Text(
                      _isGameIdEntered ? 'Oyuna Katıl' : 'Referans Kodu Girin',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // QR kod ile bağlan butonu (gelecekte eklenebilir)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // QR kod tarama özelliği gelecekte eklenebilir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR kod özelliği yakında eklenecek!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR Kod ile Bağlan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
                side: const BorderSide(color: Color(0xFF6C63FF)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinGame(MultiplayerProvider multiplayerProvider) async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) return;
    
    print('JoinGameScreen: Oyuna katılmaya çalışılıyor - $gameId');
    
    await multiplayerProvider.joinGame(gameId);
    
    // Başarılı bağlantı durumunda oyun ekranına geç
    if (multiplayerProvider.successMessage != null && 
        multiplayerProvider.currentGameId != null) {
      print('JoinGameScreen: Başarılı, oyun ekranına geçiliyor');
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
    } else {
      print('JoinGameScreen: Başarısız - ${multiplayerProvider.errorMessage}');
    }
  }
} 