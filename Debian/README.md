# Debian Setup

This file is written to be compatible with several different Debian
installations. I assume you're either running it with no GUI in a server /
Rapsberry Pi / Chromebook setting, or you are running it with Gnome Desktop.

Currently supported Debians are:

1. ChromeOS Crouton's Debian 12
2. Kali's Debian 13 Testing
3. Raspberry Pi OS Lite's Debian 12 (arm64)

Untested but hopefully working Debians are:

4. Ubuntu 24.04
5. Debian Sid (Unstable)

## KXStudio Setup

See [here](https://kx.studio/Repositories) for how to setup KX Repos. Install
all [meta-packages](https://kx.studio/Documentation:Repository:Meta-Packages)
that are available (`kxstudio-meta-all` ) plus `ardour` if you run a GUI; and
if you run headless, perhaps you only need `kxstudio-meta-audio-plugins`.

