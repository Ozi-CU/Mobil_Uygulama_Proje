// ============================================================
// api_service.dart  –  REST API ile iletişim servisi
// ============================================================

import 'dart:convert';                          // JSON encode/decode için
import 'package:flutter/foundation.dart';      // kIsWeb kontrolü için
import 'dart:io' show Platform;                // Platform kontrolü için
import 'package:http/http.dart' as http;
import '../models/person.dart';

class ApiService {
  // ── Otomatik Platform Tespiti ─────────────────────────────
  // Web veya Windows/macOS/Linux ise -> 127.0.0.1
  // Android Emülatör ise -> 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {
      // Platform kontrolü desteklenmeyen ortamlarda varsayılan
    }
    return 'http://127.0.0.1:8000/api';
  }

  // ── 1) GET /persons  →  Tüm kişileri getir ───────────────
  static Future<List<Person>> getPersons() async {
    final response = await http.get(Uri.parse('$baseUrl/persons'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception('Kişiler yüklenemedi: ${response.statusCode}');
    }
  }

  // ── 2) GET /persons/{id}  →  Tek kişi getir ──────────────
  static Future<Person> getPerson(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/persons/$id'));

    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kişi bulunamadı: ${response.statusCode}');
    }
  }

  // ── 3) POST /persons  →  Yeni kişi oluştur ───────────────
  static Future<Person> createPerson(Person person) async {
    final response = await http.post(
      Uri.parse('$baseUrl/persons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 201) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kişi oluşturulamadı: ${response.statusCode}');
    }
  }

  // ── 4) PUT /persons/{id}  →  Kişiyi güncelle ─────────────
  static Future<Person> updatePerson(int id, Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/persons/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kişi güncellenemedi: ${response.statusCode}');
    }
  }

  // ── 5) DELETE /persons/{id}  →  Kişiyi sil ───────────────
  static Future<void> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/persons/$id'));

    if (response.statusCode != 204) {
      throw Exception('Kişi silinemedi: ${response.statusCode}');
    }
  }
}
