#!/usr/bin/with-contenv bashio
set -e

# /data переживає перезапуски й оновлення: там лежать логін Claude та історія сесій
export HOME=/data
mkdir -p "${HOME}"
cp -n /etc/claude/bashrc "${HOME}/.bashrc" 2>/dev/null || true

STORAGE_PATH="$(bashio::config 'storage_path')"
/usr/local/bin/claude-storage "${STORAGE_PATH}"
bashio::log.info "Скіли й проєкти зберігаються в ${STORAGE_PATH}"

if bashio::config.has_value 'anthropic_api_key'; then
    export ANTHROPIC_API_KEY="$(bashio::config 'anthropic_api_key')"
    bashio::log.info "Використовується ANTHROPIC_API_KEY з налаштувань"
fi

# Конфігурація HA належить іншому користувачу, тож без цього git відмовляється з нею працювати
git config --global --replace-all safe.directory '*'

# Розширення від похідних доповнень. Скрипти виконуються в цьому ж shell,
# тож мають доступ до bashio і можуть експортувати змінні для Claude.
for hook in /etc/claude/init.d/*.sh; do
    [ -f "${hook}" ] || continue
    bashio::log.info "init.d: $(basename "${hook}")"
    # shellcheck source=/dev/null
    source "${hook}"
done

# --- Claude у tmux ---
export CLAUDE_REMOTE_CONTROL="$(bashio::config 'remote_control')"
export CLAUDE_SESSION_NAME="$(bashio::config 'session_name')"

# Сесія стартує разом із доповненням, тож Remote Control доступний одразу,
# навіть якщо панель у Home Assistant ще не відкривали
tmux new-session -d -s claude -c /homeassistant /usr/local/bin/claude-start

bashio::log.info "Запуск веб-термінала на порту 7681"
exec ttyd -W -p 7681 -t fontSize=14 -t disableLeaveAlert=true \
    tmux new-session -A -s claude -c /homeassistant bash
