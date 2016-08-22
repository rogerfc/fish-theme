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

  set -l normal_color     (set_color normal)
  set -l success_color    (set_color $fish_pager_color_progress ^/dev/null; or set_color cyan)
  set -l error_color      (set_color $fish_color_error ^/dev/null; or set_color red --bold)
  set -l directory_color  (set_color $fish_color_quote ^/dev/null; or set_color brown)
  set -l repository_color (set_color $fish_color_cwd ^/dev/null; or set_color green)

  set -l vcs_name_color   (set_color $directory_color ^/dev/null; or set_color brown)
  set -l vcs_dirty_color  (set_color $directory_color ^/dev/null; or set_color brown)
  set -l vcs_branch_color (set_color $directory_color ^/dev/null; or set_color brown)

  set -l vcs_dirty_char '+'

  if test $last_command_status -eq 0
    echo -n -s $success_color $fish $normal_color
  else
    echo -n -s $error_color $fish $normal_color
  end

  __get_vcs
  if test $vcs_type
    echo -n -s " " $repository_color $vcs_type ":" $vcs_branch_color $vcs_branch
    if test -n "$vcs_dirty"
      echo -n -s $vcs_dirty_color $vcs_dirty_char
    end
    echo -n -s $normal_color
  end

  if set -q theme_hostname
    echo -n -s " $theme_hostname"
  end

  echo -n -s " " $directory_color $cwd $normal_color
  echo -n -s " "
end


function __get_vcs

  function __fast_find_git_root
    git rev-parse --show-toplevel > /dev/null 2>&1
  end

  function __fast_git_dirty
    test (count (git status --porcelain)) != 0
  end

  function __fast_git_branch
    git rev-parse --abbrev-ref HEAD
  end

  function __fast_find_hg_root
    set -l dir (pwd)
    set -e HG_ROOT

    while test $dir != "/"
      if test -f $dir'/.hg/dirstate'
        set -g HG_ROOT $dir"/.hg"
        return 0
      end
      set -l dir (dirname $dir)
    end

    return 1
  end

  function __fast_hg_dirty
    test (count (hg status --cwd $HG_ROOT)) != 0
  end

  function __fast_hg_branch
    cat "$HG_ROOT/branch" 2>/dev/null
    or hg branch
  end

  if __fast_find_git_root
    set -g vcs_type 'git'
  else if __fast_find_hg_root
    set -g vcs_type 'hg'
  else
    set -e vcs_type
  end

  if test $vcs_type
    switch $vcs_type
      case git
        set -g vcs_branch (__fast_git_branch)
        __fast_git_dirty; and set -g vcs_dirty "dirty"; or set -e vcs_dirty
      case hg
        set -g vcs_branch (__fast_hg_branch)
        __fast_hg_dirty; and set -g vcs_dirty "dirty"; or set -e vcs_dirty
      case '*'
        return 1
    end
  end

end
