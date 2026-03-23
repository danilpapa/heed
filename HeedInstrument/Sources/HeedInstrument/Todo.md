**1. Базовый UIControl (selector‑путь)**
- Swizzle `UIControl.sendAction(_:to:for:)` и логируй тип контрола + action + target.
- Это ловит `addTarget(_:action:for:)`.

**2. UIAction (addAction‑путь)**
- Swizzle `UIControl.addAction(_:for:)`.
- После добавления action добавляй скрытый target‑action на те же `UIControl.Event`, чтобы логировать именно событие, а не handler.
- Это даёт один лог на событие без костылей и без swizzle `UIAction` init.

**3. UITextField**
- Лови события `editingChanged`, `editingDidBegin`, `editingDidEnd`, `editingDidEndOnExit`.
- Можно через тот же путь `UIControl.addTarget` или через Notification:
  - `UITextField.textDidBeginEditingNotification`
  - `UITextField.textDidEndEditingNotification`
  - `UITextField.textDidChangeNotification`
- Для удобства логируй `text.count`, а не сам текст, чтобы не утекали данные.

**4. UITextView**
- Лови `textDidBeginEditing`, `textDidEndEditing`, `textDidChange` через `NotificationCenter`.

**5. UIGestureRecognizer**
- Swizzle `UIGestureRecognizer.init(target:action:)` и `addTarget(_:action:)`.
- Логируй тип жеста и состояние (`began/ended/changed`).

**6. UIBarButtonItem**
- Swizzle `UIBarButtonItem.init(title:style:target:action:)` и `init(image:style:target:action:)`.
- Логируй тап по бар‑кнопкам.

**7. UICommand / UIMenu**
- Для меню/клавиатуры ловить `UICommand` / `UIMenu` действия (это отдельный путь, не проходит через `UIControl`).

**8. Дедуп**
- Делай дедуп только по пути логирования, а не временем.
- Например: если событие пришло через `UIControl.sendAction`, то не логируй его повторно через `UIApplication`.

**9. Удобство для девелопера**
- Добавь конфиг: включить/выключить категории (`controls`, `text`, `gestures`, `menu`, `bar`).
- Добавь префикс/формат логов, чтобы копировать в баг‑репорты.

Если хочешь, могу сразу внедрить это в код: по шагам (начать с `UIControl + UIAction + UITextField/UITextView`), затем жесты и bar/menu.

