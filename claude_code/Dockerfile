ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
        bash \
        build-base \
        curl \
        git \
        github-cli \
        go \
        jq \
        nano \
        nodejs \
        npm \
        openssh-client \
        ripgrep \
        tmux \
        ttyd \
    && npm install -g @anthropic-ai/claude-code \
    && npm cache clean --force

# Claude Code на musl працює з системним ripgrep, а не з вбудованим.
# Go-модулі та кеш збірки лежать у /data, щоб не завантажувати їх після кожного перезапуску.
ENV USE_BUILTIN_RIPGREP=0 \
    TERM=xterm-256color \
    GOPATH=/data/go \
    GOCACHE=/data/.cache/go-build \
    PATH=/data/go/bin:${PATH}

COPY rootfs/ /
RUN chmod a+x /run.sh /usr/local/bin/claude-start /usr/local/bin/claude-storage

CMD ["/run.sh"]
