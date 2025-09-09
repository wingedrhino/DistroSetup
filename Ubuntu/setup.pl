#!/usr/bin/env perl

use strict;
use warnings;
use FindBin; # Used to get the script's directory

# --- Configuration ---
my $K8S_VERSION = "v1.30";
my $KIND_VERSION = "v0.23.0";
my $NODE_VERSION = "24.x";
my $POSTGRES_VERSION = "17";
# --- End Configuration ---

# Ensure the script is run as root
if ($> != 0) {
    die "This script must be run as root! Please use sudo.\n";
}

# --- System Information ---
# Compute Distro Name (it can be either debian or ubuntu)
my $distro_name = `. /etc/os-release && echo \$ID`;
chomp($distro_name);

# Compute Distro Codename (e.g. noble, trixie)
# lsb_release might not be installed, so we install it first.
system("apt-get install -y lsb-release") == 0 or die "Failed to install lsb-release: $?";
my $distro_codename = `lsb_release -cs`;
chomp($distro_codename);

# Compute Distro Arch (it can be armhf, arm64, or amd64)
my $distro_arch = `dpkg --print-architecture`;
chomp($distro_arch);

# --- Helper Subroutines ---

sub tee {
  my ($file, @lines) = @_;
  print "Writing to $file\n";
  print join("\n", @lines), "\n";
  open(my $fh, '>', $file) or die "Couldn't open $file for writing: $!";
  print $fh join("\n", @lines), "\n";
  close($fh);
}

sub apt_update {
  system('apt-get update') == 0 or die "apt-get update failed: $?";
}

sub apt_upgrade {
  system('apt-get full-upgrade -y') == 0 or die "apt-get full-upgrade failed: $?";
}

sub apt_install {
  my $pkgs = join(" ", @_);
  return if !$pkgs;
  my $cmd = "apt-get install $pkgs -y";
  print("RUN $cmd\n");
  system($cmd) == 0 or die "Failed to install packages: $pkgs. Error: $?";
}

sub apt_add_repo {
  my ($name, @lines) = @_;
  my $file = "/etc/apt/sources.list.d/$name.list";
  tee($file, @lines);
}

sub apt_add_key {
  my ($filename, $url) = @_;
  my $keyring_path = "/etc/apt/keyrings/$filename";
  my $tmp_key_path = "/tmp/$filename.asc";
  print "Downloading GPG key from $url\n";
  system("curl -fsSL -o $tmp_key_path \"$url\"") == 0
    or die "Failed to download GPG key from $url. Error: $?";
  print "Dearmoring GPG key to $keyring_path\n";
  system("gpg --dearmor -o $keyring_path $tmp_key_path") == 0
    or die "Failed to dearmor key $tmp_key_path. Error: $?";
  unlink $tmp_key_path;
}

sub install_binary {
    my ($name, $url) = @_;
    my $bin_path = "/usr/local/bin/$name";
    print "Installing binary $name from $url to $bin_path\n";
    system("curl -L -o $bin_path \"$url\"") == 0
        or die "Failed to download binary from $url. Error: $?";
    system("chmod +x $bin_path") == 0
        or die "Failed to make binary executable: $bin_path. Error: $?";
}

sub apt_autoremove {
  system('apt-get autoremove -y') == 0 or die "apt-get autoremove failed: $?";
}

sub debian_enable_contrib_nonfree {
    print "Enabling contrib and non-free repositories for Debian...\n";
    # This command is idempotent and safe for default sources.list files
    system(q(sed -i -E 's/^(deb.*(main|stable))$/\1 contrib non-free non-free-firmware/' /etc/apt/sources.list)) == 0
        or die "Failed to enable contrib/non-free repos. Error: $?";
}

sub get_sudo_user {
    my $sudo_user = $ENV{'SUDO_USER'};
    if (!$sudo_user) {
        print "WARNING: Cannot determine non-root user (SUDO_USER not set). Skipping user-specific tasks.\n";
        return "";
    }
    return $sudo_user;
}

sub add_user_to_docker_group {
    my $user = get_sudo_user();
    return if !$user;
    print "Adding user '$user' to the 'docker' group...\n";
    system("usermod -aG docker $user") == 0
        or die "Failed to add user '$user' to docker group. Error: $?";
    print "INFO: User '$user' added to docker group. They may need to log out and log back in for this to take effect.\n";
}

sub set_default_shell_zsh {
    my $user = get_sudo_user();
    return if !$user;
    my $zsh_path = "/usr/bin/zsh";
    if (-e $zsh_path && `grep -Fxq "$zsh_path" /etc/shells`) {
         print "Setting zsh as the default shell for user '$user'...\n";
         system("chsh -s $zsh_path $user") == 0
            or die "Failed to set zsh as default shell for '$user'. Error: $?";
    } else {
        print "WARNING: $zsh_path not found or not listed in /etc/shells. Cannot set as default.\n";
    }
}

# --- Main Logic ---

# Parse commandline parameters and set flags
print "Parsing CLI Params @ARGV\n";
my %cli_params = map {$_ => 1} @ARGV;
my $install_gui = !exists($cli_params{'headless'});
print($install_gui ? "GUI Installation Enabled\n" : "Headless Installation Enabled\n");

# Begin Setup
print "Begin $distro_name ($distro_codename) $distro_arch Setup Process!\n";

my @installer_helpers = (
  'curl',
  'apt-transport-https',
  'ppa-purge',
  'software-properties-common',
);

print "Install software needed for installer\n";
apt_install(@installer_helpers);

# Enable distro-specific repositories
if ($distro_name eq 'ubuntu') {
    print "Enable Universe Repo\n";
    system("add-apt-repository 'universe' -n -y") == 0 or die "Failed to enable universe repo: $?";
} elsif ($distro_name eq 'debian') {
    debian_enable_contrib_nonfree();
}

# Add Third-Party Repositories

# NOTE: The 'xenial' codename is correct for all Debian/Ubuntu-based systems,
# as per Signal's official installation instructions.
print "Enable Signal Repo\n";
apt_add_key('signal.gpg', 'https://updates.signal.org/desktop/apt/keys.asc');
apt_add_repo('signal', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/signal.gpg] https://updates.signal.org/desktop/apt xenial main");

print "Enable Nodesource Repo\n";
apt_add_key('nodesource.gpg', 'https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key');
apt_add_repo('nodesource', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION nodistro main");

print "Enable Dart Repo\n";
apt_add_key('google.gpg', 'https://dl-ssl.google.com/linux/linux_signing_key.pub');
apt_add_repo('dart', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/google.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main");

print "Enable pgAdmin4 Repo\n";
apt_add_key('pgadmin.gpg', 'https://www.pgadmin.org/static/packages_pgadmin_org.pub');
apt_add_repo('pgadmin4', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$distro_codename pgadmin4 main");

print "Enable PostgreSQL Repo\n";
my $pg_key_path = '/etc/apt/keyrings/postgresql.gpg';
apt_add_key('postgresql.gpg', 'https://www.postgresql.org/media/keys/ACCC4CF8.asc');
apt_add_repo('pgdg', "deb [signed-by=$pg_key_path] http://apt.postgresql.org/pub/repos/apt/ $distro_codename-pgdg main");

# Add repos for packages that only support amd64 and arm64
if ($distro_arch eq 'amd64' or $distro_arch eq 'arm64') {
    print "Enable Brave Browser Repo\n";
    apt_add_key('brave.gpg', 'https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg');
    apt_add_repo('brave', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/brave.gpg] https://brave-browser-apt-release.s3.brave.com stable main");

    print "Enable VSCode Repo\n";
    apt_add_key('microsoft.gpg', 'https://packages.microsoft.com/keys/microsoft.asc');
    apt_add_repo('vscode', "deb [arch=$distro_arch signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main");

    print "Enable Kubernetes Repo\n";
    apt_add_key('kubernetes-apt-keyring.gpg', "https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/Release.key");
    apt_add_repo('kubernetes', "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/ /");
}

print "Initial apt-update and full-upgrade\n";
apt_update();
apt_upgrade();

# --- Define Package Lists ---

my @list_cli = (
    # Core System & Shell
    'aptitude',
    'binfmt-support',
    'byobu',
    'parallel',
    'udisks2',
    'zsh',

    # System Monitoring & Diagnostics
    'atop',
    'iotop',
    'nethogs',
    'smartmontools',

    # Networking & Remote Access
    'curl',
    'fail2ban',
    'iperf3',
    'mosh',
    'nmap',
    'openssh-server',
    'sshfs',
    'wget',
    'whois',
    'wireguard',

    # File, Search & Archive Utilities
    'fd-find',
    'hexedit',
    'lzip',
    'p7zip',
    'p7zip-full',
    'p7zip-rar',
    'ripgrep',
    'tar',
    'unzip',

    # Development Tools
    'automake',
    'build-essential',
    'cmake',
    'devscripts',
    'doxygen',
    'doxygen-doc',
    'equivs',
    'gdebi-core',
    'git-all',
    'libtool',
    'pkg-config',

    # Text Editors
    'emacs',
    'neovim',
    'vim',

    # Programming Languages & Runtimes
    'dart',
    'ipython3',
    'nodejs',
    'pipx',
    'python3',
    'python3-pdm',
    'python3-pip',
    'python3-venv',
    'rustup',

    # Web & Services
    'certbot',
    'docker.io',
    'nginx',
    'python3-certbot-nginx',

    # Databases
    "postgresql-$POSTGRES_VERSION",

    # Media & Imaging
    'ffmpeg',
    'imagemagick',
    'qpdf',
    'qrencode',
    'zbar-tools',

    # Cloud & Storage
    'rclone',
    's3cmd',

    # Filesystem & Device Tools
    'adb',
    'exfat-fuse',
    'exfatprogs',
    'fastboot',
    'libmtp-common',
    'libmtp-dev',
    'libmtp-runtime',
    'libmtp9',
    'mtp-tools',

    # DNS & Network Services
    'bind9',
    'bind9-doc',
    'bind9utils',
    'dnsutils',
);

my @list_gui = (
    # Core Applications
    'keepassxc',
    'libreoffice',
    'qbittorrent',
    'vlc',
    'vlc-plugin-*',

    # Fonts
    'fonts-comic-neue',
    'fonts-inconsolata',
    'fonts-roboto',

    # KDE/Qt Utilities
    'kamoso',
    'partitionmanager',

    # Development & Text Editors
    'neovim-qt',
    'pgadmin4',

    # Video & Camera Utilities
    'v4l-utils',
    'v4l2loopback-dkms',
    'v4l2loopback-utils',
);

my @list_install = @list_cli;

# Add packages and binaries for amd64 and arm64
if ($distro_arch eq 'amd64' or $distro_arch eq 'arm64') {
    push(@list_install, 'kubectl');
    install_binary('kind', "https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$distro_arch");

    if ($install_gui) {
        push(@list_gui, 'brave-browser', 'code', 'signal-desktop');
    }
} else {
    print "Skipping kubectl, kind, Brave, VSCode, and Signal: unsupported architecture $distro_arch\n";
}

if ($install_gui) {
  push(@list_install, @list_gui);
}

print "Giant apt-install of new packages coming up!\n";
apt_install(@list_install);

# Final system setup
if ($distro_name eq 'ubuntu' and $distro_arch eq 'amd64') {
    print "Try to auto-install custom graphics drivers and hope for the best!\n";
    system('ubuntu-drivers autoinstall') == 0 or print "ubuntu-drivers autoinstall failed (non-critical). Error: $?\n";
}

print "Final apt autoremove\n";
apt_autoremove();

print "Enable Docker Service\n";
system('systemctl enable docker') == 0 or die "Failed to enable docker service: $?";

# Post-install quality-of-life improvements
add_user_to_docker_group();
set_default_shell_zsh();

print "Copying over sample NGINX configs\n";
my $nginx_config_path = "$FindBin::Bin/../nginx/*.conf";
system("cp $nginx_config_path /etc/nginx/sites-available/") == 0
    or die "Failed to copy NGINX configs from $nginx_config_path. Error: $?";

print "Finished $distro_name-$distro_codename-$distro_arch setup!\n";
