%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Display the functions
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(code_editor).

%%%_* Exports ==================================================================
-export([ read/1
        , read_all/0
        , delete/1
        , delete_all/0
        , write/1
        ]).

%%%_* Macro  ===================================================================
-define(ID_UNDEFINED, -1).
-define(TAB_NAME, code_editor).

%%%_* Records  =================================================================
-record(code_editor, { id   = ?ID_UNDEFINED
                     , code = ""
                     , x    = 0
                     , y    = 0
                     , z    = 0
         }).

%%%_* Type =====================================================================
-type code_editor() :: #code_editor{}.

%%%_* Code  ====================================================================
-spec read(Id :: integer()) -> code_editor().
read(Id) ->
  [CodeEditor] = mnesia:dirty_read(?TAB_NAME, Id),
  CodeEditor.

-spec write(CodeEditor :: code_editor()) -> ok.
write(CodeEditor) ->
  ok = mnesia:dirty_write(?TAB_NAME, CodeEditor).

-spec delete(Id :: integer()) -> ok.
delete(Id) ->
  ok = mnesia:dirty_delete(?TAB_NAME, Id).

-spec read_all() -> [code_editor()].
read_all() ->
  lists:foldl(fun(Key, Acc) ->
                  [CodeEditor] = mnesia:dirty_read(?TAB_NAME, Key),
                  [CodeEditor|Acc]
              end, [], mnesia:dirty_all_keys(?TAB_NAME)).

-spec delete_all() -> ok.
delete_all() ->
  lists:foreach(fun(Key) ->
                    ok = mnesia:dirty_delete(?TAB_NAME, Key)
                end, mnesia:dirty_all_keys(?TAB_NAME)).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
