.PHONY: test install uninstall

test:
	sh tests/test-command.sh

install:
	sudo sh ./install.sh

uninstall:
	sudo sh ./uninstall.sh
