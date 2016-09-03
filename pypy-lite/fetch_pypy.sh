#!/bin/bash
PYPY_VERSION=pypy-5.4-linux_x86_64-portable.tar.bz2

mkdir -p /opt/pypy
curl -L "https://bitbucket.org/squeaky/portable-pypy/downloads/${PYPY_VERSION}" \
    | tar xjf - -C /opt/pypy --strip-components 1
