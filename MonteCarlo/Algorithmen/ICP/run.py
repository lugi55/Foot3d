
from simpleicp import PointCloud, SimpleICP
import numpy as np
import open3d as o3d
import matplotlib.pyplot as plt
import json
import sys
import os
import tqdm
import inspect
sys.path.append('../../Fun')
from myMetric_6DOF import *


def main():

    inspect.builtins.print = new_print
    directory_path = '../../MonteCarloTwoScanData/'


    for entry_path, _, _ in tqdm.tqdm(list(os.walk(directory_path))):

        if entry_path == directory_path:
            continue
     
        with open(entry_path+"/data.json") as f:
            data = json.load(f)

        pt1 = o3d.io.read_point_cloud(entry_path+"/pt1.ply")
        pt2 = o3d.io.read_point_cloud(entry_path+"/pt2.ply")
        pt1GT = o3d.io.read_point_cloud(entry_path+"/pt1GT.ply")
        pt2GT = o3d.io.read_point_cloud(entry_path+"/pt2GT.ply")

        pt1 = np.asarray(pt1.points)
        pt2 = np.asarray(pt2.points)
        pt1GT = np.asarray(pt1GT.points)
        pt2GT = np.asarray(pt2GT.points)

        pc_fix = PointCloud(pt1, columns=["x", "y", "z"])
        pc_mov = PointCloud(pt2, columns=["x", "y", "z"])

        icp = SimpleICP()
        icp.add_point_clouds(pc_fix, pc_mov)
        H, X_mov_transformed, rigid_body_transformation_params, distance_residuals = icp.run(max_overlap_distance=1)

        eICP = myMetric_6DOF([pt1GT,pt2GT],[pt1,X_mov_transformed])
        print(eICP)

        modify_json_file(entry_path+"/data.json", "eICP", eICP)

        if 0:
            fig = plt.figure()
            ax = fig.add_subplot(projection='3d')
            ax.scatter(pt1[:,0],pt1[:,1],pt1[:,2])
            ax.scatter(X_mov_transformed[:,0],X_mov_transformed[:,1],X_mov_transformed[:,2])
            fig.show


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
        



if __name__ == '__main__':
    main()
