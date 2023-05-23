#!/usr/bin/env perl

# Simple helpers

sub tee {
    my $file = shift; # first argument is the file
    my $lines = join("\n", @_); # assume the next arguments are the lines
    print "Writing to $file\n";
    print "$lines\n";
    my $fh;
    open(FH, '>', $file) or die "Couldn't open $file for writing! You should run this as root.";
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

sub apt_add_repo {
    my $repo = shift;
    system("add-apt-repository '$repo' -n -y");
}

sub apt_add_repo_file {
    my $name = shift;
    my $file = "/etc/apt/sources.list.d/$name.list";
    tee($file, @_);
}

sub apt_add_key {
    my $url = shift;
    my $key = `curl -sL '$url'`;
    print "Adding apt key: \n$key\n";
    system("curl -sL '$url' | apt-key add -");
}

sub manual_add_key {
    my $name = shift;
    my $url = shift;
    system("wget -O /usr/share/keyrings/$name.gpg '$url'");
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

# Parse CLI parameters and set flags

print "Parsing CLI Params @ARGV\n";

my %cli_params = map {$_ => 1} @ARGV;

my $enable_server = 0;
if(exists($cli_params{'server'})) {
    print "Server Enabled";
    $enable_server = 1;
}

my $enable_desktop = 0;
if(exists($cli_params{'desktop'})) {
    print "Desktop Enabled\n";
    $enable_desktop = 1;
}

my $enable_developer = 0;
if(exists($cli_params{'developer'})) {
    print "Developer Enabled\n";
    $enable_desktop = 1;
    $enable_developer = 1;
}

my $enable_proaudio = 0;
if(exists($cli_params{'proaudio'})) {
    print "Pro Audio Enabled\n";
    $enable_desktop = 1;
    $enable_proaudio = 1;
}

if(exists($cli_params{'all'})) {
    print "EVERYTHING is Enabled\n";
    $enable_server = 1;
    $enable_desktop = 1;
    $enable_developer = 1;
    $enable_proaudio = 1;
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

# Universe Repo
print "Enable Universe Repo\n";
apt_add_repo('universe');

if ($enable_desktop) {
  print "Enable Signal Repo\n";
  apt_add_key('https://updates.signal.org/desktop/apt/keys.asc');
  apt_add_repo_file(
      'signal',
      'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main',
  );
}

if ($enable_server) {
    print "Enable Nodesource Repo\n";
    apt_add_key('https://deb.nodesource.com/gpgkey/nodesource.gpg.key');
    apt_add_repo_file(
        'nodesource',
        'deb https://deb.nodesource.com/node_17.x impish main',
        'deb-src https://deb.nodesource.com/node_17.x impish main',
    );

    print "Enable Dart Repo\n";
    apt_add_key('https://dl-ssl.google.com/linux/linux_signing_key.pub');
    apt_add_repo_file(
        'dart_stable',
        'deb [arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main',
    );
}

if ($enable_developer) {
    print "Enable Cubic Repo\n";
    apt_add_repo('ppa:cubic-wizard/release');
    
    print "Enable Insomnia Repo\n";
    apt_add_key('https://insomnia.rest/keys/debian-public.key.asc');
    apt_add_repo_file(
        'insomnia',
        'deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all',
    );

    print "Enable VSCode Repo\n";
    apt_add_key('https://packages.microsoft.com/keys/microsoft.asc');
    apt_add_repo_file(
        'vscode',
        'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main',
    );

    print "Enable pgAdmin4 Repo\n";
    apt_add_key('https://www.pgadmin.org/static/packages_pgadmin_org.pub');
    apt_add_repo_file(
        'pgadmin4',
        'deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/impish pgadmin4 main',
    );

    apt_install_deb(
        'mongodb-compass-isolated',
        'https://downloads.mongodb.com/compass/mongodb-compass-isolated_1.29.5_amd64.deb',
    );
}

if ($enable_proaudio) {
    print "Enable OBS Studio Repo\n";
    apt_add_repo('ppa:obsproject/obs-studio');
}

print "Initial apt-update and full-upgrade\n";
apt_update();
apt_upgrade();

my @list_server = (
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
    'qemu',
    'qemu-user-static',
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
    'golang-1.17-go',
    'exfat-fuse',
    'exfat-utils',
    'adb',
    'fastboot',
    'mtp-tools',
    'libmtp-common',
    'libmtp-dev',
    'libmtp-runtime',
    'libmtp9',
    'quassel-core',
    'bind9',
    'bind9utils',
    'bind9-doc',
    'dnsutils',
);

my @list_desktop = (
    'fonts-comic-neue',
    'cpupower-gui',
    'keepassxc',
    'seahorse',
    'libreoffice',
    'telegram-desktop',
    'signal-desktop',
    'deluge',
    'gparted',
    'gnome-disk-utility',
    'gthumb',
    'cheese',
    'gnome-tweaks',
    'gnome-shell-extension-system-monitor',
    'gpaste',
    'gnome-shell-extension-gpaste',
    'neovim-qt',
    'tilix',
    'gnome-shell-extension-tilix-dropdown',
    'gnome-shell-extension-tilix-shortcut',
    'gnome-shell-extension-draw-on-your-screen',
    'gnome-shell-extension-gsconnect',
    'gnome-shell-extension-freon',
    'gnome-shell-extension-hard-disk-led',
    'gnome-shell-extension-bluetooth-quick-connect',
    'gnome-shell-extension-caffeine',
    'dconf-editor',
);

my @list_developer = (
    'code',
    'cubic',
    'insomnia',
);

my @list_proaudio = (
    'linux-lowlatency',
    'ubuntustudio-audio',
    'ubuntustudio-graphics',
    'ubuntustudio-photography',
    'ubuntustudio-publishing',
    'ubuntustudio-video',
    'handbrake',
    'ubuntustudio-lowlatency-settings',
    'ubuntustudio-performance-tweaks',
    'carla',
    'vmpk',
    'fonts-comic-neue',
    'v4l-utils',
    'v4l2loopback-dkms',
    'v4l2loopback-utils',
    'obs-studio',
    'olive-editor',
);

my @list_install = ();

if ($enable_server) {
    push(@list_install, @list_server);
}

if ($enable_desktop) {
    push(@list_install, @list_desktop);
}

if ($enable_developer) {
    push(@list_install, @list_developer);
}

if ($enable_proaudio) {
    push(@list_install, @list_proaudio);
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

print "Finished Ubuntu 21.10 Setup!\n";
