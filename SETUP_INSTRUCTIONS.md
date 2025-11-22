# Setup Instructions - Virtual Office Pomodoro

## ⚠️ Важно: Это Swift Package Manager проект!

Проект создан с использованием Swift Package Manager с модульной архитектурой. **НЕ** открывайте отдельные файлы в Xcode.

## Правильный способ открыть проект:

### Вариант 1: Open Package.swift (Рекомендуется)

1. Откройте Xcode
2. File → Open
3. Выберите файл `Package.swift` в корне проекта
4. Xcode автоматически:
   - Загрузит зависимости (TCA)
   - Настроит модули (App, Core, Features, DesignSystem, Services)
   - Разрешит все imports

### Вариант 2: Открыть из командной строки

```bash
cd /path/to/coworking-app
open Package.swift
```

Xcode откроется автоматически с правильной конфигурацией.

## После открытия Package.swift:

1. **Дождитесь загрузки зависимостей**
   - Xcode покажет "Fetching package dependencies"
   - Это займет 1-2 минуты при первом запуске

2. **Выберите схему**
   - Product → Scheme → App

3. **Выберите симулятор**
   - iPhone 16 Pro или любой iOS 18+ симулятор

4. **Запустите**
   - ⌘R или Product → Run

## Структура проекта в Xcode:

После открытия Package.swift вы увидите:

```
VirtualOfficePomodoro
├── Sources
│   ├── App                    ← Главный модуль
│   ├── Core                   ← Модели, сеть, auth
│   ├── Features               ← TCA Features
│   ├── DesignSystem           ← UI Components
│   ├── Services               ← Services
│   └── Extensions             ← Live Activities, Widgets
├── Tests
│   ├── AppTests
│   └── FeaturesTests
└── Dependencies               ← SPM зависимости (автоматически)
    └── swift-composable-architecture
```

## Если у вас уже создан .xcodeproj:

### НЕ ИСПОЛЬЗУЙТЕ ЕГО!

Вместо этого:

1. Закройте ваш существующий Xcode проект
2. Удалите `.xcodeproj` файл (если создали)
3. Откройте `Package.swift`

## Создание приложения для App Store:

Swift Package не создает .app напрямую. Для App Store submission:

### Вариант A: Создать Xcode проект из Package

1. Откройте Package.swift в Xcode
2. File → New → Project
3. Выберите "iOS App"
4. В новом проекте:
   - File → Add Package Dependencies
   - Add Local... → Выберите папку с Package.swift
   - Или добавьте как Git dependency

### Вариант B: Использовать скрипт (создам ниже)

## Решение проблем:

### Error: "No such module 'ComposableArchitecture'"

**Причина**: Зависимости не загружены

**Решение**:
1. File → Packages → Reset Package Caches
2. File → Packages → Resolve Package Versions
3. Перезапустите Xcode

### Error: "Unable to find module dependency: 'Features'"

**Причина**: Вы открыли .swift файл напрямую, а не Package.swift

**Решение**: Откройте Package.swift

### Build Errors

**Решение**:
```bash
# Очистить build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Переоткрыть Package.swift
open Package.swift
```

## Запуск на устройстве:

1. Подключите iPhone/iPad
2. Product → Destination → Ваше устройство
3. При первом запуске:
   - Settings → General → VPN & Device Management
   - Trust your developer certificate
4. ⌘R

## Следующие шаги:

1. Откройте Package.swift ✅
2. Дождитесь загрузки зависимостей ✅
3. Выберите схему "App" ✅
4. Запустите на симуляторе ✅
5. Наслаждайтесь! 🎉

## Нужна помощь?

Проверьте:
- [ ] Xcode 16.0+ установлен
- [ ] iOS 18.0+ SDK доступен
- [ ] Интернет подключен (для загрузки зависимостей)
- [ ] Открыли именно Package.swift, а не .xcodeproj

---

**Примечание**: Этот проект специально создан как Swift Package для модульности и тестируемости. Для production release понадобится обернуть его в Xcode App project.
