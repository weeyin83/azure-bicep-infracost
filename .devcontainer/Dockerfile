FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG BICEP_VERSION=latest
ARG INFRACOST_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gh \
        jq \
        lsb-release \
        unzip \
        gnupg \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Bicep CLI
RUN if [ "$BICEP_VERSION" = "latest" ]; then \
        curl -fsSL https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 -o /usr/local/bin/bicep; \
    else \
        curl -fsSL "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-x64" -o /usr/local/bin/bicep; \
    fi \
    && chmod +x /usr/local/bin/bicep

# Install Infracost
RUN if [ "$INFRACOST_VERSION" = "latest" ]; then \
        curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh; \
    else \
        curl -fsSL "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz" -o /tmp/infracost.tar.gz \
        && tar -xzf /tmp/infracost.tar.gz -C /tmp \
        && mv /tmp/infracost-linux-amd64 /usr/local/bin/infracost \
        && chmod +x /usr/local/bin/infracost; \
    fi

# Install common Azure dev tools
RUN az bicep install && az version >/dev/null

# Set a workspace directory
WORKDIR /workspaces

# Ensure the default non-root user can use the CLI tools
RUN chown -R vscode:vscode /workspaces

CMD ["bash"]
