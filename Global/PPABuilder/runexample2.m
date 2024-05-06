function runexample2

load Example2

[ssmV,PCcum,MeanPCA,Eval,Modes,PPAmodes,PPCcum,MeanPPC,Model] = PPABuilder(training,2,0.99);
dimension=size(Model(1).PPCModes,2);

rangePPAModes=min([abs(max(Model(1).PPCModes(:,nr_of_mode)));abs(min(Model(1).PPCModes(:,nr_of_mode)))]);
i=(-1:0.01:1)';
    zero=zeros(dimension,1);

for k=1:201
    
    casePPA=zeros(dimension,1);
    casePPA(1,1)=i(k,:)*rangePPAModes;
    [caseloadingsPPA1]=inversePPA(casePPA',Eval,Model,dimension);
    casePPAconstructed=MeanPCA+ssmV(:,1:dimension)*caseloadingsPPA1';
    casePPAconstructed=reshape(casePPAconstructed,length(casePPAconstructed)/3,3);
    
clf
subplot(1,2,1)
trisurf(F1,casePPAconstructed(:,1),casePPAconstructed(:,2),casePPAconstructed(:,3),'Edgecolor','none','FaceVertexCData',color);
light
lighting phong;
set(gca, 'visible', 'off')

axis equal
view(30,0)
material dull
lighting phong;

subplot(1,2,2)
menisci=casePPAconstructed(end-2399:end,:);
colormenisci=[0.5 0.5 0.1];
Fmenisci=F1(end-4439:end,:);
Fmenisci=Fmenisci-min(min(Fmenisci))+1;

trisurf(Fmenisci,menisci(:,1),menisci(:,2),menisci(:,3),'Edgecolor','none','FaceColor',colormenisci);
light
lighting phong;
set(gca, 'visible', 'off')

axis equal
view(-5,90)
material dull
lighting phong;
drawnow update
frame = getframe(gcf); 
framy{k}=frame;

end

for k=1:201
    
    casePPA=zeros(dimension,1);
    casePPA(1,1)=i(end+1-k,:)*rangePPAModes;
    [caseloadingsPPA1]=inversePPA(casePPA',Eval,Model,dimension);
    casePPAconstructed=MeanPCA+ssmV(:,1:dimension)*caseloadingsPPA1';
    casePPAconstructed=reshape(casePPAconstructed,length(casePPAconstructed)/3,3);
clf
subplot(1,2,1)
trisurf(F1,casePPAconstructed(:,1),casePPAconstructed(:,2),casePPAconstructed(:,3),'Edgecolor','none','FaceVertexCData',color);
light
lighting phong;
set(gca, 'visible', 'off')

axis equal
view(30,0)
material dull
lighting phong;

subplot(1,2,2)
menisci=casePPAconstructed(end-2399:end,:);
colormenisci=[0.5 0.5 0.1];
Fmenisci=F1(end-4439:end,:);
Fmenisci=Fmenisci-min(min(Fmenisci))+1;

trisurf(Fmenisci,menisci(:,1),menisci(:,2),menisci(:,3),'Edgecolor','none','FaceColor',colormenisci);
light
lighting phong;
set(gca, 'visible', 'off')

axis equal
view(-5,90)
material dull

drawnow update
frame = getframe(gcf); 
framy{201+k}=frame;

end


v = VideoWriter('ManuSim','MPEG-4');
v.FrameRate=15;
open(v);
for i=1:3:402
frame = framy{i};
writeVideo(v,frame);
end
close (v)
