// ============================================================
// person.dart  –  Kişi veri modeli
// ============================================================
// Bu sınıf, API'den gelen JSON'u Dart nesnesine çevirir
// ve Dart nesnesini tekrar JSON'a dönüştürür.
// ============================================================

class Person {
  final int? id;            // Sunucudan gelen benzersiz kimlik (yeni kayıtta null olabilir)
  final String fullName;    // Ad Soyad
  final String department;  // Departman
  final String photoUrl;    // Profil fotoğrafı URL'si
  final String birthPlace;  // Doğum yeri
  final String birthDate;   // Doğum tarihi (YYYY-AA-GG)
  final String email;       // E-posta adresi
  final String phone;       // Telefon numarası

  // ── Kurucu (Constructor) ──────────────────────────────────
  // required  → bu parametre zorunlu
  // this.alan → doğrudan sınıf alanına ata
  Person({
    this.id,
    required this.fullName,
    required this.department,
    this.photoUrl = '',
    this.birthPlace = '',
    this.birthDate = '',
    this.email = '',
    this.phone = '',
  });

  // ── JSON → Person (Factory Constructor) ───────────────────
  // API'den gelen Map<String, dynamic> tipindeki JSON'u
  // Person nesnesine dönüştürür.
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,                             // int veya null
      fullName: json['fullName'] as String? ?? '',         // null ise boş string
      department: json['department'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      birthPlace: json['birthPlace'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  // ── Person → JSON ────────────────────────────────────────
  // PUT/POST isteği gönderirken Person nesnesini
  // Map'e çevirir (id hariç, çünkü id sunucu atar).
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
    };
  }
}
