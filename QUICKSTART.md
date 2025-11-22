# Quick Start Guide 🚀

## Исправление ошибок "No such module"

Если вы видите ошибки:
```
No such module 'ComposableArchitecture'
Unable to find module dependency: 'Features'
Unable to find module dependency: 'DesignSystem'
```

### ✅ ПРАВИЛЬНЫЙ способ (3 минуты):

#### Вариант 1: Открыть Package.swift

1. **Закройте** текущий Xcode проект
2. **Откройте Finder** и перейдите в папку проекта
3. **Двойной клик** на файл `Package.swift`
4. Xcode откроется и покажет: "Fetching dependencies..."
5. **Подождите 1-2 минуты** пока загрузятся зависимости
6. Выберите схему **"App"** в Xcode
7. Нажмите **⌘R** для запуска

#### Вариант 2: Из Terminal

```bash
cd ~/Downloads/coworking-app
open Package.swift
```

Готово! Xcode настроит всё автоматически.

---

## Альтернатива: Использование скрипта

Вы можете использовать наш скрипт для автоматического открытия:

```bash
cd ~/Downloads/coworking-app
./Scripts/generate-xcode-project.sh
```

Скрипт откроет Package.swift и покажет подробные инструкции.

---

## Что НЕ делать ❌

1. ❌ НЕ создавайте свой .xcodeproj
2. ❌ НЕ копируйте файлы в другой проект
3. ❌ НЕ открывайте отдельные .swift файлы
4. ❌ НЕ пытайтесь добавить зависимости вручную

---

## Проверка что всё работает

После открытия `Package.swift`:

### 1. Проверьте зависимости

В Xcode слева должны быть видны:
- ✅ Swift Dependencies
  - ✅ swift-composable-architecture

### 2. Проверьте модули

В Project Navigator должны быть:
- ✅ Sources
  - ✅ App
  - ✅ Core
  - ✅ Features
  - ✅ DesignSystem
  - ✅ Services
  - ✅ Extensions

### 3. Выберите схему

Product → Scheme → **App**

### 4. Выберите destination

Product → Destination → iPhone 16 Pro (iOS 18.0+)

### 5. Build!

⌘R или Product → Run

---

## Если ничего не помогает

### Вариант A: Полная очистка

```bash
# Закройте Xcode

# Очистите DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Очистите package cache
cd ~/Downloads/coworking-app
rm -rf .build

# Переоткройте Package.swift
open Package.swift
```

### Вариант B: Reset Package Dependencies

В Xcode:
1. File → Packages → **Reset Package Caches**
2. File → Packages → **Update to Latest Package Versions**
3. Product → Clean Build Folder (⇧⌘K)
4. Product → Build (⌘B)

---

## Системные требования

- ✅ macOS 14.0 (Sonoma) или новее
- ✅ Xcode 16.0 или новее
- ✅ iOS 18.0 SDK
- ✅ Интернет (для загрузки зависимостей)

---

## Структура после открытия Package.swift

```
VirtualOfficePomodoro (Package)
├── 📦 Dependencies
│   └── swift-composable-architecture
├── 📁 Sources
│   ├── 📱 App (Main module)
│   │   ├── VirtualOfficePomodoroApp.swift
│   │   ├── AppFeature.swift
│   │   └── AppView.swift
│   ├── 🎯 Features
│   │   ├── Authentication
│   │   ├── Timer
│   │   ├── Office
│   │   ├── Friends
│   │   └── Statistics
│   ├── 🎨 DesignSystem
│   │   ├── Components
│   │   └── Themes
│   ├── ⚙️ Services
│   └── 🔌 Extensions
│       ├── LiveActivities
│       ├── Widgets
│       └── Intents
└── 🧪 Tests
```

---

## FAQ

**Q: Почему не .xcodeproj?**
A: Проект использует современный Swift Package Manager для модульности. При необходимости можно сгенерировать .xcodeproj скриптом.

**Q: Как добавить новые файлы?**
A: Создавайте файлы в соответствующих папках Sources/. Xcode автоматически подхватит их.

**Q: Можно ли запустить на физическом устройстве?**
A: Да! Просто выберите ваш iPhone/iPad в destination selector.

**Q: Работает ли с TestFlight?**
A: Для TestFlight/App Store нужно создать wrapper app project. Используйте скрипт генерации .xcodeproj.

---

**🎯 Главное правило**: Всегда открывайте **Package.swift**, а не отдельные файлы!
