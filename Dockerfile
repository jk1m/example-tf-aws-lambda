ARG PY_VER=3.8-slim-buster
FROM python:${PY_VER}

COPY src/requirements.txt src/lambda.py /

RUN apt-get update -y && \
  apt-get install vim wget curl jq -y && \
  useradd -ms /bin/bash worker && \
  mv requirements.txt lambda.py /home/worker && \
  chown -R worker:worker /home/worker

WORKDIR /home/worker

USER worker

RUN pip install -r requirements.txt