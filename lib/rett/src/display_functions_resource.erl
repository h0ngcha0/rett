%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Display the functions
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(display_functions_resource).

%%%_* Exports =================================================================
-export([ allowed_methods/2
        , init/1
        , process_post/2
        ]).

%%%_* Include =================================================================
-include_lib("webmachine/include/webmachine.hrl").

%%%_* Code ====================================================================
init([]) ->
  {ok, undefined}.

%% This should take a list of the functions that we wanna display and display
%% it on the web page
allowed_methods(ReqData, State) ->
  {['POST'], ReqData, State}.

process_post(ReqData, State) ->
  {true, ReqData, State}.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
