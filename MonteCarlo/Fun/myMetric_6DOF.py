import numpy as np

def estgeotform3d(ptGlobal, ptGitterGlobal):
    # Calculate centroids
    centroid_ptGlobal = np.mean(ptGlobal, axis=0)
    centroid_ptGitterGlobal = np.mean(ptGitterGlobal, axis=0)
    
    # Center the points
    ptGlobal_centered = ptGlobal - centroid_ptGlobal
    ptGitterGlobal_centered = ptGitterGlobal - centroid_ptGitterGlobal
    
    # Compute the covariance matrix
    H = ptGitterGlobal_centered.T @ ptGlobal_centered
    
    # Singular Value Decomposition
    U, S, Vt = np.linalg.svd(H)
    
    # Compute the rotation matrix
    R = Vt.T @ U.T
    
    # Special reflection case
    if np.linalg.det(R) < 0:
        Vt[-1, :] *= -1
        R = Vt.T @ U.T
    
    # Compute the translation vector
    T = centroid_ptGlobal - R @ centroid_ptGitterGlobal
    
    return {'R': R, 'Translation': T}

def myMetric_6DOF(ptGT, ptGitter):
    ptGlobal = np.vstack(ptGT)
    ptGitterGlobal = np.vstack(ptGitter)
    tformGlobal = estgeotform3d(ptGlobal, ptGitterGlobal)

    e = []
    for i in range(len(ptGitter)):
        ptGitter_transformed = (ptGitter[i] @ tformGlobal['R'].T) + tformGlobal['Translation']
        e.append(np.mean(np.linalg.norm(ptGitter_transformed - ptGT[i], axis=1)))
    
    return np.mean(e)
