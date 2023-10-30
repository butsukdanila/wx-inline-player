FROM alpine

# install base packages and configure helpers
RUN apk add --no-cache -u bash curl 

# install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

COPY "usr/.bashrc" "/root/.bashrc"