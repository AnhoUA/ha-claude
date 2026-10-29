# Changelog

## 0.3.0

- Перший публічний реліз.
- Claude Code у веб-терміналі в бічній панелі HA (ttyd + tmux).
- Claude стартує одразу в режимі Remote Control (`remote_control`, `session_name`).
- Go з `build-base`, git, GitHub CLI та SSH-клієнт; опції `git_user_name`, `git_user_email`, `github_token`.
- Постійне сховище `storage_path` (типово `/share/claude`) для скілів, агентів, команд, `CLAUDE.md` і проєктів.
- Готові образи для `amd64` і `aarch64` у GHCR: HA завантажує їх, а не збирає на пристрої.
