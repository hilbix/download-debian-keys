# Public Domain
#
# Usage: make && git status
# If it seems legit, then commit

SUB=copy devuan

.PHONY:	love
love:	all

.PHONY:	all
all:	$(SUB)

.PHONY:	$(SUB)
$(SUB):
	$(MAKE) -C '$@'

