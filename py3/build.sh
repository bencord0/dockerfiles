#!/bin/bash

ensure_volume() {
	VOLUME="$1"
	if docker volume ls -q | grep -q "^${VOLUME}$"; then
		echo "Volume exists: ${VOLUME}"
	else
		echo -n "Creating volume: "
		docker volume create --name "${VOLUME}"
	fi
}

docker_shell() {
	docker run \
		-v "$(portageq get_repo_path / gentoo):/usr/portage:ro" \
		-v "$(portageq distdir):/usr/portage/distfiles:ro" \
		-v "$(portageq pkgdir):/usr/portage/packages" \
		-v $PWD/make.conf:/etc/portage/make.conf \
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
		-v "rootfs:/rootfs" \
		-v "staging:/staging" \
		--net host \
		--rm gentoo/stage3-amd64 \
		$@
}

docker_run() {
	docker run \
		-v "$(portageq get_repo_path / gentoo):/usr/portage:ro" \
		-v "$(portageq distdir):/usr/portage/distfiles:ro" \
		-v "$(portageq pkgdir):/usr/portage/packages" \
		-v $PWD/make.conf:/etc/portage/make.conf \
		-v $PWD/package.keywords:/etc/portage/package.keywords/monolith \
		-v "rootfs:/rootfs" \
		-v "staging:/staging" \
		--rm gentoo/stage3-amd64 \
		$@
}

docker_emerge() {
	docker_fetcher \
		emerge -efq \
			$@
	docker_run \
		emerge -ebkuv --root /staging \
			$@
	docker_run \
		emerge -vKu --root /rootfs $@
}

ensure_volume rootfs
ensure_volume staging
docker_run ln -s lib64 /rootfs/lib
docker_run ln -s lib64 /staging/lib
docker_emerge \
	app-shells/bash \
	dev-lang/python:3.5 \
	dev-python/pip \
	dev-python/virtualenv \
	sys-apps/coreutils \
	sys-libs/glibc

docker_run tar cvf - -C /rootfs . | docker import - python35
