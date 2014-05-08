DIRS = $(filter %/, $(wildcard */))

COMMANDS = distro build dput clean

all:
	@echo "Available commands:"
	@\
for command in ${COMMANDS}; do  \
echo "  $$command"; \
done


$(COMMANDS): ${DIRS}
	@\
for dir in ${DIRS}; do \
  (cd $$dir && $(MAKE) $@) ; \
done
