:- lib(fd).
:- set_flag(print_depth, 1000).

%% Default file: graphs/graph1.clq
max_clique(Clique) :-
    min_max(findSol(1, Clique, Cost), Cost).
max_clique(FileNo, Clique) :-
    min_max(findSol(FileNo, Clique, Cost), Cost).

findSol(FileNo, Clique, Cost) :-
    read_graph(FileNo, EdgesList, VerticesSize),
    length(VertInClique, VerticesSize),
    VertInClique :: 0..1, %% which edges to choose
    forAllVertices(VertInClique, EdgesList, 2, VerticesSize),
    ascList(VerticesSize, AscList),
    evalSol(VertInClique, AscList, Clique, Cost).

%% Evaluate the selected vertices and their costs 
evalSol([], [], [], 0).
evalSol([1|VertInClique], [Vertex|AscList], [Vertex|Clique], Cost) :-
    Cost #= TempCost - 1,
    evalSol(VertInClique, AscList, Clique, TempCost).
evalSol([0|VertInClique], [_|AscList], Clique, Cost) :-
    evalSol(VertInClique, AscList, Clique, Cost).

%% for i in range(2, VertSize)
%%     for j in range(1, i)
%%          if edge(i, j) not member
%%          then only one of i, j in clique. (not together!)
forAllVertices(_, _, I, VerticesSize) :- I > VerticesSize.
forAllVertices(VertInClique, EdgesList, I, VerticesSize) :-
    I =< VerticesSize,
    forVertOneToI(VertInClique, EdgesList, I, 1),
    I_Succ is I+1,
    forAllVertices(VertInClique, EdgesList, I_Succ, VerticesSize).

forVertOneToI(_, _, I, I).
forVertOneToI(VertInClique, EdgesList, I, J) :-
    J < I,
    member([I, J], EdgesList), !,
    J_Succ is J+1,
    forVertOneToI(VertInClique, EdgesList, I, J_Succ).
forVertOneToI(VertInClique, EdgesList, I, J) :-
    J < I, J_Succ is J+1,
    nthOfLst(VertInClique, I, Elem1),
    nthOfLst(VertInClique, J, Elem2),
    Elem1 + Elem2 #=< 1,
    forVertOneToI(VertInClique, EdgesList, I, J_Succ).

%% ascList(N, List): List = [1, 2, ..., N]
ascList(1, [1]) :- !. 
ascList(N, List) :- 
    N > 1, Npred is N-1, 
    ascList(Npred, L1),
    append(L1, [N], List). 

%% nthOfLst(List, Idx, El): El = List[Idx]
nthOfLst([Elem|_], 1, Elem).
nthOfLst([_|Ls], Cnt, Elem) :-
    Cnt > 1, CntPred is Cnt-1,
    nthOfLst(Ls, CntPred, Elem).

%%%%%%%%%% DATASETS %%%%%%%%%%
datafile(1, 'graphs/graph1.clq').
datafile(2, 'graphs/graph2.clq').
datafile(3, 'graphs/graph3.clq').
datafile(4, 'graphs/graph4.clq').
datafile(5, 'graphs/graph5.clq').
datafile(6, 'graphs/graph6.clq').
datafile(30, 'graphs/C30.9.clq').

%%%%%%%%% PARSE FILE %%%%%%%%%
read_graph(I, EdgesList, VerticesSize) :-
    datafile(I, DataFile),
    open(DataFile, read, Stream),
    read_header(Stream, VerticesSize, EdgesSize),
    read_edges(Stream, EdgesSize, EdgesList),    
    close(Stream).

%% header is in form: p col 125 4
read_header(Stream, VerticesSize, EdgesSize) :-
    read_token(Stream, _, _), read_token(Stream, _, _),
    read_token(Stream, VerticesSize, integer), read_token(Stream, EdgesSize, integer).

%% each edge is in form: e 4 2
read_edges(_, 0, []).
read_edges(Stream, M, [[K, V]|EdgesList]) :-
   M > 0,
   read_token(Stream, _, _),
   read_token(Stream, K, integer),
   read_token(Stream, V, integer),
   M1 is M-1,
   read_edges(Stream, M1, EdgesList).
