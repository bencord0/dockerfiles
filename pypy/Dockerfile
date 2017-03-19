FROM bencord0/gentoo-lite
ADD fetch_pypy.sh /tmp/
RUN /tmp/fetch_pypy.sh

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/pypy/bin

RUN pypy -m ensurepip && \
    python2 -m ensurepip && \
    python3 -m ensurepip

RUN pypy -m pip install -U pip wheel
RUN python2 -m pip install -U pip wheel
RUN python3 -m pip install -U pip wheel

CMD pypy

