function plotData(Data)
  hold 
  for i=1:length(Data(:,1))  
    if (Data(i,3)== 0) 
       plot(Data(i,1),Data(i,2),'bo'); %mark 'label 0' samples with 'o'
    else
       plot(Data(i,1),Data(i,2),'b*'); %mark 'label 1' samples as '*'
    end
  end
end  
