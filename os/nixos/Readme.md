# NixOS setup

## Machine config

```bash
$ sudo cat /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    /home/knarf/configs/os/nixos/machine/configuration.nix
  ];
}
```

This way I can version control my config by having an empty configurations.nix that just imports the one in the repo.

After making changes simply run:

```bash
sudo nixos-rebuild switch
```

## home-manager

[home-manager guide](https://nix-community.github.io/home-manager/)

