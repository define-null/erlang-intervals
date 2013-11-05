%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 ft=erlang et

-ifndef(intervals_types).

-define(MINUS_INFINITY, 0).
-define(PLUS_INFINITY, infinity).

-type key_t() :: non_neg_integer().

-type left_bracket()  :: '(' | '['.
-type right_bracket() :: ')' | ']'.
-type key() :: key_t().

-type simple_interval2() :: {interval, left_bracket(), key(), key(), right_bracket()}
                          | {interval, left_bracket(), key(), ?PLUS_INFINITY, ')'}.

-type simple_interval()         :: {element, key()} | all | simple_interval2().
-type invalid_simple_interval() :: {element, key()} | all | simple_interval2().
-opaque interval() :: [simple_interval()].
-opaque invalid_interval() :: [simple_interval()].
-opaque continuous_interval() :: [simple_interval()].

-endif.
