{ config, pkgs, ... }:

{
  # enable docker
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;

  # enable incus
  # todo: docker needs iptables, but Incus needs nftables. So need to figure out how to solve that conflict
  #networking.nftables.enable = true
  #virtualisation.incus.enable = true;
}
