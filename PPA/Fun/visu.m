function visu(ax,nr_of_mode,Model,ssmV,MeanPCA,Eval,F,pc)

%function to plot the PPA and PCA components
% Input
% nr_of_mode : componet tp be visualized
% Model : PPA Model
% ssmV : PCA shape vectors
% MeanPCA : average PCA shape
% Eval : eigenvalues of PCA
% F : Faces
% PCAon : 0 or 1 when aiming to co-visualize PCA results
% pc : data percentile representation

rangePPAModes=min([abs(max(Model(1).PPCModes(:,nr_of_mode)));abs(min(Model(1).PPCModes(:,nr_of_mode)))]);
dimension=size(Model(1).PPCModes,2);

PPCModes=Model(1).PPCModes;
scaling=rangePPAModes*normcdf(pc);
SDpos2=zeros(dimension,1);
SDpos2(nr_of_mode,1)=scaling;
SDneg2=-SDpos2;

[pcloadings2plus]=inversePPA(SDpos2',Eval,Model,dimension);
[pcloadings2min]=inversePPA(SDneg2',Eval,Model,dimension);


s=length(MeanPCA)/3;

PC=MeanPCA+ssmV(:,1:dimension)*pcloadings2plus';
PCplus(:,1)=PC(1:s,1);
PCplus(:,2)=PC(s+1:2*s,1);
PCplus(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCplus(:,1),PCplus(:,2),PCplus(:,3),'Edgecolor','none','Parent',ax);


material(ax,"dull")
light(ax)
lighting(ax,'phong');
axis(ax,"equal")

end
