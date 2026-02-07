F  = 0 ; %farmer
Fx = 3 ; %fox
Go = 4 ; %goose 
Gr = 5 ; %grain
V  = 1 ; %VOID

departure_bin   = [1,1,1,1] ; 
destination_bin = [0,0,0,0] ;

INIELEMENT      = [F,Fx,Go,Gr] ; 
departure_num   = [F,Fx,Go,Gr] ; 
destination_num = [1,1,1,1] ;

% ----------- numerical approch ---------- 
startNode.state = departure_num ;
startNode.path = {departure_num} ;
queue = {startNode} ;
isVisited = departure_num ; 

while  ~isempty(queue) 
    currentNode = queue{1} ;
    queue(1) = [] ; 
    currentState = currentNode.state ; 

    if isequal(currentState , destination_num ) 
        disp( currentNode.path)
    end

    fPos = currentState(1) ; 
    for i = 1:4
        if ((fPos == 0) && (currentState(i) ~= 1)) || ((fPos == 1 ) && (i==1 || currentState(i) == 1))
            nextState = currentState ; 
            rightState = currentState ;
            if fPos == 0 
                nextState(1) = 1 ;
                nextState(i) = 1 ;
            else 
                nextState(1) = 0 ;
                nextState(i) = INIELEMENT(i) ;
            end 

            for i = 1:4 
                if nextState(i) == 1 
                    rightState(i) = INIELEMENT(i) ; 
                else 
                    rightState(i) = 1 ; 
                end 
            end

            if isSafeNumerical( nextState ) && isSafeNumerical( rightState ) 
                if ~ismember( nextState , isVisited , 'rows' ) 
                    isVisited = [isVisited ; nextState ] ;

                    newNode.state = nextState ; 
                    newNode.path = [currentNode.path , {nextState} ] ;
                    queue{end+1} = newNode ;
                end 
            end
        end
    end


end 
