%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc Editors Resource
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%_* Module declaration =======================================================
-module(editors_resource).

%%%_* Exports =================================================================
-export([ allowed_methods/2
        , content_types_provided/2
        , delete_resource/2
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
  ct:pal("in to_json, editors resource"),
  Result = code_editor:to_json(code_editor:read_all()),
  ct:pal("Editors:~p", [list_to_binary(Result)]),
  {Result, RD, Ctx}.

process_post(ReqData, State) ->
  %% Assuming that only one editor could be added at a time.
  %% TODO: add support for more than one editors
  Editor = code_editor:from_json(wrq:req_body(ReqData)),
  ok     = code_editor:write(Editor),
  ct:pal("in post for editors resource:~p~n", [Editor]),
  {true, ReqData, State}.

delete_resource(ReqData, State) ->
  Editor = code_editor:from_json(wrq:req_body(ReqData)),
  ct:pal("in delete for editors resource:~p~n", [Editor]),
  ok     = code_editor:delete(code_editor:get_id(Editor)),
  {true, ReqData, State}.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
