## 📘 MüşteriDefterim – Flutter + Firebase Müşteri Takip Uygulaması

#### MüşteriDefterim; işletmelerin müşterilerini, randevularını ve müşteri notlarını kolayca yönetebilmesi amacıyla geliştirilmiş modern bir mobil uygulamadır.

#### Flutter ile geliştirilmiş olup Firebase altyapısı ile kimlik doğrulama, veri saklama ve güvenli giriş sağlar.

#### Uygulama; kullanıcıların günlük müşteri takibini kolaylaştırır, her işletmeye özel müşteri listesini dinamik olarak yönetir.

## 🚀 Özellikler

### 🔐 Kimlik Doğrulama:

- E-posta + Şifre ile kayıt olma
- Firebase Auth tabanlı güvenli giriş
- E-posta ile şifre sıfırlama
- Oturum açıkken uygulamanın otomatik giriş yapması

### 👤 Kullanıcı Yönetimi

- Kullanıcı adı ve e-posta bilgilerini Firestore’dan dinamik çekme
- Kullanıcıya özel müşteri listesi
- Profil ayarları (şifre değiştirme vb.)

### 📋 Müşteri Yönetimi

- Müşteri ekleme
- Müşteri detaylarını görüntüleme
- Not ekleme / düzenleme
- Müşteriyi silme
- Her kullanıcı için ayrı müşteri listesi (Firestore’da userId altında tutulur)

### 📅 Randevu Sistemi

- Randevu ekleme
- Tarihe göre filtreleme
- Randevu görüntüleme
- Firestore’a kayıt

### 🎨 Arayüz Tasarımı

- Light & Dark Mode destekler
- AppColors ve AppStyles ile merkezi tasarım yönetimi
- Yumuşak geçişli degrade arka planlar
- Responsive tasarım

## 🛠 Kullanılan Teknolojiler

### Flutter

- State Management: Stateful widgets + FutureBuilder + StreamBuilder
- Material Design
- Responsive UI
- Custom Theme (AppTheme)

### Firebase

- Firebase Authentication → Giriş/Kayıt/Şifre Sıfırlama
- Cloud Firestore → Kullanıcı ve müşteri verileri
- Firebase Core
- Firebase Options (flutterfire CLI ile oluşturuldu)

### Diğer

- MVVM’ye yakın modüler sayfa yapısı
- Drawer + Navigation routes
- Custom tasarım bileşenleri

## 📱 Uygulama Kullanımı

1. Kayıt Ol

- E-posta ve şifre ile kayıt ol
- Firestore’da kullanıcıya özel bir profil oluşturulur

2. Giriş Yap

- Firebase Auth kontrol eder
- Oturum açıksa otomatik giriş sağlanır

3. Ana Sayfa

- Kullanıcı adı, e-posta → Firestore’dan otomatik gelir
- Kullanıcıya özel müşteri listesi yüklenir

4. Müşteri Yönetimi

- Müşteri ekle
- Detaylarında not ve randevu oluştur
- Gerekirse müşteriyi sil

5. Şifre Sıfırlama

- E-posta gir → Firebase kullanıcıya reset linki gönderir

## 📌 Gelecek Geliştirmeler

- Bildirim sistemi
- Takvim görünümü
- Bulut yedekleme & geri yükleme
- PDF müşteri raporu alma

## 👩‍💻 Geliştirici

### Rümeysa Gökçe - Software Developer
