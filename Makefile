.PHONY: test install uninstall

test:
	sh tests/test-command.sh

install:
	sudo ./install.sh

uninstall:
	sudo ./uninstall.sh
