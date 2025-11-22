# Virtual Office Pomodoro

iOS приложение для совместной работы по методу Pomodoro с возможностью создания виртуальных офисов, где пользователи могут видеть активность друзей в реальном времени.

## Основные возможности

### MVP (Phase 1)
- ✅ Аутентификация (Sign in with Apple, Email/Password)
- ✅ Pomodoro таймер с настройками
- ✅ Создание и управление виртуальными офисами
- ✅ Real-time обновления статусов участников
- ✅ Базовая статистика
- ⏳ Управление друзьями
- ⏳ Push и локальные уведомления

### Phase 2
- ⏳ Live Activities
- ⏳ Home Screen Widget
- ⏳ Расширенная статистика с Charts
- ⏳ QR-код приглашения
- ⏳ Calendar integration
- ⏳ Siri Shortcuts

### Phase 3
- ⏳ Apple Watch companion app
- ⏳ CloudKit синхронизация
- ⏳ Focus Mode integration
- ⏳ Экспорт данных

## Технический стек

- **Language**: Swift 6.0+ (strict concurrency)
- **UI Framework**: SwiftUI
- **Architecture**: The Composable Architecture (TCA)
- **Data Persistence**: SwiftData
- **Networking**: URLSession, WebSocket
- **Authentication**: Sign in with Apple, KeyChain
- **Platform**: iOS 18.0+, watchOS 11.0+

## Архитектура проекта

```
VirtualOfficePomodoro/
├── Sources/
│   ├── App/                    # Главное приложение
│   │   ├── VirtualOfficePomodoroApp.swift
│   │   ├── AppFeature.swift
│   │   └── AppView.swift
│   ├── Core/                   # Базовые компоненты
│   │   ├── Models/             # Модели данных (SwiftData)
│   │   ├── Networking/         # Сетевой слой
│   │   ├── Authentication/     # Аутентификация
│   │   └── Utils/              # Утилиты
│   ├── Features/               # Функциональные модули (TCA)
│   │   ├── Authentication/     # Аутентификация
│   │   ├── Office/             # Виртуальные офисы
│   │   ├── Timer/              # Pomodoro таймер
│   │   ├── Friends/            # Управление друзьями
│   │   ├── Profile/            # Профиль пользователя
│   │   └── Statistics/         # Статистика
│   ├── DesignSystem/           # UI компоненты
│   │   ├── Components/         # Переиспользуемые компоненты
│   │   ├── Themes/             # Цвета, типографика, отступы
│   │   └── Modifiers/          # View модификаторы
│   └── Services/               # Сервисы
│       ├── NotificationService.swift
│       ├── HapticService.swift
│       └── BiometricService.swift
└── Tests/                      # Тесты
```

## Установка и запуск

### Требования

- Xcode 16.0+
- iOS 18.0+ SDK
- Swift 6.0+

### Шаги установки

1. Клонируйте репозиторий:
```bash
git clone https://github.com/yourusername/virtual-office-pomodoro.git
cd virtual-office-pomodoro
```

2. Откройте проект:
```bash
open Package.swift
```
или используйте Xcode для открытия Package.swift

3. Подождите, пока SPM загрузит зависимости

4. Выберите схему и запустите проект

### Зависимости

Проект использует Swift Package Manager для управления зависимостями:

- [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) - TCA фреймворк
- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) - Dependency injection

## Конфигурация backend

Для работы приложения требуется настроить backend API:

1. Обновите URL в `Sources/Core/Networking/NetworkService.swift`:
```swift
let baseURL = URL(string: "https://your-api.com")!
```

2. Обновите WebSocket URL в `Sources/Core/Networking/WebSocketManager.swift`:
```swift
let url = URL(string: "wss://your-api.com/ws")!
```

## API Endpoints

Backend должен реализовать следующие endpoints:

### Authentication
- `POST /auth/register` - Регистрация
- `POST /auth/login` - Вход
- `POST /auth/apple` - Sign in with Apple
- `POST /auth/refresh` - Обновление токена

### Users
- `GET /users/me` - Текущий пользователь
- `PATCH /users/me` - Обновление профиля
- `GET /users/:id` - Пользователь по ID
- `GET /users/search?q=:query` - Поиск пользователей

### Offices
- `GET /offices` - Список офисов
- `POST /offices` - Создание офиса
- `GET /offices/:id` - Детали офиса
- `PATCH /offices/:id` - Обновление офиса
- `DELETE /offices/:id` - Удаление офиса
- `POST /offices/:id/members` - Добавление участника
- `DELETE /offices/:id/members/:userId` - Удаление участника

### Sessions
- `GET /sessions` - История сессий
- `POST /sessions` - Создание сессии
- `PATCH /sessions/:id` - Обновление сессии

### Statistics
- `GET /stats/personal` - Личная статистика
- `GET /stats/office/:id` - Статистика офиса

### WebSocket Events

#### Client → Server
```json
{
  "type": "timer.start",
  "data": { "sessionId": "uuid", "duration": 1500, "phase": "work" }
}
```

#### Server → Client
```json
{
  "type": "office.member_status_changed",
  "data": {
    "officeId": "uuid",
    "userId": "uuid",
    "status": "in_focus",
    "timeRemaining": 1200
  }
}
```

## Тестирование

### Unit Tests
```bash
swift test
```

### UI Tests
Запустите UI тесты через Xcode Test Navigator (⌘+6)

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [x] Базовая архитектура проекта
- [x] Модели данных (SwiftData)
- [x] Сетевой слой (REST + WebSocket)
- [x] Аутентификация (Email/Password, Apple Sign In)
- [x] Pomodoro таймер с TCA
- [x] Виртуальные офисы
- [x] Design System
- [ ] Управление друзьями
- [ ] Уведомления
- [ ] Статистика с Charts
- [ ] Live Activities
- [ ] Widgets
- [ ] Apple Watch app
- [ ] CloudKit sync

## Лицензия

MIT License - see the [LICENSE](LICENSE) file for details

## Контакты

- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## Acknowledgments

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) от Point-Free
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) от Apple
- Pomodoro Technique® by Francesco Cirillo
