.PHONY: test lint install uninstall

test:
	python3 tests/test_suite.py

lint:
	shellcheck bin/sleep_my_sweetie install.sh uninstall.sh

install:
	sudo sh ./install.sh

uninstall:
	sudo sh ./uninstall.sh
