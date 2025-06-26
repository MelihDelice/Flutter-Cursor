import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'multiplayer_menu_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadQuestions();
    });
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve başlık
                  Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'VersusMind',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
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
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Minimal skor satırı
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return Text(
                        'En Yüksek: ${gameProvider.highScore}   Son Skor: ${gameProvider.score}   Başarım: %${gameProvider.successRate.toInt()}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Ubuntu',
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Modern menü butonları
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ModernMenuButton(
                            icon: Icons.play_arrow_rounded,
                            text: 'TEK OYUNCULU',
                            onPressed: () {
                              _showCategorySelectionDialog(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          _ModernMenuButton(
                            icon: Icons.people_rounded,
                            text: 'ÇOK OYUNCULU',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MultiplayerMenuScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _ModernMenuButton(
                            icon: Icons.settings_rounded,
                            text: 'AYARLAR',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Kategori Seç',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Kategori listesi
                Consumer<GameProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: provider.categories.map((category) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).pop();
                                provider.startNewGame(category: category);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const GameScreen()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getCategoryColor(category).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getCategoryColor(category).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(category),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: _getCategoryColor(category),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // İptal butonu
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'İptal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
}

// Modern menü buton widget'ı
typedef VoidCallback = void Function();

class _ModernMenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _ModernMenuButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.black87),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 