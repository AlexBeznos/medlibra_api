FROM ruby:2.7.1-slim

ENV RACK_ENV production

RUN apt-get update;\
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libcurl4 \
    libcurl4-openssl-dev \
    libcurl3-gnutls \
    libc-dev; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

COPY . /app

RUN bundle config --global frozen 1 \
  && bundle config set without 'development test' \
  && bundle install -j4 --retry 3

ENTRYPOINT ["bundle", "exec", "puma", "-t", "0:16", "-e", "production", "-p", "$PORT"]
