# Makefile for Auto-Maintainer project

run:
	bash scripts/main.sh

build:
	cat scripts/modules/*.sh scripts/main.sh > scripts/update_all.sh
	chmod +x scripts/update_all.sh

test:
	bash tests/test_runner.sh

clean:
	rm -rf logs/*
