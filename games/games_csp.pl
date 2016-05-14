%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% games(Ps, T, K, Gs, P)       %%
%% Ps: List of game pleasures   %%
%% T: capacity of the box       %%
%% K: chips refill              %%
%% Gs: List of each game played %%
%% P: final pleasure            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Constraint library ic %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- set_flag(print_depth, 1000).

:- lib(ic).
:- lib(branch_and_bound).

games_csp(Ps, T, K, Gs, P) :-
    length(Ps, N), length(Gs, N),
    Gs #:: 1..T,
    constraint(Ps, T, T, K, Gs, Pllist),
    Pminus #= sum(Pllist), % calculate total pleasure
    bb_min(search(Gs, 0, first_fail, indomain_middle, complete, []), 
                Pminus, [], _, Pminus, bb_options{strategy:continue}), % Find the best solution 
    P is (-1) * Pminus,
    search(Gs, 0, first_fail, indomain_middle, complete, []).

constraint([], _, _, _, [], []).
constraint([P|Ps], Tnow, T, K, [Times|Gs], [P*Times*(-1)|Pllist]) :-
	P >= 0,
    Times #=< Tnow,         % Don't play more times than you can
    Temp #= Tnow - Times + K,
    NewT #= min(Temp, T),   % refill
    constraint(Ps, NewT, T, K, Gs, Pllist).
constraint([P|Ps], Tnow, T, K, [1|Gs], [P*(-1)|Pllist]) :-
	P < 0,
    Temp #= Tnow - 1 + K,   % if pleasure is negative, play only one time
    NewT #= min(Temp, T),   % refill
    constraint(Ps, NewT, T, K, Gs, Pllist).
