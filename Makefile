DIRS := $(wildcard */.)

COMMANDS := distro source-build build dput clean

all: help

help:
	@echo "Available commands:"
	@\
for command in ${COMMANDS}; do \
  echo "  $$command"; \
done

$(COMMANDS): ${DIRS}
	@\
for dir in ${DIRS}; do \
  (cd $$dir && $(MAKE) $@) ; \
done

deb: ${DIRS}
	mkdir .deb || true
	@\
for dir in ${DIRS}; do \
  (cd $$dir && $(MAKE) build && cp work/*.deb ../.deb/) ; \
done

.PHONY: all help deb
