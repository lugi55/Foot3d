function [wmodes]=WeightedModes(Eval,Modes)

[r,c]=size(Modes);
for i=1:c
    wmodes(:,i)=Modes(:,i).*sqrt(Eval(i,1));
end