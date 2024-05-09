function [ methodID ] = readInput( list )
%READINPUT  

fprintf('Please, Enter the number you want to reproduce:\n'); 
for i=1:length(list)
   fprintf('[%d] %s \n',i,list{i});
end
methodID = input('> ');

end

