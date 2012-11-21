%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc RETT supervisor
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(rett_sup).

-behaviour(supervisor).

%%%_* Exports ==================================================================
%% API
-export( [ start_link/0
         ]).

%% Supervisor callbacks
-export( [ init/1
         ]).

%%%_* Macros ===================================================================
%% Helper macro for declaring children of supervisor
-define(CHILD(I, A, T), {I, {I, start_link, [A]}, permanent, 5000, T, [I]}).

%%%_* Code =====================================================================
%% API functions
start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% Supervisor callbacks
init([]) ->
  Ip     = rett_util:get_env(web_ip, "0.0.0.0"),
  Port   = rett_util:get_env(web_port, 8000),
  LogDir = rett_util:get_env(log_dir, "priv/log"),

  {ok, Dispatch} = file:consult(filename:join( code:priv_dir(rett)
                                             , "dispatch.conf")),

  WebConfig = [ {ip, Ip}
              , {port, Port}
              , {log_dir, LogDir}
              , {dispatch, Dispatch}],

  Web = ?CHILD(webmachine_mochiweb, WebConfig, worker),
  {ok, { {one_for_one, 5, 10}, [Web]} }.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
