{ config, pkgs, lib, ... }:

let
  # Launcher script that switches back to Steam (gamescope) session.
  returnToSteam = pkgs.writeShellScript "return-to-steam" ''
    exec /run/current-system/sw/bin/steamos-session-select gamescope
  '';
in
{
  # Weston config tuned for Samsung "The Frame" TV via NVIDIA HDMI.
  # Forces 1920x1080@60 because the EDID-preferred 4K@30 is rejected by the TV.
  # Used as the "desktop" session — gamescope handles Steam separately.
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
    panel-position=bottom
    background-color=0xff202030

    [launcher]
    icon=/run/current-system/sw/share/icons/hicolor/48x48/apps/steam.png
    path=${returnToSteam}

    [launcher]
    icon=/run/current-system/sw/share/icons/hicolor/48x48/apps/foot.png
    path=${pkgs.foot}/bin/foot
  '';
}
