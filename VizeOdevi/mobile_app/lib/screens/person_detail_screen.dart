// ============================================================
// person_detail_screen.dart  –  Kişi Detay Sayfası
// ============================================================
// Seçilen kişinin tüm bilgilerini gösterir.
// Alt kısımda Düzenle ve Sil butonları bulunur.
// E-posta ve telefon tıklanabilir (intent/url_launcher).
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // Telefon/e-posta açmak için
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_form_screen.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId; // Hangi kişinin detayı gösterilecek

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Future<Person> _futurePerson;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  void _loadPerson() {
    _futurePerson = ApiService.getPerson(widget.personId);
    // widget.personId → üst widget'tan gelen ID
  }

  // ── Kişiyi Sil ────────────────────────────────────────────
  Future<void> _deletePerson() async {
    // Onay diyaloğu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kişiyi Sil'),
        content: const Text('Bu kişiyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // İptal
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),  // Onayla
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    // Kullanıcı onayladıysa API'ye DELETE isteği gönder
    if (confirmed == true) {
      await ApiService.deletePerson(widget.personId);
      if (mounted) {
        // mounted → widget hâlâ ekranda mı kontrol eder
        Navigator.pop(context); // Listeye geri dön
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişi Detay Bilgileri'),
      ),
      body: FutureBuilder<Person>(
        future: _futurePerson,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final person = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Profil Fotoğrafı ──────────────────────
                CircleAvatar(
                  radius: 60,
                  backgroundImage: person.photoUrl.isNotEmpty
                      ? NetworkImage(person.photoUrl)
                      : null,
                  child: person.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Ad Soyad ──────────────────────────────
                Text(
                  person.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),

                // ── Departman ─────────────────────────────
                Text(
                  person.department,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // ── Bilgi Kartları ────────────────────────
                Card(
                  child: Column(
                    children: [
                      // Doğum Yeri
                      _InfoTile(
                        icon: Icons.location_on,
                        label: 'Doğum Yeri',
                        value: person.birthPlace,
                      ),
                      const Divider(height: 1),

                      // Doğum Tarihi
                      _InfoTile(
                        icon: Icons.cake,
                        label: 'Doğum Tarihi',
                        value: person.birthDate,
                      ),
                      const Divider(height: 1),

                      // E-posta (tıklanabilir)
                      _InfoTile(
                        icon: Icons.email,
                        label: 'E-posta',
                        value: person.email,
                        onTap: person.email.isNotEmpty
                            ? () => launchUrl(Uri.parse('mailto:${person.email}'))
                            : null,
                      ),
                      const Divider(height: 1),

                      // Telefon (tıklanabilir)
                      _InfoTile(
                        icon: Icons.phone,
                        label: 'Telefon',
                        value: person.phone,
                        onTap: person.phone.isNotEmpty
                            ? () => launchUrl(Uri.parse('tel:${person.phone}'))
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Aksiyon Butonları ─────────────────────
                Row(
                  children: [
                    // Düzenle Butonu
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PersonFormScreen(person: person),
                            ),
                          );
                          // Geri dönünce verileri yenile
                          setState(() => _loadPerson());
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('DÜZENLE'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sil Butonu
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _deletePerson,
                        icon: const Icon(Icons.delete),
                        label: const Text('KİŞİYİ SİL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _InfoTile  –  Bilgi satırı widget'ı (ikon + etiket + değer)
// ════════════════════════════════════════════════════════════

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap; // null ise tıklanamaz

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        value.isNotEmpty ? value : '-',
        style: TextStyle(
          fontSize: 16,
          color: onTap != null ? Colors.indigo : null, // Tıklanabilirse mavi
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
