#########################
# multi stage Dockerfile
# 1. set up the build environment and build the expath-package
# 2. run the eXist-db
#########################
FROM openjdk:8-jdk as builder
LABEL maintainer="Johannes Kepper"

ENV SMUFL_BUILD_HOME="/opt/smufl-build"

ADD https://deb.nodesource.com/setup_8.x /tmp/nodejs_setup 

WORKDIR ${SMUFL_BUILD_HOME}

RUN apt-get update \
    && apt-get install -y --force-yes git \
    # installing nodejs
    && chmod 755 /tmp/nodejs_setup; sync \
    && /tmp/nodejs_setup \
    && apt-get install -y nodejs \
    && ln -s /usr/bin/nodejs /usr/local/bin/node

COPY . .

RUN addgroup smuflbuilder \
    && adduser smuflbuilder --ingroup smuflbuilder --disabled-password --system \
    && chown -R smuflbuilder:smuflbuilder ${SMUFL_BUILD_HOME}

USER smuflbuilder:smuflbuilder

RUN npm install \
    && ./node_modules/.bin/gulp bump-patch

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
ENV EXIST_DEFAULT_APP_PATH="xmldb:exist:///db/apps/module2"

# simply copy our SMuFL-browser xar package
# to the eXist-db autodeploy folder
COPY --from=builder /opt/smufl-build/dist/*.xar ${EXIST_HOME}/autodeploy/