-include .env

.PHONY: all clean install build

all:; clean remove install update build

clean:
	@forge clean

remove:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "deps: add modules"

install:
	@forge install openzeppelin/openzeppelin-contracts

update:
	@forge update

build:
	@forge build

format:
	@forge fmt