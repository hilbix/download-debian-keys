# Public Domain

URL=https://files.devuan.org/
GPG=devuan-archive-keyring.gpg devuan-devs.gpg

.PHONY:	love
love:	all

.PHONY:	all
all:	$(GPG)

.PHONY:	$(GPG)
$(GPG):
	curl -o '$@' '$(URL)/$@'

