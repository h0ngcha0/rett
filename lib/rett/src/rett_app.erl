%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc RETT app entry module
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(rett_app).

-behaviour(application).

%%%_* Exports ==================================================================
%% Application callbacks
-export( [ start/0
         , start/2
         , stop/1]).

%%%_* Code =====================================================================
%% Application callbacks
start() ->
  start_deps(),
  ensure_tables_exist(),
  application:start(rett).

start(_StartType, _StartArgs) ->
  rett_sup:start_link().

stop(_State) ->
  stop_deps(),
  ok.

%%%_* Internal Functions ===============================================
dependent_applications() ->
  [ crypto
  , compiler
  , syntax_tools
  , lager
  , public_key
  , ssl
  , inets
  , webmachine
  , erlydtl
  , mnesia
  ].

start_deps() ->
  lists:foreach( fun(App) ->
                     ensure_start(App)
                 end
               , dependent_applications()).

stop_deps() ->
  lists:foreach( fun(App) ->
                     application:stop(App)
                 end
               , lists:reverse(dependent_applications())).

ensure_start(App) ->
  case application:start(App) of
    {error, {already_started, App}} -> ok;
    ok                              -> ok
  end.

ensure_tables_exist() ->
  lists:foreach(fun ensure_table_exist/1, dependent_tables()).

ensure_table_exist(Tab) ->
  case mnesia:create_table(Tab, []) of
    {aborted,{already_exists,Tab}} -> ok;
    {atomic, ok}                   -> ok
  end.

dependent_tables() ->
  [ code_editor
  ].

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
