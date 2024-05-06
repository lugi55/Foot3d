function plotPPSmode(nr_of_mode,Model,ssmV,MeanPCA,Eval,F,PCAon,pc)

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

MeanPPC=inversePPA(zeros(1,dimension),Eval,Model,dimension);
 MeanPPC=MeanPCA+ssmV(:,1:dimension)*MeanPPC';
MeanParentbone=reshape(MeanPPC,length(MeanPPC)/3,3);
clf
trisurf(F,MeanParentbone(:,1),MeanParentbone(:,2),MeanParentbone(:,3),'Edgecolor','none');
hold
colormap bone
light
lighting phong;
set(gca, 'visible', 'off')
set(gcf,'Color',[1 1 0.88])
% set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);
axis equal
view(0,90)
material dull
lighting phong;

PPCModes=Model(1).PPCModes;
scaling=rangePPAModes*pc;
SDpos2=zeros(dimension,1);
SDpos2(nr_of_mode,1)=scaling;
SDneg2=-SDpos2;

[pcloadings2plus]=inversePPA(SDpos2',Eval,Model,dimension);

[pcloadings2min]=inversePPA(SDneg2',Eval,Model,dimension);


s=length(MeanPCA)/3;

PC=MeanPCA+ssmV(:,1:dimension)*pcloadings2plus';
PCplusplus=2*(max(PC(1:s,1))-min((PC(1:s,1))));
PCplus(:,1)=PC(1:s,1)+PCplusplus;
PCplus(:,2)=PC(s+1:2*s,1);
PCplus(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCplus(:,1),PCplus(:,2),PCplus(:,3),'Edgecolor','none');material dull;lighting phong;

PC=MeanPCA+ssmV(:,1:dimension)*pcloadings2min';
PCmin(:,1)=PC(1:s,1)-PCplusplus;
PCmin(:,2)=PC(s+1:2*s,1,1);
PCmin(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCmin(:,1),PCmin(:,2),PCmin(:,3),'Edgecolor','none');material dull;lighting phong;

if PCAon==1

PC=MeanPCA+ssmV(:,nr_of_mode)*(-2)*pc;
PCmin(:,1)=PC(1:s,1)-PCplusplus;
PCmin(:,2)=PC(s+1:2*s,1,1);
PCmin(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCmin(:,1),PCmin(:,2),PCmin(:,3),'FaceColor','m','Edgecolor','none');material dull;lighting phong;
PC=MeanPCA+ssmV(:,nr_of_mode)*0;
PCplus(:,1)=PC(1:s,1);
PCplus(:,2)=PC(s+1:2*s,1);
PCplus(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCplus(:,1),PCplus(:,2),PCplus(:,3),'FaceColor','m','Edgecolor','none');material dull;lighting phong;
PC=MeanPCA+ssmV(:,nr_of_mode)*2*pc;
PCplus(:,1)=PC(1:s,1)+PCplusplus;
PCplus(:,2)=PC(s+1:2*s,1);
PCplus(:,3)=PC(2*s+1:3*s,1);
trisurf(F,PCplus(:,1),PCplus(:,2),PCplus(:,3),'FaceColor','m','Edgecolor','none');material dull;lighting phong;

end
