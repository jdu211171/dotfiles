SHELL := /usr/bin/env bash

# ---------- OS & host-aware defaults ----------
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)

DEFAULT_PACKAGES_LINUX  := hypr waybar kitty nvim zsh git scripts wofi dunst zed ohmyposh codex gemini
DEFAULT_PACKAGES_DARWIN := kitty nvim zsh git scripts zed ohmyposh codex gemini
DEFAULT_PACKAGES_OTHER  := kitty nvim zsh git scripts zed ohmyposh codex gemini

ifeq ($(UNAME_S),Linux)
DEFAULT_PACKAGES := $(DEFAULT_PACKAGES_LINUX)
else ifeq ($(UNAME_S),Darwin)
DEFAULT_PACKAGES := $(DEFAULT_PACKAGES_DARWIN)
else
DEFAULT_PACKAGES := $(DEFAULT_PACKAGES_OTHER)
endif

# Default packages to stow; override with `make stow PACKAGES="..."`
PACKAGES ?= $(DEFAULT_PACKAGES)

# Target directory (usually $HOME)
TARGET ?= $(HOME)

# Optional host overlay package (e.g., host-laptop, host-macos)
HOST ?= $(shell hostname -s 2>/dev/null || uname -n)
HOST_PACKAGE := host-$(HOST)
HOST_EXISTS := $(wildcard $(HOST_PACKAGE))

.PHONY: help stow restow unstow dry-run stow-os restow-os stow-with-host restow-with-host

help:
	@echo "Targets:"
	@echo "  make dry-run                 # Show what would be stowed (OS-aware default set)"
	@echo "  make stow                    # Stow $(PACKAGES) into $(TARGET)"
	@echo "  make restow                  # Restow (use after changes)"
	@echo "  make unstow                  # Remove symlinks for $(PACKAGES)"
	@echo "  make stow-os                 # Stow OS-appropriate defaults"
	@echo "  make restow-os               # Restow OS-appropriate defaults"
	@echo "  make stow-with-host          # Stow defaults plus host overlay if present"
	@echo "  make restow-with-host        # Restow defaults plus host overlay if present"
	@echo "Vars: PACKAGES=... TARGET=... HOST=$(HOST)"

dry-run:
	@stow -nv -t "$(TARGET)" $(PACKAGES)

stow:
	@stow -v -t "$(TARGET)" $(PACKAGES)

restow:
	@stow -v -R -t "$(TARGET)" $(PACKAGES)

unstow:
	@stow -v -D -t "$(TARGET)" $(PACKAGES)

# OS-aware helpers
stow-os:
	@echo "OS=$(UNAME_S)"; echo "Packages: $(DEFAULT_PACKAGES)"; stow -v -t "$(TARGET)" $(DEFAULT_PACKAGES)

restow-os:
	@echo "OS=$(UNAME_S)"; echo "Packages: $(DEFAULT_PACKAGES)"; stow -v -R -t "$(TARGET)" $(DEFAULT_PACKAGES)

# Include host overlay if directory exists
stow-with-host:
	@if [ -n "$(HOST_EXISTS)" ]; then \
	  echo "Including host overlay: $(HOST_PACKAGE)"; \
	  stow -v -t "$(TARGET)" $(DEFAULT_PACKAGES) $(HOST_PACKAGE); \
	else \
	  echo "No host overlay found: $(HOST_PACKAGE)"; \
	  stow -v -t "$(TARGET)" $(DEFAULT_PACKAGES); \
	fi

restow-with-host:
	@if [ -n "$(HOST_EXISTS)" ]; then \
	  echo "Including host overlay: $(HOST_PACKAGE)"; \
	  stow -v -R -t "$(TARGET)" $(DEFAULT_PACKAGES) $(HOST_PACKAGE); \
	else \
	  echo "No host overlay found: $(HOST_PACKAGE)"; \
	  stow -v -R -t "$(TARGET)" $(DEFAULT_PACKAGES); \
	fi
