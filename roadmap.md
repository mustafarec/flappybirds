# Sky Hopper Roadmap

Amaç: Oynanabilir mevcut çekirdeği koruyarak oyun hissini geliştirmek ve kararlı bir App Store 1.0 sürümüne ulaşmak.

## Mevcut durum

- [x] Temel uçuş, engel, çarpışma ve yeniden başlatma akışı
- [x] Yıldız zinciri ve `x5` puan çarpanı
- [x] Cihazda saklanan en yüksek skor
- [x] Özgün oyun görselleri ve uygulama ikonu
- [x] Xcode projesi ve temel XCTest kapsamı
- [x] Veri toplamayan yapı ve gizlilik sayfası

## 1. Sağlamlaştırma

- [ ] Xcode 26 ile projeyi derle ve tüm testleri çalıştır
- [ ] Küçük, orta ve büyük iPhone ekranlarında arayüzü kontrol et
- [ ] Başlatma, çarpışma, skor, yıldız zinciri ve hızlı yeniden başlatmayı cihazda test et
- [x] Uygulama arka plana geçtiğinde oyunu güvenli biçimde duraklat
- [x] Gizlilik ve destek bağlantılarını `mustafarec/flappybirds` ile hizala
- [ ] GitHub Pages sonrasında gizlilik ve destek bağlantılarını canlı ortamda doğrula
- [x] Skor, yüksek skor ve zorluk davranışı için kritik test kaynaklarını tamamla

**Çıkış kriteri:** Testler geçiyor, engelleyici hata yok ve aynı oyun oturumu desteklenen ekran boyutlarında tutarlı çalışıyor.

## 2. Oyun hissi

- [x] İlk oyunda yıldız zinciri mekaniğini tek cümleyle açıkla
- [x] Kanat çırpma, yıldız, puan ve çarpışma için kısa ses efektleri ekle
- [x] Önemli oyun olaylarına hafif haptik geri bildirim ekle
- [x] Ses için cihazda saklanan aç/kapat seçeneği ekle
- [x] Geçilen kapı sayısı yükseldikçe engel hızını ve sıklığını kontrollü üst sınırlara kadar artır
- [ ] En az 10 dakikalık oturumlarla zorluk dengesini test et

**Çıkış kriteri:** Yeni oyuncu mekaniği anlayabiliyor; ses, haptik ve zorluk artışı oynanışı destekliyor ve kapatılabiliyor.

## 3. App Store 1.0 hazırlığı

- [x] GitHub deposunu, destek bağlantısını ve `flappybirds` adreslerini hizala
- [x] Oyundaki sabit metinleri İngilizce ve Türkçe yerelleştir
- [x] App Store adı, alt başlık, açıklama, anahtar kelimeler ve kategori taslağını hazırla
- [ ] Gerekli iPhone ekran görüntülerini oluştur
- [x] Gizlilik ve yaş derecelendirmesi için yerel beyan taslağını hazırla
- [ ] Gizlilik URL'sini ekle ve "veri toplanmıyor" beyanını tamamla
- [ ] Güncel yaş derecelendirmesi sorularını yanıtla
- [ ] TestFlight sürümünü küçük bir test grubuyla doğrula
- [ ] Xcode 26 ve iOS 26 SDK ile Release arşivi oluştur

**Çıkış kriteri:** TestFlight geri bildirimlerinde engelleyici sorun yok; mağaza bilgileri, gizlilik beyanı ve yüklenebilir Release arşivi hazır.

## 4. Yayın ve takip

- [ ] 1.0 sürümünü App Review'a gönder
- [ ] Yayın sonrası çökme raporlarını ve kullanıcı geri bildirimlerini izle
- [ ] Yalnızca doğrulanmış kritik sorunlar için 1.0.x düzeltme sürümü çıkar
- [ ] Sonraki sürüm önceliklerini gerçek kullanım ve geri bildirime göre belirle

**Çıkış kriteri:** 1.0 yayında ve kritik hata bulunmuyor ya da düzeltme sürümünde kapatılmış durumda.

## Şimdilik kapsam dışı

- Backend ve hesap sistemi
- Reklam veya analitik SDK'ları
- Çok oyunculu mod
- Kozmetik mağaza ve günlük görevler
- Game Center liderlik tablosu ve başarımlar

Bu özellikler yalnızca ölçülebilir kullanıcı talebi veya net bir ürün ihtiyacı oluşursa yeniden değerlendirilecek.

## Güncel resmi gereksinimler

- [Apple SDK minimum gereksinimleri](https://developer.apple.com/news/upcoming-requirements/)
- [App Store Connect gizlilik yönetimi](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)
- [App Store yaş derecelendirmesi](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating)
