# Heed Project Knowledge

## Что это за проект

Проект состоит из двух основных частей:

- `HeedInstrument` — Swift Package, который инструментирует iOS-приложение через runtime swizzling и логирует пользовательские и системные события.
- `HeedSandbox` — демо-приложение, в котором можно руками проверить, какие события ловит `HeedInstrument`.

По сути `HeedInstrument` — это lightweight SDK для наблюдения за поведением интерфейса, навигации, клавиатуры, сетевых запросов и частью lifecycle приложения.

---

## Общая архитектура

### 1. Точка входа SDK

SDK запускается через:

- `HeedInstrument/Sources/HeedInstrument/HeedInstrument.swift`

Этот файл:

- регистрирует набор swizzling-модулей через `Heed.invoke { ... }`
- запускает дополнительные observers, например для клавиатуры и lifecycle
- предоставляет публичные entry points SDK

### 2. Механизм подключения swizzling

Базовая инфраструктура swizzling находится в:

- `HeedInstrument/Sources/HeedInstrument/Protocols/IHeedSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Helper/SwizzledBuilder.swift`

Идея простая:

- каждый swizzling-модуль реализует `IHeedSwizzling`
- у него есть `static func enable()`
- `Heed.invoke` собирает эти типы и включает их по очереди

### 3. Модель события

Модель события сейчас очень простая:

- `HeedInstrument/Sources/HeedInstrument/Model/EventLog.swift`

Событие содержит:

- `timestamp`
- `category`
- `eventType`
- `duration`
- `detail`

Это довольно минималистичный формат. В проекте пока нет сложной схемы с `sessionId`, `traceId`, privacy flags или typed attributes.

`EventLog` реализует `Codable` — нужно для JSON-сериализации при отправке через `UDPExporter`.

### 4. Логгер

Главный sink логов:

- `HeedInstrument/Sources/HeedInstrument/Logger/EventLogger.swift`

События идут в консоль через `print(...)` и опционально в `HeedExporter`, если он подключён.

### 5. Export layer

Отдельный слой экспорта событий наружу:

- `HeedInstrument/Sources/HeedInstrument/Export/HeedExporter.swift` — протокол `HeedExporter: Sendable` с методом `export(_ event: EventLog)`
- `HeedInstrument/Sources/HeedInstrument/Export/UDPExporter.swift` — реализация, отправляет каждое событие как JSON-пакет по UDP на указанный `host:port`

`UDPExporter` использует `NWConnection` из `Network` framework. Соединение открывается один раз при `init`, отправка — fire-and-forget через `.idempotent`.

Подключается через:
```swift
HeedInstrument.start(exporter: UDPExporter(host: "127.0.0.1", port: 9876))
```

### 6. CLI инструмент (heed-cli)

Отдельный Go-проект вне iOS репозитория (`~/heed-cli`).

Слушает UDP-порт, принимает JSON-события от `UDPExporter`, pretty-print выводит в терминал.

Запуск:
```bash
go run main.go --port 9876 --filter Network
```

Структура события в Go:
```go
type EventLog struct {
    Timestamp time.Time
    Category  string
    EventType string
    Duration  float64
    Detail    string
}
```

---

## Какие события уже поддерживает SDK

### UIControl / UIButton

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIControl+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIButton/UIButtonSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIControl/UIControlAddActionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAction/UIActionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAction/UIAction+.swift`

Что логируется:

- нажатия на `UIControl`
- selector-based actions
- `UIAction`
- события, добавленные через `addAction`

### UITextField

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITextField/UITextFieldSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITextField/UITextField+.swift`

Что логируется:

- `editingDidBegin`
- `editingChanged`
- `editingDidEnd`
- `editingDidEndOnExit`

Логирование бережное: фиксируется не сам текст, а в основном `text.count`.

### UIGestureRecognizer

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIGestureRecognizer/UIGestureRecognizerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIGestureRecognizer/UIGestureRecognizer+.swift`

Что логируется:

- тип gesture recognizer
- переходы по состояниям, например `changed`, `ended`

### UITableView

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITableView/UITableViewSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITableView/UITableView+Instrumented.swift`

Что логируется:

- выбор ячейки `didSelectRowAt`
- часть scroll-related событий через delegate proxy

### UINavigationController

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UINavigationController/UINavigationControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UINavigationController/UINavigationController+.swift`

Что логируется:

- `push`
- `pop`
- `popToRoot`
- `popTo`

### UIViewController

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIViewController/UIViewControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIViewController/UIViewController+.swift`

Что логируется:

- `viewDidLoad`
- `viewWillAppear`
- `viewDidAppear`
- `viewWillDisappear`
- `viewDidDisappear`
- `present`
- `screenView`
- `screenVisibleDuration`

Это один из важнейших блоков в SDK, потому что через него строится карта экранов и навигации.

### UIAlertController

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAlertController/UIAlertControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAlertController/UIAlertController+.swift`

Что логируется:

- показ alert/action sheet
- нажатие на action внутри alert

### URLSession / Network

Основные файлы:

- `HeedInstrument/Sources/HeedInstrument/Swizzling/URLSession/URLSessionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/URLSession/URLSession+.swift`

Что логируется:

- сетевые запросы через `URLSession.dataTask`
- method, url, path
- статус
- длительность
- часть response/body
- сетевой результат

По моему предыдущему анализу и эволюции проекта, это одна из самых чувствительных областей, потому что именно тут быстрее всего возникают privacy-риски.

### Keyboard

Основной файл:

- `HeedInstrument/Sources/HeedInstrument/Keyboard/KeyboardObserver.swift`

Что логируется:

- `keyboardWillShow`
- `keyboardWillHide`
- `keyboardWillChangeFrame`

### App lifecycle / performance

Основной файл:

- `HeedInstrument/Sources/HeedInstrument/Lifecycle/AppLifecycleObserver.swift`

Что логируется:

- базовые app lifecycle события
- часть performance событий, например первый показ экрана

---

## Что я знаю о текущем состоянии SDK

### Сильные стороны

- Архитектура простая и понятная.
- Очень низкий порог входа: достаточно вызвать `HeedInstrument.start()`.
- Покрытие UIKit уже довольно широкое.
- Хороший sandbox для ручной проверки гипотез.
- Удобная модель расширения: можно добавить новый swizzling-модуль без полного рефакторинга SDK.

### Ограничения текущего подхода

- Основа проекта — runtime swizzling, а это всегда чувствительная техника.
- Логирование уходит в консоль и опционально во внешний `HeedExporter`.
- Нет полноценной конфигурации SDK.
- Есть начальное разделение на capture layer и export layer, но нет processing pipeline, storage layer.
- Мало или нет автоматических тестов.
- В сетевом слое возможны privacy/security риски, если логируются body, query, response.
- Некоторые реализации могут опираться на хрупкие runtime-детали UIKit/Foundation.

### Общая оценка зрелости

Сейчас проект выглядит как хороший foundation для SDK и сильный инженерный prototype, но ещё не как fully production-ready observability SDK.

---

## Самые основные файлы в HeedInstrument

Ниже список файлов, которые я считаю самыми важными для понимания `HeedInstrument`.

### Базовый вход и инфраструктура

- `HeedInstrument/Package.swift`
- `HeedInstrument/Sources/HeedInstrument/HeedInstrument.swift`
- `HeedInstrument/Sources/HeedInstrument/Protocols/IHeedSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Helper/SwizzledBuilder.swift`
- `HeedInstrument/Sources/HeedInstrument/Model/EventLog.swift`
- `HeedInstrument/Sources/HeedInstrument/Logger/EventLogger.swift`

### Export layer

- `HeedInstrument/Sources/HeedInstrument/Export/HeedExporter.swift`
- `HeedInstrument/Sources/HeedInstrument/Export/UDPExporter.swift`

### UI instrumentation

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIControl+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIButton/UIButtonSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIControl/UIControlAddActionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAction/UIActionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAction/UIAction+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITextField/UITextFieldSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITextField/UITextField+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIGestureRecognizer/UIGestureRecognizerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIGestureRecognizer/UIGestureRecognizer+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITableView/UITableViewSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UITableView/UITableView+Instrumented.swift`

### Навигация и экраны

- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIViewController/UIViewControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIViewController/UIViewController+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UINavigationController/UINavigationControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UINavigationController/UINavigationController+.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAlertController/UIAlertControllerSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/UIAlertController/UIAlertController+.swift`

### Сеть, клавиатура, lifecycle

- `HeedInstrument/Sources/HeedInstrument/Swizzling/URLSession/URLSessionSwizzling.swift`
- `HeedInstrument/Sources/HeedInstrument/Swizzling/URLSession/URLSession+.swift`
- `HeedInstrument/Sources/HeedInstrument/Keyboard/KeyboardObserver.swift`
- `HeedInstrument/Sources/HeedInstrument/Lifecycle/AppLifecycleObserver.swift`

---

## Что я знаю о HeedSandbox

`HeedSandbox` — это демонстрационное iOS-приложение, которое нужно для ручной проверки instrumentation-поведения.

### Основные файлы приложения

- `HeedSandbox/HeedSandbox.xcodeproj/project.pbxproj`
- `HeedSandbox/HeedSandbox/Application/AppDelegate.swift`
- `HeedSandbox/HeedSandbox/Application/SceneDelegate.swift`
- `HeedSandbox/HeedSandbox/Application/DemoListViewController.swift`

### Важные demo-экраны

- `HeedSandbox/HeedSandbox/Heeding/ButtonsViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/TextFieldsViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/AdvancedTextInputsViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/GesturesViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/ScrollViewViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/CollectionDemoViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/NavigationStackViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/ModalTestViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/NetworkDemoViewController.swift`
- `HeedSandbox/HeedSandbox/Heeding/LifecycleAndErrorsViewController.swift`

### Как используется SDK внутри sandbox

Самое важное:

- `HeedInstrument.start()` вызывается при старте приложения
- дальше пользователь проходит по demo-экранам
- SDK печатает события в лог

---

## Какая у проекта инженерная идея

Идея проекта выглядит так:

1. Не просить интегратора вручную обвешивать весь UI аналитикой.
2. Снимать значимую часть сигналов автоматически через UIKit/Foundation hooks.
3. Использовать sandbox как лабораторию для проверки покрытия событий.
4. Постепенно эволюционировать это в production-ready SDK.

---

## Во что проект логично развивать дальше

Если смотреть стратегически, следующие крупные шаги для проекта такие:

- добавить `HeedConfiguration`
- ввести privacy/redaction rules
- ~~отделить capture от export~~ — сделано: `HeedExporter` протокол + `UDPExporter`
- добавить storage/batching/offline queue
- ~~сделать нормальный exporter вместо одного `print`~~ — сделано: `UDPExporter` + `heed-cli`
- покрыть ключевые swizzling-сценарии тестами
- ввести более строгую схему событий
- добавить защиту от конфликтов swizzling и повторного enable
- развивать `heed-cli`: фильтрация, форматы вывода, сохранение сессий в файл

---

## Краткий итог

`HeedInstrument` — это SDK для автоматического перехвата событий iOS-приложения через swizzling. Основной фокус проекта — UI, navigation, keyboard, network и lifecycle instrumentation. `HeedSandbox` служит тестовым приложением для проверки этих сценариев. Архитектура уже достаточно понятная и расширяемая, а самые важные файлы сосредоточены вокруг `HeedInstrument.swift`, `EventLog.swift`, `EventLogger.swift` и папки `Swizzling`.

Добавлен export layer: `HeedExporter` протокол и `UDPExporter`, который отправляет события в реальном времени по UDP как JSON. Отдельный Go CLI (`heed-cli`) принимает эти события и выводит их в терминале с возможностью фильтрации.
