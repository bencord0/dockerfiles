FROM gentoo/stage3-amd64

ADD rsyncd.conf /etc/rsyncd.conf

EXPOSE 873

ENTRYPOINT [ "/usr/bin/rsync", "--daemon", "--no-detach", "--verbose"]
