import test

# import numpy as np

# def solve_n_body_problem(positions, threshold_distance):
#     n = positions.shape[0]  # Number of particles

#     # Compute pairwise distances between positions
#     pairwise_distances = np.linalg.norm(positions[:, np.newaxis] - positions, axis=2)

#     # Initialize cluster labels and visited array
#     labels = np.arange(n)
#     visited = np.zeros(n, dtype=bool)

#     # Helper function to find the nearest unvisited neighbor
#     def find_nearest_unvisited(index):
#         distances = pairwise_distances[index]
#         unvisited_indices = np.where(~visited)[0]
#         nearest_unvisited_index = unvisited_indices[np.argmin(distances[unvisited_indices])]
#         return nearest_unvisited_index

#     # Perform hierarchical clustering
#     for i in range(n):
#         if visited[i]:
#             continue

#         visited[i] = True
#         cluster_label = labels[i]

#         while True:
#             nearest_index = find_nearest_unvisited(i)

#             if pairwise_distances[i, nearest_index] > threshold_distance:
#                 break

#             visited[nearest_index] = True
#             labels[nearest_index] = cluster_label

#     # Find the center of mass for each cluster
#     unique_clusters = np.unique(labels)
#     cluster_centers = []
#     for cluster in unique_clusters:
#         cluster_positions = positions[labels == cluster]
#         center_of_mass = np.mean(cluster_positions, axis=0)
#         cluster_centers.append(center_of_mass)

#     return np.array(cluster_centers)

# # Example usage
# positions = np.array([[1, 1], [2, 2], [10, 10], [11, 11], [20, 20], [21, 21]])
# threshold_distance = 10.0

# cluster_centers = solve_n_body_problem(positions, threshold_distance)
# print(cluster_centers)
