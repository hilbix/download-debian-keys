# Public Domain

DEBIAN=debian-keyring debian-archive-keyring ubuntu-keyring ubuntu-archive-keyring

.PHONY:	love
love:	all

.PHONY:	all
all:	$(DEBIAN)

.PHONY:	$(DEBIAN)
$(DEBIAN):
	@if debsums -as '$@'; \
	then	n="$@-$$(dpkg -s '$@' | sed -n 's/^Version: //p')" && \
		rm -rf "$$n" && \
		mkdir -vp "$$n" && \
		list="$$(debsums -a '$@')" && \
		list="$$(echo "$$list" | sed -n 's/\.gpg[[:space:]]*OK$$/.gpg/p')" && \
		echo "$$list" | xargs -- cp -t "$$n" && \
		for a in "$$n"/*.gpg; do for b in "$$a"*~; do [ ! -f "$$b" ] || cmp "$$a" "$$b" && rm -vf "$$b" || break; done; done; \
	else true; fi

