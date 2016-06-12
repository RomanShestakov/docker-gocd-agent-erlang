FROM travix/base-debian-git-jre8:latest

MAINTAINER rshestakov

# build time environment variables
ENV GO_VERSION=16.5.0-3305 \
    USER_NAME=go \
    USER_ID=999 \
    GROUP_NAME=go \
    GROUP_ID=999

ENV ERLANG_VERSION=17.5.3

# install go agent
RUN groupadd -r -g $GROUP_ID $GROUP_NAME \
    && useradd -r -g $GROUP_NAME -u $USER_ID -d /var/go $USER_NAME \
    && mkdir -p /var/lib/go-agent \
    && mkdir -p /var/go \
    && curl -fSL "https://download.go.cd/binaries/$GO_VERSION/deb/go-agent-$GO_VERSION.deb" -o go-agent.deb \
    && dpkg -i go-agent.deb \
    && rm -rf go-agent.db \
    && sed -i -e "s/DAEMON=Y/DAEMON=N/" /etc/default/go-agent \
    && echo "export PATH=$PATH" | tee -a /var/go/.profile \
    && chown -R ${USER_NAME}:${GROUP_NAME} /var/lib/go-agent \
    && chown -R ${USER_NAME}:${GROUP_NAME} /var/go \
    && groupmod -g 200 ssh

# runtime environment variables
ENV GO_SERVER=localhost \
    GO_SERVER_PORT=8153 \
    AGENT_MEM=128m \
    AGENT_MAX_MEM=256m \
    AGENT_KEY="" \
    AGENT_RESOURCES="" \
    AGENT_ENVIRONMENTS="" \
    AGENT_HOSTNAME="" \
    DOCKER_GID_ON_HOST=""

# add erlang
RUN \
  apt-get update && \
  apt-get --fix-missing -y install build-essential autoconf libncurses5-dev \
  libgl1-mesa-dev libglu1-mesa-dev libpng3 libssh-dev unixodbc-dev openssl fop xsltproc \
  libmozjs185-1.0 libmozjs185-dev libcurl4-openssl-dev libicu-dev wget curl

RUN cd /tmp; wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb

RUN apt-get update
RUN apt-get -y install erlang=1:$ERLANG_VERSION

# v16
COPY ./docker-entrypoint.sh /

RUN chmod 500 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
