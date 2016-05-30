%%%%%%%%%%%%
%% inputs %%
%%%%%%%%%%%%%%%%%%%%%%
%% options([M/K/O]) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Constraint library ic %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% classes([1,1,2,2,2,2]).
%% options([2/1/[1,0,0,0,1,1],
%%         3/2/[0,0,1,1,0,1],
%%         3/1/[1,0,0,0,1,0],
%%         5/2/[1,1,0,1,0,0],
%%         5/1/[0,0,1,0,0,0]]).

classes([5,3,7,1,10,2,11,5,4,6,12,1,1,5,9,5,12,1]).
options([2/1/[1,1,1,0,1,1,1,1,0,0,0,0,0,1,0,0,0,0],
        3/2/[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,0,0,0],
        3/1/[0,0,1,1,0,0,0,1,0,0,1,1,1,0,0,0,0,1],
        5/2/[0,1,0,1,0,0,1,0,0,1,0,0,1,0,0,0,1,0],
        5/1/[1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0]]).

%% classes([6,3,2,2,1,4,1,5,2,3]).
%% options([2/1/[1,1,1,0,0,0,0,0,1,0],
%%         3/2/[0,1,1,1,0,1,1,0,0,0],
%%         3/1/[0,1,0,1,0,0,1,1,1,1],
%%         5/2/[1,0,0,0,1,0,1,1,1,0],
%%         5/1/[0,0,1,0,0,0,0,0,0,0]]).

:- set_flag(print_depth, 1000).

carseq(S) :-
    classes(Clss),
    length(Clss, Configurations),
    sum(Clss, TotalCars),
    length(S, TotalCars),
    S #:: 1..Configurations,
    options(Opts),
    occ_constraint(S, 1, Clss),
    constraint(S, Opts),
    ic:search(S, 0, most_constrained, indomain_middle, complete, []).

occ_constraint(_, _, []).
occ_constraint(CarLine, Idx, [Ci|Clss]) :-
    ic_global:occurrences(Idx, CarLine, Ci),
    Index is Idx+1,
    occ_constraint(CarLine, Index, Clss).

constraint(_, []).
constraint(CarLine, [M/K/O|Opts]) :-
    calcPos(O, 1, Positions),
    ic_global:sequence_total(0, 1000, 0, K, M, CarLine, Positions),
    constraint(CarLine, Opts).

calcPos([], _, []).
calcPos([0|Ls], I, Rs) :-
    Ind is I+1,
    calcPos(Ls, Ind, Rs).
calcPos([1|Ls], I, [I|Rs]) :-
    Ind is I+1,
    calcPos(Ls, Ind, Rs).
