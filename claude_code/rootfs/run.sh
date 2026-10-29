#!/usr/bin/with-contenv bashio
set -e

# /data переживає перезапуски й оновлення: там лежать логін Claude, ~/.ssh, ~/.gitconfig, gh і Go-кеш
export HOME=/data
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
cp -n /etc/claude/bashrc "${HOME}/.bashrc" 2>/dev/null || true

STORAGE_PATH="$(bashio::config 'storage_path')"
/usr/local/bin/claude-storage "${STORAGE_PATH}"
bashio::log.info "Скіли й проєкти зберігаються в ${STORAGE_PATH}"

if bashio::config.has_value 'anthropic_api_key'; then
    export ANTHROPIC_API_KEY="$(bashio::config 'anthropic_api_key')"
    bashio::log.info "Використовується ANTHROPIC_API_KEY з налаштувань"
fi

# --- git ---
if bashio::config.has_value 'git_user_name'; then
    git config --global user.name "$(bashio::config 'git_user_name')"
fi
if bashio::config.has_value 'git_user_email'; then
    git config --global user.email "$(bashio::config 'git_user_email')"
fi
git config --global --add safe.directory '*'
if bashio::config.has_value 'github_token'; then
    export GH_TOKEN="$(bashio::config 'github_token')"
    gh auth setup-git
    bashio::log.info "GitHub: використовується github_token з налаштувань"
fi

# --- Claude у tmux ---
export CLAUDE_REMOTE_CONTROL="$(bashio::config 'remote_control')"
export CLAUDE_SESSION_NAME="$(bashio::config 'session_name')"

# Сесія стартує разом із доповненням, тож Remote Control доступний одразу,
# навіть якщо панель у Home Assistant ще не відкривали
tmux new-session -d -s claude -c /homeassistant /usr/local/bin/claude-start

bashio::log.info "Запуск веб-термінала на порту 7681"
exec ttyd -W -p 7681 -t fontSize=14 -t disableLeaveAlert=true \
    tmux new-session -A -s claude -c /homeassistant bash
