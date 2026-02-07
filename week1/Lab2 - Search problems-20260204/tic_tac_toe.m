function tic_tac_toe_ai()
    % 1.Representation
    % 3x3 MATRIX：0 EMPTY，1 PLAYER-X，-1 PLAYER-O
    board = zeros(3,3); 
    
    % 2. Initial Conditions
    fprintf('START！AI (O) vs PLAYER (X)\n');
    
    % MAIN LOOP
    for turn = 1:9
        display_board(board);
        if mod(turn, 2) ~= 0
            % PLAYER X TURN
            board = player_move(board);
        else
            % AI O TURN (USE Minimax )
            fprintf('AI 思考中...\n');
            board = ai_best_move(board);
        end
        
        % 3. Condition
        result = check_winner(board);
        if result ~= 0
            display_board(board);
            if result == 1, disp('PLAYER X WIN！'); else, disp('AI O WIN！'); end
            return;
        end
    end
    display_board(board);
    disp('DRAW！');
end

function bestBoard = ai_best_move(board)
    % 
    bestScore = -inf;
    bestRow = -1;
    bestCol = -1;
    
    [rows, cols] = find(board == 0);
    for i = 1:length(rows)
        % simulate ai's move
        board(rows(i), cols(i)) = -1;
        % use Minimax to evaluate next round (player)
        score = minimax(board, 0, true);
        % backtracking
        board(rows(i), cols(i)) = 0;
        
        % 
        if score > bestScore 
            bestScore = score;
            bestRow = rows(i);
            bestCol = cols(i);
        end
    end
    board(bestRow, bestCol) = -1;
    bestBoard = board;
end

function score = minimax(board, depth, isMaximizing)
    % check 
    res = check_winner(board);
    if res == -1, score = 10 - depth; return; end  % AI win
    if res == 1,  score = depth - 10; return; end  % PLAYER win
    if all(board(:) ~= 0), score = 0; return; end   % DRAW
    
    if isMaximizing
        bestScore = -inf;
        [rows, cols] = find(board == 0);
        for i = 1:length(rows)
            board(rows(i), cols(i)) = 1;
            score = minimax(board, depth + 1, false);
            board(rows(i), cols(i)) = 0;
            bestScore = max(score, bestScore);
        end
        score = bestScore;
    else
        bestScore = inf;
        [rows, cols] = find(board == 0);
        for i = 1:length(rows)
            board(rows(i), cols(i)) = -1;
            score = minimax(board, depth + 1, true);
            board(rows(i), cols(i)) = 0;
            bestScore = min(score, bestScore);
        end
        score = bestScore;
    end
end

%% --- AUX functions ---

function board = player_move(board)
    % Legal Moves：must be empty box
    valid = false;
    while ~valid
        prompt = 'Please enter [colum, row] (eg [1 1]): ';
        pos = input(prompt);
        if pos(1)>=1 && pos(1)<=3 && pos(2)>=1 && pos(2)<=3 && board(pos(1), pos(2)) == 0
            board(pos(1), pos(2)) = 1;
            valid = true;
        else
            disp('INVALID INPUT, please retry.');
        end
    end
end

function board = ai_move(board)
    % ai will find an empty box first
    [r, c] = find(board == 0);
    board(r(1), c(1)) = -1; 
end

function winner = check_winner(board)
    winner = 0;
    % check col & row
    for i = 1:3
        if abs(sum(board(i,:))) == 3, winner = sign(sum(board(i,:))); return; end
        if abs(sum(board(:,i))) == 3, winner = sign(sum(board(:,i))); return; end
    end
    % check diagnal
    diag1 = board(1,1) + board(2,2) + board(3,3);
    diag2 = board(1,3) + board(2,2) + board(3,1);
    if abs(diag1) == 3, winner = sign(diag1); return; end
    if abs(diag2) == 3, winner = sign(diag2); return; end
end

function display_board(board)
    % print the board
    symbols = {'O', '.', 'X'};
    disp('  1 2 3');
    for i = 1:3
        row_str = sprintf('%d ', i);
        for j = 1:3
            row_str = [row_str, symbols{board(i,j) + 2}, ' '];
        end
        disp(row_str);
    end
end