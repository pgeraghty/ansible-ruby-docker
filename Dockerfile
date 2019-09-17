ARG RUBY_VERSION=2.6.4
ARG ANSIBLE_VERSION=2.8.5

FROM ruby:$RUBY_VERSION-alpine

ARG RUBY_VERSION
ENV RUBY_VERSION=$RUBY_VERSION

ARG ANSIBLE_VERSION
ENV ANSIBLE_VERSION=$ANSIBLE_VERSION

ENV SODIUM_INSTALL=system

# python & pip for Ansible, git for bundler
# make/g++ for building native extensions to gems
RUN apk add --update python py-pip git make g++ && \
    apk --update add --virtual build-dependencies \
      gcc \
      musl-dev \
      libffi-dev \
      openssl-dev \
      python-dev \
      libsodium-dev && \
    apk update && apk upgrade && \   
    pip install --upgrade pip && \
    pip install python-keyczar docker-py && \
    pip install ansible==$ANSIBLE_VERSION && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks