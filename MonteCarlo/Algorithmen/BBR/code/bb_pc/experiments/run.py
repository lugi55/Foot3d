import open3d as o3d
import numpy as np
import os
import sys
import scipy.io
import open3d as o3d
import json
import tqdm
import inspect
sys.path.append('../../../Fun')
from myMetric_6DOF import *


# select which GPU to work on (read from first command line argument) (this code has to come before "import tensorflow")
if len(sys.argv) > 1:
    os.environ["CUDA_VISIBLE_DEVICES"] = sys.argv[1]  # select the gpu to use

from ..net.optimize_neural_network import optimize_neural_network
from ..general.TicToc import *
from ..general.bb_pc_path import bb_pc_path
from ..utils.data_tools import import_ply
from ..utils.normals import calc_normals
from ..utils.torch_numpy_3d_tools import rotate_around_random_axis, random_unit_vector
from ..utils.GT_utils import print_GT_vs_result, invert_motion
from ..utils.tools_3d import apply_rot_trans
from ..utils.visualization import draw_registration_result

np.set_printoptions(precision=3, floatmode='maxprec', suppress=True, linewidth=200, threshold=10**6)

def modify_json_file(file_path, new_key, new_value):

    with open(file_path, 'r') as file:
        data = json.load(file)
    
    data[new_key] = new_value
    
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

def new_print(*args, **kwargs):
    try:
        tqdm.tqdm.write(*args, **kwargs)
    except:
        pass

def create_subsets_with_normals(full_PC, num_samples):
    full_normals = calc_normals(full_PC)
    inds_A = np.random.permutation(full_PC.shape[0])[:num_samples]
    A = full_PC[inds_A,:]
    A_normals = full_normals[inds_A, :]
    inds_B = np.random.permutation(full_PC.shape[0])[:num_samples]
    B = full_PC[inds_B,:]
    B_normals = full_normals[inds_B, :]
    return A, B, A_normals, B_normals


def optimize(mode, A, B, A_normals, B_normals):
    config = {}
    config['BBR-softBBS'] = {
        'loss_type': 'BBS',
        'distance_measure': 'point2point',
        'nIterations': 750,
        'alpha_lr': 5e-6,
        'angles_lr': 5e-3,
        'trans_lr': 1e-5,
    }
    config['BBR-softBD'] = {
        'loss_type': 'BD',
        'distance_measure': 'point2point',
        'nIterations': 750,
        'alpha_lr': 5e-6,
        'angles_lr': 5e-3,
        'trans_lr': 1e-5,
    }
    config['BBR-N'] = {
        'loss_type': 'BD',
        'distance_measure': 'point2plane',
        'nIterations': 1000,
        'alpha_lr': 3e-6,
        'angles_lr': 8e-3,
        'trans_lr': 9e-5,
        'LR_step_size': 500,
        'LR_factor': 1e-1
    }
    config['BBR-F'] = {
        'BBR_F': True,
        'nIterations': 750,
        'angles_lr': 5e-3,
        'trans_lr': 1e-5
    }

    _, res_motion, _, _ = \
        optimize_neural_network(A, B, A_normals, B_normals, **config[mode])
    return res_motion

def main():
    inspect.builtins.print = new_print
    directory_path = '../../../MonteCarloTwoScanData'
    for entry_path, _, _ in tqdm.tqdm(list(os.walk(directory_path))):

        if entry_path == directory_path:
            continue

        VISUALIZE = False

        with open(entry_path+'/data.json') as f:
            data = json.load(f)
    
        src = o3d.io.read_point_cloud(entry_path+'/pt1.ply')
        tgt = o3d.io.read_point_cloud(entry_path+'/pt2.ply')
        srcGT = o3d.io.read_point_cloud(entry_path+'/pt1GT.ply')
        tgtGT = o3d.io.read_point_cloud(entry_path+'/pt2GT.ply')

        src.estimate_normals(search_param=o3d.geometry.KDTreeSearchParamKNN(knn=10))
        tgt.estimate_normals(search_param=o3d.geometry.KDTreeSearchParamKNN(knn=10))

        srcGT = np.asarray(srcGT.points)
        tgtGT = np.asarray(tgtGT.points)
        srcN = np.asarray(src.normals)
        tgtN = np.asarray(tgt.normals)
        src = np.asarray(src.points)
        tgt = np.asarray(tgt.points)


        if src.size > tgt.size:
            idx = np.random.choice(src.shape[0],tgt.shape[0],replace=False)
            srcBuf = src[idx,:]
            srcNBuf = srcN[idx,:]
            tgtBuf = tgt
            tgtNBuf = tgtN

        if src.size < tgt.size:
            idx = np.random.choice(tgt.shape[0],src.shape[0],replace=False)
            tgtBuf = tgt[idx,:]
            tgtNBuf = tgtN[idx,:]
            srcBuf = src
            srcNBuf = srcN    



        if VISUALIZE:
            draw_registration_result(srcBuf, tgtBuf, "before")

        for mode in ['BBR-softBBS', 'BBR-softBD', 'BBR-N', 'BBR-F']:
            print("\n\n================= Running in mode: %s =================" % mode)
            estimated_motion = optimize(mode, srcBuf, tgtBuf, srcNBuf, tgtNBuf)
            tgtTrans = apply_rot_trans(tgt, estimated_motion['angles'], estimated_motion['trans'])
            eBBR = myMetric_6DOF([srcGT,tgtGT],[src,tgtTrans])
            tqdm.tqdm.write(mode+': '+str(eBBR))
            modify_json_file(entry_path+'/data.json','e'+mode.replace,eBBR)



            if VISUALIZE:  
                draw_registration_result(src, tgtTrans, "after %s" % mode)

        print("\n\n========= Finished Successfully ========")



if __name__ == "__main__":
    main()
