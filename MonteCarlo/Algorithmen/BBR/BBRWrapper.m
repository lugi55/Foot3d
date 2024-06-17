


function pt = BBRWrapper(pt)

    ptA = zeros([1,3,1024],"single");
    ptB = zeros([1,3,1024],"single");

    randIdx = randperm(length(pt{1}), 1024);
    ptA(1,:,:) = pt{1}(randIdx,:)';
    randIdx = randperm(length(pt{2}), 1024);
    ptB (1,:,:) = pt{2}(randIdx,:)';

 
    A = py.numpy.array(to_np(ptA));
    B = py.numpy.array(to_np(ptB));
    transform_model_points = pyrunfile('pcr_net.py','transformed_source',template=A,source=B);
    pt{2} = from_np(transform_model_points);
    pt{1} = ptA;

    pt{1} = squeeze(pt{1}(1,:,:))';
    pt{2} = squeeze(pt{2}(1,:,:))';


end


function p = to_np(p)
    sz = size(p);
    p = reshape(p,[1 numel(p)]); 
    p = py.numpy.array(p);
    p = p.reshape(num2cell(fliplr(uint32(sz))));
    t = 0:length(uint32(sz))-1;
    t(end-[1 0]) = t(end-[0 1]);
    p = p.transpose(num2cell(uint32(t)));
end

function p = from_np(p)
    sz = cellfun(@double,cell(p.shape));
    method = 1;
    switch method
        case 1
            empty = any(sz == 0);
            if empty
                p = py.numpy.insert(p,0,0);
            end
            p = py.array.array(p.dtype.char,p.ravel); 
            c = p.pop(); 
            if ~empty
                p.append(c);
            end
        case 2
            p = py.numpy.insert(p,p.size,0); 
            p = py.array.array(p.dtype.char,p); 
            c = p.pop();
    end
    
    p = cast(p,'like',c);
    p = reshape(p,fliplr(sz));
    t = 1:length(sz);
    t([1 2]) = t([2 1]);
    p = permute(p,t);
end
