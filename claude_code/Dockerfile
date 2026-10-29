ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_VERSION
LABEL io.hass.type="addon" \
      io.hass.arch="${BUILD_ARCH}" \
      io.hass.version="${BUILD_VERSION}" \
      io.hass.name="Claude Code"

RUN apk add --no-cache \
        bash \
        curl \
        git \
        jq \
        nano \
        nodejs \
        npm \
        ripgrep \
        tmux \
        ttyd \
    && npm install -g @anthropic-ai/claude-code \
    && npm cache clean --force

# Claude Code на musl працює з системним ripgrep, а не з вбудованим
ENV USE_BUILTIN_RIPGREP=0 \
    TERM=xterm-256color

# Образ слугує базою для похідних доповнень (наприклад, ha-claude-go-dev):
# вони додають свої скрипти в /etc/claude/init.d/, а run.sh виконує їх перед стартом Claude
COPY rootfs/ /
RUN chmod a+x /run.sh /usr/local/bin/claude-start /usr/local/bin/claude-storage \
        /usr/local/bin/claude-login-notify \
    && mkdir -p /etc/claude/init.d

CMD ["/run.sh"]
