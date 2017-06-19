#FROM openjdk:8-jdk
FROM openkbs/jre-mvn-py3

MAINTAINER OpenKBS <DrSnowbird@openkbs.org>

################################
#### ---- Environment Vars ----
################################
ARG GRAPHDB_EDITION=${GRAPHDB_EDITION:-free}
ARG GRAPHDB_VERSION=${GRAPHDB_VERSION:-8.1.1}

ARG GRAPHDB_PORT=${GRAPHDB_PORT:-7200}
ARG DATA_DIR=/graphdb-data

ENV APP_PARENT_DIR=/usr

ENV GRAPHDB_EDITION=${GRAPHDB_EDITION}
ENV GRAPHDB_VERSION=${GRAPHDB_VERSION}

ENV GRAPHDB_PACKAGE=graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}-dist.zip
ENV GRAPHDB_HOME=${APP_PARENT_DIR}/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}

ENV GRAPHDB_PORT=${GRAPHDB_PORT}
ENV DATA_DIR=${DATA_DIR:-/data}

WORKDIR ${APP_PARENT_DIR}

#### ---- (You need to download GraphDB tar from ontotext web side (using local host tar file) ----
COPY ${GRAPHDB_PACKAGE} /tmp
RUN unzip /tmp/${GRAPHDB_PACKAGE} -d ${APP_PARENT_DIR} && \
    ln -s ${APP_PARENT_DIR}/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION} ${APP_PARENT_DIR}/graphdb && \
    ln -s ${APP_PARENT_DIR}/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}/data ${DATA_DIR} && \
    ls -al && \
    rm /tmp/${GRAPHDB_PACKAGE}

RUN export GRAPHDB_HOME=${GRAPHDB_HOME} && \
    export PATH=${GRAPHDB_HOME}/bin:$PATH

## -- Ontotext requiring you to use account to download Free GRAPHDB_VERSION --
#RUN curl -fsSL "http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-${GRAPHDB_EDITION}/${GRAPHDB_VERSION}/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}-dist.zip" > \
#    graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}.zip && \
#    bash -c 'md5sum -c - <<<"$(curl -fsSL http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-${GRAPHDB_EDITION}/${GRAPHDB_VERSION}/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}-dist.zip.md5) graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}.zip"' && \
#    mkdir -p ${APP_PARENT_DIR} && \
#    cd ${APP_PARENT_DIR} && \
#    unzip /tmp/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}.zip && \
#    rm /tmp/graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION}.zip && \
#    mv graphdb-${GRAPHDB_EDITION}-${GRAPHDB_VERSION} 

ENV PATH=${GRAPHDB_HOME}/bin:$PATH

VOLUME ${DATA_DIR}

EXPOSE ${GRAPHDB_PORT}

#CMD ["-Dgraphdb.home=/opt/graphdb/home"]
CMD "sh", "-c", "-Dgraphdb.home=${GRAPHDB_HOME}"

#ENTRYPOINT ["/opt/graphdb/dist/bin/graphdb"]
ENTRYPOINT "${GRAPHDB_HOME}/bin/graphdb"

