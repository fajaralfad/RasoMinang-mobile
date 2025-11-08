# 🍛 Minang Food Classifier

![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi)
![TensorFlow](https://img.shields.io/badge/TensorFlow-MobileNetV3-FF6F00?logo=tensorflow)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)
![License](https://img.shields.io/badge/License-MIT-4CAF50)

---

## 📋 Deskripsi
**Minang Food Classifier** adalah aplikasi **Flutter** yang menggunakan model **MobileNetV3** untuk mengklasifikasikan makanan khas Minangkabau.  
Aplikasi ini mampu mengenali **9 jenis makanan tradisional Minangkabau** dengan akurasi tinggi melalui integrasi dengan **FastAPI backend**.

---

## 🍽️ Makanan yang Dikenali

| No | Kode | Nama Makanan | Deskripsi |
|----|------|---------------|------------|
| 1 | ayam_goreng | Ayam Goreng | Ayam goreng khas Minangkabau dengan bumbu rempah yang kaya |
| 2 | ayam_pop | Ayam Pop | Ayam kukus dengan citarasa gurih dan lembut |
| 3 | daging_rendang | Daging Rendang | Daging sapi dimasak dengan santan dan rempah hingga kering |
| 4 | dendeng_batokok | Dendeng Batokok | Daging sapi tipis digepuk dan dibakar dengan bumbu spesial |
| 5 | gulai_ikan | Gulai Ikan | Ikan segar dalam kuah gulai kuning yang gurih |
| 6 | gulai_tambusu | Gulai Tambusu | Usus sapi isi tahu dan telur dalam kuah gulai |
| 7 | gulai_tunjang | Gulai Tunjang | Kikil sapi dimasak dengan kuah gulai pedas |
| 8 | telur_balado | Telur Balado | Telur rebus dengan sambal balado pedas manis |
| 9 | telur_dadar | Telur Dadar | Telur dadar padat dengan bumbu khas Minang |

---

## 🚀 Fitur

### ✨ Core Features
- 🎯 **Klasifikasi Real-time** – Upload gambar dan dapatkan hasil prediksi instan  
- 📷 **Multiple Source Input** – Kamera & galeri  
- 📊 **Confidence Score Visualization** – Warna sesuai tingkat kepercayaan  
- 📈 **Probability Distribution View** – Semua probabilitas kelas makanan  
- 💾 **History Tracking** – Riwayat prediksi tersimpan secara lokal  

### 🛠️ Technical Features
- 🏗️ **Clean Architecture** – Struktur kode modular dan scalable  
- 🌐 **REST API Integration** – Koneksi backend FastAPI  
- 📱 **Responsive UI** – Optimal di berbagai ukuran layar  
- 🎨 **Material Design 3** – Tampilan modern & ramah pengguna  
- 🔒 **API Key Authentication** – Akses aman ke backend  
- ⚡ **Performance Optimized** – Kompresi dan caching gambar 

## 🚀 Installation & Setup

### 📦 Prasyarat
- Flutter SDK >= 3.0.0  
- Dart SDK >= 3.0.0  
- Android Studio / VS Code  
- FastAPI Backend aktif  

---

### 💻 Langkah Instalasi
```bash
# Clone repository
git clone https://github.com/your-username/minang-food-classifier.git
cd minang-food-classifier

# Install dependencies
flutter pub get
```
### ⚙️ Konfigurasi API

Edit file berikut: lib/core/constants/api_constants.dart
```bash
class ApiConstants {
  static const String baseUrl = 'https://your-railway-app.railway.app';
  static const String apiKey = 'your-actual-api-key';
}
```

### 🎯 Cara Penggunaan

- Buka aplikasi dan tap “Pilih Gambar”
- Pilih sumber: Kamera atau Galeri
- Tunggu proses klasifikasi
- Lihat hasil beserta confidence score
- Akses riwayat prediksi di ikon History

### ▶️ Jalankan Aplikasi dan 🧪 Testing
```bash
flutter run
flutter test
```
## 🔗 Links

### 🧠 [Backend & Model Repository: FastAPI + MobileNetV3 (Fine-tuning & API Deployment)](https://github.com/fajaralfad/klasifikasi-makanan-minangkabau-mobilenetV3)

Berisi model **MobileNetV3** yang telah di-*fine-tune* serta implementasi **FastAPI** untuk menyediakan layanan klasifikasi makanan Minangkabau.  
Model sudah termasuk di dalam repository ini bersama dengan backend.

---

### 📑 [API Documentation: Swagger UI](https://klasifikasi-makanan-minangkabau.up.railway.app)

Dapat diakses melalui endpoint **`/docs`** saat backend dijalankan secara lokal atau di server (Railway).


