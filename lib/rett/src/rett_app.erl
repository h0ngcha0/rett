%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc RETT app entry module
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(rett_app).

-behaviour(application).

%%%_* Exports ==================================================================
%% Application callbacks
-export( [ start/2
         , stop/1]).

%%%_* Code =====================================================================
%% Application callbacks
start(_StartType, _StartArgs) ->
  rett_sup:start_link().

stop(_State) ->
  ok.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
