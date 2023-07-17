FROM node:18 as docker-compose
ENV VERSION=1.25.5
RUN curl -L -o /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-Linux-x86_64"
COPY docker-compose.sha256 /usr/local/bin/docker-compose.sha256
RUN sha256sum -c /usr/local/bin/docker-compose.sha256
RUN chmod +x /usr/local/bin/docker-compose

# https://docs.docker.com/install/linux/docker-ce/debian/
FROM node:18 as docker
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    lsb-release \
    software-properties-common
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
# RUN apt update -y
# COPY docker-public-key.asc /
# RUN apt-key add /docker-public-key.asc
# RUN add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/debian \
#    $(lsb_release -cs) \
#    stable"
RUN apt-get update && apt-get install -y docker-ce-cli

FROM node:18
COPY --from=docker /usr/bin/docker /usr/bin/docker
COPY --from=docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose

RUN docker -v
RUN docker-compose -v
