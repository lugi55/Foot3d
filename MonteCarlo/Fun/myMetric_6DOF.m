

function e = myMetric_6DOF(ptGT,ptGitter)
    ptGlobal = vertcat(ptGT{:});
    ptGitterGlobal = vertcat(ptGitter{:});
    tformGlobal = estgeotform3d(ptGlobal,ptGitterGlobal,'rigid');
    for i = 1:length(ptGitter)
        ptGitter{i} = ptGitter{i}*tformGlobal.R-tformGlobal.Translation;
        e(i) = mean(vecnorm(ptGitter{i}-ptGT{i},2,2));
    end
    e = mean(e);
end


