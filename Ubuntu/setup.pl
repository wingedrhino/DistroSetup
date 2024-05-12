#!/usr/bin/env perl

# Simple helpers

sub tee {
  my $file = shift; # first argument is the file
  my $lines = join("\n", @_); # assume the next arguments are the lines
  print "Writing to $file\n";
  print "$lines\n";
  my $fh;
  open(FH, '>', $file) or die "Couldn't open $file for writing! You should run this as root.\n";
  print FH "$lines\n";
  close(FH);
}

sub apt_update {
  system('apt update');
}

sub apt_upgrade {
  system('apt full-upgrade -y');
}

sub apt_install {
  my $pkgs = join(" ", @_);
  my $cmd = "apt-get install $pkgs -y";
  print("RUN $cmd\n");
  system($cmd);
}

sub apt_install_recommends {
  my $pkgs = join(' ', @_);
  my $cmd = "apt-get install --install-recommends $pkgs -y";
  print("RUN $cmd\n");
  system($cmd);
}

sub apt_enable_repo {
  my $repo = shift;
  system("add-apt-repository '$repo' -n -y");
}

sub apt_add_repo {
  my $name = shift;
  my $file = "/etc/apt/sources.list.d/$name.list";
  tee($file, @_);
}

sub apt_add_key {
  my $filename = shift;
  my $url = shift;
  system("wget -O- $url | gpg --dearmor > /etc/apt/keyrings/$filename");
}

sub apt_install_deb {
  my $name = shift;
  my $url = shift;
  system("wget -c -O ./$name.deb '$url'");
  system("apt-get install -y ./$name.deb");
}

sub apt_autoremove {
  system('apt autoremove -y');
}

# Parse commandline parameters and set flags

print "Parsing CLI Params @ARGV\n";

my %cli_params = map {$_ => 1} @ARGV;

my $install_gui = 1;
if(exists($cli_params{'headless'})) {
  print "Headless Installation Enabled";
  $install_gui = 0;
}

# Begin Setup

print "Begin Ubuntu 21.10 Setup Process!\n";

my @installer_helpers = (
  'curl',
  'apt-transport-https',
  'ppa-purge',
  'software-properties-common',
);

print "Install software needed for installer\n";
apt_install(@installer_helpers);

# Universe Repository
print "Enable Universe Repo\n";
apt_enable_repo('universe');

print "Enable Signal Repo\n";
apt_add_key(
  'signal.gpg',
  'https://updates.signal.org/desktop/apt/keys.asc',
);
apt_add_repo(
  'signal',
  'deb [arch=amd64 signed-by=/etc/apt/keyrings/signal.gpg] https://updates.signal.org/desktop/apt xenial main',
);

print "Enable Nodesource Repo\n";
apt_add_key(
  'nodesource.gpg',
  'https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key',
);
apt_add_repo(
  'nodesource',
  'deb [arch=amd64 signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main',
);

print "Enable Dart Repo\n";
apt_add_key(
  'google.gpg',
  'https://dl-ssl.google.com/linux/linux_signing_key.pub',
);
apt_add_repo(
  'dart',
  'deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main',
);

print "Enable Brave Browser Repo\n";
apt_add_key(
  'brave.gpg',
  'https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg',
);
apt_add_repo(
  'brave',
  'deb [signed-by=/etc/apt/keyrings/brave.gpg] https://brave-browser-apt-release.s3.brave.com stable main',
);

print "Enable VSCode Repo\n";
apt_add_key(
  'microsoft.gpg',
  'https://packages.microsoft.com/keys/microsoft.asc',
);
apt_add_repo(
  'vscode',
  'deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main',
);

print "Enable pgAdmin4 Repo\n";
apt_add_key(
  'pgadmin.gpg',
  'https://www.pgadmin.org/static/packages_pgadmin_org.pub',
);
apt_add_repo(
  'pgadmin4',
  'deb [signed-by=/etc/apt/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/mantic pgadmin4 main',
);

if ($install_gui) {
  apt_install_deb(
    'mongodb-compass_1.43.0_amd64.deb',
    'https://downloads.mongodb.com/compass/mongodb-compass-isolated-1.43.0_amd64.deb',
  );
}

print "Initial apt-update and full-upgrade\n";
apt_update();
apt_upgrade();

my @list_cli = (
  'byobu',
  'zsh',
  'udisks2',
  'aptitude',
  'hexedit',
  'parallel',
  'fd-find',
  'ripgrep',
  'iotop',
  'atop',
  'binfmt-support',
  'vim',
  'neovim',
  'emacs',
  'tar',
  'lzip',
  'p7zip',
  'p7zip-full',
  'p7zip-rar',
  'unzip',
  'qrencode',
  'zbar-tools',
  'ffmpeg',
  'imagemagick',
  'qpdf',
  'smartmontools',
  'rclone',
  's3cmd',
  'mosh',
  'sshfs',
  'whois',
  'curl',
  'wget',
  'iperf3',
  'nmap',
  'nethogs',
  'wireguard',
  'fail2ban',
  'openssh-server',
  'git-all',
  'doxygen',
  'doxygen-doc',
  'build-essential',
  'cmake',
  'automake',
  'libtool',
  'pkg-config',
  'devscripts',
  'equivs',
  'gdebi-core',
  'nginx',
  'certbot',
  'python3-certbot-nginx',
  'docker.io',
  'docker-compose',
  'nodejs',
  'python3',
  'python3-pip',
  'python3-venv',
  'ipython3',
  'dart',
  'golang-1.22-go',
  'exfat-fuse',
  'exfatprogs',
  'adb',
  'fastboot',
  'mtp-tools',
  'libmtp-common',
  'libmtp-dev',
  'libmtp-runtime',
  'libmtp9',
  'bind9',
  'bind9utils',
  'bind9-doc',
  'dnsutils',
);


my @list_gui = (
  'fonts-comic-neue',
  'gpaste-2',
  'gnome-shell-extensions',
  'gnome-shell-extension-*',
  'dconf-editor',
  'gthumb',
  'gnome-tweaks',
  'gnome-disk-utility',
  'gparted',
  'cpupower-gui',
  'cheese',
  'vlc',
  'vlc-plugin-*',
  'keepassxc',
  'libreoffice',
  'brave-browser',
  'code',
  'signal-desktop',
  'deluge',
  'neovim-qt',
  'tilix',
  'ubuntustudio-installer',
  'v4l-utils',
  'v4l2loopback-dkms',
  'v4l2loopback-utils',
);

my @list_install = ();
push(@list_install, @list_cli);

if ($install_gui) {
  push(@list_install, @list_gui)
}

print "Giant apt-install of new packages coming up!\n";
apt_install(@list_install);

print "Try to auto-install custom graphics drivers and hope for the best!\n";
system('ubuntu-drivers autoinstall');

print "Final apt autoremove\n";
apt_autoremove();

print "Enable Docker Service\n";
system('systemctl enable docker');

print "Copying over sample NGINX configs\n";
system('cp ../nginx/*.conf /etc/nginx/sites-available/');

print "Finished Ubuntu Setup!\n";
  
