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
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%%_* Code =====================================================================
%% API functions
start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% Supervisor callbacks
init([]) ->
  {ok, { {one_for_one, 5, 10}, []} }.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
