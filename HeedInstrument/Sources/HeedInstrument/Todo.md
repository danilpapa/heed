**4. UITextView**
- Лови `textDidBeginEditing`, `textDidEndEditing`, `textDidChange` через `NotificationCenter`.

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

