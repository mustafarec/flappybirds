# Flappy Birds

Swift + SpriteKit ile yapılmış klasik Flappy Birds oyunu.

## Gereksinimler

- **Xcode 15+**
- **iOS 15+** (iPhone)
- Swift 5

## Kurulum

1. `FlappyBirds.xcodeproj` dosyasını Xcode'da açın.
2. Bir iPhone simülatörü veya cihaz seçin.
3. **Product → Run** (⌘R) ile oyunu çalıştırın.

## Test

Xcode'da **Product → Test** (⌘U) komutunu çalıştırın. `FlappyBirdsTests` hedefi, kuşun zıplama hızını doğrular.

## Oynanış

- **Tap**: Kuşu zıplat
- Boruların arasından geç, her geçiş +1 puan
- Yere veya boruya çarparsan oyun biter
- En yüksek skorun kaydedilir

## Proje Yapısı

| Dosya | Açıklama |
|---|---|
| `AppDelegate.swift` | Uygulama giriş noktası |
| `GameViewController.swift` | SpriteKit sahnesini yönetir |
| `GameScene.swift` | Ana oyun sahnesi, tüm oyun mantığı |
| `GameState.swift` | Oyun durumu enum'u |
| `BirdNode.swift` | Kuş karakteri |
| `PipeNode.swift` | Boru engelleri |
| `GroundNode.swift` | Hareketli zemin |
| `ScoreManager.swift` | Skor takibi ve kaydı |
| `Assets.xcassets/` | Oyun asset'leri (kuş, boru, zemin, arka plan PNG) |

## Asset Kaynakları

Oyun grafikleri GitHub'daki açık kaynak Flappy Bird reposundan alınmıştır:

| Asset | Kaynak |
|---|---|
| `bird.png` (34×24) | [AnishKanojia/Flappy-Bird](https://github.com/AnishKanojia/Flappy-Bird) |
| `pipe.png` (52×320) | [AnishKanojia/Flappy-Bird](https://github.com/AnishKanojia/Flappy-Bird) |
| `ground.png` (336×112) | [AnishKanojia/Flappy-Bird](https://github.com/AnishKanojia/Flappy-Bird) |
| `background.png` (288×512) | [AnishKanojia/Flappy-Bird](https://github.com/AnishKanojia/Flappy-Bird) |
