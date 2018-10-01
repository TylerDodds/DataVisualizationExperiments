using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DataVisualization
{
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(MeshFilter))]
    [ExecuteInEditMode]
    public abstract class HeightmapShaderRendererBase: MonoBehaviour
    {
        protected abstract Mesh GetMeshFromHeightmap(Texture heightmap, Vector3 gridDelta);

        protected void OnValidate()
        {
            MeshFilter.sharedMesh = GetMeshFromHeightmap(_heightmap, _gridDelta);
        }

        protected virtual void UpdatePropertyBlockFromHeightmap(MaterialPropertyBlock materialPropertyBlock, Texture heightmap, Vector3 gridDelta)
        {
            materialPropertyBlock.SetTexture("_Heightmap", heightmap);
            materialPropertyBlock.SetFloat("_heightmapWidth", heightmap.width);
            materialPropertyBlock.SetFloat("_heightmapHeight", heightmap.height);
        }

        private void Awake()
        {
            _materialPropertyBlock = new MaterialPropertyBlock();
            UpdatePropertyBlock();
        }

        private void Update()
        {
            //Nothing to update if using Substance textures that update over time
        }

        private void UpdatePropertyBlock()
        {
            if (_heightmap != null)
            {
                UpdatePropertyBlockFromHeightmap(_materialPropertyBlock, _heightmap, _gridDelta);
            }
            else
            {
                _materialPropertyBlock.SetFloat("_heightmapWidth", 0);
                _materialPropertyBlock.SetFloat("_heightmapHeight", 0);
            }
            MeshRenderer.SetPropertyBlock(_materialPropertyBlock);
        }

        [SerializeField]
        private Vector3 _gridDelta = new Vector3(1, 0, 1);

        [SerializeField]
        private Texture _heightmap;

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

        protected MeshRenderer MeshRenderer
        {
            get
            {
                if (_meshRenderer == null)
                {
                    _meshRenderer = GetComponent<MeshRenderer>();
                }
                return _meshRenderer;
            }
        }
        private MeshRenderer _meshRenderer;

        private MaterialPropertyBlock _materialPropertyBlock;

    }
}