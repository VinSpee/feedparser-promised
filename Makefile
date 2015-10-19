NODE_PATH := ./node_modules/.bin
SHELL     := /usr/bin/env bash
CPUS      := $(shell node -p "require('os').cpus().length" 2> /dev/null || echo 1)
MAKEFLAGS += --jobs $(CPUS)

.PHONY: install
install:
	npm install

.PHONY: test
ESLINT := $(NODE_PATH)/eslint --parser 'babel-eslint' lib/** test/**
COMPILERS   := --compilers js:babel/register
ifdef CI
NPM_INSTALL    := $(MAKE) install
MOCHA_REPORTER := dot
else
MOCHA_REPORTER  := spec
endif
ifdef COVERAGE
MOCHA := $(NODE_PATH)/istanbul cover $(NODE_PATH)/_mocha --
else
MOCHA := $(NODE_PATH)/mocha
endif
MOCHA_FLAGS := --recursive \
								--reporter $(MOCHA_REPORTER) \
								--require test/helper
ifdef WATCH
	MOCHA_FLAGS += --watch
endif
test:
	$(NPM_INSTALL)
	$(ESLINT)
	NODE_ENV=test \
	time $(MOCHA) \
		$(MOCHA_FLAGS) \
		$(COMPILERS)