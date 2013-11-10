erlang-intervals
================

Erlang intervals library borrowed from scalaris project.
It's main purpose to provide operations on intervals of non negative integers. 

examples
--------

Creation of two intervals:
```erlang
1> A1 = intervals:new('[', 10, 20, ')').
[{interval,'[',10,20,')'}]
2> A2 = intervals:new('(', 13, 24, ']').
[{interval,'(',13,24,']'}]
```
Some operations defined on them:
```erlang
3> intervals:intersection(A1, A2).
[{interval,'(',13,20,')'}]
4> intervals:in(A1, A2).          
false
5> intervals:union(A1, A2). 
[{interval,'[',10,24,']'}]
6> intervals:minus(A1, A2). 
[{interval,'[',10,13,']'}]
```
You can create intervals from proplists:
```erlang
7> intervals:from_proplist('(', ')', [{1,3},5,{7,8},{10,20},{6,9}]).
[{interval,'(',1,3,')'},
 {element,5},
 {interval,'(',6,9,')'},
 {interval,'(',10,20,')'}]
```
And also use infinity atom if needed:
```erlang
8> B1 = intervals:new('(',10,20,']').
[{interval,'(',10,20,']'}]
9> B2 = intervals:new('(',15,infinity,']').
[{interval,'(',15,infinity,')'}]
10> intervals:minus(B2, B1).
[{interval,'(',20,infinity,')'}]
```
