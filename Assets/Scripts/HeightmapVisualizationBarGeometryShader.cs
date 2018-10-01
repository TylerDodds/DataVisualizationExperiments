using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DataVisualization
{
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshFilter))]
    [ExecuteInEditMode]
    public class HeightmapVisualizationBarGeometryShader : HeightmapShaderRendererBase
    {
        protected override Mesh GetMeshFromHeightmap(Texture heightmap, Vector3 gridDelta)
        {
            return PlaneCreation.GetMeshPointsFromHeightmap(heightmap, gridDelta);
        }

        protected override void UpdatePropertyBlockFromHeightmap(MaterialPropertyBlock materialPropertyBlock, Texture heightmap, Vector3 gridDelta)
        {
            base.UpdatePropertyBlockFromHeightmap(materialPropertyBlock, heightmap, gridDelta);

            materialPropertyBlock.SetFloat("_squareWidth", gridDelta.x * 0.5f);
            materialPropertyBlock.SetFloat("_squareHeight", gridDelta.z * 0.5f);
        }
    }
}