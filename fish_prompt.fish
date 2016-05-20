# You can override some default options with config.fish:
#
#  set -g theme_short_path yes
#  set -g theme_hostname (hostname | cut -d . -f 1)
#  set -g theme_prompt_logo \U1F420 " " # Tropical fish

function fish_prompt
  set -l last_command_status $status
  set -l cwd

  if test "$theme_short_path" = 'yes'
    set cwd (basename (prompt_pwd))
  else
    set cwd (prompt_pwd)
  end

  if not set -q theme_prompt_logo
    set -g theme_prompt_logo "⋊>"
  end

  set -l fish $theme_prompt_logo

  set -l ahead    "↑"
  set -l behind   "↓"
  set -l diverged "⥄ "
  set -l dirty    "⨯"
  set -l none     "◦"

  set -l normal_color     (set_color normal)
  set -l success_color    (set_color $fish_pager_color_progress ^/dev/null; or set_color cyan)
  set -l error_color      (set_color $fish_color_error ^/dev/null; or set_color red --bold)
  set -l directory_color  (set_color $fish_color_quote ^/dev/null; or set_color brown)
  set -l repository_color (set_color $fish_color_cwd ^/dev/null; or set_color green)

  if test $last_command_status -eq 0
    echo -n -s $success_color $fish $normal_color
  else
    echo -n -s $error_color $fish $normal_color
  end

  if set -q theme_hostname
    echo -n -s " $theme_hostname"
  end

  echo -n -s " " $directory_color $cwd $normal_color

  echo -n -s " "
end
