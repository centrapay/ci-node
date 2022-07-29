FROM node:16 as docker-compose
ENV VERSION=1.25.5
RUN curl -L -o /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-Linux-x86_64"
COPY docker-compose.sha256 /usr/local/bin/docker-compose.sha256
RUN sha256sum -c /usr/local/bin/docker-compose.sha256
RUN chmod +x /usr/local/bin/docker-compose

# https://docs.docker.com/install/linux/docker-ce/debian/
FROM node:16 as docker
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
COPY docker-public-key.asc /
RUN apt-key add /docker-public-key.asc
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce-cli

FROM node:16
COPY --from=docker /usr/bin/docker /usr/bin/docker
COPY --from=docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose

RUN docker -v
RUN docker-compose -v
