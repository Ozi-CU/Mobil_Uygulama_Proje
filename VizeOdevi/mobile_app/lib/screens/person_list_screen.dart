// ============================================================
// person_list_screen.dart  –  Kişi Listesi (Ana Sayfa)
// ============================================================
// API'den kişileri çeker ve ListView ile listeler.
// FAB butonu ile yeni kişi ekleme ekranına gider.
// Bir satıra tıklayınca detay sayfası açılır.
// ============================================================

import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

// StatefulWidget → içeriği değişebilen widget.
// _PersonListScreenState → widget'ın durumunu yönetir.
class _PersonListScreenState extends State<PersonListScreen> {
  // ── Durum Değişkenleri ──────────────────────────────────
  late Future<List<Person>> _futurePersons;
  // late  → değer daha sonra atanacak (initState'te)
  // Future → asenkron sonuç; veri henüz gelmemiş olabilir

  // ── initState ───────────────────────────────────────────
  // Widget ilk oluşturulduğunda bir kez çağrılır.
  @override
  void initState() {
    super.initState();
    _futurePersons = ApiService.getPersons(); // API'den veri çek
  }

  // ── Listeyi yenile ─────────────────────────────────────
  void _refreshList() {
    setState(() {
      // setState → Flutter'a "durum değişti, ekranı yeniden çiz" der.
      _futurePersons = ApiService.getPersons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Üst Çubuk ────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Rehber / Kişi Listesi'),
        centerTitle: true,
      ),

      // ── Gövde: FutureBuilder ─────────────────────────────
      // FutureBuilder → asenkron veri gelene kadar yükleniyor
      // gösterir, gelince listeyi çizer.
      body: FutureBuilder<List<Person>>(
        future: _futurePersons,
        builder: (context, snapshot) {
          // ↓ Veri henüz yükleniyorsa dönen yükleme göstergesi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ↓ Hata oluştuysa hata mesajı göster
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshList,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          // ↓ Veri geldi – listeyi al
          final persons = snapshot.data!;
          // snapshot.data! → null olmadığından eminiz (! operatörü)

          // ↓ Liste boşsa bilgi mesajı
          if (persons.isEmpty) {
            return const Center(child: Text('Henüz kişi eklenmemiş.'));
          }

          // ── ListView.builder ──────────────────────────────
          // Yalnızca ekranda görünen öğeleri oluşturur (performans).
          return RefreshIndicator(
            onRefresh: () async => _refreshList(),
            child: ListView.builder(
              itemCount: persons.length,
              itemBuilder: (context, index) {
                final person = persons[index];
                return _PersonCard(
                  person: person,
                  onTap: () async {
                    // Detay ekranına git, geri dönünce listeyi yenile
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonDetailScreen(personId: person.id!),
                      ),
                    );
                    _refreshList(); // Silme/güncelleme sonrası listeyi tazele
                  },
                );
              },
            ),
          );
        },
      ),

      // ── FAB (Floating Action Button) ─────────────────────
      // Sağ alt köşedeki + butonu → yeni kişi ekleme ekranı
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonFormScreen()),
          );
          _refreshList(); // Yeni kişi eklendikten sonra listeyi yenile
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _PersonCard  –  Listedeki her bir kişi kartı
// ════════════════════════════════════════════════════════════
// Alt çizgi (_) ile başlayan sınıf → dosya dışından erişilemez (private).

class _PersonCard extends StatelessWidget {
  final Person person;
  final VoidCallback onTap; // Tıklandığında çağrılacak fonksiyon

  const _PersonCard({required this.person, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        // ── Sol taraftaki daire profil fotoğrafı ─────────
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: person.photoUrl.isNotEmpty
              ? NetworkImage(person.photoUrl) // URL varsa ağdan yükle
              : null,                          // yoksa ikon göster
          child: person.photoUrl.isEmpty
              ? const Icon(Icons.person)       // Varsayılan ikon
              : null,
        ),
        // ── Başlık: Ad Soyad (kalın) ────────────────────
        title: Text(
          person.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // ── Alt başlık: Departman ───────────────────────
        subtitle: Text(person.phone),
        // ── Sağ ok ikonu ────────────────────────────────
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
