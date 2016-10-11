%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(request_handler).

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	#{topic := Topic, msg := Msg} = cowboy_req:match_qs([{topic, msg, [], undefined}], Req0),
	Req = publish(Method, Topic, Msg, Req0),
	{ok, Req, Opts}.

publish(<<"GET">>, undefined, _, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing topic parameter.">>, Req);
publish(<<"GET">>, _, undefined, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing msg parameter.">>, Req);
publish(<<"GET">>, Topic, Msg, Req) ->
	emqtt_srv ! {publish, Topic, Msg},	
	%%Reply = Topic ++ " " ++ Msg,
	cowboy_req:reply(200, #{
	<<"content-type">> => <<"text/plain; charset=utf-8">>}, Topic, Req);
publish(_, _, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).
