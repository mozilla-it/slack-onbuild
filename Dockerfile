FROM python:3.6

# lifted straight from https://github.com/docker-library/python/blob/7eca63adca38729424a9bab957f006f5caad870f/3.6/onbuild/Dockerfile
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Extra python env
ONBUILD ENV PYTHONUNBUFFERED=1, \
    PYTHONDONTWRITEBYTECODE=1, \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# build args with defaults
ONBUILD ENV APP_UID=1000
ONBUILD ENV APP_GID=1000
ONBUILD ENV APP_USER=slack
ONBUILD ENV APP_PORT=8080
ONBUILD ENV APP_WORKERS=2
ONBUILD ENV APP_MODULE=main:app

ONBUILD COPY requirements.txt /usr/src/app/
ONBUILD RUN pip install --no-cache-dir -r requirements.txt

# add non-priviledged user
ONBUILD RUN groupadd --gid $APP_GID $APP_USER && \
    adduser --uid $APP_UID --disabled-password --gecos '' --ingroup $APP_USER --no-create-home $APP_USER

# add bundled source code
ONBUILD ADD app.tar.gz /usr/src/app/

# change user
ONBUILD RUN chown $APP_USER:$APP_USER -R .
ONBUILD USER $APP_USER

CMD sh -c "/usr/local/bin/hypercorn -w ${APP_WORKERS} -b :${APP_PORT} ${APP_MODULE}"
