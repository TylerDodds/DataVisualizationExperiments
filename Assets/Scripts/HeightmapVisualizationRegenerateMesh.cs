using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DataVisualization
{
    public class HeightmapVisualizationRegenerateMesh : MonoBehaviour
    {
        protected void OnValidate()
        {
            MeshFilter.sharedMesh = PlaneCreation.GetMeshFromHeightmap(_heightmap, _gridDelta);

            var mesh = MeshFilter.sharedMesh;
            if (mesh != null && _heightmap != null)
            {
                float heightScale = Mathf.Min(_heightmap.width, _heightmap.height) * 0.5f;
                PlaneCreation.SetMeshVertexHeights(mesh, _heightmap, heightScale);
            }
        }

        [SerializeField]
        private Texture2D _heightmap;

        protected MeshFilter MeshFilter
        {
            get
            {
                if (_meshFilter == null)
                {
                    _meshFilter = GetComponent<MeshFilter>();
                }
                return _meshFilter;
            }
        }
        private MeshFilter _meshFilter;

        [SerializeField]
        private Vector3 _gridDelta = new Vector3(1, 0, 1);

    }
}