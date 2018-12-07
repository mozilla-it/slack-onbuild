FROM python:3.6-onbuild

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=1, \
    PYTHONUNBUFFERED=1, \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# build args with defaults
ARG APP_UID=1000
ENV APP_UID=$APP_UID

ARG APP_GID=1000
ENV APP_GID=$APP_GID

ARG APP_USER=slack
ENV APP_USER=$APP_USER

ARG KUBECTL_VERSION

# write kubectl version to a file
RUN ["sh", "-c", "[ -n \"$KUBECTL_VERSION\" ] && echo \"$KUBECTL_VERSION\" > KUBECTL_VERSION || echo $(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) > KUBECTL_VERSION"]
RUN ["sh", "-c", "curl -s https://storage.googleapis.com/kubernetes-release/release/$(cat KUBECTL_VERSION)/bin/linux/amd64/kubectl > /usr/local/bin/kubectl"]
RUN chmod +x /usr/local/bin/kubectl


# add non-priviledged user
RUN groupadd --gid $APP_GID $APP_USER && \
    adduser --uid $APP_UID --disabled-password --gecos '' --ingroup $APP_USER --no-create-home $APP_USER

ENV APP_PORT=8080
ENV APP_TIMEOUT=120
ENV APP_WORKERS=2
ENV APP_MODULE=main:app

CMD ["sh", "-c", "/usr/local/bin/gunicorn -t ${APP_TIMEOUT} -w ${APP_WORKERS} -b :${APP_PORT} ${APP_MODULE}"]

# change user
RUN chown $APP_USER:$APP_USER -R .
USER $APP_USER
