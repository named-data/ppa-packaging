# PPA archive
PPA=ppa:named-data/ppa-dev

# List of target distributions
DISTROS=precise trusty wily xenial

DEBUILD=debuild -S

all: _phony

_phony:

distro: work/${NAME}_${VERSION}

work/${NAME}_${VERSION}:
	\
mkdir work || true ; \
cd work	; \
git clone "${GIT_URL}" "${NAME}_${VERSION}" ; \
cd "${NAME}_${VERSION}" ; \
git fetch origin "${GIT_VERSION}"; \
git checkout "${GIT_VERSION}" ; \
git submodule init ; git submodule update ; \
(./waf version || true) ; \
(./waf distclean || true) ; \
cd .. ; \
tar --exclude .git --exclude '*.pyc' -cf - ${NAME}_${VERSION} | gzip -n9c > ${NAME}_${VERSION}.orig.tar.gz

source-build:
	$(MAKE) _build DEBUILD="debuild -S -sa"

build:
	$(MAKE) _build DEBUILD=debuild

install: build
	sudo dpkg -i work/*.deb

_build: distro
	\
if test -z "$$DEBEMAIL" -o -z "$$DEBFULLNAME"; then \
  echo "DEBFULLNAME and DEBEMAIL environmental variable should be set" ; \
  echo "For example:" ; \
  echo "export DEBEMAIL=\"my@emailaddress.com\"" ; \
  echo "export DEBFULLNAME=\"Full Name\"" ;\
  exit 1; \
fi
	\
cd "work/${NAME}_${VERSION}" ; \
for distro in ${DISTROS}; do \
  NEW_VER="${VERSION}-ppa${PPA_VERSION}~$$distro"; \
  rm -Rf debian ; cp -r ../../debian . ; \
  sed -i -e "s/DISTRO/$$distro/g" debian/changelog ; \
  for file in debian/*.$$distro; do \
    if [ -f $$file ]; then \
      rename -f "s/\.$$distro$$//" $$file ; \
    fi ; \
  done ; \
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

dput: source-build
	\
cd "work" ; \
for distro in ${DISTROS}; do \
  dput -f "${PPA}" "${NAME}_${VERSION}-ppa${PPA_VERSION}~$$distro""_source.changes" ; \
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
