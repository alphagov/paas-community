FROM sitespeedio/webbrowsers:chrome-78.0.3904.87-firefox-70.0

ENV SITESPEED_IO_BROWSERTIME__XVFB true
ENV SITESPEED_IO_BROWSERTIME__DOCKER true

ENV PATH="/usr/sbin:/usr/local/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y git curl jq

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
RUN export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts

RUN git clone https://github.com/sitespeedio/sitespeed.io.git /sitespeed.io

WORKDIR /sitespeed.io

RUN ln -sf /sitespeed.io /usr/src/app

RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    nvm use --lts &&  nvm exec --lts -- npm install --production
