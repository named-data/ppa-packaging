# PPA archive
PPA=ppa:named-data/ppa

# List of target distributions
DISTROS=precise saucy trusty

DEBUILD=debuild -S -sa

all: _phony

_phony:

distro: work/${NAME}

work/${NAME}:
	\
mkdir work || true ; \
cd work	; \
git clone --recursive "${GIT_URL}" "${NAME}" ; \
cd "${NAME}" ; \
git checkout "${GIT_VERSION}" ; \
git archive --format=tar.gz --prefix=${NAME}_${VERSION}/ \
  -o ../${NAME}_${VERSION}.orig.tar.gz HEAD

build: distro
	\
if test -z "$$DEBEMAIL" -o -z "$$DEBFULLNAME"; then \
  echo "DEBFULLNAME and DEBEMAIL environmental variable should be set" ; \
  echo "For example:" ; \
  echo "export DEBEMAIL=\"my@emailaddress.com\"" ; \
  echo "export DEBFULLNAME=\"Full Name\"" ;\
  exit 1; \
fi
	\
cd "work/${NAME}" ; \
for distro in ${DISTROS}; do \
  NEW_VER="${VERSION}-ppa${PPA_VERSION}~$$distro"; \
  rm -Rf debian ; cp -r ../../debian . ; \
  sed -i -e "s/DISTRO/$$distro/g" debian/changelog ; \
  if [ -f "debian/control.$$distro" ]; then \
    mv "debian/control.$$distro" debian/control ; \
  fi ; \
  CUR_VER=`dpkg-parsechangelog | grep '^Version: ' | awk '{print $$2}'`; \
  if dpkg --compare-versions $$NEW_VER gt $$CUR_VER; then \
    echo "New version. Will update changelog and build source package" ; \
    dch -v $$NEW_VER -D $$distro --force-distribution \
      -u low "New version based on ${GIT_VERSION} (${GIT_URL})" ; \
  else \
    if dpkg --compare-versions $$NEW_VER ne $$CUR_VER; then \
      echo "ERROR: Cannot rebuild source package, because new version is earlier \
than the one specified in changelog ($$NEW_VER < $$CUR_VER)" ; \
      exit 1; \
    fi ; \
    echo "Same version, just rebuild source package" ; \
  fi ; \
  ${DEBUILD} ; \
done

dput: build
	\
cd "work" ; \
for distro in ${DISTROS}; do \
  dput "${PPA}" "${NAME}_${VERSION}-ppa${PPA_VERSION}~$$distro""_source.changes" ; \
done ; \
\
cd .. ; \
NEW_VER="${VERSION}-ppa${PPA_VERSION}~DISTRO"; \
CUR_VER=`dpkg-parsechangelog | grep '^Version: ' | awk '{print $$2}'`; \
if dpkg --compare-versions $$NEW_VER gt $$CUR_VER; then \
  dch -v $$NEW_VER -D DISTRO --force-distribution \
        -u low "New version based on ${GIT_VERSION} (${GIT_URL})" ; \
fi

clean:
	@rm -Rf work
