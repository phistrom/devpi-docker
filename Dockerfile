FROM python:3.9-alpine

# specifiy a specific devpi-server package version
ARG DEVPI_SERVER_VERSION

# specify a specific devpi-web package version
ARG DEVPI_WEB_VERSION

# This adds an '==' before the version number if you specified one as a 
# build arg. Otherwise it will remain an empty string.
ENV DEVPI_SERVER_VERSION "${DEVPI_SERVER_VERSION:+==${DEVPI_SERVER_VERSION}}"
ENV DEVPI_WEB_VERSION "${DEVPI_WEB_VERSION:+==${DEVPI_WEB_VERSION}}"

RUN apk add --no-cache --virtual .build-deps \
      build-base \
      libffi-dev \
  && pip install --no-cache \
        devpi-server${DEVPI_SERVER_VERSION} \
        devpi-web${DEVPI_WEB_VERSION} \
  && apk del .build-deps \
  && find /usr/local/lib/python*/ -type f -name '*.py[cod]' -delete

ARG DEVPISERVER_CONFIGFILE="/configfile"
ARG DEVPISERVER_PORT=3141
ARG DEVPISERVER_SECRETFILE="/secretfile"
ARG DEVPISERVER_SERVERDIR="/devpi"
ARG USERNAME="devpiusr"
ARG USER_ID=1000

ENV DEVPISERVER_CONFIGFILE "${DEVPISERVER_CONFIGFILE}"
ENV DEVPISERVER_HOST "0.0.0.0"
ENV DEVPISERVER_PORT "${DEVPISERVER_PORT}"
ENV DEVPISERVER_SECRETFILE "${DEVPISERVER_SECRETFILE}"
ENV DEVPISERVER_SERVERDIR "${DEVPISERVER_SERVERDIR}"

# a user can specify the password they want in their secretfile
# by using -e SECRETFILE_CONTENTS="<a long password here>"
ENV SECRETFILE_CONTENTS ""

COPY entrypoint.sh /entrypoint.sh

# create non-privileged user
RUN addgroup -g "${USER_ID}" "${USERNAME}" \
  && adduser -D -u "${USER_ID}" -G "${USERNAME}" "${USERNAME}" \
  && mkdir -p "${DEVPISERVER_SERVERDIR}" \
  && touch "${DEVPISERVER_CONFIGFILE}" "${DEVPISERVER_SECRETFILE}" \
  && chown -R "${USERNAME}:${USERNAME}" \
      "${DEVPISERVER_CONFIGFILE}" \
      "${DEVPISERVER_SECRETFILE}" \
      "${DEVPISERVER_SERVERDIR}" \
  && chmod 0600 "${DEVPISERVER_SECRETFILE}" \
  && chmod +x /entrypoint.sh  

USER "${USERNAME}"

WORKDIR "${DEVPISERVER_SERVERDIR}"

EXPOSE "${DEVPISERVER_PORT}/tcp"
VOLUME "${DEVPISERVER_SERVERDIR}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["devpi-server"]
