SHELL := /usr/bin/env bash

# Default packages to stow; override with `make stow PACKAGES="..."`
PACKAGES ?= hypr waybar kitty nvim zsh git scripts wofi dunst zed oh-my-posh

# Target directory (usually $HOME)
TARGET ?= $(HOME)

.PHONY: help stow restow unstow dry-run

help:
	@echo "Targets:"
	@echo "  make dry-run       # Show what would be stowed"
	@echo "  make stow          # Stow $(PACKAGES) into $(TARGET)"
	@echo "  make restow        # Restow (use after changes)"
	@echo "  make unstow        # Remove symlinks for $(PACKAGES)"
	@echo "Vars: PACKAGES=... TARGET=..."

dry-run:
	@stow -nv -t "$(TARGET)" $(PACKAGES)

stow:
	@stow -v -t "$(TARGET)" $(PACKAGES)

restow:
	@stow -v -R -t "$(TARGET)" $(PACKAGES)

unstow:
	@stow -v -D -t "$(TARGET)" $(PACKAGES)
