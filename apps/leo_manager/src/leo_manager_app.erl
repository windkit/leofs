%%======================================================================
%%
%% Leo Manager
%%
%% Copyright (c) 2012-2015 Rakuten Inc.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%%======================================================================
-module(leo_manager_app).
-compile([{parse_transform, lager_transform}]).

-behaviour(application).

-include("leo_manager.hrl").
-include_lib("leo_commons/include/leo_commons.hrl").
-include_lib("leo_logger/include/lager_logger.hrl").
-include_lib("eunit/include/eunit.hrl").

%% Application and Supervisor callbacks
-export([start/2, prep_stop/1, stop/1]).

%%----------------------------------------------------------------------
%% Application behaviour callbacks
%%----------------------------------------------------------------------
start(_Type, _Args) ->
    ok = start_logger(),
    case leo_manager_sup:start_link() of
        {ok,_Pid} = Ret ->
            _ = timer:apply_after(?APPLY_AFTER_TIME, leo_manager_cluster_monitor,
                                  get_remote_node_proc, []),
            Ret;
        Other ->
            Other
    end.

prep_stop(_State) ->
    leo_redundant_manager_sup:stop(),
    leo_mq_sup:stop(),
    ok.

stop(_State) ->
    ok.


%% ---------------------------------------------------------------------
%% Inner Function(s)
%% ---------------------------------------------------------------------
%% @doc Launch LeoLogger
%% @private
start_logger() ->
    LogDir = ?env_log_dir(),
    LogLevel = ?env_log_level(leo_manager),
    application:set_env(lager, log_root, LogDir),
    application:set_env(lager, crash_log, "crash.log"),

%%    ok = application:set_env(lager, handlers,
%%                             [{lager_file_backend, [{file, "info.log"}, {level, none},
%%                                                    {size, 10485760}, {date, "$D0"}, {count, 100},
%%                                                    {formatter, lager_leofs_formatter},
%%                                                    {formatter_config, ["[", sev, "]\t", atom_to_list(node()), "\t", leodate, "\t", leotime, "\t", {module, "null"}, ":", {function, "null"}, "\t", {line, "0"}, "\t", message, "\n"]}
%%                                                   ]},
%%                              {lager_file_backend, [{file, "error.log"}, {level, none},
%%                                                    {size, 10485760}, {date, "$D0"}, {count, 100},
%%                                                    {formatter, lager_leofs_formatter},
%%                                                    {formatter_config, ["[", sev, "]\t", atom_to_list(node()), "\t", leodate, "\t", leotime, "\t", {module, "null"}, ":", {function, "null"}, "\t", {line, "0"}, "\t", message, "\n"]}
%%                                                   ]}]),
%%
%%    ok = application:set_env(lager, extra_sinks,
%%                             [{cmdhistory_lager_event,
%%                               [{handlers,
%%                                 [{lager_file_backend, [{file, ?LOG_FILENAME_HISTORY}, {level, info},
%%                                                        {size, 10485760}, {date, "$D0"}, {count, 100},
%%                                                        {formatter, lager_default_formatter},
%%                                                        {formatter_config, [message, "\n"]}
%%                                                       ]}]
%%                                },
%%                                {async_threshold, 500},
%%                                {async_threshold_window, 50}]
%%                              }]),

    lager:start(),
    {ok, Handlers} = ?log_handlers(LogLevel),

    lists:foreach(fun({File, Level}) ->
                          lager:set_loglevel(lager_file_backend, File, Level)
                  end, Handlers),
	lager:info("Start Logger"),
    ok.


