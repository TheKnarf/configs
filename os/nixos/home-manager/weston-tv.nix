{ config, pkgs, lib, ... }:

{
  # Weston config tuned for Samsung "The Frame" TV via NVIDIA HDMI.
  # Forces 1920x1080@60 because the EDID-preferred 4K@30 is rejected by the TV.
  xdg.configFile."weston.ini".text = ''
    [core]
    backend=drm-backend.so
    idle-time=0
    xwayland=true

    [output]
    name=HDMI-A-2
    mode=1920x1080@60
    transform=normal

    [shell]
    panel-position=none
    background-color=0xff000000

    [autolaunch]
    path=${config.xdg.configHome}/steam-bigpicture.sh
    watch=false
  '';

  xdg.configFile."steam-bigpicture.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Wait briefly for the compositor to be ready
      sleep 2
      exec /run/current-system/sw/bin/steam -bigpicture
    '';
  };
}
