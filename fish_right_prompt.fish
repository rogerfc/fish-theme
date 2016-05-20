function fish_right_prompt
  function find_hg_root
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

  if find_hg_root 2>&1
    set_color black
    printf '['

    # show red dot if there are uncommited changes
    if test (count (hg status)) != 0
      set_color red
      printf '●'
    end

    set_color black
    printf 'hg:'

    # show branch name
    set_color green
    printf '%s' (cat "$HG_ROOT/branch" 2>/dev/null; or hg branch)

    set_color black
    printf '@'

    # show 7 digits of commit hash (like git)
    set_color yellow
    printf '%s' (hexdump -n 4 -e '1/1 "%02x"' "$HG_ROOT/dirstate" | cut -c-7)

    set_color black
    printf ']'
  end

  set_color normal
end
