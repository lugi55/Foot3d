
import os
import sys
import logging
import numpy as np
import torch
import torchvision
from torch.utils.data import DataLoader
from tensorboardX import SummaryWriter
import transforms3d


sys.path.insert(1, '/home/frieder/MATLAB-Drive/Foot3d/ShoeFitter/Algorithmen/PCRNet')
cwd = os.getcwd()
print(cwd)


from pcrnet.models import PointNet, iPCRNet


ptnet = PointNet(emb_dims=1024)
model = iPCRNet(feature_model=ptnet)
model = model.to('cuda:0')
model.load_state_dict(torch.load('/home/frieder/MATLAB-Drive/Foot3d/ShoeFitter/Algorithmen/PCRNet/pcrnet/pretrained/exp_ipcrnet/models/best_model.t7', map_location='cpu'))
model.to('cuda:0')



template = torch.from_numpy(template)
source = torch.from_numpy(source)

template = template.to('cuda:0')
source = source.to('cuda:0')


result = model.forward(template,source,10)
est_R = result['est_R']
est_t = result['est_t']
print('est_R',est_R)
print('est_t',est_t)
transformed_source = torch.bmm(est_R, source.permute(0, 2, 1)).permute(0,2,1) + est_t

transformed_source = transformed_source.to('cpu')
transformed_source = transformed_source.detach().numpy()
