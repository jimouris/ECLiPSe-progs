%%%%%%%%%%%%
%% inputs %%
%%%%%%%%%%%%%%%%%%%%%%
%% options([M/K/O]) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Constraint library ic %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

classes([1,1,2,2,2,2]).
options([2/1/[1,0,0,0,1,1],
        3/2/[0,0,1,1,0,1],
        3/1/[1,0,0,0,1,0],
        5/2/[1,1,0,1,0,0],
        5/1/[0,0,1,0,0,0]]).

%% classes([5,3,7,1,10,2,11,5,4,6,12,1,1,5,9,5,12,1]).
%% options([2/1/[1,1,1,0,1,1,1,1,0,0,0,0,0,1,0,0,0,0],
%%          3/2/[1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,0,0,0],
%%          3/1/[0,0,1,1,0,0,0,1,0,0,1,1,1,0,0,0,0,1],
%%          5/2/[0,1,0,1,0,0,1,0,0,1,0,0,1,0,0,0,1,0],
%%          5/1/[1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0]]).

%% classes([6,3,2,2,1,4,1,5,2,3]).
%% options([2/1/[1,1,1,0,0,0,0,0,1,0],
%%         3/2/[0,1,1,1,0,1,1,0,0,0],
%%         3/1/[0,1,0,1,0,0,1,1,1,1],
%%         5/2/[1,0,0,0,1,0,1,1,1,0],
%%         5/1/[0,0,1,0,0,0,0,0,0,0]]).

:- set_flag(print_depth, 1000).
:- lib(ic).
:- lib(ic_global).

carseq(S) :-
    classes(Clss),
    length(Clss, Configurations),
    sum(Clss, TotalCars),
    length(S, TotalCars),
    S #:: 1..Configurations,
    options(Opts),
    occ_constraint(S, 1, Clss),
    constraint(S, Opts),
    search(S, 0, first_fail, indomain, complete, []).

%% Constrain each variable(index) to appear in solution Ci times.
occ_constraint(_, _, []).
occ_constraint(CarLine, Idx, [Ci|Clss]) :-
    occurrences(Idx, CarLine, Ci),
    Index is Idx+1,
    occ_constraint(CarLine, Index, Clss).

%% Never exist in each M consecutive cars, more than K that require option O.
constraint(_, []).
constraint(CarLine, [M/K/O|Opts]) :-
    calcPos(O, 1, Positions),
    sequence_total(0, 100000, 0, K, M, CarLine, Positions),
    constraint(CarLine, Opts).

%% Convert a list of 0,1 to a indexes of 1 list.
%% e.g. calcPos([0,1,1,0,0,1], 1, R), R = [2,3,6] 
calcPos([], _, []).
calcPos([0|Ls], I, Rs) :-
    Ind is I+1,
    calcPos(Ls, Ind, Rs).
calcPos([1|Ls], I, [I|Rs]) :-
    Ind is I+1,
    calcPos(Ls, Ind, Rs).
