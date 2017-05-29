-compile([{parse_transform, lager_transform}]).

%% log-level
-define(LOG_LEVEL_DEBUG, 0).
-define(LOG_LEVEL_INFO,  1).
-define(LOG_LEVEL_WARN,  2).
-define(LOG_LEVEL_ERROR, 3).
-define(LOG_LEVEL_FATAL, 4).
-type(log_level() :: ?LOG_LEVEL_DEBUG |
                     ?LOG_LEVEL_INFO  |
                     ?LOG_LEVEL_WARN  |
                     ?LOG_LEVEL_ERROR |
                     ?LOG_LEVEL_FATAL).

-record(message_log,  {level              :: log_level(),
                       module             :: string()|atom(),
                       function           :: string()|atom(),
                       line = 0           :: non_neg_integer(),
                       format  = []       :: string(),
                       message = []       :: [any()],
                       formatted_msg = [] :: string()|binary(),
                       esearch = []       :: list(tuple())
                      }).

-define(log_handlers(_LogLvl),
    case LogLvl of
        ?LOG_LEVEL_DEBUG ->
            {ok, [{"info.log", '<=info'},
                  {"error.log", warning}]};
        ?LOG_LEVEL_INFO ->
            {ok, [{"info.log", '=info'},
                  {"error.log", warning}]};
        ?LOG_LEVEL_WARN ->
            {ok, [{"error.log", warning}]};
        ?LOG_LEVEL_ERROR ->
            {ok, [{"error.log", error}]};
        ?LOG_LEVEL_FATAL ->
            {ok, [{"error.log", critical}]};
        _ ->
            {error, badarg}
    end).

-define(fatal(_Func,_Format,_Message),
        lager:critical(_Format, Message)).
-define(fatal(_Func,_MsgL),
        lager:critical(_MsgL)).
-define(error(_Func,_Format,_Message),
        lager:error(_Format,_Message)).
-define(error(_Func,_MsgL),
        lager:error(_MsgL)).
-define(warn(_Func,_Format,_Message),
        lager:warning(_Format,_Message)).
-define(warn(_Func,_MsgL),
        lager:warning(_MsgL)).
-define(info(_Func,_Format,_Message),
        lager:info(_Format,_Message)).
-define(info(_Func,_MsgL),
        lager:info(_MsgL)).
-define(debug(_Func,_Format,_Message),
        lager:debug(_Format,_Message)).
-define(debug(_Func,_MsgL),
        lager:debug(_MsgL)).
