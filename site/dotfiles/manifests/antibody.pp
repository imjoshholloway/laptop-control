
class dotfiles::antibody inherits dotfiles {

  exec { 'install antibody':
    command => 'curl -sL https://git.io/antibody | bash -s',
    creates => '/usr/local/bin/antibody',
    path    => $::path
  }
}
