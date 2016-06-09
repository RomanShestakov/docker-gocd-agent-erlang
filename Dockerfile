FROM travix/base-debian-git-jre8:latest

MAINTAINER rshestakov

# build time environment variables
ENV GO_VERSION=16.5.0-3305 \
    USER_NAME=go \
    USER_ID=999 \
    GROUP_NAME=go \
    GROUP_ID=999

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
RUN apt-get update && apt-get -y upgrade && apt-get -y install wget

# RUN cd /tmp; wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
#     dpkg -i erlang-solutions_1.0_all.deb

# RUN apt-get update && apt-get -y install erlang erlang-base-hipe build-essential \
#   autoconf libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev git

# Erlang
RUN echo -e "deb http://packages.erlang-solutions.com/debian jessie contrib" | sudo tee /etc/apt/sources.list.d/erlang-solutions.list
RUN wget -qO - http://packages.erlang-solutions.com/debian/erlang_solutions.asc | sudo apt-key add -

# Update packages
RUN apt-get update

# Install dependencies
RUN apt-get install build-essential curl libmozjs185-1.0 libmozjs185-dev libcurl4-openssl-dev libicu-dev wget curl

# Install older version of erlang for couch
RUN apt-get install erlang-dev=1:17.5.3 erlang-base=1:17.5.3 erlang-crypto=1:17.5.3 \
                      erlang-nox=1:17.5.3 erlang-inviso=1:17.5.3 erlang-runtime-tools=1:17.5.3 \
                      erlang-inets=1:17.5.3 erlang-edoc=1:17.5.3 erlang-syntax-tools=1:17.5.3 \
                      erlang-xmerl=1:17.5.3 erlang-corba=1:17.5.3 erlang-mnesia=1:17.5.3 \
                      erlang-os-mon=1:17.5.3 erlang-snmp=1:17.5.3 erlang-ssl=1:17.5.3 \
                      erlang-public-key=1:17.5.3 erlang-asn1=1:17.5.3 erlang-ssh=1:17.5.3 \
                      erlang-erl-docgen=1:17.5.3 erlang-percept=1:17.5.3 erlang-diameter=1:17.5.3 \
                      erlang-webtool=1:17.5.3 erlang-eldap=1:17.5.3 erlang-tools=1:17.5.3 \
                      erlang-eunit=1:17.5.3 erlang-ic=1:17.5.3 erlang-odbc=1:17.5.3 \
                      erlang-parsetools=1:17.5.3
# v16
COPY ./docker-entrypoint.sh /

RUN chmod 500 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
