# dockerfiles
A selection of docker build templates

## gentoo/portage
Description: The upstream gentoo portage tree
Image: gentoo/portage

	$ docker create -v /usr/portage --name portage gentoo/portage

Set this one up first, most of the images below will need access to a portage
tree to build. Note, this image is not "run", instead it is created but not
started.

## gentoo/stage3-amd64
Description: A basic gentoo container
Image: gentoo/stage3-amd64

	$ docker run --rm -it --volumes-from portage gentoo/stage3-amd64 \
		emerge --buildpkg vim

You can create gentoo binpkgs, stored in the portage container, using docker
volume mounts from a gentoo container.
This technique will be a common way of creating more advanced containers that
require access to the portage tree, without rebuilding from source.

## rsync
Description: A gentoo rsync server, hosting the gentoo-portage tree.
Dockerfile: rsyncd/Dockerfile
Build:
	$ docker build -t bencord0/rsyncd rsyncd

Run:
	$ docker run --volumes-from portage -p 873:873 -d --name rsyncd \
		bencord0/rsyncd

Use this container as a portage rsync host suitable for /etc/portage/repos.conf

## nginx
Description: A gentoo nginx base image
Dockerfile: none
Build:
This container is not built using a dockerfile because it requires access to
volumes, which are not available during the "docker build" command.

	$ NGINX_ID=$(docker run -d --volumes-from portage gentoo/stage3-amd64 \
		emerge --buildpkg --usepkg nginx)
	$ docker wait $NGINX_ID
	$ docker commit -c 'ENTRYPOINT [ "/usr/sbin/nginx" ]' \
		$NGINX_ID bencord0/nginx

This image isn't very useful by itself, but once built, it can be used in
Dockerfile FROM lines.

## binhost
Description: Serves the portage tree (with distfiles and packages) over http
Dockerfile: binhost/Dockerfile
Build:
	$ docker build -t bencord0/binhost binhost

Run:
	$ docker run --volumes-from portage -p 80:80 -d --name binhost \
		bencord0/binhost

More packages can be created (and shared).

	$ docker exec binhost emerge --buildpkg --usepkg qemu
