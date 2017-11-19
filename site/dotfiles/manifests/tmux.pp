
class dotfiles::tmux (
  $user = $dotfiles::user,
  $config_dir = "/home/$user/.tmux"
) inherits dotfiles {

  $plugins_dir = "$config_dir/plugins"

  file { [ $config_dir, $plugins_dir ]:
    recurse => true,
    ensure  => directory,
    owner   => $user,
    group   => $user,
  }

  vcsrepo { "$plugins_dir/tpm":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/tmux-plugins/tpm',
    owner    => $user,
    group    => $user,
  }
}
