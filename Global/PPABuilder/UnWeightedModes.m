function [uwmodes]=UnWeightedModes(Eval,Modes)

[r,c]=size(Modes);
for i=1:c
    uwmodes(:,i)=Modes(:,i)./sqrt(Eval(i,1));
end