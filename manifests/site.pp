
node default {

  include apt

  $user = lookup('username')

  user { $user:
    ensure => present,
  }

  # Add the sshkeys from hiera
  $sshkeys = lookup('sshkeys')
  if ($sshkeys) {
    create_resources(sshkey, lookup('sshkeys'))
  }

  $packages = {
    'tmux'              => {},
    'vim'               => {},
    'firefox'           => {},
    # theme
    'unity-tweak'       => {},
    'flatabulous-theme' => {},
  }

  create_resources(package, $packages, { ensure => latest, require => Class['apt::update'] })

  class { 'dotfiles':
    user => $user
  }
}
