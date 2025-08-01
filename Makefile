# ==============================================================================
# Master Makefile for building various distribution container images.
#
# This is a simple interface to compiling the multiple docker containers
# that TKT provides.
# ==============================================================================

# --- Variable Definitions ---

# Define the list of distros that use a simple, single Dockerfile build.
# To add a new distro, just add its name here and create the corresponding
# <name>.Dockerfile.
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

# Define the Gentoo-specific build targets.
DISTROS_GENTOO := \
	gentoo-openrc \
	gentoo-systemd \
	gentoo-musl

# Combine all targets for the 'all' and 'clean' rules.
ALL_TARGETS := $(DISTROS_SIMPLE) $(DISTROS_GENTOO)

# Use .PHONY to ensure these targets run even if files with the same name exist.
.PHONY: all help gentoo clean $(ALL_TARGETS)

# --- Main Targets ---

# The default target, executed when you just run 'make'.
all: $(ALL_TARGETS)
	@echo "All container builds are complete."

# A help target to explain how to use the Makefile.
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Core Targets:"
	@echo "  all            Build all 13 container images (default)."
	@echo "  gentoo         Build all 3 Gentoo variants."
	@echo "  clean          Remove all container images built by this Makefile."
	@echo "  help           Show this help message."
	@echo "Options:"
	@echo "  load           Passes the '--load' flag to 'docker build' to load."
	@echo "                 the image into the local docker images."
	@echo ""
	@echo ""
	@echo "Individual Container Targets:"
	@echo "  arch           debian         fedora         gentoo-musl"
	@echo "  gentoo-openrc  gentoo-systemd mint           nixos"
	@echo "  popos          slackware      suse           ubuntu"
	@echo "  void"


# --- Build Recipes ---

# Add the `--load` flag to docker, to load the build image into the users system.
# --- Special Target: load ---
load:
	@echo "--- Enabling image loading into local docker ---"
	@$(MAKE) $(filter-out load,$(MAKECMDGOALS)) LOAD=--load
	@exit 0


# Generic pattern rule for all simple, single-Dockerfile builds.
# The '$@' is an automatic variable that holds the name of the target.
# For example, when you run 'make arch', '$@' becomes 'arch'.
$(DISTROS_SIMPLE):
	@echo "--- Building $@:latest from $@.Dockerfile ---"
	docker build \
		-f $@.Dockerfile \
		-t $@:latest .
	@echo "--- Built $@:latest from $@.Dockerfile ---"

# Convenience target to build all Gentoo variants at once.
gentoo: $(DISTROS_GENTOO)

# Specific rule for the Gentoo OpenRC variant (uses default build-args).
gentoo-openrc:
	@echo "--- Building gentoo:openrc from gentoo.Dockerfile ---"
	docker build \
		-f gentoo-openrc.Dockerfile \
		-t gentoo:openrc .
	@echo "--- Built gentoo:openrc from gentoo.Dockerfile ---"

# Specific rule for the Gentoo Systemd variant.
gentoo-systemd:
	@echo "--- Building gentoo:systemd from gentoo.Dockerfile ---"
	docker build \
		-f gentoo-systemd.Dockerfile \
		-t gentoo:systemd .
	@echo "--- Built gentoo:systemd from gentoo.Dockerfile ---"

# Specific rule for the Gentoo Musl variant.
gentoo-musl:
	@echo "--- Building gentoo:musl from gentoo.Dockerfile ---"
	docker build \
		-f gentoo-musl.Dockerfile \
		-t gentoo:musl .
	@echo "--- Built gentoo:musl from gentoo.Dockerfile ---"

# --- Cleanup ---

# Target to remove all images built by this Makefile.
clean:
	@echo "--- Removing all built container images ---"
	docker rmi -f $(patsubst %,%:latest,$(DISTROS_SIMPLE)) gentoo:openrc gentoo:systemd gentoo:musl || true
