# =============================================================
# Make framework tour
#
# Covers variables, automatic variables, pattern rules, phony
# targets, conditionals, functions, includes and .DEFAULT_GOAL.
# =============================================================

.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:

# ---- configuration -----------------------------------------
VERSION      ?= $(shell node -p "require('./package.json').version")
NODE_VERSION ?= 22
SRC_DIR      := src
OUT_DIR      := dist
SOURCES      := $(wildcard $(SRC_DIR)/*.ts)
OBJECTS      := $(patsubst $(SRC_DIR)/%.ts,$(OUT_DIR)/%.js,$(SOURCES))

CYAN  := \033[36m
RESET := \033[0m

ifeq ($(CI),true)
  NPM_FLAGS := ci --no-audit --no-fund
else
  NPM_FLAGS := install
endif

# ---- targets -----------------------------------------------
.PHONY: help install build test lint clean package publish

## help: Show this message
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed -e 's/## //' | awk -F': ' \
		'{ printf "  $(CYAN)%-12s$(RESET) %s\n", $$1, $$2 }'

## install: Install dependencies
install: node_modules

node_modules: package.json package-lock.json
	npm $(NPM_FLAGS)
	@touch $@   # inline comment: refresh the sentinel

## build: Compile sources
build: $(OBJECTS)

$(OUT_DIR)/%.js: $(SRC_DIR)/%.ts | $(OUT_DIR)
	@echo "  compiling $< -> $@"
	npx tsc "$<" --outDir "$(@D)"

$(OUT_DIR):
	@mkdir -p $@

## test: Run the test suite
test: build
	npm test -- --reporter=verbose

## lint: Check formatting and types
lint:
	npx tsc --noEmit
	npx eslint $(SRC_DIR) --max-warnings 0

## package: Build the VS Code extension
package: build
	npx @vscode/vsce package --out "coolest-dark-$(VERSION).vsix"

## clean: Remove build artefacts
clean:
	$(RM) -r $(OUT_DIR) *.vsix
	@echo "cleaned"
