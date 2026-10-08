FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools and iptables/ipset
# (Brotato additions: python3/pipx for gdtoolkit, zip for packaging)
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  zip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  python3 \
  pipx \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# --- Brotato modding tools ---------------------------------------------------
# Godot 3.x headless for CLI validation/export. Must match the engine of Brotato.pck
# (Brotato 1.1.15.4 = "3.7.dev.custom_build"). GODOT_VERSION is a godot-builds release tag, e.g. 3.7-dev1 or 3.6.3-stable.
ARG GODOT_VERSION=3.7-dev1
RUN cd /tmp && \
  base="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}" && \
  file="Godot_v${GODOT_VERSION}_linux_headless.64.zip" && \
  wget -q "${base}/${file}" "${base}/SHA512-SUMS.txt" && \
  grep " ${file}$" SHA512-SUMS.txt | sha512sum -c - && \
  unzip -q "${file}" -d /tmp/godot && \
  mv "/tmp/godot/Godot_v${GODOT_VERSION}_linux_headless.64" /usr/local/bin/godot && \
  chmod +x /usr/local/bin/godot && \
  rm -rf /tmp/godot "/tmp/${file}" /tmp/SHA512-SUMS.txt

# gdtoolkit 3.x = gdlint/gdformat for GDScript 3 (Godot 3.x)
# gdtoolkit 3 imports pkg_resources, which newer setuptools no longer ships
ARG GDTOOLKIT_VERSION=3.*
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install "gdtoolkit==${GDTOOLKIT_VERSION}" && \
  PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx inject gdtoolkit "setuptools<81"
ENV PYTHONWARNINGS="ignore:pkg_resources is deprecated:UserWarning"
# -----------------------------------------------------------------------------

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}


# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node
