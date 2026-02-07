function [isSafe] = isSafeBinary(state)
%ISSAFEBINARY 
f=state(1); fox=state(2); goose=state(3); grain=state(4);
if( fox == goose) && (f ~= fox) 
    isSafe = false ;
elseif (goose == grain ) && (f ~= goose ) 
    isSafe = false ;
else 
    isSafe = true ;
end 
end

