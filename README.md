# NDN binary packages for Ubuntu

## Prerequisites

The following dependencies need to be installed in order to build the source `.deb` packages
to be uploaded to the PPA:

    sudo apt install git devscripts debhelper dh-make

## Building source packages

The build process is fully automated. The following command can be used to build all
packages and upload them to the PPA:

    make dput

Before running `dput`, make sure that you have access to upload packages to `named-data/ppa`
(or modify the target PPA repository in `packaging.mk`).

To build a specific package, go to the package's folder and run the same `make dput` command.

## Advanced uses

By default, the scripts will create source packages for Ubuntu 20.04 (focal), 22.04 (jammy),
and 22.10 (kinetic). If necessary, the default actions and distributions can be overriden,
for example:

* To only build source packages (no upload), only for Ubuntu 12.04:

      make build DISTROS=precise

* To build binary package that can be installed with `sudo dpkg -i <package>.deb`:

      make build DEBUILD=debuild DISTROS=precise

  The built package will be in `<package-folder>/work/<package-name>_<version>.deb`
