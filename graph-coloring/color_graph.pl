%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% color_graph(N, D, Col, C) %%
%% N: nodes of the graph     %%
%% D: density of the graph   %%
%% Col: List of coloring     %%
%% C: color number           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Constraint library fd %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- set_flag(print_depth, 1000).
:- lib(fd).

color_graph(N, D, Col, C) :-
    create_graph(N, D, G),
    length(Col, N),
    Col :: 1..N,
    constraint(G, Col),
    min_max(generate(Col), Col),
    max(Col, C).

constraint([], _).
constraint([X1-X2|Xs], Sol) :-
    getElement(Sol, X1, CX1),
    getElement(Sol, X2, CX2),
    CX1 ## CX2,
    constraint(Xs, Sol).

getElement([C|_], 1, C).
getElement([_|Ls], X, C) :-
    X > 1, Xpred is X-1,
    getElement(Ls, Xpred, C).

generate([]).
generate(L) :-
   deleteffc(X, L, R),
   indomain(X),
   generate(R).


%%%%%%%%%%%%%%%%%%%%
%% graph creation %%
%%%%%%%%%%%%%%%%%%%%
create_graph(NNodes, Density, Graph) :-
    cr_gr(1, 2, NNodes, Density, [], Graph).

cr_gr(NNodes, _, NNodes, _, Graph, Graph).
cr_gr(N1, N2, NNodes, Density, SoFarGraph, Graph) :-
    N1 < NNodes, N2 > NNodes,
    NN1 is N1 + 1, NN2 is NN1 + 1,
    cr_gr(NN1, NN2, NNodes, Density, SoFarGraph, Graph).

cr_gr(N1, N2, NNodes, Density, SoFarGraph, Graph) :-
    N1 < NNodes, N2 =< NNodes,
    rand(1, 100, Rand),
    (Rand =< Density ->
        append(SoFarGraph, [N1 - N2], NewSoFarGraph) ;
        NewSoFarGraph = SoFarGraph),
    NN2 is N2 + 1,
    cr_gr(N1, NN2, NNodes, Density, NewSoFarGraph, Graph).

rand(N1, N2, R) :-
    random(R1),
    R is R1 mod (N2 - N1 + 1) + N1.
