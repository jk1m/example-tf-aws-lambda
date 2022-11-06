ARG PY_VER=3.8-slim-buster
FROM python:${PY_VER}

RUN apt-get update -y && \
  apt-get install vim wget curl jq -y && \
  useradd -ms /bin/bash worker && \
  chown -R worker:worker /home/worker

WORKDIR /home/worker

USER worker
