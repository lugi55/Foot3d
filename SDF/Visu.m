

%%Set Z Vector

for i=1:10
    Z = [i*0.01;0;0];
    data.net.Learnables{1,3}{1} = gpuArray(dlarray(single(Z)));
    draw(data,50)
end