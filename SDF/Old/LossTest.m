

t = linspace(-1,1,50);
y = linspace(-1,1,50);


[Y,T] = meshgrid(y,t);


loss = myLoss(Y(:),T(:));
loss = reshape(loss,size(Y));

surf(T,Y,loss)
xlabel('T')
ylabel('Y')


function loss = myLoss(Y,T)
    sigma = 0.5
    loss = abs((min(max(Y,-sigma),sigma)-min(max(T,-sigma),sigma)))
end


