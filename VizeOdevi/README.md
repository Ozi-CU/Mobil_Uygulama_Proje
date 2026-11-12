# Kişi Yönetim Sistemi – Vize Projesi

Mobil Programlama Dersi | 2026-2027 Güz | Vize Ödevi

## Proje Yapısı

```
├── backend_api/       ← FastAPI REST API sunucusu
│   ├── main.py        ← API kodunun tamamı
│   └── requirements.txt
├── mobile_app/        ← Flutter mobil uygulama
│   └── lib/
│       ├── main.dart
│       ├── models/person.dart
│       ├── services/api_service.dart
│       └── screens/
│           ├── person_list_screen.dart
│           ├── person_detail_screen.dart
│           └── person_form_screen.dart
└── README.md
```

## Backend API Kurulumu

### Gereksinimler
- Python 3.10 veya üzeri

### Kurulum Adımları

```bash
# 1. Proje klasörüne gir
cd backend_api

# 2. Sanal ortam oluştur (önerilir)
python -m venv venv

# 3. Sanal ortamı aktifle
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 4. Bağımlılıkları kur
pip install -r requirements.txt

# 5. Sunucuyu başlat
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Sunucu başladıktan sonra:
- API: http://127.0.0.1:8000/api/persons
- Swagger UI (test arayüzü): http://127.0.0.1:8000/docs

### API Uç Noktaları

| Metot  | URL                    | Açıklama              |
|--------|------------------------|-----------------------|
| GET    | `/api/persons`         | Tüm kişileri listele  |
| GET    | `/api/persons/{id}`    | Tek kişi getir        |
| POST   | `/api/persons`         | Yeni kişi oluştur     |
| PUT    | `/api/persons/{id}`    | Kişi bilgilerini güncelle |
| DELETE | `/api/persons/{id}`    | Kişiyi sil            |

## Mobil Uygulama Kurulumu

### Gereksinimler
- Flutter SDK (3.x)
- Android Studio veya VS Code

### Kurulum Adımları

```bash
# 1. Flutter proje klasörüne gir
cd mobile_app

# 2. Bağımlılıkları indir
flutter pub get

# 3. Emülatör veya fiziksel cihazda çalıştır
flutter run
```

> **Not:** Android Emülatör kullanıyorsanız `api_service.dart` içindeki
> `baseUrl` değerini `http://10.0.2.2:8000` olarak ayarlayın.
> (10.0.2.2, Android emülatörün host makineye erişim IP'sidir.)
