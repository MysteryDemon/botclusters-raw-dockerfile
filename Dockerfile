FROM mysterysd/wzmlx:v3

ARG PYTHON_VERSION=3.10.14
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        g++ make wget pv git bash xz-utils gawk \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libffi-dev liblzma-dev uuid-dev libgdbm-dev \
        libncurses5-dev libncursesw5-dev libnsl-dev \
        xz-utils tar curl build-essential libxml2-dev tk-dev \
        libxmlsec1-dev software-properties-common findutils \
        mediainfo psmisc procps supervisor \
        python3-pip python3-setuptools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j"$(nproc)" && \
    make altinstall && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3 && \
    cd / && rm -rf /usr/src/Python-${PYTHON_VERSION}*

RUN python3 -m pip install --upgrade pip setuptools

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

RUN bash -c '\
    export PYENV_ROOT="/root/.pyenv" && \
    export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH" && \
    git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv && \
    eval "$(pyenv init -)" && \
    eval "$(pyenv virtualenv-init -)" && \
    export PYTHON_CONFIGURE_OPTS="--without-tk" && \
    pyenv install 3.8.18 && \
    pyenv install 3.9.18 && \
    pyenv install 3.10.14 && \
    pyenv install 3.11.9 && \
    pyenv install 3.12.3 && \
    pyenv install 3.13.3 && \
    unset PYTHON_CONFIGURE_OPTS'

ENV SUPERVISORD_CONF_DIR=/etc/supervisor/conf.d
ENV SUPERVISORD_LOG_DIR=/var/log/supervisor

RUN mkdir -p ${SUPERVISORD_CONF_DIR} \
    ${SUPERVISORD_LOG_DIR} \
    /app

WORKDIR /app
COPY --from=mwader/static-ffmpeg:7.1.1 /ffmpeg /bin/ffmpeg
COPY --from=mwader/static-ffmpeg:7.1.1 /ffprobe /bin/ffprobe
COPY . .
