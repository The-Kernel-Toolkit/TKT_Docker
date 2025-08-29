# ==============================================================================
# Master Makefile for building various distribution container images.
#
# This is a simple interface to compiling the multiple docker containers
# that TKT provides.
# ==============================================================================

# --- Variable Definitions ---
DISTROS_SIMPLE := \
	arch \
	debian \
	fedora \
	mint \
	nixos \
	popos \
	slackware \
	suse \
	ubuntu \
	void

DISTROS_GENTOO := \
	gentoo-openrc \
	gentoo-systemd \
	gentoo-musl

ALL_DISTROS := $(DISTROS_SIMPLE) $(DISTROS_GENTOO)

.PHONY: all help gentoo clean $(ALL_DISTROS)

# Prevent parallel builds (important for heavy builds / network usage)
.NOTPARALLEL:

# Default BUILD_TYPE
BUILD_TYPE ?= base

# Map BUILD_TYPE to Dockerfile suffix
ifeq ($(BUILD_TYPE),base)
	DOCKERFILE_SUFFIX := base
else ifeq ($(BUILD_TYPE),update)
	DOCKERFILE_SUFFIX := updater
else
$(error Invalid BUILD_TYPE '$(BUILD_TYPE)'. Must be 'base' or 'update'.)
endif

# --- Main Targets ---

all: $(ALL_DISTROS)
	@echo "All container builds complete."

help:
	@echo "Usage: make [target] BUILD_TYPE=base|update"
	@echo ""
	@echo "Example: make void BUILD_TYPE=update"
	@echo ""
	@echo "Core Targets:"
	@echo "  all            Build all container images (defaults to BUILD_TYPE=base)."
	@echo "  gentoo         Build all 3 Gentoo variants."
	@echo "  clean          Remove all container images built by this Makefile."
	@echo ""
	@echo "Individual Container Targets:"
	@echo "  $(ALL_DISTROS)"
	@echo ""
	@echo "Options:"
	@echo "  BUILD_TYPE     Specify 'base' or 'update' build (default: base)."
	@echo "  load           Passes the '--load' flag to 'docker build'."

# --- Special Target: load ---
load:
	@echo "--- Enabling image loading into local docker ---"
	@$(MAKE) $(filter-out load,$(MAKECMDGOALS)) LOAD=--load
	@exit 0

# --- Build Rules ---

$(ALL_DISTROS):
	@echo "--- Building $@:latest ($(BUILD_TYPE)) ---"
	docker build $(if $(LOAD),$(LOAD)) \
		-f $@-$(DOCKERFILE_SUFFIX).Dockerfile \
		-t $@:latest .
	@echo "--- Built $@:latest ($(BUILD_TYPE)) ---"

# Convenience target for Gentoo
gentoo: $(DISTROS_GENTOO)

# --- Cleanup ---
clean:
	@echo "--- Removing all built container images ---"
	docker rmi -f $(patsubst %,%:latest,$(ALL_DISTROS)) || true
