# ============================================================
# main.py  –  Kişi Yönetim Sistemi  REST API  (FastAPI)
# ============================================================
# Bu dosya backend sunucusunun tamamını içerir.
# Çalıştırmak için:  uvicorn main:app --reload
# Swagger UI:  http://127.0.0.1:8000/docs
# ============================================================

from fastapi import FastAPI, HTTPException          # Web framework + hata sınıfı
from fastapi.middleware.cors import CORSMiddleware  # Tarayıcı/mobil CORS izni
from pydantic import BaseModel                      # Veri doğrulama modeli
from typing import Optional                         # Opsiyonel alan tipi

# ── FastAPI uygulama nesnesi ─────────────────────────────────
app = FastAPI(title="Kişi Yönetim API")

# ── CORS Middleware ──────────────────────────────────────────
# Flutter uygulaması farklı bir port/IP'den istek atacağı için
# tüm origin'lere izin veriyoruz (geliştirme ortamı için).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # Tüm kaynaklara izin ver
    allow_methods=["*"],        # GET, POST, PUT, DELETE hepsi serbest
    allow_headers=["*"],        # Tüm başlıklar serbest
)

# ── Pydantic Modelleri ───────────────────────────────────────
# Pydantic, gelen JSON verisini otomatik doğrular.
# Yanlış tipte veri gelirse 422 hatası döner.

class PersonCreate(BaseModel):
    """Yeni kişi oluştururken veya güncellerken gönderilen JSON yapısı."""
    fullName: str                   # Zorunlu – Ad Soyad
    department: str                 # Zorunlu – Departman
    photoUrl: Optional[str] = ""    # İsteğe bağlı – Fotoğraf URL'si
    birthPlace: Optional[str] = ""  # İsteğe bağlı – Doğum yeri
    birthDate: Optional[str] = ""   # İsteğe bağlı – Doğum tarihi (YYYY-AA-GG)
    email: Optional[str] = ""      # İsteğe bağlı – E-posta
    phone: Optional[str] = ""      # İsteğe bağlı – Telefon

class PersonOut(PersonCreate):
    """API'nin döndürdüğü kişi modeli – id alanı ekleniyor."""
    id: int                         # Sunucu tarafından atanan benzersiz kimlik

# ── Bellek İçi Veritabanı ────────────────────────────────────
# Basitlik için verileri bir Python listesinde tutuyoruz.
# Sunucu kapanınca veriler silinir (kalıcı DB gerekmez).

_id_counter: int = 4  # Bir sonraki atanacak ID

persons: list[dict] = [
    {
        "id": 1,
        "fullName": "Ahmet Yılmaz",
        "department": "Yazılım Geliştirme",
        "photoUrl": "",
        "birthPlace": "Adana",
        "birthDate": "1994-04-12",
        "email": "ahmet.yilmaz@sirket.com",
        "phone": "+905550123456",
    },
    {
        "id": 2,
        "fullName": "Ayşe Kaya",
        "department": "İnsan Kaynakları",
        "photoUrl": "",
        "birthPlace": "İstanbul",
        "birthDate": "1990-08-23",
        "email": "ayse.kaya@sirket.com",
        "phone": "+905551234567",
    },
    {
        "id": 3,
        "fullName": "Mehmet Demir",
        "department": "Bilgi Teknolojileri",
        "photoUrl": "",
        "birthPlace": "Ankara",
        "birthDate": "1988-01-15",
        "email": "mehmet.demir@sirket.com",
        "phone": "+905552345678",
    },
]

# ── Yardımcı Fonksiyon ──────────────────────────────────────

def _find_person(person_id: int) -> dict:
    """Verilen ID'ye sahip kişiyi listede bulur, yoksa 404 fırlatır."""
    for person in persons:
        if person["id"] == person_id:
            return person
    # Kişi bulunamazsa HTTP 404 hatası döndür
    raise HTTPException(status_code=404, detail="Kişi bulunamadı")

# ── API Uç Noktaları (Endpoints) ────────────────────────────

# 1) GET /api/persons  →  Tüm kişileri listele
@app.get("/api/persons", response_model=list[PersonOut])
def list_persons():
    """Veritabanındaki tüm kişileri JSON dizisi olarak döndürür."""
    return persons


# 2) GET /api/persons/{id}  →  Tek kişi getir
@app.get("/api/persons/{person_id}", response_model=PersonOut)
def get_person(person_id: int):
    """Belirtilen ID'ye sahip kişinin detaylarını döndürür."""
    return _find_person(person_id)


# 3) POST /api/persons  →  Yeni kişi oluştur
@app.post("/api/persons", response_model=PersonOut, status_code=201)
def create_person(data: PersonCreate):
    """
    İstek gövdesindeki JSON'dan yeni kişi oluşturur.
    Otomatik artan bir ID atar ve 201 Created döner.
    """
    global _id_counter
    new_person = {"id": _id_counter, **data.model_dump()}
    #  **data.model_dump()  →  Pydantic modelini sözlüğe çevirip
    #                          id ile birleştiriyoruz.
    _id_counter += 1
    persons.append(new_person)
    return new_person


# 4) PUT /api/persons/{id}  →  Kişiyi güncelle
@app.put("/api/persons/{person_id}", response_model=PersonOut)
def update_person(person_id: int, data: PersonCreate):
    """
    Mevcut kişinin bilgilerini günceller.
    Kişi bulunamazsa 404 döner.
    """
    person = _find_person(person_id)
    # Gelen verileri mevcut sözlüğe yaz
    person.update(data.model_dump())
    return person


# 5) DELETE /api/persons/{id}  →  Kişiyi sil
@app.delete("/api/persons/{person_id}", status_code=204)
def delete_person(person_id: int):
    """
    Belirtilen ID'ye sahip kişiyi siler.
    Başarılıysa 204 No Content döner (gövde boş).
    """
    person = _find_person(person_id)
    persons.remove(person)
    # 204 = başarılı ama döndürülecek içerik yok
    return None
