function [ isSafe ] = isSafeNumerical( arr )
%ISSAFENUMERICAL , input with array with size of 4.
%   using product rule to determine if situation is safe.
    prod = arr(1)*arr(2)*arr(3)*arr(4) ;
  
    if( (prod == 0) || (mod(prod,2) ~= 0) || (prod==4) ) 
        isSafe = true ;
    else 
        isSafe = false ;
    end
end

