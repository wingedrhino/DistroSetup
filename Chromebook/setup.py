#!/usr/bin/python3

import subprocess
import apt
import sys

cache = apt.cache.Cache()
cache.update()
cache.open()

packages = [
        'git',
        'curl',
        'wget',
        'software-properties-common',
        'build-essential',
        'automake',
        'libtool',
        'autoconf',
        'pkg-config',
        'udev',
        'fuse',
        'snap',
        'snapd',
        'zsh',
        'byobu',
        'python3',
        'libsquashfuse0',
        'squashfuse',
        'fuse',
        'vim',
        'atop',
        'zsh',
        'byobu',
        'htop',
        'iotop',
        'nethogs',
        'aptitude',
        'udisks2',
        'parted',
        'gparted',
        'udisks2-lvm2',
        'udisks2-vdo',
        'udisks2-zram',
        'udisks2-btrfs',
        'udisks2-doc',
        'default-jdk',
        'leiningen',
        'clojure',
]

for pkg_name in packages:
    pkg = cache[pkg_name]
    if pkg.is_installed:
        print(f'{pkg_name} is already installed.')
    else:
        print(f'{pkg_name} will be marked for installation.') 

