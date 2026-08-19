function __jj_prompt
    jj log --revisions @ --no-graph --ignore-working-copy --color never --limit 1 --template '
        separate(" ",
          change_id.shortest(4),
          separate(" ", bookmarks.map(|b|
            if(b.name().len() > 20, b.name().substr(0, 19) ++ "…", b.name())
            ++ if(!b.synced(), "*")
          )),
          concat(
            if(conflict, raw_escape_sequence("\x1b[1;31m") ++ "×"),
            if(divergent, "‼️"),
            if(hidden, "👻"),
            if(immutable, "🔒"),
            if(empty, raw_escape_sequence("\x1b[1;32m") ++ "·"),
          ),
          )
      '
end

function is_jj_repo
    jj root >/dev/null 2>&1
    return $status
end

function _tide_item_jj
    if is_jj_repo
        _tide_print_item jj $tide_jj_icon' ' (__jj_prompt)
    end
end
