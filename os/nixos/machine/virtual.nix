{ config, pkgs, ... }:

{
  # enable docker
  virtualisation.docker.enable = true;

  # enable incus
  # todo: docker needs iptables, but Incus needs nftables. So need to figure out how to solve that conflict
  #networking.nftables.enable = true
  #virtualisation.incus.enable = true;
}
