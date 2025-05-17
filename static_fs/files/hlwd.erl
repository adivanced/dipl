
% hello world program
-module(hlwd).
-export([start/0]).

start() ->
    io:fwrite("Hello, world!\n").