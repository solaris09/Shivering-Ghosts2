# 👻 Shivering Ghosts

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue?style=flat-square&logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.0+-orange?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/SpriteKit-2D-green?style=flat-square" alt="SpriteKit">
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow?style=flat-square" alt="Status">
</p>

<p align="center">
  <em>"Not scary. Just a little cold." ❄️</em>
</p>

<p align="center">
  <em>Last Updated: 24 December 2025 · Güncelleme: 24 Aralık 2025</em>
</p>

---

## Overview (English)
**Shivering Ghosts** is a short, cozy puzzle game for iOS. Instead of yarn-based knitting, the core mechanic is dressing a chilly ghost with three outfit pieces in the correct order: **beanie**, **scarf** and **sweater**. Match all three items to warm the ghost and score points.

### Gameplay
- A ghost appears and shows a 3‑slot outfit pattern (beanie / scarf / sweater).
- The player must drag or tap the correct items into the slots in the shown order.
- If all three slots are correct the ghost warms up and floats away, awarding points and possible outfit unlocks.
- If any slot is wrong the ghost shivers and the round can be retried.

### Controls
- Single-finger tap to select and place, or drag & drop from the item tray.
- Simple and accessible for quick sessions (30–90 seconds per run recommended).

### Features
- ✅ Fast, intuitive outfit dressing (3 slots: beanie, scarf, sweater)
- ✅ Drag & Drop / Tap controls
- ✅ **Dynamic Weather**: Sudden blizzards (Storm Mode) increase difficulty and reward! 🌪️
- ✅ **Power-ups**: Coffee (Time Freeze), Campfire (Instant Warmth), Magnet (Auto Match) ☕🔥🧲
- ✅ **Ghost Reactions**: Ghosts shake their head at wrong items, show hearts for correct ones, and sweat when time is low! 😰❤️
- ✅ **Shocking Ending**: Ghosts get struck by lightning and charred if time runs out! ⚡️☠️
- ✅ Different ghost types and rarity (Standard, Baby, Picky, Rare)
- ✅ In-game **Debug Tuner** for visual adjustments (DebugTuner.swift)
- ✅ Sound effects, particles, and responsive animations

### Gameplay & Mechanics (Detailed)
- **Pattern**: Each round shows a 3‑slot pattern for the ghost (beanie → scarf → sweater).
- **Ghost Types & Difficulty**:
  - **Standard**: normal patterns, base score.
  - **Baby**: simpler patterns, 0.8x score.
  - **Picky**: strict — mistakes can end the round, higher multipliers.
  - **Rare**: longer patterns; higher reward and special outfits.
- **Power-ups**: Spawn rarely; tap to activate special effects.
- **Storm Mode**: Random heavy weather events that speed up gameplay.
- **Scoring**: base points for a correct outfit; streaks and rarity multipliers increase score.
- **Outfit Collection**: Successful matches may award outfits or unlock cosmetic variations.

### Debug Tuner (Design)
- `DebugTuner.swift` provides sliders for adjusting per-ghost sprite alignment (hat/scarf/sweater widths and Y offsets).
- Values persist in `UserDefaults` under `tuner.<ghostKey>.<parameter>` so changes survive relaunch during development.

### Assets (where to look)
- Ghost sprites: `Shivering Ghosts/Assets.xcassets/ghost_*.imageset`
- Outfit sprites: `hat_*.imageset`, `scarf_*.imageset`, `sweater_*.imageset`
- Power-ups/Effects: `powerup_*.imageset`, `icicle_sweat`, `heart`
- UI: `button_green`, `button_blue`, `button_red`, `heart.imageset`
- Backgrounds & particles: `background_night.imageset`, `snowflake.imageset`
- Sounds: see `TASKS.md` for expected files (e.g., `correct_match.mp3`, `ghost_happy.mp3`, `game_music.mp3`)

### Screenshots
- Add screenshots to `Shivering Ghosts/Assets.xcassets/screenshots/` and reference them here.

![Screenshot placeholder 1](assets/screenshot-1.png)
![Screenshot placeholder 2](assets/screenshot-2.png)

### Installation
**Requirements:** macOS 13.0+, Xcode 15+, iOS 15.0+

1. Clone the repository
```bash
git clone https://github.com/solaris09/Shivering-Ghosts.git
cd "Shivering Ghosts"
```

2. Open the project in Xcode
```bash
open "Shivering Ghosts.xcodeproj"
```

3. Run in Simulator
- Choose an iOS Simulator (e.g., iPhone 14) and press `Cmd + R`.

4. Build to a Device (optional)
- Select your connected device in the target selector.
- In **Signing & Capabilities** choose your Team or add a development profile.
- Set the app bundle identifier if needed and press `Cmd + R`.

Troubleshooting
- Xcode build errors: try `Product → Clean Build Folder` (Shift+Cmd+K) and rebuild.
- Code signing issues: ensure your Apple ID is added in Xcode Preferences → Accounts and the Team is selected.
- Missing asset images: add PNGs to `Assets.xcassets/screenshots.imageset/` and re-open the asset catalog.

Adding screenshots for App Store
- Place prepared portrait screenshots in `Shivering Ghosts/Assets.xcassets/screenshots.imageset/` named `screenshot-1.png`, `screenshot-2.png`, etc.
- Follow Apple App Store size guidelines when preparing images (use @1x / @2x / @3x scaled versions as needed).

### App Store Short Description (EN)
Dress cute, chilly ghosts with a beanie, scarf and sweater — fast, cozy puzzle fun! ❄️👻

---

## Özet (Türkçe)
**Shivering Ghosts**, iOS için kısa, samimi bir bulmaca oyunudur. İplik mekaniği yerine temel oyun, soğuk bir hayalete **bere**, **atkı** ve **kazak** olmak üzere üç parça giydirmenize dayanır. Üçü doğruysa hayalet ısınır ve puan kazanırsınız.

### Oynanış
- Bir hayalet belirir ve 3 yuvalı bir kıyafet deseni gösterir (bere, atkı, kazak).
- Oyuncu doğru öğeleri gösterilen sırayla sürükleyerek ya da dokunarak yerleştirir.
- Üçü doğruysa hayalet ısınır, uçar ve puan ve özel kıyafetler kazanılabilir.
- Yanlış varsa hayalet daha fazla üşür ve tekrar denenir.

### Kontroller
- Tek parmakla dokunma veya sürükle-bırak ile öğe seçme ve yerleştirme
- Kısa oyun oturumları için tasarlandı (30–90 saniye)

### Özellikler
- ✅ Hızlı ve sezgisel kıyafet giydirme (3 yuva: bere, atkı, kazak)
- ✅ Sürükle & Bırak / Dokunma kontrolleri
- ✅ **Dinamik Hava**: Aniden bastıran fırtına (Blizzard) heyecanı artırır! 🌪️
- ✅ **Güçlendiriciler**: Kahve (Zamanı Dondur), Kamp Ateşi (Anında Isıt), Mıknatıs (Oto Eşle) ☕🔥🧲
- ✅ **Hayalet Tepkileri**: Yanlışta kafa sallama, doğruda kalp saçma, süre azalınca terleme! 😰❤️
- ✅ **Şok Edici Son**: Süre biterse hayalete yıldırım çarpar ve kömürleşir! ⚡️☠️
- ✅ Farklı hayalet türleri ve nadirlikler (Standard, Baby, Picky, Rare)
- ✅ Oyun içi **Debug Tuner** ile görsel ince ayar (DebugTuner.swift)
- ✅ Ses efektleri, parçacıklar ve akıcı animasyonlar

### Ekran Görüntüleri
- Ekran görüntülerini `Shivering Ghosts/Assets.xcassets/screenshots/` içine ekleyin ve burada referans verin.

![Ekran görüntüsü yer tutucu 1](assets/screenshot-1.png)
![Ekran görüntüsü yer tutucu 2](assets/screenshot-2.png)

### Kurulum
**Gereksinimler:** macOS 13.0+, Xcode 15+, iOS 15.0+

1. Depoyu klonlayın
```bash
git clone https://github.com/solaris09/Shivering-Ghosts.git
cd "Shivering Ghosts"
```
2. Xcode ile açın
```bash
open "Shivering Ghosts.xcodeproj"
```
3. Bir simülatör veya cihaz seçin, `Cmd + R` ile çalıştırın.

### App Store Kısa Açıklama (TR)
Bere, atkı ve kazak giydirerek sevimli hayaletleri ısıtın — hızlı ve samimi bir bulmaca deneyimi! ❄️👻

---

## Contributing
1. Fork the repo
2. Create a feature branch: `git checkout -b feature/MyFeature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push and open a PR

## License
This project is licensed under the MIT License. See `LICENSE` for details.

## Developer / İletişim
Cemal Hekimoğlu — GitHub: @solaris09

<p align="center">Made with ❤️ and ☕ in Turkey</p>
