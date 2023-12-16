FROM openjdk:17-jdk-slim-bullseye as builder

RUN apt-get update -y
RUN apt-get install -y unzip git

ENV LANG C.UTF-8

# https://github.com/GumTreeDiff/gumtree/blob/main/docker/Dockerfile
RUN git clone https://github.com/GumTreeDiff/gumtree.git /opt/gumtree --depth 1 \
  && /opt/gumtree/gradlew -p /opt/gumtree build \
  && unzip -d /opt/gumtree/dist/build/distributions /opt/gumtree/dist/build/distributions/gumtree-3.1.0-SNAPSHOT.zip \
  && git clone https://github.com/GumTreeDiff/jsparser.git /opt/jsparser --depth 1

FROM node:20.10.0-slim

ENV APP_ROOT /works

WORKDIR $APP_ROOT

RUN apt-get update -y
RUN apt-get install -y openjdk-17-jre-headless

COPY ./package.json ./package-lock.json $APP_ROOT

RUN npm ci

COPY . $APP_ROOT

COPY --from=builder /opt/gumtree/dist/build/distributions/gumtree-3.1.0-SNAPSHOT /opt/gumtree/dist
COPY --from=builder /opt/jsparser /opt/jsparser

RUN npm --prefix=/opt/jsparser/ install @babel/parser @babel/traverse xml-writer \
  && npm --prefix=/opt/jsparser uninstall acorn dash-ast \
  && ln -s /opt/gumtree/dist/bin/gumtree /usr/bin/gumtree \ 
  && ln -s /opt/jsparser/jsparser /usr/bin/jsparser 

RUN chmod +x ${APP_ROOT}/scripts/jsparser

# webdiff
EXPOSE 4567
