{ config, pkgs, ... }:

{
  home.packages = [
		pkgs.zsh

		pkgs.git

		pkgs.kitty

		pkgs.tmux
		pkgs.fzf
		pkgs.fd
		pkgs.ripgrep
		pkgs.wget
		pkgs.tree

		pkgs.htop
		pkgs.jq
		pkgs.cloc

		pkgs.direnv
		pkgs.git-annex
		pkgs.eza
		pkgs.bat

		pkgs.gh
		pkgs.yazi

		# Editors
		pkgs.vim
		pkgs.neovim
		pkgs.helix

		# Programming
    pkgs.nodejs_20
    pkgs.corepack
		pkgs.bun
		pkgs.rustup
		pkgs.go
  ];
}
