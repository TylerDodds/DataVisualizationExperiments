Shader "DataVisualization/BarHeightShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Glossiness("Smoothness", Range(0.1,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_HeightFactor("Height Factor", Range(0,100)) = 50
		[PerRendererData]
		_Heightmap("Heightmap", 2d) = "white" {}
		[PerRendererData]
		_heightmapWidth("Heightmap Width", Float) = 0
		[PerRendererData]
		_heightmapHeight("Heightmap Height", Float) = 0
		[PerRendererData]
		_squareWidth("Square Width", Float) = 0
		[PerRendererData]
		_squareHeight("Square Height", Float) = 0
	}
		SubShader
		{
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom
				#pragma target 4.0
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				#define FORWARD_BASE_PASS
				#define WIREFRAME
				#if defined(WIREFRAME)
				#define SetSquareCoordsSize(x,y) fragment.squareCoords.zw = float2(x, y);
				#define SetSquareCoords_00 fragment.squareCoords.xy = float2(0, 0);
				#define SetSquareCoords_10 fragment.squareCoords.xy = float2(fragment.squareCoords.z, 0);
				#define SetSquareCoords_01 fragment.squareCoords.xy = float2(0, fragment.squareCoords.w);
				#define SetSquareCoords_11 fragment.squareCoords.xy = fragment.squareCoords.zw;
				#else
				#define SetSquareCoordsSize(x,y)
				#define SetSquareCoords_00
				#define SetSquareCoords_10
				#define SetSquareCoords_01
				#define SetSquareCoords_11
				#endif

			sampler2D _Heightmap;
			half _HeightFactor;
			float _heightmapWidth;
			float _heightmapHeight;
			float _squareWidth;
			float _squareHeight;

			struct VertexData
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct GeometryData
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			struct FragmentInterpolators
			{
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 position : SV_POSITION;
				#if defined(WIREFRAME)
				float4 squareCoords : TEXCOORD9;
				#endif
			};

			
			GeometryData vert (VertexData v)
			{
				GeometryData o;

				o.position = v.position;
				o.uv = v.uv;
				o.normal = (v.normal);
				return o;
			}

			[maxvertexcount(20)]
			void geom(point GeometryData IN[1], inout TriangleStream<FragmentInterpolators> triStream)
			{
				GeometryData g = IN[0];
				float tex_dx = 1.0 / (_heightmapWidth - 1);
				float tex_dy = 1.0 / (_heightmapHeight - 1);
				float2 texCoord = float2(tex_dx, tex_dy) * 0.5f + g.uv * float2(1 - 0.5 * tex_dx, 1 - 0.5 * tex_dy);
				float pointHeight = tex2Dlod(_Heightmap, float4(texCoord, 0, 0)).a * _HeightFactor;


				FragmentInterpolators fragment;
				fragment.normal = UnityObjectToWorldNormal(g.normal);

				float4 dx = float4(1, 0, 0, 0) * _squareWidth;
				float4 dz = float4(0, 0, 1, 0) * _squareHeight;

				float4 objectPos = g.position;
				float4 fragmentObjectPos = objectPos;

				//Top side 
				SetSquareCoordsSize(2 * _squareWidth, 2 * _squareHeight);
				SetSquareCoords_00;
				fragment.normal = UnityObjectToWorldNormal(float3(0, 1, 0));
				objectPos = g.position + float4(0, pointHeight, 0, 0);
				fragmentObjectPos = objectPos - dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_10;
				fragmentObjectPos = objectPos - dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_01;
				fragmentObjectPos = objectPos + dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_11;
				fragmentObjectPos = objectPos + dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				triStream.RestartStrip();

				//Left side
				SetSquareCoordsSize(2 * _squareHeight, pointHeight);
				SetSquareCoords_00;
				fragment.normal = UnityObjectToWorldNormal(float3(-1, 0, 0));
				objectPos = g.position;
				fragmentObjectPos = objectPos - dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_10;
				fragmentObjectPos = objectPos - dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_01;
				objectPos = g.position + float4(0, pointHeight, 0, 0);
				fragmentObjectPos = objectPos - dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_11;
				fragmentObjectPos = objectPos - dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				triStream.RestartStrip();

				//Right side
				SetSquareCoordsSize(2 * _squareHeight, pointHeight);
				SetSquareCoords_00;
				fragment.normal = UnityObjectToWorldNormal(float3(1, 0, 0));
				objectPos = g.position;
				fragmentObjectPos = objectPos + dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_10;
				fragmentObjectPos = objectPos + dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				objectPos = g.position + float4(0, pointHeight, 0, 0);
				SetSquareCoords_01;
				fragmentObjectPos = objectPos + dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_11;
				fragmentObjectPos = objectPos + dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				triStream.RestartStrip();

				//Front side
				SetSquareCoordsSize(2 * _squareWidth, pointHeight);
				SetSquareCoords_00;
				fragment.normal = UnityObjectToWorldNormal(float3(0, 0, -1));
				objectPos = g.position;
				fragmentObjectPos = objectPos + dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_10;
				fragmentObjectPos = objectPos - dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_01;
				objectPos = g.position + float4(0, pointHeight, 0, 0);
				fragmentObjectPos = objectPos + dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_11;
				fragmentObjectPos = objectPos - dx - dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				triStream.RestartStrip();

				//Back side
				fragment.normal = UnityObjectToWorldNormal(float3(0, 0, 1));
				objectPos = g.position;

				SetSquareCoordsSize(2 * _squareWidth, pointHeight);
				SetSquareCoords_00;
				fragmentObjectPos = objectPos - dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_10;
				fragmentObjectPos = objectPos + dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_01;
				objectPos = g.position + float4(0, pointHeight, 0, 0);
				fragmentObjectPos = objectPos - dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				SetSquareCoords_11;
				fragmentObjectPos = objectPos + dx + dz;
				fragment.position = UnityObjectToClipPos(fragmentObjectPos);
				fragment.worldPos = mul(unity_ObjectToWorld, fragmentObjectPos);
				triStream.Append(fragment);

				triStream.RestartStrip();
			}
			
			float4 _Color;
			float _Glossiness;

			UnityIndirect CreateIndirectLight(FragmentInterpolators i)
			{
				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				//We'll ignore vertex lights for now
				#if defined(FORWARD_BASE_PASS)
				indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
				//Ensure only positive contribution from spherical harmonics is added.
				#endif
				//Of course, only calculate this in the base pass, independent of vertex lights

				return indirectLight;
			}

			fixed4 frag (FragmentInterpolators i) : SV_Target
			{
				fixed4 col = _Color;

				UnityIndirect indirectLight = CreateIndirectLight(i);

				//Just simple diffuse and specular for this example. 
				//We can consider fog, environment lighting, shadows, PBR etc. later.

				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 reflectionDir = reflect(-lightDir, i.normal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 halfDir = normalize(lightDir + viewDir);

				fixed3 lightColor = _LightColor0.xyz;
				fixed3 albedo = _Color.rgb;
				float3 diffuse = albedo * (lightColor * DotClamped(lightDir, i.normal) + indirectLight.diffuse);

				const float glossMultiplier = 1;//NB This multiple is just so that the power will be large enough to have (roughly) the correct visual effect.
				float specularVal = DotClamped(halfDir, i.normal);
				specularVal = pow(specularVal, _Glossiness * glossMultiplier);
				float3 specular = specularVal * lightColor * _Color.rgb;

				float4 finalColor = float4(diffuse + specular, 1);

				#if defined(WIREFRAME)
				float2 minCoords = min(i.squareCoords.xy, i.squareCoords.zw - i.squareCoords.xy);
				float minCoord = min(minCoords.x, minCoords.y);
				float minSquareSide = min(i.squareCoords.z, i.squareCoords.w);
				float minSquareSideScale = minSquareSide * 0.1;

				float2 screenSpaceSizes = fwidth(i.squareCoords);
				float minScreenSpaceSize = min(screenSpaceSizes.x, screenSpaceSizes.y);

				float scale = min(minSquareSideScale, minScreenSpaceSize);
				
				float scaleFrac = saturate(max(minSquareSideScale, minScreenSpaceSize) * 3);//Fade out the wireframe when far. Factor of 3 is just a rough estimate.
				float invWireFraction = scaleFrac + (1 - scaleFrac) * smoothstep(scale, scale * 1.5, minCoord);

				finalColor.rgb *= invWireFraction;
				#endif

				return finalColor;
			}
			ENDCG
		}
	}
}
