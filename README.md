# ha-claude

Доповнення для Home Assistant OS, яке запускає **Claude Code** у веб-терміналі в бічній панелі HA.

- Claude стартує разом із доповненням у режимі **Remote Control**, тож сесією можна керувати з claude.ai або мобільного застосунку Claude.
- Є доступ до конфігурації HA (`/homeassistant`), до `/share` і до HA API.
- **Постійне сховище** для скілів, агентів, команд, `CLAUDE.md` і проєктів, яке не залежить від контейнера.
- Логін Claude зберігається між перезапусками та оновленнями.
- Мінімальний образ: тільки Claude Code, `git`, `ripgrep`, `jq`, `curl` і `nano`. Додаткові інструменти дають похідні доповнення.

### Варіанти

| Доповнення | Репозиторій | Що всередині |
|---|---|---|
| **Claude Code** | [AnhoUA/ha-claude](https://github.com/AnhoUA/ha-claude) (цей) | чистий Claude Code |
| **Claude Code Go Dev** | [AnhoUA/ha-claude-go-dev](https://github.com/AnhoUA/ha-claude-go-dev) | усе з Claude Code, а також Go, `gh`, SSH і налаштування git |

> Підтримувані архітектури: `amd64` (NUC, x86-ПК, віртуальні машини) і `aarch64` (Raspberry Pi 4/5, HA Green/Yellow). 32-бітні системи не підтримуються.

---

## Встановлення

### Спосіб 1: через репозиторій на GitHub (рекомендовано)

[![Додати репозиторій у Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FAnhoUA%2Fha-claude)

1. У Home Assistant відкрийте **Settings → Add-ons → Add-on Store**.
2. Натисніть **⋮** (праворуч угорі) → **Repositories**.
3. Вставте `https://github.com/AnhoUA/ha-claude` і натисніть **Add**, потім **Close**.
4. Оновіть сторінку. Доповнення **Claude Code** з'явиться внизу списку.
5. Відкрийте його й натисніть **Install**. HA завантажить готовий образ для вашої архітектури з GHCR, на що піде хвилина-дві.

### Спосіб 2: локальне доповнення без GitHub

1. Встановіть доповнення **Samba share** або **Advanced SSH & Web Terminal**, щоб отримати доступ до файлів HAOS.
2. Скопіюйте папку [`claude_code`](claude_code) у `/addons/`, щоб вийшло `/addons/claude_code/config.yaml`.
   - Через Samba: `\\homeassistant.local\addons\claude_code`
   - Через SSH з комп'ютера: `scp -r claude_code root@homeassistant.local:/addons/`
3. **Settings → Add-ons → Add-on Store → ⋮ → Check for updates**.
4. Доповнення з'явиться в розділі **Local add-ons**. Відкрийте його й натисніть **Install**.

Щоб локальна копія збиралася з `Dockerfile` прямо на пристрої, а не завантажувала готовий образ, видаліть рядок `image:` з `/addons/claude_code/config.yaml`. Збирання займає 5–15 хвилин.

---

## Налаштування

Відкрийте вкладку **Configuration** доповнення:

| Опція | За замовчуванням | Опис |
|---|---|---|
| `remote_control` | `true` | Запускати Claude одразу з Remote Control |
| `session_name` | `Home Assistant` | Назва сесії в списку Remote Control |
| `storage_path` | `/share/claude` | Постійне сховище для скілів і проєктів. Має бути в `/share/...` або `/media/...` |
| `anthropic_api_key` | — | **Необов'язкова**, прихована під *Show unused optional configuration options*. Без неї Claude працює з вашою підпискою claude.ai. Якщо ключ задано, Remote Control вимикається, бо працює лише з підпискою |

Збережіть налаштування й перезапустіть доповнення.

---

## Перший запуск

1. На вкладці **Info** увімкніть **Start on boot** і **Show in sidebar**, потім натисніть **Start**.
2. У бічній панелі HA відкрийте **Claude**.
3. Під час першого запуску Claude попросить увійти. Оберіть **Claude account with subscription**. Клікніть посилання для входу прямо в терміналі. Воно також приходить **сповіщенням у Home Assistant** (дзвіночок унизу бічної панелі) і з'являється одним рядком на вкладці **Log** доповнення. Відкрийте його, увійдіть, скопіюйте код, вставте його в термінал і натисніть Enter. Логін збережеться в `/data`, тож повторювати його не доведеться.
4. Після входу сесія з'явиться в Remote Control під назвою `Home Assistant`. Відкрийте її на [claude.ai/code](https://claude.ai/code) або в мобільному застосунку Claude.

Сесія працює в `tmux` і стартує разом із доповненням, тому Remote Control доступний навіть тоді, коли панель HA закрита. Якщо закрити Claude, у терміналі залишиться shell, і Claude можна запустити знову:

```bash
claude --remote-control "Home Assistant"
```

### Копіювання та виділення в терміналі

Текст виділяється звичайним протягуванням мишею, копіюється через Cmd+C або Ctrl+C і вставляється через Cmd+V або Ctrl+V. Прокручувати можна коліщатком.

Посилання для входу в Claude довге й у терміналі розбивається на кілька рядків. **Не копіюйте його виділенням**, бо у скопійований текст потраплять переноси рядків і вхід завершиться помилкою «Невідома область: user:mcp_». Натомість:
- **клікніть посилання прямо в терміналі**, по будь-якому його рядку, і підтвердіть перехід: відкриється повний URL;
- або відкрийте сповіщення під дзвіночком у HA, де посилання клікабельне;
- або перейдіть на вкладку **Log** доповнення: там посилання одним рядком після `[claude-login]`.

---

## Постійне сховище: скіли та проєкти

Усе, що ви створюєте, зберігається поза контейнером, у `storage_path` (типово `/share/claude`):

```
/share/claude/
├── CLAUDE.md     # глобальні інструкції для Claude (~/.claude/CLAUDE.md)
├── skills/       # ваші скіли (~/.claude/skills)
├── agents/       # субагенти (~/.claude/agents)
├── commands/     # slash-команди (~/.claude/commands)
└── projects/     # робочі проєкти (~/projects)
```

У `~/.claude` на ці теки ведуть симлінки, тож Claude знаходить скіли автоматично. Скіл — це тека з файлом `SKILL.md`, наприклад `/share/claude/skills/ha-automations/SKILL.md`. Його можна написати самому або попросити Claude: «створи скіл для …».

Чим це сховище відрізняється від `/data`:

| | `/share/claude` | `/data` (`$HOME`) |
|---|---|---|
| Що там | скіли, агенти, команди, `CLAUDE.md`, проєкти | логін Claude, історія сесій, `~/.gitconfig` |
| Після видалення доповнення | **залишається** | видаляється |
| Спільне для всіх варіантів | так: Claude Code і Go Dev бачать ті самі скіли | ні, у кожного доповнення свій |
| Доступ із комп'ютера | так, через Samba: `\\homeassistant.local\share\claude` | ні |
| Видно іншим доповненням | так | ні |
| Потрапляє в бекапи HA | так (папка Share) | так (разом із доповненням) |

**Сховище на NAS.** Щоб зберігати все на мережевому диску, відкрийте **Settings → System → Storage → Add network storage**, оберіть **Usage: Share**, вкажіть назву, наприклад `nas`, і задайте `storage_path: /share/nas/claude`. Після перезапуску доповнення скіли й проєкти лежатимуть на NAS.

Скіли й проєкти зручно тримати під git, наприклад `cd /share/claude && git init`. Так їх можна синхронізувати з GitHub і з комп'ютером.

---

## Похідні доповнення

Правила, що належить базі, а що похідним, контракт для похідних і процес випуску описано в [`AGENTS.md`](AGENTS.md). Claude Code підхоплює їх автоматично через `CLAUDE.md`.

Образ `ghcr.io/anhoua/{arch}-addon-claude_code:<версія>` задуманий як база для інших доповнень. Так побудовано [ha-claude-go-dev](https://github.com/AnhoUA/ha-claude-go-dev). Щоб зробити власний варіант:

1. **`build.yaml`:** вкажіть базою потрібну версію ha-claude:
   ```yaml
   build_from:
     aarch64: ghcr.io/anhoua/aarch64-addon-claude_code:0.4.0
     amd64: ghcr.io/anhoua/amd64-addon-claude_code:0.4.0
   ```
2. **`Dockerfile`:** використайте `FROM ${BUILD_FROM}`, додайте пакети через `apk add` і скопіюйте `rootfs/`. Задавати `CMD` не потрібно, він успадковується.
3. **Хуки запуску:** покладіть скрипти в `rootfs/etc/claude/init.d/NN-назва.sh`. `run.sh` підключає їх через `source` перед стартом Claude, тож у них доступні `bashio::config` і `$HOME=/data`, а все, що вони експортують, побачить Claude.
4. **`config.yaml`:** скопіюйте всі опції базового доповнення (`remote_control`, `session_name`, `storage_path`, `anthropic_api_key`), бо їх читає `run.sh`. Після них додайте свої.
5. **CI:** викличте workflow з цього репозиторію:
   ```yaml
   jobs:
     build:
       uses: AnhoUA/ha-claude/.github/workflows/build.yaml@main
       permissions:
         contents: write
         packages: write
       with:
         addon_dir: <тека доповнення>
   ```

---

## Що доступно всередині

| Шлях / змінна | Що це |
|---|---|
| `/homeassistant` | конфігурація HA (читання й запис) |
| `/share/claude` | постійне сховище: скіли й проєкти (`storage_path`) |
| `~/projects` | симлінк на `/share/claude/projects` |
| `/share`, `/media` | спільні папки HA, зокрема мережеві диски |
| `/data` | домашня тека (`$HOME`), зберігається між перезапусками |
| `$SUPERVISOR_TOKEN` | токен для HA API через `http://supervisor/core/api/` |
| `ha_api <шлях>` | обгортка над curl, наприклад `ha_api states` |

> **Увага:** Claude має право запису в конфігурацію HA. Перед великими змінами робіть резервні копії (**Settings → System → Backups**) або тримайте `/homeassistant` під git.

## Оновлення

Образи збирає GitHub Actions ([`.github/workflows/build.yaml`](.github/workflows/build.yaml)) на нативних раннерах для `amd64` і `aarch64`.

### Як випустити нову версію

1. Внесіть зміни в `claude_code/`.
2. Збільште `version` у [`claude_code/config.yaml`](claude_code/config.yaml) за [SemVer](https://semver.org/lang/uk/): `0.3.0` → `0.3.1` для виправлень, `0.4.0` для нових можливостей, `1.0.0` для несумісних змін.
3. Додайте розділ `## <версія>` у [`claude_code/CHANGELOG.md`](claude_code/CHANGELOG.md). HA показує його у вікні оновлення, а workflow бере звідти нотатки до релізу.
4. Запуште зміни в `main`. Workflow:
   - перевірить доповнення лінтером;
   - збере й опублікує `ghcr.io/anhoua/{amd64,aarch64}-addon-claude_code:<версія>` (і `:latest`);
   - створить git-тег `v<версія>` і GitHub Release.
5. У HA з'явиться оновлення, і користувачі завантажать новий образ.

Кожна версія публікується лише один раз. Якщо запушити зміни в `claude_code/` без нової версії, workflow впаде з підказкою збільшити `version`. У pull request-ах образи збираються без публікації, щоб перевірити, що збирання проходить.

Під час кожного збирання встановлюється найновіший Claude Code, доступний на той момент. Щоб оновити Claude Code в образі, достатньо випустити нову патч-версію доповнення.

### GHCR: пакети мають бути публічними

Після першого успішного запуску відкрийте **github.com/orgs/AnhoUA/packages**. Для кожного з пакетів `amd64-addon-claude_code` і `aarch64-addon-claude_code` зайдіть у **Package settings → Change visibility → Public**. Без цього HA не зможе завантажити образ, а CI похідних доповнень не зможе зібратися на його основі. Це потрібно зробити один раз.
