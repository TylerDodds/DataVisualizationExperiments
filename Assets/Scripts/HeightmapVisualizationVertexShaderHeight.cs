using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DataVisualization
{
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshFilter))]
    [ExecuteInEditMode]
    public class HeightmapVisualizationVertexShaderHeight : HeightmapShaderRendererBase
    {
        protected override Mesh GetMeshFromHeightmap(Texture heightmap, Vector3 gridDelta)
        {
            return PlaneCreation.GetMeshFromHeightmap(heightmap, gridDelta);
        }

    }
}