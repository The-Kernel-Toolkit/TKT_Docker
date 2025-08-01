#### TKT Dockerfile setup

This is where TKT set's up the docker containers used for the GHCI Actions auto-builds of the kernels.

# Attached Makefile building service

Attached to this repository is a simple 'Makefile' which allows us to simplify building the docker containers.
Instead of having to run some commands, modify them each run per distro, and deal with headaches, I (ETJAKEOC)
have generated this Makefile to make the job of building, loading, and cleaning the Docker containers easier.

```yml
Usage: make [target]

Core Targets:
all            Build all 13 container images (default).
gentoo         Build all 3 Gentoo variants.
clean          Remove all container images built by this Makefile.
help           Show this help message.
Options:
load           Passes the '--load' flag to 'docker build' to load.
the image into the local docker images.


Individual Container Targets:
arch           debian         fedora         gentoo-musl
gentoo-openrc  gentoo-systemd mint           nixos
popos          slackware      suse           ubuntu
void
```
