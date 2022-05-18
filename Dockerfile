FROM ubuntu:20.04

ENV TZ=Europe/Istanbul \
    DEBIAN_FRONTEND=noninteractive

USER root
# RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget openjdk-11-jre-headless



RUN apt update
RUN apt install -y --no-install-recommends locales tzdata install-info git gcc wget tar texinfo autotools-dev asciidoc automake libevent-dev libssl-dev zlib1g-dev build-essential make curl ca-certificates docbook-xsl docbook-xml xmlto obfs4proxy tini ;
# RUN rm -rf /var/lib/apt/lists/*



# golang
RUN wget -P /tmp https://go.dev/dl/go1.17.10.linux-arm64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.17.10.linux-arm64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
RUN rm -rf /tmp/go1.17.10.linux-arm64.tar.gz

# Snowflake
RUN git clone  https://git.torproject.org/pluggable-transports/snowflake.git /data/snowflake
WORKDIR /data/snowflake/client
RUN cd /data/snowflake/client
RUN /usr/local/go/bin/go get
RUN /usr/local/go/bin/go build -o /usr/bin/snowflake-client
RUN chmod +x /usr/bin/snowflake-client


 # Polipo
RUN git clone --progress --verbose https://github.com/jech/polipo.git /data/polipo
WORKDIR /data/polipo
RUN make all
RUN make install
RUN man polipo
COPY polipo /etc/polipo/polipo

# Tor
RUN git clone --progress --verbose https://github.com/torproject/tor.git /data/tor
WORKDIR /data/tor
RUN /data/tor/autogen.sh
RUN /data/tor/configure
RUN make
RUN make install
COPY torrc /etc/tor/torrc

COPY docker-entrypoint.sh /etc/docker-entrypoint.sh
# RUN ln -s /etc/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /etc/docker-entrypoint.sh
ENTRYPOINT ["tini", "--", "/etc/docker-entrypoint.sh"]

USER root


EXPOSE 8123