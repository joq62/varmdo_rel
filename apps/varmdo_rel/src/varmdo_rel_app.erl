%%%-------------------------------------------------------------------
%% @doc balcony_rel public API
%% @end
%%%-------------------------------------------------------------------

-module(varmdo_rel_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    {ok,Cwd}=file:get_cwd(),
    io:format("Cwd :~p~n",[Cwd]),
    code:add_patha("priv"),
    PathToFile=code:where_is_file("index.html"),
    io:format("PathToFile :~p~n",[PathToFile]),
    FullPath=filename:join(Cwd,PathToFile),
 %   FullPath="index.html",
    io:format("FullPath :~p~n",[FullPath]),
    timer:sleep(1000),
    Port=6809,
    io:format("Port :~p~n",[Port]),
    ssl:start(),
    application:start(crypto),
    application:start(ranch), 
    application:start(cowlib), 
    application:start(cowboy), 

    HelloRoute = { "/", cowboy_static, {file,FullPath} },
    WebSocketRoute = {"/please_upgrade_to_websocket", varmdo_handler, []},
    CatchallRoute = {"/[...]", no_matching_route_handler, []},

    Dispatch = cowboy_router:compile([
				      {'_',
				       [HelloRoute, 
					WebSocketRoute, 
					CatchallRoute
				       ]
				      }
				     ]),
    {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
							 env => #{dispatch => Dispatch}
							}),
    {ok,Pid}=varmdo_rel_sup:start_link(),
    {ok,Pid}.
 

stop(_State) ->
    ok = cowboy:stop_listener(http).


%% internal functions
