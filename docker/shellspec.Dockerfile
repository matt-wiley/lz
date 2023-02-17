FROM mattwiley/ubuntu:20.04

WORKDIR /opt

RUN git clone https://github.com/shellspec/shellspec.git && \
    ln -s /opt/shellspec/shellspec /usr/bin/shellspec
