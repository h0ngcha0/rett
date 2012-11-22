%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Homepage for RETT web interface
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(home_resource).

%%%_* Exports =================================================================
-export([ allowed_methods/2
        , init/1
        , to_html/2
        ]).

%%%_* Include =================================================================
-include_lib("webmachine/include/webmachine.hrl").

%%%_* Code ====================================================================
init([]) ->
  {ok, undefined}.

allowed_methods(ReqData, State) ->
  {['GET'], ReqData, State}.

to_html(ReqData, State) ->
  %%{ok, Content} = index_dtl:render([]),
  Content = "fuck yay",
  {Content, ReqData, State}.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
