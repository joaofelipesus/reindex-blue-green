FROM ruby:3.2.2

# Instala nossas dependencias
RUN apt-get update && apt-get install -qq -y --no-install-recommends  build-essential \
    libpq-dev git-all

# env var with workdir path
ENV INSTALL_PATH /reindex-blue-green

# create workdir
RUN mkdir -p $INSTALL_PATH

# define initial location of the container
WORKDIR $INSTALL_PATH

# copy Gemfile to container
COPY Gemfile ./

# gems path
ENV BUNDLE_PATH /gems

# copy application dir to container
COPY . .
