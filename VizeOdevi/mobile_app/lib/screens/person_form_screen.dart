// ============================================================
// person_form_screen.dart  –  Kişi Ekleme / Düzenleme Formu
// ============================================================
// person parametresi null ise → yeni kişi oluşturma modu
// person parametresi doluysa → mevcut kişiyi düzenleme modu
// ============================================================

import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

class PersonFormScreen extends StatefulWidget {
  final Person? person; // null → yeni kayıt, dolu → düzenleme

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  // ── Form Anahtarı ─────────────────────────────────────────
  // GlobalKey<FormState> → form doğrulaması (validation) için gerekli.
  final _formKey = GlobalKey<FormState>();

  // ── TextEditingController'lar ─────────────────────────────
  // Her metin alanı için bir controller; alanın değerini okur/yazar.
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _photoUrlCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isLoading = false; // Kaydetme sırasında buton devre dışı

  @override
  void initState() {
    super.initState();
    // Düzenleme modundaysa mevcut değerleri controller'lara yaz
    final p = widget.person;
    _fullNameCtrl   = TextEditingController(text: p?.fullName ?? '');
    _departmentCtrl = TextEditingController(text: p?.department ?? '');
    _photoUrlCtrl   = TextEditingController(text: p?.photoUrl ?? '');
    _birthPlaceCtrl = TextEditingController(text: p?.birthPlace ?? '');
    _birthDateCtrl  = TextEditingController(text: p?.birthDate ?? '');
    _emailCtrl      = TextEditingController(text: p?.email ?? '');
    _phoneCtrl      = TextEditingController(text: p?.phone ?? '');
  }

  // ── Controller'ları temizle (bellek sızıntısını önle) ────
  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _departmentCtrl.dispose();
    _photoUrlCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _birthDateCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Formu Kaydet ──────────────────────────────────────────
  Future<void> _saveForm() async {
    // 1. Form doğrulaması – validate() tüm validator'ları çalıştırır
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 2. Controller'lardan değerleri oku ve Person nesnesi oluştur
    final person = Person(
      fullName:   _fullNameCtrl.text.trim(),
      department: _departmentCtrl.text.trim(),
      photoUrl:   _photoUrlCtrl.text.trim(),
      birthPlace: _birthPlaceCtrl.text.trim(),
      birthDate:  _birthDateCtrl.text.trim(),
      email:      _emailCtrl.text.trim(),
      phone:      _phoneCtrl.text.trim(),
    );

    try {
      if (widget.person == null) {
        // ── Yeni Kayıt → POST ────────────────────────────
        await ApiService.createPerson(person);
      } else {
        // ── Güncelleme → PUT ─────────────────────────────
        await ApiService.updatePerson(widget.person!.id!, person);
      }

      if (mounted) Navigator.pop(context); // Başarılıysa geri dön
    } catch (e) {
      // Hata durumunda SnackBar ile bildir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.person != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kişiyi Düzenle' : 'Yeni Kişi Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // ── Form Widget'ı ─────────────────────────────────
        // Form, içindeki TextFormField'ları gruplar ve
        // toplu doğrulama (validation) yapabilir.
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ad Soyad (Zorunlu)
              TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // Boşsa hata mesajı döndür
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad Soyad zorunludur';
                  }
                  return null; // null = sorun yok
                },
              ),
              const SizedBox(height: 12),

              // Departman (Zorunlu)
              TextFormField(
                controller: _departmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Departman *',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Departman zorunludur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Fotoğraf URL'si
              TextFormField(
                controller: _photoUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fotoğraf URL',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              // Doğum Yeri
              TextFormField(
                controller: _birthPlaceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Doğum Yeri',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Doğum Tarihi
              TextFormField(
                controller: _birthDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Doğum Tarihi (YYYY-AA-GG)',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                  hintText: '1994-04-12',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 12),

              // E-posta
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Telefon
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '+905550123456',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // ── Kaydet Butonu ─────────────────────────────
              SizedBox(
                width: double.infinity, // Tam genişlik
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveForm,
                  // _isLoading true ise buton devre dışı (null = disabled)
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isEditing ? 'GÜNCELLE' : 'KAYDET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
