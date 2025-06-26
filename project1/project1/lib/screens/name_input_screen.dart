import 'package:flutter/material.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
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
                
                const Spacer(),
                
                // Başlık
                const Text(
                  'İsminizi Girin',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Ubuntu',
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // İsim giriş formu
                Form(
                  key: _formKey,
                  child: Container(
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
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Oyuncu Adı',
                            hintText: 'Adınızı yazın...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lütfen bir isim girin';
                            }
                            if (value.trim().length < 2) {
                              return 'İsim en az 2 karakter olmalı';
                            }
                            if (value.trim().length > 20) {
                              return 'İsim en fazla 20 karakter olabilir';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                          maxLength: 20,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Devam Et',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Ubuntu',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  void _submitName() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      Navigator.pop(context, name);
    }
  }
} 