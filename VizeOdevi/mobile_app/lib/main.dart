// ============================================================
// main.dart  –  Uygulamanın giriş noktası
// ============================================================

import 'package:flutter/material.dart';        // Flutter UI kütüphanesi
import 'screens/person_list_screen.dart';       // Ana liste ekranı

// ── main() fonksiyonu ───────────────────────────────────────
// Dart programları her zaman main() ile başlar.
// runApp() → verilen widget'ı ekranın tamamına yerleştirir.
void main() {
  runApp(const MyApp());
}

// ── MyApp Widget'ı ──────────────────────────────────────────
// Uygulamanın kök (root) widget'ı.
// StatelessWidget → durumu (state) değişmeyen widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişi Yönetim',                      // Uygulama başlığı
      debugShowCheckedModeBanner: false,            // Sağ üstteki DEBUG etiketini kaldır
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,             // Renk teması
        useMaterial3: true,                         // Material 3 tasarım sistemi
      ),
      home: const PersonListScreen(),              // İlk açılacak ekran
    );
  }
}
