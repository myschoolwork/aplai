:- lib(ic).
:- lib(util).

:- compile("sudex_toledo").
:- compile("sudoku_eclipse_util").

solve_all :-
	solve(_),
	fail.
solve_all.

solve(Name) :-
	puzzles(Board,Name), % get the puzzle

	write("Solving: "), write(Name),

	% Selection methods:
    % input_order, anti_first_fail, first_fail, smallest, occurrence, largest, most_constrained, max_regret
	% Choice methods:
	% indomain/1, indomain_max, indomain_min, indomain_reverse_min Like, indomain_reverse_max, indomain_middle, indomain_median, indomain_split, indomain_reverse_split, indomain_random, indomain_interval
	time(solve(Board, most_constrained,indomain,complete,[backtrack(B)])),

	write("Required "), write(B), write(" backtracks"), nl,

	% write final result
	write_board(Board).

solve(Board, Select, Choice, Method, Option) :-
	model(Board, BoardArray),
	% do the search
	search(BoardArray, 0, Select, Choice, Method, Option).

model(Board, BoardArray) :-
	%Board is a list, we need it as array
	( foreach(Row,Board), foreach(RowArray,Out)
	do
		array_list(RowArray,Row)
	),
	array_list(BoardArray,Out),

	% get dim, also makes sure it's square
	dim(BoardArray, [D,D]),

	% all cells have range 1 to Dim
	BoardArray :: 1..D,

	% set constraints
	row_col_constraint(BoardArray),
	block_constraint(BoardArray). %assumes D is a power of something

row_col_constraint(BoardArray) :-
	dim(BoardArray, [D,D]),
	( for(I,1,D), param(BoardArray,D)
	do
		Row is BoardArray[I,1..D],
		Col is BoardArray[1..D,I],
		alldifferent(Row),
		alldifferent(Col)
	).

block_constraint(BoardArray) :-
	dim(BoardArray, [D,D]),
	DD is integer(sqrt(D)),
	( multifor([I,J],[1,1],[DD,DD]), param(BoardArray,DD)
	do
		Left is (I-1) * DD + 1,
		Right is Left + DD - 1,
		Top is (J-1) * DD + 1,
		Bottom is Top + DD - 1,

		Block is BoardArray[Left..Right, Top..Bottom],
		flatten(Block,FlatBlock),
		alldifferent(FlatBlock)
	).
