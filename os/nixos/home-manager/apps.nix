{ config, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = [
    # Browsers
    pkgs.firefox

    # Chat
    pkgs.discord

    # Multimedia
    pkgs.spotify
    pkgs.vlc
    pkgs.audacity

    # Streaming
    pkgs.obs-studio

    # 3D / CAD / Game engines
#    pkgs.blender
#    pkgs.freecad
    pkgs.openscad
		pkgs.godot_4

    # Other
    pkgs.webtorrent_desktop
    pkgs.obsidian
  ];

}
