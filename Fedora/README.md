# Fedora Setup

This page documents the way I setup Fedora on my laptops, while the scripts in
this folder provide some level of automation so that you may perform the setup
in an unattended manner.

The base installation is Fedora 36 Workstation (Gnome), with added tools for
software development, audio production, multimedia creation, general
productivity, and a better commandline experience, all done for my personal
needs.

If you have come here, you are either a future version of me looking to setup a
laptop quickly or an employee/intern/friend who'd like to setup their laptop
identically to mine for whatever reason.

## Pre-install Partition Setup

* Enable full disk encryption (hoping your CPU supports
  [AES-NI](https://en.wikipedia.org/wiki/AES_instruction_set) instructions)
* [EXT4](https://en.wikipedia.org/wiki/Ext4) everywhere (TODO: Evaluate
  [Btrfs](https://en.wikipedia.org/wiki/Btrfs) sometime)
* `1.5GB` for `/boot` would be sda1 (enough room for all the messing around with
  experimental kernels you'll ever need - I managed just fine with a 0.5GB in an
  earlier setup so this is plenty!)
* Rest is sda2 managed by
  [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux))
* `50GB` for `/` to be sure that experimenting with apps wouldn't screw up badly
* `sizeof(RAM) + 1GB` for `swap` (for hibernate + buffer when RAM is full)
* Remaining space as `/home`

## During Installation

While you install Fedora 34 on your new machine, use your browser to copy these
scripts into someplace you'll easily find, like /postinstall. That way you can
escape from having to first install git to run these scripts.

## Automated Setup Script

Run `./setup.sh` to install a bunch of software automatically as a starting
point.

## Gnome Setup

Fedora comes with a barebones gnome setup. Press super, type extensions, open
the extensions app, and setup dash-to-dock and gsconnect. The former gives you
a dock that pops up when your mouse is at the bottom of the display, and the
later gives you a KDEConnect compatible Gnome extension.

Next, press super, type tweaks, open the gnome tweaks app, go to the top bar
section, and select EVERYTHING there.

There! Your gnome is now setup.


## CPU Frequency Scaling

To ensure that your CPU is at the highest performance setting and isn't being
throttled to save power (useful during audio work for example), run this:

```bash
sudo cpupower frequency-set --governor performance
```

Alternatively, you may use a powersaver mode when all you are doing is surfing
the internet on battery power.

```bash
sudo cpupower frequency-set --governor powersave
```

## Recommended Fonts

* monospace: Roboto Mono Regular
* Serif: Roboto Slab
* Sans: Roboto

Note: Google's roboto fonts seem to work particularly well on high resolution
displays because they don't contain some unnecessary details, like the stroke
through the S in the dollar symbol $ which makes them easier to read.

