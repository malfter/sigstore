FROM mcr.microsoft.com/devcontainers/base:bullseye

RUN apt-get update \
  && apt-get install -y --no-install-recommends skopeo \
  && rm -rf /var/lib/apt/lists/*

COPY etc/containers/registries.conf /etc/containers/registries.conf

# Install k8s tools
# - k3d     - https://k3d.io/stable/#releases
# - helm    - https://helm.sh/docs/intro/install/
# - kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# - k9s     - https://github.com/derailed/k9s
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash \
  && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
  && curl -sS https://webinstall.dev/k9s | bash

USER vscode

COPY *.sh /tmp/.
ENV PATH="/home/vscode/.local/bin:${PATH}"
RUN sudo chmod +x /tmp/*.sh \
  && /tmp/install-binary-manager.sh \
  && /tmp/install-dependencies.sh
