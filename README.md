# Вариант 2. QuestWay

Веб-приложение на Python 3.12, Django 5.2.19, SQLite, HTML5, CSS3 и JavaScript ES6+. Вариант хранится в собственном Git-репозитории. Шрифты, изображения и скрипты загружаются локально.

## Запуск

Выполните в папке репозитория. Команда `demo` создаёт учебные записи при первом запуске. В QuestWay она также пополняет расписание от текущей даты.

```powershell
uv run --python 3.12 --with-requirements requirements.txt manage.py migrate
uv run --python 3.12 --with-requirements requirements.txt manage.py demo
uv run --python 3.12 --with-requirements requirements.txt manage.py runserver 127.0.0.1:8002
```

На Windows для установки без интернета используйте Python 3.12 и каталог `offline_wheels/` из общего пакета.

```powershell
uv venv --offline --python 3.12 .venv
uv pip install --python .venv\Scripts\python.exe --no-index --find-links ../offline_wheels -r requirements.txt
.venv\Scripts\python.exe manage.py migrate
.venv\Scripts\python.exe manage.py demo
.venv\Scripts\python.exe manage.py runserver 127.0.0.1:8002
```

- [Главная](http://127.0.0.1:8002/)
- [Вход](http://127.0.0.1:8002/login/)
- [Макет модуля 4](http://127.0.0.1:8002/ui-kit-prototype.html)
- Демо-пользователь — `demo2026` / `Demo2026!`.
- Демо-администратор — `Admin` / `33HjpGfy`.

## Состав

- `portal/core_models.py`, `portal/models.py` — модели и ограничения БД.
- `portal/forms.py`, `portal/domain_forms.py` — общая и предметная валидация.
- `portal/views.py`, `portal/security.py` — классовые представления и контроль ролей.
- `database.sql` — структура и демонстрационные данные предметной области. Для штатной инициализации приложения используйте миграции и `demo`. Служебные таблицы сеансов и миграций создаёт Django.
- `schema.sql`, `schema.json`, `er_diagram.png` — DDL, метаданные SQLite и диаграмма.
- `design/` — материалы Модуля 4.
- `MEDIA.md` — происхождение, размеры и оптимизация изображений.

## Проверка

```powershell
uv run --python 3.12 --with-requirements requirements.txt manage.py test
uv run --python 3.12 --with-requirements requirements.txt manage.py makemigrations --check --dry-run
```

Из корня общего пакета скриншоты можно переснять командой `uv run --python 3.12 --with Django==5.2.19 --with playwright qa/capture.py 2` после установки Chromium для Playwright.
