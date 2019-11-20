# Public Domain

DEBIAN=debian-archive-keyring ubuntu-archive-keyring

.PHONY:	love
love:	all

.PHONY:	all
all:	$(DEBIAN)

.PHONY:	$(DEBIAN)
$(DEBIAN):
	debsums -as '$@'
	rm -rf '$@' && mkdir -p '$@' && list="$$(debsums -a '$@')" && list="$$(echo "$$list" | sed -n 's/\.gpg[[:space:]]*OK$$/.gpg/p')" && echo "$$list" | xargs -- cp -t '$@/'

