//NB Most of this is default generated from a new Surface shader, except for the vertex program.
Shader "DataVisualization/VertexHeightmapSurfaceShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_HeightFactor("Height Factor", Range(0,100)) = 50
		[PerRendererData]
		_Heightmap("Heightmap", 2d) = "white" {}
		[PerRendererData]
		_heightmapWidth("Heightmap Width", Float) = 0
		[PerRendererData]
		_heightmapHeight("Heightmap Height", Float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows vertex:vert addshadow

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			struct Input
			{
				float2 uv_MainTex;//Need something here so structure is not empty
			};

			sampler2D _Heightmap;
			half _HeightFactor;
			float _heightmapWidth;
			float _heightmapHeight;

			void vert(inout appdata_full v)
			{
				float dx = 1.0 / (_heightmapWidth - 1);
				float dy = 1.0 / (_heightmapHeight - 1);

				float2 texCoord = float2(dx, dy) * 0.5f + v.texcoord.xy * float2(1 - 0.5 * dx, 1 - 0.5 * dy);

				float f00 = tex2Dlod(_Heightmap, float4(texCoord, 0, 0)).a;
				float fp0 = tex2Dlod(_Heightmap, float4(texCoord + float2(dx, 0), 0, 0)).a;
				float fm0 = tex2Dlod(_Heightmap, float4(texCoord - float2(dx, 0), 0, 0)).a;
				float f0p = tex2Dlod(_Heightmap, float4(texCoord + float2(0, dy), 0, 0)).a;
				float f0m = tex2Dlod(_Heightmap, float4(texCoord - float2(0, dy), 0, 0)).a;
				float fpp = tex2Dlod(_Heightmap, float4(texCoord + float2(dx, dy), 0, 0)).a;
				float fmm = tex2Dlod(_Heightmap, float4(texCoord - float2(dx, dy), 0, 0)).a;
				float fpm = tex2Dlod(_Heightmap, float4(texCoord + float2(dx, -dy), 0, 0)).a;
				float fmp = tex2Dlod(_Heightmap, float4(texCoord + float2(-dx, dy), 0, 0)).a;

				v.vertex.y += f00 * _HeightFactor;

				float scharrXUnnormalized = 3 * (fpp + fpm - fmp - fmm) + 10 * (fp0 - fm0);
				float scharrYUnnormalized = 3 * (fpp + fmp - fpm - fmm) + 10 * (f0p - f0m);

				float pseudoXDerivative = scharrXUnnormalized / (32 * dx);
				float pseudoYDerivative = scharrYUnnormalized / (32 * dy);

				//Note that the choice for approximation of first partial derivatives remains open, even using a 3x3 stencil.
				//Instead of the most straightforward such approximations (commented below) we will opt for the Scharr operator to minimize angular error.
				//float pseudoXDerivative = (fp0 - fm0) / (2 * dx);
				//float pseudoYDerivative = (f0p - f0m) / (2 * dy);

				//If viewed too close, LOD 0 will create artifacts ...
				float3 normal = normalize(float3(-pseudoXDerivative, 1, -pseudoYDerivative));
				normal = UnityObjectToWorldNormal(normal);
				v.normal = normal;
			}

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_CBUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_CBUFFER_END

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				// Albedo comes from a texture tinted by color
				//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				fixed4 c = _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
