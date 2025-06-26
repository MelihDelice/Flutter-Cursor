import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri butonu
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        color: Color(0xFF4ECDC4),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Başlık
                const Text(
                  'Ayarlar',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Ubuntu',
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Ses ayarı
                _SettingsCard(
                  icon: Icons.volume_up_rounded,
                  title: 'Ses Efektleri',
                  child: Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return Switch(
                        value: gameProvider.soundEnabled,
                        onChanged: (value) {
                          gameProvider.toggleSound();
                        },
                        activeColor: const Color(0xFF4ECDC4),
                        activeTrackColor: const Color(0xFF4ECDC4).withOpacity(0.3),
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[300],
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Titreşim ayarı
                _SettingsCard(
                  icon: Icons.vibration_rounded,
                  title: 'Titreşim',
                  child: Switch(
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                    activeColor: const Color(0xFF4ECDC4),
                    activeTrackColor: const Color(0xFF4ECDC4).withOpacity(0.3),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4ECDC4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
} 