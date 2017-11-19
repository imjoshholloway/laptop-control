#!/usr/bin/env bash
#
# This bootstraps Puppet on Ubuntu >16.04.
#
set -e

# Load up the release information
. /etc/lsb-release

DEB_PACKAGE="puppet5-release-${DISTRIB_CODENAME}.deb"
REPO_DEB_URL="http://apt.puppetlabs.com/${DEB_PACKAGE}.deb"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

PUPPET_ENV=master
CODE_DIR=/etc/puppetlabs/code
PUPPET_DIR=/opt/puppetlabs/puppet

run_puppet() {
    $PUPPET_DIR/bin/puppet apply -t $CODE_DIR/environments/$PUPPET_ENV/manifests/site.pp
}

setup_repo() {
    # Check if the repo already exists before adding it
    # We mainly do this because curl'ing from a remote URL can be slooowww
    if $(apt-cache policy | grep --quiet apt.puppetlabs.com); then
        echo "Puppetlabs repo is already installed."
    else
        # Install the PuppetLabs repo
        echo "Setting up Puppetlabs repo..."
        curl -O "${REPO_DEB_URL}" 2>/dev/null
        dpkg -i "${DEB_PACKAGE}" >/dev/null
        apt-get update >/dev/null
    fi
}

install_deps() {
    echo "Installing Puppet & dependencies..."
    apt-get install --yes puppet-agent
    $PUPPET_DIR/bin/gem install r10k
}

setup_r10k() {
    mkdir -p /etc/puppetlabs/r10k
    cat > /etc/puppetlabs/r10k/r10k.yaml << YAML
    :cachedir: "/var/cache/r10k"

    :sources:
        :laptop:
            remote: "https://github.com/imjoshholloway/laptop-control.git"
            basedir: "${CODE_DIR}/environments"
YAML

    $PUPPET_DIR/bin/r10k deploy environment -p

    # set the config to use our "master" environment
    $PUPPET_DIR/bin/puppet config set --section=main environment $PUPPET_ENV
}

setup_repo
install_deps
setup_r10k
run_puppet
