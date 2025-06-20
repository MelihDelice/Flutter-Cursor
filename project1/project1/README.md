# Quiz Oyunu

Modern ve eğlenceli bir quiz oyunu uygulaması. Hem tek oyunculu hem de çok oyunculu (multiplayer) modları destekler.

## Özellikler

### 🎮 Tek Oyunculu Mod
- **Animasyonlu Oyun Deneyimi**: Soru geçişlerinde yumuşak animasyonlar
- **Ses Efektleri**: Doğru/yanlış cevap sesleri, geri sayım sesi, gerilim müziği
- **Zaman Sınırlı Mod**: 30 saniye süre sınırı ile heyecan dolu oyun
- **Kalıcı Skor Sistemi**: En yüksek skor ve başarım yüzdesi kaydedilir
- **Cartoon Temalı Tasarım**: Renkli ve eğlenceli arayüz

### 🌐 Çok Oyunculu (Multiplayer) Mod
- **Gerçek Zamanlı Oyun**: WebSocket teknolojisi ile anlık iletişim
- **Oyun Oluşturma**: Referans kodu ile oyun oluştur ve paylaş
- **Oyuna Katılma**: Referans kodu ile arkadaşının oyununa katıl
- **Yarışma Modu**: Aynı anda aynı soruları cevaplayarak yarış
- **Skor Takibi**: Gerçek zamanlı skor güncellemeleri
- **Paylaşım Özelliği**: WhatsApp ve diğer uygulamalarda paylaş

### 🎨 Kullanıcı Arayüzü
- **Modern Tasarım**: Material Design 3 prensipleri
- **Responsive Layout**: Farklı ekran boyutlarına uyum
- **Animasyonlar**: Yumuşak geçişler ve etkileşimler
- **Tema Renkleri**: Cartoon temalı renk paleti

### ⚙️ Ayarlar
- **Ses Kontrolü**: Ses efektlerini açma/kapama
- **Müzik Kontrolü**: Arka plan müziğini kontrol etme
- **Zaman Modu**: Zaman sınırlı modu açma/kapama

## Kurulum

### Gereksinimler
- Flutter SDK (3.0 veya üzeri)
- Dart SDK
- Android Studio / VS Code

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone <repository-url>
cd project1
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **WebSocket sunucusunu başlatın** (Multiplayer mod için)
```bash
cd server
dart websocket_server.dart
```

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## Kullanım

### Tek Oyunculu Mod
1. Ana menüden "OYUNA BAŞLA" butonuna tıklayın
2. Soruları cevaplayın ve skorunuzu görün
3. Ayarlardan ses ve müzik ayarlarını yapın

### Multiplayer Mod
1. Ana menüden "ARKADAŞLARINLA OYNA" butonuna tıklayın
2. **Oyun Oluştur** seçeneği ile:
   - Yeni oyun oluşturun
   - Referans kodunu kopyalayın
   - Arkadaşlarınızla paylaşın
   - Oyuncu katıldığında oyunu başlatın

3. **Oyuna Bağlan** seçeneği ile:
   - Referans kodunu girin
   - Oyuna katılın
   - Oyun sahibinin başlatmasını bekleyin

## Teknik Detaylar

### Mimari
- **Provider Pattern**: Durum yönetimi için
- **WebSocket**: Gerçek zamanlı iletişim
- **SharedPreferences**: Yerel veri saklama
- **AudioPlayers**: Ses efektleri

### Dosya Yapısı
```
lib/
├── main.dart
├── models/
│   ├── question.dart
│   └── multiplayer_game.dart
├── providers/
│   ├── game_provider.dart
│   └── multiplayer_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── main_menu_screen.dart
│   ├── game_screen.dart
│   ├── settings_screen.dart
│   ├── multiplayer_menu_screen.dart
│   ├── create_game_screen.dart
│   ├── join_game_screen.dart
│   └── multiplayer_game_screen.dart
└── services/
    └── multiplayer_service.dart

server/
└── websocket_server.dart

assets/
├── images/
├── sounds/
└── questions.json
```

### Kullanılan Paketler
- `provider`: Durum yönetimi
- `shared_preferences`: Yerel veri saklama
- `audioplayers`: Ses efektleri
- `web_socket_channel`: WebSocket iletişimi
- `share_plus`: Paylaşım özelliği
- `uuid`: Benzersiz ID oluşturma

## Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## İletişim

Sorularınız için issue açabilir veya pull request gönderebilirsiniz.
