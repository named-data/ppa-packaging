# NDN binary packages for Ubuntu

## Prerequisites

The following packages needs to be installed in order to build source .deb package to be
upload to PPA:

    sudo apt-get install git devscripts debhelper dh-make

## Building source packages

The build process is very much automated and the following command can be used to build
all packages and upload them to the ppa.

    make dput

Before running dput make sure that you have access to upload packages to `named-data/ppa`
(or modify target PPA repository in `packaging.mk`).

To build a specific package, go to the package's folder and run the same `make dput` command.

## Advanced uses

The scripts by default create source packages for Ubuntu 16.04 (xenial) and 18.04 (bionic).
If necessary, default actions and distributions can be overriden:

To only build source packages (no upload), only for Ubuntu 12.04:

    make build DISTROS=precise

To build binary package that can be installed with `dpkg -i <package>.deb`:

    make build DEBUILD=debuild DISTROS=precise

The built package will be in `<package-folder>/work/<package-name>_<version>.deb`
