#!/bin/bash
set -ex

ensure_volume() {
    VOLUME="$1"
    if docker volume ls -q | grep -q "^${VOLUME}$"; then
        echo "Removing existing: ${VOLUME}"
        docker volume rm "${VOLUME}"
    fi
    echo -n "Creating volume: "
    docker volume create --name "${VOLUME}"
}

docker_shell() {
    docker run \
        -v "$(portageq get_repo_path / gentoo):/usr/portage:ro" \
        -v "$(portageq distdir):/usr/portage/distfiles:ro" \
        -v "$(portageq pkgdir):/usr/portage/packages" \
        -v $PWD/make.conf:/etc/portage/make.conf \
        -v $PWD/package.keywords:/etc/portage/package.keywords/monolith \
        -v $PWD/package.use:/etc/portage/package.use/monolith \
        -v $PWD/package.mask:/etc/portage/package.mask/monolith \
        -v $PWD/basepackages:/usr/portage/profiles/base/packages \
        -v $PWD/locale.gen:/etc/locale.gen \
        -v "rootfs:/rootfs" \
        -v "staging:/staging" \
        --net host \
        --rm -it gentoo/stage3-amd64 \
        /bin/bash
}

docker_fetcher() {
    docker run \
        -v "$(portageq get_repo_path / gentoo):/usr/portage:ro" \
        -v "$(portageq distdir):/usr/portage/distfiles" \
        -v "$(portageq pkgdir):/usr/portage/packages" \
        -v $PWD/make.conf:/etc/portage/make.conf \
        -v $PWD/package.keywords:/etc/portage/package.keywords/monolith \
        -v $PWD/package.use:/etc/portage/package.use/monolith \
        -v $PWD/package.mask:/etc/portage/package.mask/monolith \
        -v $PWD/basepackages:/usr/portage/profiles/base/packages \
        -v $PWD/locale.gen:/etc/locale.gen \
        -v "rootfs:/rootfs" \
        -v "staging:/staging" \
        --net host \
        --rm gentoo/stage3-amd64 \
        $@
}

docker_run() {
    docker run \
        -v $(portageq get_repo_path / gentoo):/usr/portage:ro \
        -v $(portageq distdir):/usr/portage/distfiles:ro \
        -v $(portageq pkgdir):/usr/portage/packages \
        -v $PWD/make.conf:/etc/portage/make.conf \
        -v $PWD/package.keywords:/etc/portage/package.keywords/monolith \
        -v $PWD/package.use:/etc/portage/package.use/monolith \
        -v $PWD/package.mask:/etc/portage/package.mask/monolith \
        -v $PWD/basepackages:/usr/portage/profiles/base/packages \
        -v $PWD/locale.gen:/etc/locale.gen \
        -v rootfs:/rootfs \
        -v staging:/staging \
        --cap-add SYS_PTRACE \
        --rm gentoo/stage3-amd64 \
        $@
}

docker_emerge() {
    docker_fetcher \
        emerge -efq $@
    docker_run \
        emerge -DNbektuv --binpkg-respect-use=y --root /staging $@
    docker_run \
        emerge -DNKuv --root /rootfs $@
}

docker pull gentoo/stage3-amd64
ensure_volume rootfs
ensure_volume staging

docker_run ln -s lib64 /rootfs/lib
docker_run ln -s lib64 /staging/lib
docker_emerge \
    app-shells/bash
docker_emerge \
    dev-db/postgresql \
    dev-lang/python:{3.5,3.6} \
    dev-libs/openssl \
    dev-python/pip \
    dev-python/psycopg:2 \
    dev-python/virtualenv \
    sys-libs/glibc

docker_run sh -c 'echo hosts: files dns > /rootfs/etc/nsswitch.conf'
docker_run tar cvf - -C /rootfs . | docker import - python36
docker tag python36 bencord0/python:latest
docker tag python36 bencord0/python:2
docker tag python36 bencord0/python:3
docker tag python36 bencord0/python:2.7
docker tag python36 bencord0/python:3.4
docker tag python36 bencord0/python:3.5
docker tag python36 bencord0/python:3.6
docker tag python36 bencord0/python:2.7.13
docker tag python36 bencord0/python:3.4.6
docker tag python36 bencord0/python:3.5.3
docker tag python36 bencord0/python:3.6.0
