FROM mysterysd/wzmlx:v3

ARG PYTHON_VERSION=3.10
ENV PYTHON_VERSION=${PYTHON_VERSION}

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y \
        g++ make wget pv git bash xz-utils gawk \
        python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python3-pip python3-setuptools \
        mediainfo psmisc procps supervisor \
        zlib1g-dev bzip2 bzip2 libbz2-dev libreadline-dev sqlite3 libsqlite3-dev \
        libssl-dev liblzma-dev libffi-dev xz-utils findutils libnsl-dev uuid-dev \
        libgdbm-dev libncurses5-dev libncursesw5-dev tar curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m pip install --upgrade pip setuptools && \
    ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    ln -sf /usr/bin/pip3 /usr/bin/pip${PYTHON_VERSION}

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
