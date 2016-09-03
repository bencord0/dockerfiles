FROM bencord0/gentoo-lite
ADD fetch_pypy.sh /tmp/
RUN /tmp/fetch_pypy.sh

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/pypy/bin

RUN pypy -m ensurepip
RUN pypy -m pip install -U \
 pip \
 requests \
 virtualenv
CMD pypy

