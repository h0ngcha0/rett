%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Editors Resource
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(editors_resource).

%%%_* Exports =================================================================
-export([ allowed_methods/2
        , content_types_provided/2
        , init/1
        , process_post/2
        , to_json/2
        ]).

%%%_* Include =================================================================
-include_lib("webmachine/include/webmachine.hrl").

%%%_* Code ====================================================================
init([]) ->
  ct:pal("in editors resource init:"),
  {ok, undefined}.

%% This should take a list of the functions that we wanna display and display
%% it on the web page
allowed_methods(ReqData, State) ->
  {['GET', 'POST', 'PUT'], ReqData, State}.

content_types_provided(RD, Ctx) ->
    {[{"application/json", to_json}], RD, Ctx}.

to_json(RD, Ctx) ->
  ct:pal("in to_json_editors resource"),
  Result = list_to_binary("[{\"x\":\"1\",\"y\":\"1\",\"z\":\"1\",\"id\":\"0\",\"code\":\"bla\"},{\"x\":\"1\",\"y\":\"1\",\"z\":\"1\",\"id\":\"1\",\"code\":\"foo\"}]"),
  %%Result = list_to_binary("[{x:1,y:1,z:1,id:0,code:bla},{x:1,y:1,z:1,id:1,code:foo}]"),
  {Result, RD, Ctx}.

process_post(ReqData, State) ->
  ct:pal("in post for editors resource"),
  {true, ReqData, State}.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
