# Data Visualization Experiments

## Overview

These are quick experiments designed to experiment with different methods of visualizing data, primarily heightmap data.

## Heightmap

We investigate how can a heightmap image be rendered, particularly one that is constantly changing.

The choice of representation depends strongly on the data and the purpose of visualization. 

* Generate triangulated heightmap mesh, recalculate normals CPU-side.
* Generate triangulated grid, shift vertices and recalculated shared vertex normals in GPU by sampling heightmap.
 - Appropriate approximation of derivative, for instance with a Scharr operator, is necessary to approximate the normals.
 - We could also consider performing these convolutions CPU-side first.
* As above, but with point rendering instead of full triangulated mesh rendering.
* For heightmaps with high-frequency components, we may wish to present each data point without any smoothing approximations.
 - Representing each heightmap point in a pseudo-bar-chart form may help to distinguish certain features.
