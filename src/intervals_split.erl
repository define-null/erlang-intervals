%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 ft=erlang et

%% @copyright 2007-2012 Zuse Institute Berlin
%%            2008 onScale solutions GmbH
%%
%%  Licensed under the Apache License, Version 2.0 (the "License");
%%  you may not use this file except in compliance with the License.
%%  You may obtain a copy of the License at
%%
%%      http://www.apache.org/licenses/LICENSE-2.0
%%
%%  Unless required by applicable law or agreed to in writing, software
%%  distributed under the License is distributed on an "AS IS" BASIS,
%%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%  See the License for the specific language governing permissions and
%%  limitations under the License.
%%
%% @author Thorsten Schuett <schuett@zib.de>
%% @author Florian Schintke <schintke@zib.de>
%% @author Nico Kruber <kruber@zib.de>
%% @author Defnull <define.null@gmail.com>

-module(intervals_split).
-include("types.hrl").

-export([split/2]).

%%------------------------------------------------------------------------------
%% Split funcions
%%------------------------------------------------------------------------------

%% @doc Splits a continuous interval in X roughly equally-sized subintervals,
%%      the result of non-continuous intervals is undefined.
%%      Returns: List of adjacent intervals
-spec split(interval(), Parts::pos_integer()) -> [interval()].
split(I, 1) -> [I];
split(I, Parts) ->
    {LBr, LKey, RKey, RBr} = intervals:get_bounds(I),
    %% keep brackets inside the split interval if they are different
    %% (i.e. one closed, the other open), otherwise exclude split keys
    %% from each first interval at each split
    {InnerLBr, InnerRBr} =
        if (LBr =:= '[' andalso RBr =:= ']') orelse
           (LBr =:= '(' andalso RBr =:= ')') -> {'[', ')'};
           true -> {LBr, RBr}
        end,
    lists:reverse(split2(LBr, LKey, RKey, RBr, Parts, InnerLBr, InnerRBr, [])).

-spec split2(left_bracket(), key(), key(), right_bracket(), Parts::pos_integer(),
             InnerLBr::left_bracket(), InnerRBr::right_bracket(), Acc::[interval()]) -> [interval()].
split2(LBr, Key, Key, RBr, _, _InnerLBr, _InnerRBr, Acc) ->
    [intervals:new(LBr, Key, Key, RBr) | Acc];
split2(LBr, LKey, RKey, RBr, 1, _InnerLBr, _InnerRBr, Acc) ->
    [intervals:new(LBr, LKey, RKey, RBr) | Acc];
split2(LBr, LKey, RKey, RBr, Parts, InnerLBr, InnerRBr, Acc) ->
    SplitKey = get_split_key(LKey, RKey, {1, Parts}),
    case SplitKey =:= LKey of
        true -> [intervals:new(LBr, LKey, RKey, RBr) | Acc];
        false -> split2(InnerLBr, SplitKey, RKey, RBr,
                        Parts - 1, InnerLBr, InnerRBr,
                        [intervals:new(LBr, LKey, SplitKey, InnerRBr) | Acc])
    end.

%% @doc Helper for get_range/2 to make dialyzer happy with internal use of
%%      get_range/2 in the other methods, e.g. get_split_key/3.
-spec get_range_(Begin::key_t(), End::key_t() | ?PLUS_INFINITY) -> number().
get_range_(Begin, Begin) -> n_(); % I am the only node
get_range_(?MINUS_INFINITY, ?PLUS_INFINITY) -> n_(); % special case, only node
get_range_(Begin, End) when End > Begin -> End - Begin;
get_range_(Begin, End) when End < Begin -> (n_() - Begin) + End.

%% @doc Gets the key that splits the interval (Begin, End] so that the first
%%      interval will (roughly) be (Num/Denom) * range(Begin, End). In the
%%      special case of Begin==End, the whole key range is split.
%%      Beware: (Num/Denom) must be in [0, 1]; the final key will be rounded
%%      down and may thus be Begin.
-spec get_split_key(Begin::key(), End::key() | ?PLUS_INFINITY,
                    SplitFraction::{Num::non_neg_integer(), Denom::pos_integer()}) -> key().
get_split_key(Begin, _End, {Num, _Denom}) when Num == 0 -> Begin;
get_split_key(_Begin, End, {Num, Denom}) when Num == Denom -> End;
get_split_key(Begin, End, {Num, Denom}) ->
    normalize(Begin + (get_range_(Begin, End) * Num) div Denom).

%% @doc Keep a key in the address space. See n/0.
-spec normalize(non_neg_integer()) -> key_t().
normalize(Key) -> Key band 16#FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF.

%% @doc Returns the size of the address space.
-spec n() -> integer().
n() -> n_().
%% @doc Helper for n/0 to make dialyzer happy with internal use of n/0.
-spec n_() -> 16#100000000000000000000000000000000.
n_() -> 16#FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF + 1.

