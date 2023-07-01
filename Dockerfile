FROM node:16.20.1-bookworm as build

ARG APP_NAME=cloud-academy-labs

RUN echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list && \
    apt-get update && \
    apt-get install -y git-lfs yarn nfpm jq gnupg quilt rsync unzip bats \
                       build-essential g++ libx11-dev libxkbfile-dev libsecret-1-dev python-is-python3
# RUN npm install -g typescript && npm i --save-dev @types/node

WORKDIR /code-server
RUN git clone --branch v4.14.1 https://github.com/coder/code-server.git . && \
    git submodule update --init
COPY files/product.json lib/vscode/product.json
RUN yarn install --frozen-lockfile
RUN yarn build
RUN VERSION=1.79.2 yarn build:vscode
RUN yarn release
RUN yarn release:standalone

FROM ubuntu:20.04 as release
COPY --from=build /code-server/release-standalone /usr/lib/code-server
COPY files/code-server /usr/bin/code-server