function PCplus = SSM(ssmV,MEAN,Z)

    [p,~]=size(ssmV);
    s=p/3;
    
    PC=MEAN;
    for i=1:length(Z)
        PC=PC+Z(i)*ssmV(:,i);
    end
    
    PCplus(:,1)=PC(1:s,1);
    PCplus(:,2)=PC(s+1:2*s,1);
    PCplus(:,3)=PC(2*s+1:3*s,1);
end

