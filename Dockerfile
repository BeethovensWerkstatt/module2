#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
FROM openjdk:8-jdk as builder
LABEL maintainer="Johannes Kepper"

ENV MODULE2_BUILD_HOME="/opt/module2-build"

ADD https://deb.nodesource.com/setup_8.x /tmp/nodejs_setup 

WORKDIR ${MODULE2_BUILD_HOME}

RUN apt-get update \
    && apt-get install -y --force-yes git \
    # installing nodejs
    && chmod 755 /tmp/nodejs_setup; sync \
    && /tmp/nodejs_setup \
    && apt-get install -y nodejs \
    && ln -s /usr/bin/nodejs /usr/local/bin/node

COPY . .

RUN addgroup module2builder \
    && adduser module2builder --ingroup module2builder --disabled-password --system \
    && chown -R module2builder:module2builder ${MODULE2_BUILD_HOME}

USER module2builder:module2builder

RUN npm install \
    && cp existConfig.tmpl.json existConfig.json \
    && ./node_modules/.bin/gulp dist

#########################
# Now running the eXist-db
# and adding our freshly built xar-package
#########################
FROM stadlerpeter/existdb

# add SMuFL-browser specific settings 
# for a production ready environment with 
# SMuFL-browser as the root app.
# For more details about the options see  
# https://github.com/peterstadler/existdb-docker
ENV EXIST_ENV="production"
ENV EXIST_CONTEXT_PATH="/"
ENV EXIST_DEFAULT_APP_PATH="xmldb:exist:///db/apps/bw-module2"

# simply copy our SMuFL-browser xar package
# to the eXist-db autodeploy folder
COPY --from=builder /opt/module2-build/dist/*.xar ${EXIST_HOME}/autodeploy/