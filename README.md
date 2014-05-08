NDN Binary packages for Ubuntu
==============================

Prerequisites
-------------

The following packages needs to be installed in order to build source .deb package to be
upload to PPA:

    sudo apt-get install git devscripts debhelper dh-make

Building source packages
------------------------

The build process is very much automated and the following command can be used to build a
specific source package and upload it to the ppa.

    make dput <PACKAGE_NAME>

Before running dput make sure that you have access to upload packages to `named-data/ppa`
(or modify target PPA repository in `packaging.mk`).
