FROM mcr.microsoft.com/devcontainers/base:bullseye

RUN apt-get update \
  && apt-get install -y --no-install-recommends skopeo \
  && rm -rf /var/lib/apt/lists/*

COPY etc/containers/registries.conf /etc/containers/registries.conf

USER vscode

COPY *.sh /tmp/.
ENV PATH="/home/vscode/.local/bin:${PATH}"
RUN sudo chmod +x /tmp/*.sh \
  && /tmp/install-binary-manager.sh \
  && /tmp/install-dependencies.sh
