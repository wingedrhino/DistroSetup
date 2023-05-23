# Termux Setup

Termux is an awesome Linux environment for Android, based on Ubuntu. I am
currently in the very early stages of automating its setup, so that I can run
it on a bunch of old Android phones and treat them like tiny low powered
servers.

## Initial Install

Due to a problem that should be resolved by the time Termux hits v1.0, you need
to install Termux through [F-Droid](https://f-droid.org/) instead of Google Play
Store.

So head over to F-Droid, download its APK, install it (you might need to say yes
when asked if you'd like to install an app from an unknown source), open it,
pull down, and wait for the package list to refresh.

Type `termux` in the searchbar.

Install the following packages:

* Termux
  * Bare minimum; you'd need this to run Linux apps
* Termux:Widget
  * Allows you to launch scripts placed inside `~/.shortcuts` from the Android
    homescreen. VERY nifty!
* Termux:API
  * Exposes phone's features through CLI APIs in the terminal, accessible via
    shell scripts.
* Termux:Float
  * Not super useful; this lets you place termux inside a floating window.
    You'd probably appreciate this more in a tablet than on a phone.
* Termux:Boot
  * Allows termux to startup at boot.
* Termux:Styling
  * Extra themes for Termux.

Launch Termux.

## Static IP

Make sure your household WiFi router's DHCP server assigns the same IP to the
phone on which Termux runs, whenever it connects. This would make your life a
LOT easier. Example: [TP-Link](https://www.tp-link.com/us/support/faq/488/).

If you can't do this, the next best option is to assign it a static IP from
within your Android WiFi settings. What I like to do is to reserve IPs of
192.168.blah.100 to 192.168.blah.200 for DHCP, and keep the IPs lower than 100
for static assignment.

## SSH Setup

Refer to wiki on [Remote Access](https://wiki.termux.com/wiki/Remote_Access)
before you proceed, because the lack of a full-sized keyboard to monkey on
makes Termux *slightly* painful before SSH is setup.

The quick tl;dr is this:

```bash
pkg install openssh
sshd
passwd
```

You need to setup a password now.

Then you go to your desktop and do

```bash
ssh 192.168.1.14 -p 8022
```

assumung 192.168.1.14 is the static IP you assigned your phone earlier, and
then you login.

Note the `-p 8022` part because we run `sshd` on a non-standard port.

## Initial Setup from Desktop

Now that you have SSH'ed into Termux from your desktop, it's time to do things
from your desktop where you can type larger sentences without getting cramped.

```bash
pkg update
pkg install vim curl wget byobu zsh dnsutils python nodejs perl
pkg install postgresql redis
mkdir -p ~/bin
mkdir -p ~/ext/workspace
cd ~/ext/workspace
git clone https://github.com/wingedrhino/DistroSetup
cp DistroSetup/dotfiles/zshrc ~/.zshrc
cp DistroSetup/dotfiles/gitconfig ~/.gitconfig
cp DistroSetup/dotfiles/vimrc ~/.vimrc
cp DistroSetup/dotfiles/profile ~/.profile
```

Now switch to zsh as the default shell.

```bash
chsh
```

and then type `zsh`.

Now, we log out back to our desktop.

```bash
exit
```

And then log back in

```bash
ssh 192.168.1.14 -p 8022
```

You're now logged into zsh, a MUCH better shell!

Time for more customizations.


```bash
byobu-ctrl-a
```

Select emacs mode here. This lets you use `F12` as the key to activate commands
in byobu instead of `ctrl-a` as in GNU Screen. On a chromebook, `F12` would be
`Search + +` (i.e, hold Search and hit Plus).

A quick walkthrough of byobu will show up in my blog at some point!

## Optional: Disable Password based SSH

You probably set a weak password to make it easy to type. This is never a good
idea because anyone in your network can try logging into your Termux-equipped
phone with that password. Disable password-based authentication and setup
passwordless SSH!

I already have docs covering that. But let's re-visit the main steps here:

From your desktop/laptop, run

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the line and do this on the phone's Termux instance:

```
echo "pasted content here" >> ~/.ssh/authorized_keys
```

Now we logout and log back in to verify that we didn't need to enter our
password to login.

Now you may disable password-based login on SSH.

```bash
vim $PREFIX/etc/ssh/sshd_config
```

Set

```
PasswordAuthentication no
```

inside the file.

## Create Widgets to launch programs

There's a package on F-Droid called `Termux Widget`. This creates a 2x2 widget
on your home screen, with shortcuts to executable files located in
`~/.shortcuts`.

Try this:

```bash
echo "sshd" >> ~/.shortcuts/sshd && chmod a+x ~/.shortcuts/sshd
```

It'll let you start sshd on Termux from your Android home screen.

I also setup widgets to auto-launch PostgreSQL, Redis, Minio, etc for when I
need to use my Android phone as an external server while I program from my
rather resource-constrained Chromebook!

## Android Debugger based Port Forwarding

By default SSH runs on Port 8022 in Termux. ADB can forward this port on the
phone to the same port on localhost. There's a nice blog about this subject
[here](https://glow.li/technology/2016/9/20/access-termux-via-usb/).

## Get PostgreSQL Running

Refer: https://wiki.termux.com/wiki/Postgresql

### First-time Setup

```bash
mkdir -p $PREFIX/var/lib/postgresql
initdb $PREFIX/var/lib/postgresql
echo 'pg_ctl -D $PREFIX/var/lib/postgresql start' > ~/bin/pgstart
chmod a+x ~/bin/pgstart
echo 'pg_ctl -D $PREFIX/var/lib/postgresql stop' > ~/bin/pgstop
chmod a+x ~/bin/pgstop
```

You can now use the `pgstart` and `pgstop` commands to start/stop PostgreSQL.

```bash
createuser --superuser --pwprompt yourUserName
```

Enter a password.

Then do

```bash
createdb yourUserName
```

Now you can access the `psql` prompt like this:

```bash
psql -U yourUserName
```

You won't use this user/password/db combo in production; but you WILL use it
to create more user+db+password combos - one for each app. This is the
"normal" way of using PostgreSQL, without relying on Docker to create a brand
new instance of PostgreSQL each time you start a new project!

You can run PostgreSQL commands in this prompt, or just exit by typing

```sql
exit
```

### (Re)Creating New Users/Databases for Projects

First, we open our psql prompt.

```bash
psql -U yourUserName
```

Then,

```sql
drop user if exists myprojectname;
drop database if exists myprojectname_db;
create database myprojectname_db;
create user myprojectname with encrypted password 'myprojectname_12345';
grant all privileges on database myprojectname_db to myprojectname;
```

## Running Redis

Unlike PostgreSQL, Redis is a lot more fuss-free.


```bash
cd $HOME
wget https://raw.githubusercontent.com/redis/redis/6.0/redis.conf
echo 'redis-server ~/redis.conf' > ~/bin/redisstart
chmod a+x ~/bin/redisstart
echo 'killall redis-server' > ~/bin/redisstop
chmod a+x ~/bin/redisstop
vim  ~/redis.conf
```

Inside the `~/redis.conf` file, change `daemonize` to `yes` and uncomment the
`requirepass` field and set it to something hard to guess (you'd need to use
this password while connecting to Redis from your application).

## Running Node.js v16

This is currently not supported due to a couple of upstream issues
https://github.com/termux/termux-packages/pull/6973

So... Try to make do with v14 until it gets fixed?

## Running Minio (an S3 clone)

Unlike Redis and PostgreSQL, Minio is not supplied within the Termux
repositories. You'd need to install it from source.

```bash
pkg install golang
GO111MODULE=on go get github.com/minio/minio
mkdir -p ~/miniodata
echo 'MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password MINIO_REGION_NAME=fra1 nohup ~/go/bin/minio server ~/miniodata &' > ~/bin/miniostart
chmod a+x ~/bin/miniostart
```

This will take a LONG time to install, especially on an older phone.

But now you can run miniostart to launch minio!

## Running Your Application's Databases on your phone

I sometimes have to use my Chromebook to write software because I have frequent
blackouts, and the Chromebook is the only device (other than the phone) with a
huge battery life. But the RAM is a measly 4GB (which is the same as my phone).

```bash
echo "pgstart" > ~/.shortcuts/dbup.sh
echo "redisstart" >> ~/.shortcuts/dbup.sh
echo "miniostart" >> ~/.shortcuts/dbup.sh
chmod a+x ~/.shortcuts/dbup.sh
echo "killall postgresql" > ~/.shortcuts/dbdown.sh
echo "killall redis" >> ~/.shortcuts/dbdown.sh
echo "killall minio" >> ~/.shortcuts/dbdown.sh
chmod a+x ~/.shortcuts/dbdown.sh
```

Now your databases can all be started/stopped from the termux widget!

## Configuring Databases for Remote Access

This has been disabled for safety reasons by default. What you can instead do
is to create an ssh tunnel.

Add the following entry to `~/.ssh/config` on the laptop/desktop from where
you'd like to be able to access Termux's databases:


```
# Termux
Host 192.168.1.14
    HostName 192.168.1.14
    LocalForward localhost:19000 localhost:9000
    LocalForward localhost:15432 localhost:5432
    LocalForward localhost:16379 localhost:6379
    Port 8022
```

Now you can simply do `ssh 192.168.1.14` and you'd automatically forward the
databases to local ports.

I tend to add 10000 to the port numbers because I wouldn't like a conflict
between a locally installed database and one which is remotely accessed.

## Other Stuff

More coming soon!

