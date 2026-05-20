.PHONY: help version build debug release test test-release test-integration pre-commit conda lockfiles sbom sbom-force install-local-plugin

help:  ## Display help on all Makefile targets
	@@grep -h '^[a-zA-Z]' $(MAKEFILE_LIST) | awk -F ':.*?## ' 'NF==2 {printf "   %-20s%s\n", $$1, $$2}' | sort

version:  ## Derive version from git tags
	pixi run get-version

build: release  ## Build the release binary (alias for release)

debug:  ## Build the debug binary
	pixi run build-debug

release:  ## Build the release binary
	pixi run build-release

test:  ## Run the unit tests
	pixi run test

test-release:  ## Run the unit tests in release mode
	pixi run test-release

test-integration:  ## Run CLI integration tests
	pixi run test-integration

pre-commit:  ## Run pre-commit hooks on all files
	pixi run pre-commit

conda:  ## Build the conda package
	pixi run build-conda

lockfiles:  ## Regenerate embedded lockfiles
	./tool-specs/lock-all.sh

sbom:  ## Regenerate Cargo.lock (if needed) and update SBOM
	pixi run sbom

sbom-force:  ## Regenerate Cargo.lock and SBOM unconditionally
	pixi run sbom-force

ANA_HOME_DIR := $(or $(ANA_HOME),$(HOME)/.ana)
TOOL_PREFIX := $(ANA_HOME_DIR)/tools/anaconda-cli

install-local-plugin:  ## Install a local plugin into the anaconda-cli prefix (PLUGIN_PATH=<path>)
	@if [ -z "$(PLUGIN_PATH)" ]; then \
		echo "Error: PLUGIN_PATH is required. Usage: make install-local-plugin PLUGIN_PATH=../conda-repo-cli"; \
		exit 1; \
	fi
	@if [ ! -d "$(TOOL_PREFIX)" ]; then \
		echo "Error: anaconda-cli prefix not found at $(TOOL_PREFIX)"; \
		echo "Run 'ana bootstrap' first to create the environment."; \
		exit 1; \
	fi
	@if [ ! -d "$(PLUGIN_PATH)" ]; then \
		echo "Error: plugin directory not found at $(PLUGIN_PATH)"; \
		exit 1; \
	fi
	$(TOOL_PREFIX)/bin/pip install -e "$(PLUGIN_PATH)"
	@echo "Installed $(PLUGIN_PATH) into $(TOOL_PREFIX)"
