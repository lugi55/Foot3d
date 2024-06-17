
function ptGitter = pairwiseICP_6DOF(ptGitter)
    for i=1:length(ptGitter)-1
        [ptGitter{i+1}] = ICPWrapper(ptGitter{i},ptGitter{i+1});
        %[~,pt] = pcregistericp(pointCloud(ptGitter{i+1}),pointCloud(ptGitter{i}),"Metric","pointToPlane","InlierDistance",0.008);
        %ptGitter{i+1} = pt.Location;
    end
end


function transformed = ICPWrapper(pt1,pt2)
    A1 = py.numpy.array(pt1);
    B1 = py.numpy.array(pt2);
    result = pyrunfile('pyICP_6DOF.py','result',A=A1,B=B1);
    transformed = double(result{1});
end
