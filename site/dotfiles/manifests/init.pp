
class dotfiles (
  String $user,
  String $source_repository = 'https://github.com/imjoshholloway/dotfiles.git'
) {

  include dotfiles::antibody
  include dotfiles::tmux
}
