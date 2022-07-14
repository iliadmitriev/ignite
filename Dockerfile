FROM alpine:3.16

RUN { 	echo '#!/bin/sh';echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
	
	
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
	PATH=${PATH}:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin \
	JAVA_VERSION=8u322 \
	JAVA_ALPINE_VERSION=8.322.06-r0 \
	IGNITE_SHA256="35e32c1c240281ae7f6604d56cce65905c523c9ae20169ed21a9ea8cc2b9c461" \
	IGNITE_HOME=/opt/ignite/apache-ignite \
	IGNITE_VERSION=2.13.0

RUN set -x 	\
	&& apk add --no-cache \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
		bash \ 
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

WORKDIR /opt/ignite

RUN wget https://dlcdn.apache.org/ignite/${IGNITE_VERSION}/apache-ignite-slim-${IGNITE_VERSION}-bin.zip \
		-O /tmp/apache-ignite-slim.zip \
	&& echo "${IGNITE_SHA256}  /tmp/apache-ignite-slim.zip" | sha256sum -c - \
	&& cd /tmp/ && unzip apache-ignite-slim.zip \
	&& rm /tmp/apache-ignite-slim.zip \
	&& rm -rf /tmp/apache-ignite-slim-${IGNITE_VERSION}-bin/{docs,examples,platforms} \
	&& mv /tmp/apache-ignite* /opt/ignite/apache-ignite

COPY run.sh /opt/ignite/apache-ignite/

RUN chmod 777 ${IGNITE_HOME}/libs \
	&& chmod 777 ${IGNITE_HOME} \
	&& chmod 555 $IGNITE_HOME/run.sh

EXPOSE 10800 11211 47100 4750 49112 8080

CMD $IGNITE_HOME/run.sh

