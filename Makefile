# Makefile for upKep Linux Maintainer

run:
	bash scripts/main.sh

build:
	cat scripts/modules/*.sh scripts/main.sh > scripts/upkep.sh
	chmod +x scripts/upkep.sh

test:
	bash tests/test_runner.sh

clean:
	rm -rf logs/*
