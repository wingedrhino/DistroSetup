# Raspberry Pi Setup

I own a Pi Zero and a few Pi Zero WH's.


## Install

You first need a good MicroSD card. I use a Samsung Evo+ Class 10 32GB.
https://www.amazon.in/gp/product/B00WR4IJBE/

But TBH you can also use an old slow 8GB memory card that you have lying around,
if all you do with the Pi is treat it like a much beefier microcontroller to do
random gruntwork where performance isn't important as much as the fromfactor
being tiny.

Download the latest image via BitTorrent. Here's the Torrent link for quick
access: https://downloads.raspberrypi.org/raspbian_lite_latest.torrent

Follow the official install instructions here:
https://www.raspberrypi.org/documentation/installation/installing-images/linux.md

Extract the image (I shall update my script later to work with compressed
images) via the `etch.pl` command within this repository.

```bash
etch.pl 2019-09-26-raspbian-buster-lite.img /dev/mmcblk0
```

If the file name or the location to write to is incorrect, the script will warn
you and error out.

## Resizing the Root Partition

Raspbian does this automatically upon first boot

## Enabling SSH

Go to the boot partition on the card in your laptop (it's a tiny ~43mb fat32)
and run `touch ssh` to enable SSH access. Otherwise SSH access is disabled due
to security reasons.

For the same security reasons (default username is `pi` and default password is
`raspberry`) I suggest connecting to a trusted network for the very first time
to change the password so that a nefarious machine doesn't infect the Pi before
you even begin to use it. Or better, just launch it while it's connected to a
HDMI display, keyboard and mouse.

## Setting up Ethernet

You don't need to. This comes pre-configured!

## Setting up WiFi

You can create a `wpa_supplicant.conf` in the boot partition like this:

```
country=IN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="your WiFi SSID"
    psk="<your WiFi password>"
}

```

After booting up it'll be copied over automatically to where it should go -
`/etc/wpa_supplicant/wpa_supplicant.conf`.

## Setting up Static IP Address

Edit `/etc/dhcpcd.conf` and add this to the bottom:

```
interface wlan0
static ip_address=192.168.43.22
static routers=192.168.43.1
static domain_name_servers=1.1.1.1 1.0.0.1
```

You could do something similar for `interface eth0`, if this is a full-sized Pi
that comes with Ethernet.

I've this setup where ALL my routers/hotspots use the same subnet address,
`192.168.43.0`. I then allocate static IP addresses to all my machines so that
whatever network they're on, their IP addresses remain the same. You might note
that this subnet `192.168.43.0` is what's used by an Android phone.

## Pi Zero Gadget Mode

This is _the_ thing that makes a Pi Zero a fun toy. You can make the Pi Zero
emulate a keyboard, mouse, ethernet port, MIDI device, etc.

1. Edit `/boot/config.txt`
    * add a line with `dtoverlay=dwc2` at the very end of the file.
2. Edit `/boot/cmdline.txt`
    * This file is weird; it has no newlines and everything is separated by
      exactly ONE space
    * add `modules-load=dwc2,g_ether` after `rootwait`
3. Your next boot should have your Pi Zero working as an ethernet controller.
4. Plug the Pi Zero into your laptop and wait ~90 seconds.
5. Wait for the Wired Connection (1/2/3) to show up in your network manager tab
6. Go to network-manager's menu
    * hit edit connections
    * edit the new connection
    * switch to ipv4 tab
    * change the method to "shared to other computers"
    * repeat for ipv6, save, and close
7. Disconnect and reconnect this network
8. You can now run `ssh pi@10.42.0.whatever` to access the Pi.
   Scroll down for instructions on how to fetch its IP Address!

## Determine IP Address of Raspberry Pi

This step applies to Raspberry Pi devices connected via USB Gadget Mode, and
also Raspberry Pi devices connected via Ethernet cable directly to your laptop.

Both these have one thing in common - you need to determine their IP Address.

First, run `ip route` to know what network the new interface is on. The native
ethernet port should be `eno1`, a PCI ethernet card would be `ens1`, and you'd
have a long ugly name for the USB ethernet interface that I cannot be bothered
to remember and type here.

You'd see a network that looks like this: `10.42.0.0/24`.

Run nmap on it: `sudo nmap -sP 10.42.0.0/24` and wait for the command to finish
executing.

You'd see a couple of devices on the network now. The one with the ip address
that ends with 1 (like 10.42.0.1) is your host laptop. The "other" one is the
Raspberry Pi.

Alternatively, you can also just check if port 22 is open in a network. You can
do it via `nmap -p 22 192.168.0.0/24`. This explicitly checks if the port 22 is
open for your device on the network. On a public WiFi network, there shouldn't
be any (hopefully) other than your Pi.

Anyway, IP Address can be random, so you'd need to do this each time you try to
connect to a Pi. NetworkManager, Android hotspots (from Android 10), and public
WiFi networks wouldn't always let you set a static IP for the Pi, so usually
this is the best way to make things work.

Eventually, you could do something funky like writing a server which does
nothing that listens on port 666, and then look for THIS port to uniquely
identify that you are on a Raspberry Pi.

I should _probably_ try automating these steps at some point! Pretty sure there
are wrappers around ip link, ip route, and nmap in Python.

## Reference Links for OTG Gadget Mode

* https://forums.raspberrypi.com/viewtopic.php?t=245810
* https://e2e.ti.com/support/processors/f/791/t/612303?Linux-AM5728-USB-OTG-network-works-intermittently


## Compiling Kernel Modules on the Pi Zero (W(H))

When you compile a kernel module for the Raspberry Pi, you need to install the
kernel headers.

For this, you'd typically do

```
sudo apt install raspberrypi-kernel-headers
```

On literally any modern Raspberry Pi which supports the ARMv8 instruction set -
and you'd be an idiot to not buy one that does, you don't need to do anything
else.

That covers the Pi 3A+, the Pi 4B, and the Pi Zero 2W.

But, if you're unfortunate enough to own an older Pi, a Pi Zero (W(H)), or if
you absolutely NEED to write software for the Zero because you read
https://picockpit.com/raspberry-pi/everything-about-raspberry-pi-zero-2-w/
and decided that you want the lower peak power usage of the Zero (again, you
should probably just design for the Zero 2 and then underclock it and/or shut
off its radio), then you need to run this before you can compile software for
it.

```
sudo ln -s /usr/src/linux-headers-$(uname -r)/arch/arm /usr/src/linux-headers-$(uname -r)/arch/armv6l
```

Why is that? because `/usr/src/linux-headers-versiongoeshere/arch/arm64` exists
but `/usr/src/linux-headers-versiongoeshere/arch/armv6l` does not, and instead
there is a solitary `/usr/src/linux-headers-versiongoeshere/arch/arm` for both
armv6l and the Raspberry Pi 2's ARMv7.

You'd need to run this command EVERY SINGLE TIME your kernel updates and you
need to build a fresh module for it.

## Setting up an RTL8188FTV based USB WiFi Dongle

If you are looking to buy an RTL8188-series WiFi Dongle, please spend the extra
money and get something which works out of the box with Linux.

But if you're stuck with one - these are super common unbranded dongles you can
buy for as little as 2$ on Amazon.in, you need to install a binary blob of a
driver that cannot - and will not ever - be shipped with the Linux kernel.

Head over to https://github.com/kelebek333/rtl8188fu and follow the
instructions.

If you are on a Pi Zero (W(H)), look at the previous section to save yourself
some headache.

## Using the Pi as a hotspot

TODO: WIP

https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md

TODO: I am creating a bunch of scripts to automate some of the actions involved
in turning the Pi into a Hotspot / shared connection tool.

## Using the Pi as a WiFi Bridge

Read https://www.maketecheasier.com/turn-raspberry-pi-into-wi-fi-bridge/

I have a HP Chromebook MT8183 (4GB RAM, 64GB eMMC) which is a bit too weak for
use standalone as a developer workstation. It DOES have a USB Type-C port though
which provides more than enough power to my Raspberry Pi (Type-C ports can
supply a steady 5V 3A). Thus, a natural setup was to combine my Raspberry Pi 4B
8GB (with a 128GB Western Digital Purple MicroSD Card inside) with the
Chromebook by conecting the Pi over the Type-C port and using the Chromebook as
a frontend for the headless Pi.

ChromeOS has a few quirks (which I shall detail in my blog later) and one of
them is that it can only connect to one network at a time. This means that if I
connected the Pi over USB (and used networking via `g_ether`), I would _only_ be
able to access internet _through_ the Pi.

This means the Pi would need to connect to WiFi and route/bridge that connection
to `usb0`. Follow the steps in the article I linked to achieve that!

This gives you a USB 2.0 speed connection between the Pi and the Chromebook.
Anything slower would make something like a VNC extremely laggy. Chromebooks
don't have ethernet ports either so you don't want to carry around a dongle to
connect yours to your Pi.

