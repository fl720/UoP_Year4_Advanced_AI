departure_bin= [1,1,1,1] ; % farmer, fox , goose , grain
departureNode.state = departure_bin ; 
departureNode.path  = { departure_bin } ;
destination_bin     = [0,0,0,0] ;

queue = { departureNode } ;
isVisited = [1,1,1,1] ; 

while ~isempty( queue ) 
    currentNode = queue{1} ;
    queue(1) = [] ; 

    currentState = currentNode.state ; 

    if isequal( currentState , destination_bin ) 
        disp( currentNode.path ) ; 
    end 

    for i = 1:4 
        if currentState(i) == currentState(1) 
            nextState = currentState ; 
            nextState(1) = 1 - currentState(1) ;

            if( i > 1 ) 
                nextState(i) = 1 - currentState(i) ; 
            end 

            if isSafeBinary( nextState) 
                if ~ismember( nextState , isVisited , 'rows' ) 
                    isVisited = [isVisited ; nextState ] ; 
                    newNode.state = nextState; 
                    newNode.path =  [currentNode.path , {nextState} ] ;
                    queue{end+1} = newNode ;
                end
            end
        end
    end
end


