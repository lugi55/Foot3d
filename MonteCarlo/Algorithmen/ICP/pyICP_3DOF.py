from simpleicp import PointCloud, SimpleICP
import numpy as np


# Create point cloud objects
pc_fix = PointCloud(A, columns=["x", "y", "z"])
pc_mov = PointCloud(B, columns=["x", "y", "z"])

# Create simpleICP object, add point clouds, and run algorithm!
icp = SimpleICP()
icp.add_point_clouds(pc_fix, pc_mov)
H, X_mov_transformed, rigid_body_transformation_params, distance_residuals = icp.run(max_overlap_distance=0.05,rbp_observation_weights=(np.inf, np.inf, 0, 0, 0, np.inf))

result = [X_mov_transformed]