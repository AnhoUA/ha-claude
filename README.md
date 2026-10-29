# ha-claude

Доповнення для Home Assistant OS, яке запускає **Claude Code** у веб-терміналі в бічній панелі HA.

- Claude стартує разом із доповненням у режимі **Remote Control**, тож сесією можна керувати з claude.ai або мобільного застосунку Claude.
- Усередині є **Go** (з `gcc` для cgo), **git**, **GitHub CLI (`gh`)** і SSH-клієнт.
- Є доступ до конфігурації HA (`/homeassistant`), до `/share` і до HA API.
- **Постійне сховище** для скілів, агентів, команд, `CLAUDE.md` і проєктів, яке не залежить від контейнера.
- Логін, ключі й кеші зберігаються між перезапусками та оновленнями.

> Підтримувані архітектури: `amd64` (NUC, x86-ПК, віртуальні машини) і `aarch64` (Raspberry Pi 4/5, HA Green/Yellow). 32-бітні системи не підтримуються.

---

## Встановлення

### Спосіб 1: через репозиторій на GitHub (рекомендовано)

1. Завантажте цей проєкт у свій GitHub-репозиторій і впишіть його адресу в поле `url` у [`repository.yaml`](repository.yaml).
2. У Home Assistant відкрийте **Settings → Add-ons → Add-on Store**.
3. Натисніть **⋮** (праворуч угорі) → **Repositories**.
4. Вставте URL репозиторію, наприклад `https://github.com/AnhoUA/ha-claude`, і натисніть **Add**, потім **Close**.
5. Оновіть сторінку. Доповнення **Claude Code** з'явиться внизу списку.
6. Відкрийте його й натисніть **Install**. Перше встановлення займає 5–15 хвилин: HA збирає образ на місці.

Якщо репозиторій приватний, HA його не побачить. Тоді скористайтеся способом 2.

### Спосіб 2: локальне доповнення без GitHub

1. Встановіть доповнення **Samba share** або **Advanced SSH & Web Terminal**, щоб отримати доступ до файлів HAOS.
2. Скопіюйте папку [`claude_code`](claude_code) у `/addons/`, щоб вийшло `/addons/claude_code/config.yaml`.
   - Через Samba: `\\homeassistant.local\addons\claude_code`
   - Через SSH з комп'ютера: `scp -r claude_code root@homeassistant.local:/addons/`
3. **Settings → Add-ons → Add-on Store → ⋮ → Check for updates**.
4. Доповнення з'явиться в розділі **Local add-ons**. Відкрийте його й натисніть **Install**.

---

## Налаштування

Відкрийте вкладку **Configuration** доповнення:

| Опція | За замовчуванням | Опис |
|---|---|---|
| `remote_control` | `true` | Запускати Claude одразу з Remote Control |
| `session_name` | `Home Assistant` | Назва сесії в списку Remote Control |
| `storage_path` | `/share/claude` | Постійне сховище для скілів і проєктів. Має бути в `/share/...` або `/media/...` |
| `anthropic_api_key` | — | API-ключ Anthropic. Якщо його задано, Remote Control вимикається: він працює лише з підпискою claude.ai |
| `git_user_name` | — | `git config user.name` |
| `git_user_email` | — | `git config user.email` |
| `github_token` | — | Personal access token GitHub для `git push/pull` по HTTPS і для `gh` |

Збережіть налаштування й перезапустіть доповнення.

---

## Перший запуск

1. На вкладці **Info** увімкніть **Start on boot** і **Show in sidebar**, потім натисніть **Start**.
2. У бічній панелі HA відкрийте **Claude**.
3. Під час першого запуску Claude попросить увійти. Оберіть **Claude account with subscription**, відкрийте посилання в браузері, увійдіть і вставте код назад у термінал. Логін збережеться в `/data`, тож повторювати його не доведеться.
4. Після входу сесія з'явиться в Remote Control під назвою `Home Assistant`. Відкрийте її на [claude.ai/code](https://claude.ai/code) або в мобільному застосунку Claude.

Сесія працює в `tmux` і стартує разом із доповненням, тому Remote Control доступний навіть тоді, коли панель HA закрита. Якщо закрити Claude, у терміналі залишиться shell, і Claude можна запустити знову:

```bash
claude --remote-control "Home Assistant"
```

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
| Що там | скіли, агенти, команди, `CLAUDE.md`, проєкти | логін Claude, токени, `~/.ssh`, `~/.gitconfig`, історія сесій, Go-кеш |
| Після видалення доповнення | **залишається** | видаляється |
| Доступ із комп'ютера | так, через Samba: `\\homeassistant.local\share\claude` | ні |
| Видно іншим доповненням | так | ні |
| Потрапляє в бекапи HA | так (папка Share) | так (разом із доповненням) |

**Сховище на NAS.** Щоб зберігати все на мережевому диску, відкрийте **Settings → System → Storage → Add network storage**, оберіть **Usage: Share**, вкажіть назву, наприклад `nas`, і задайте `storage_path: /share/nas/claude`. Після перезапуску доповнення скіли й проєкти лежатимуть на NAS.

Скіли й проєкти зручно тримати під git, наприклад `cd /share/claude && git init`. Так їх можна синхронізувати з GitHub і з комп'ютером.

---

## Git і GitHub

Є три способи авторизуватися в GitHub. Усі дані зберігаються в `/data`.

**Токен у налаштуваннях.** Створіть [fine-grained token](https://github.com/settings/personal-access-tokens) з доступом до потрібних репозиторіїв і вставте його в `github_token`. Після перезапуску працюють і `git`, і `gh`.

**Вхід через `gh`.** У терміналі доповнення виконайте:
```bash
gh auth login
gh auth setup-git
```

**SSH-ключ.** Створіть ключ:
```bash
ssh-keygen -t ed25519 -C "ha-claude"
cat ~/.ssh/id_ed25519.pub
```
Потім додайте публічний ключ на GitHub у **Settings → SSH and GPG keys**.

Щоб тримати конфігурацію HA під git:
```bash
cd /homeassistant
git init
git remote add origin git@github.com:<логін>/ha-config.git
```
Обов'язково додайте `secrets.yaml`, `.storage/` і `*.db` у `.gitignore`.

---

## Go

Встановлено Go з пакетів Alpine разом із `build-base` для cgo. `GOPATH=/data/go` і кеш збірки зберігаються між перезапусками, а `go install` кладе бінарники в `/data/go/bin`, який уже додано в `PATH`.

```bash
go version
go install golang.org/x/tools/gopls@latest
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

Після змін у репозиторії збільште `version` у [`claude_code/config.yaml`](claude_code/config.yaml). HA запропонує оновлення, а образ перезбереться з найновішою версією Claude Code.
