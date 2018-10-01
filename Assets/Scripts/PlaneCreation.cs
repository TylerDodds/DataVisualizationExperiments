using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DataVisualization
{
    public static class PlaneCreation
    {
        public static Mesh GetMeshFromHeightmap(Texture heightmap, Vector3 gridDelta)
        {
            Mesh mesh = null;
            if (heightmap != null)
            {
                mesh = CreatePlane(heightmap.width, heightmap.height, new Vector2(gridDelta.x, gridDelta.z));
            }
            return mesh;
        }

        public static Mesh GetMeshPointsFromHeightmap(Texture heightmap, Vector3 gridDelta)
        {
            Mesh mesh = null;
            if (heightmap != null)
            {
                mesh = CreatePlanePoints(heightmap.width, heightmap.height, new Vector2(gridDelta.x, gridDelta.z));
            }
            return mesh;
        }

        public static void SetMeshVertexHeights(Mesh planeMesh, Texture2D texture, float heightScale)
        {
            int numPointsX = texture.width;
            int numPointsY = texture.height;
            int totalNumPoints = numPointsX * numPointsY;
            var vertices = planeMesh.vertices;

            for (int i = 0; i < totalNumPoints; i++)
            {
                int xIndex = i % numPointsX;
                int yIndex = i / numPointsX;

                Vector3 point = vertices[i];
                point.y = GetHeight(xIndex, yIndex, texture, heightScale);
                vertices[i] = point;
            }

            planeMesh.vertices = vertices;
            planeMesh.RecalculateNormals();
            //NB we won't worry about tangents yet
        }

        private static Mesh CreatePlanePoints(int numPointsX, int numPointsY, Vector2 vertexPositionScale)
        {
            Mesh mesh = new Mesh();

            int totalNumPoints = numPointsX * numPointsY;

            if (totalNumPoints < _numVerticesCutoff)
            {
                Vector3[] vertices = new Vector3[totalNumPoints];
                Vector2[] uvs = new Vector2[totalNumPoints];
                Vector3[] normals = new Vector3[totalNumPoints];
                int[] indices = new int[totalNumPoints];

                for (int i = 0; i < totalNumPoints; i++)
                {
                    int xIndex = i % numPointsX;
                    int yIndex = i / numPointsX;

                    vertices[i] = new Vector3(xIndex * vertexPositionScale.x, 0f, yIndex * vertexPositionScale.y);
                    uvs[i] = new Vector2(xIndex / (float)(numPointsX - 1), yIndex / (float)(numPointsY - 1));
                    indices[i] = i;
                    normals[i] = Vector3.up;
                }

                mesh.vertices = vertices;
                mesh.uv = uvs;
                mesh.normals = normals;
                mesh.SetIndices(indices, MeshTopology.Points, 0);
            }
            else
            {
                Debug.LogWarning(string.Format("Attempting to create a plane with {0} x {1} = {2} points results in too many vertices in the mesh (max {3}).", numPointsX, numPointsY, totalNumPoints, _numVerticesCutoff));
            }

            return mesh;
        }

        private static Mesh CreatePlane(int numPointsX, int numPointsY, Vector2 vertexPositionScale)
        {
            Mesh mesh = new Mesh();

            int totalNumPoints = numPointsX * numPointsY;

            if (totalNumPoints < _numVerticesCutoff)
            {
                Vector3[] vertices = new Vector3[totalNumPoints];
                Vector2[] uvs = new Vector2[totalNumPoints];
                Vector3[] normals = new Vector3[totalNumPoints];
                Vector4[] tangents = new Vector4[totalNumPoints];
                int[] trindices = new int[(numPointsX - 1) * (numPointsY - 1) * 6];

                Vector3 normal = Vector3.up;
                Vector4 tangent = new Vector4(1f, 0f, 0f, 1f);
                for (int i = 0; i < totalNumPoints; i++)
                {
                    int xIndex = i % numPointsX;
                    int yIndex = i / numPointsX;

                    vertices[i] = new Vector3(xIndex * vertexPositionScale.x, 0f, yIndex * vertexPositionScale.y);
                    uvs[i] = new Vector2(xIndex / (float)(numPointsX - 1), yIndex / (float)(numPointsY - 1));
                    normals[i] = normal;
                    tangents[i] = tangent;

                    if (xIndex < numPointsX - 1 && yIndex < numPointsY - 1)
                    {
                        int trindexBase = 6 * (xIndex + yIndex * (numPointsX - 1));
                        trindices[trindexBase + 0] = i;
                        trindices[trindexBase + 1] = i + numPointsX;
                        trindices[trindexBase + 2] = i + 1;
                        trindices[trindexBase + 3] = i + 1 + numPointsX;
                        trindices[trindexBase + 4] = i + 1;
                        trindices[trindexBase + 5] = i + numPointsX;
                        //Note that we are always triangulating along the same diagonal here.
                        //If we expect the heightmap to change then we cannot use the height to determine 'best' choice of diagonal.
                    }
                }

                mesh.vertices = vertices;
                mesh.uv = uvs;
                mesh.triangles = trindices;
                mesh.normals = normals;
                mesh.tangents = tangents;
            }
            else
            {
                Debug.LogWarning(string.Format("Attempting to create a plane with {0} x {1} = {2} points results in too many vertices in the mesh (max {3}).", numPointsX, numPointsY, totalNumPoints, _numVerticesCutoff));
            }

            return mesh;
        }

        private static float GetHeight(int xIndex, int yIndex, Texture2D texture, float heightScale)
        {
            var texColor = texture.GetPixel(xIndex, yIndex);
            return texColor.a * heightScale;
        }

        const int _numVerticesCutoff = 65000;
    }

}