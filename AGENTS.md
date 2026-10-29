# AGENTS.md — ha-claude

Інструкції для AI-агентів (Claude Code та інших) і людей, які змінюють цей репозиторій.

## Що це

Доповнення Home Assistant OS **Claude Code**: чистий Claude Code у веб-терміналі HA з Remote Control
і постійним сховищем скілів і проєктів. Водночас це **база для похідних доповнень**:

```
ghcr.io/home-assistant/{arch}-base          (Alpine + bashio + s6)
        └── ghcr.io/anhoua/{arch}-addon-claude_code:<версія>          ← цей репозиторій
                └── ghcr.io/anhoua/{arch}-addon-claude_code_go_dev:<версія>   ← AnhoUA/ha-claude-go-dev
```

Похідні: [AnhoUA/ha-claude-go-dev](https://github.com/AnhoUA/ha-claude-go-dev) (Go, gh, SSH, git-налаштування).

## Головне правило: що належить базі

**База — це сам Claude і загальна робота доповнення. Інструменти розробки належать похідним.**

| Зміна | Куди |
|---|---|
| Встановлення чи оновлення Claude Code, Node.js | **база** |
| Веб-термінал (ttyd), tmux, `run.sh`, `claude-start` | **база** |
| Remote Control, `session_name`, `anthropic_api_key` | **база** |
| Постійне сховище (`claude-storage`, `storage_path`, симлінки скілів) | **база** |
| Доступ до HA (`map`, `homeassistant_api`, `ha_api`, ingress) | **база** |
| Мінімальні утиліти, потрібні будь-якому варіанту (`git`, `jq`, `curl`, `ripgrep`, `nano`) | **база** |
| Механізм хуків `init.d`, reusable workflow збирання | **база** |
| Мови та компілятори (Go, `build-base`…), `gh`, SSH, git-ідентичність і токени | **похідне** (go-dev) |
| Будь-які інші інструменти розробки | **похідне** або нове похідне |

Якщо сумніваєтеся, запитайте себе: «чи потрібно це людині, яка просто спілкується з Claude
про свій Home Assistant?» Якщо так, зміна йде в базу, якщо ні — у похідне.
Образ бази має лишатися мінімальним, бо його завантажують усі варіанти, зокрема на Raspberry Pi.

## Контракт для похідних (публічний API бази)

На ці речі спираються похідні доповнення. Змінюйте їх лише свідомо, як **breaking change**
(див. «Версії»), і одразу оновлюйте похідні.

| Контракт | Деталі |
|---|---|
| Імена образів | `ghcr.io/anhoua/{amd64,aarch64}-addon-claude_code:<версія>` |
| `CMD ["/run.sh"]` | похідні не задають власний `CMD` |
| Хуки `/etc/claude/init.d/*.sh` | `run.sh` підключає їх через `source` у алфавітному порядку **після** налаштування `HOME`, сховища, API-ключа й `safe.directory` і **до** старту tmux/Claude; доступні `bashio`, а експортовані змінні бачить Claude |
| Опції, які читає `run.sh` | `remote_control`, `session_name`, `storage_path`, `anthropic_api_key`. Похідні копіюють їх у свій `config.yaml`. **Нова обов'язкова опція в базі ламає похідні**, доки їх не оновлять |
| `HOME=/data`, `/homeassistant`, `storage_path` | шляхи, на які розраховують хуки й документація похідних |
| Reusable workflow | `.github/workflows/build.yaml`, `workflow_call` з входами `addon_dir` (обов'язковий) і `image_prefix`. Похідні викликають його через `@main`, тож **кожна зміна workflow одразу діє на всі репозиторії** |

## Як випустити нову версію

1. Змініть `claude_code/`.
2. Збільште `version` у `claude_code/config.yaml` (див. «Версії»).
3. Додайте розділ `## <версія>` на початок `claude_code/CHANGELOG.md`. Звідти береться опис релізу й текст у вікні оновлення HA.
4. Запуште зміни в `main`. CI перевірить лінтером, збере `amd64` і `aarch64` на нативних раннерах, опублікує образи (`:<версія>` і `:latest`) та створить тег `v<версія>` і GitHub Release.
5. **Оновіть похідні:** у кожному з них підніміть тег бази в `build.yaml`, синхронізуйте опції і випустіть нову версію (див. `AGENTS.md` у похідному репозиторії).

Кожна версія публікується лише один раз. Пуш змін у `claude_code/` без нової версії зламає CI.
Зміни лише в документації (`README.md`, цей файл) не запускають CI і не потребують нової версії.

### Версії (SemVer)

- **patch** (`0.4.0` → `0.4.1`): виправлення або свіжий Claude Code. Claude встановлюється з npm під час збирання, тож будь-яке нове збирання підтягує останню версію.
- **minor** (`0.4.x` → `0.5.0`): нові можливості й нові **необов'язкові** опції.
- **breaking** (зміни контракту вище): після `1.0.0` це major. Поки версія `0.x`, піднімайте minor і починайте запис у CHANGELOG з **BREAKING:**.

## Інваріанти

- `slug: claude_code` не змінюйте, бо це зламає встановлені копії в HA.
- Опції в `config.yaml` мають безпечні значення за замовчуванням, а нові опції краще робити необов'язковими (`str?`, `password?`).
- Секрети (`anthropic_api_key`) мають тип `password?`, і їхні значення ніколи не потрапляють у логи.
- Стан, що має переживати перезапуск, кладіть у `/data`. Те, що має переживати видалення доповнення, кладіть у `storage_path`.
- `claude-storage` ідемпотентний і **ніколи не видаляє** дані користувача: при конфліктах робить бекап `.bak-*`.
- Скрипти з `rootfs/` виконуються під busybox, тому перевіряйте прапорці (`cp -n` з `dir/.` там мовчки нічого не робить).
- Підтримуються лише `amd64` і `aarch64` (arm64: Raspberry Pi 4/5, HA Green/Yellow).

## Локальна перевірка перед пушем

```bash
cd claude_code
docker build \
  --build-arg BUILD_FROM=$(awk '$1=="amd64:" {print $2}' build.yaml) \
  --build-arg BUILD_ARCH=amd64 --build-arg BUILD_VERSION=dev \
  -t ghcr.io/anhoua/amd64-addon-claude_code:dev .

# інструменти на місці
docker run --rm --entrypoint bash ghcr.io/anhoua/amd64-addon-claude_code:dev \
  -c 'claude --version; claude --help | grep -c -- --remote-control; tmux -V; ttyd --version'

# сховище: ідемпотентність і перенесення наявних скілів
docker run --rm --entrypoint bash -e HOME=/data ghcr.io/anhoua/amd64-addon-claude_code:dev -c '
  mkdir -p /data/.claude/skills/x && echo hi > /data/.claude/skills/x/SKILL.md
  claude-storage /share/claude && claude-storage /share/claude && cat ~/.claude/skills/x/SKILL.md'

# лінтер workflow
docker run --rm -v "$PWD/..:/repo" -w /repo rhysd/actionlint:latest
```

**Як перевірити вплив на похідні до релізу.** Позначте локальний образ тегом, який очікує `build.yaml`
похідного (наприклад, `ghcr.io/anhoua/amd64-addon-claude_code:0.5.0`), і зберіть похідне
локально, як описано в його `AGENTS.md`.

## Публікація

- Пакети GHCR мають бути **публічними**, інакше HA отримає `denied`, а CI похідних отримає `403`.
  Перевірка: `docker buildx imagetools inspect ghcr.io/anhoua/<arch>-addon-claude_code:<версія>`.
- Видимість пакета змінюється лише в інтерфейсі GitHub: **Package settings → Change visibility**.
