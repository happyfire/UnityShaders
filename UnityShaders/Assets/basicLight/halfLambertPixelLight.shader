// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "custom/basic/halfLambertPixelLight"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal: TEXCOORD0;	
			};			
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);				

				//应该使用顶点变换矩阵的逆转置矩阵去变换法线，这里要将法线从模型空间变换到世界空间，需要 ObjectToWorld矩阵的逆转置，即 WorldToObject的转置矩阵
				//由于法线是三维矢量，所以只需截取这个矩阵的前三行前三列，因为 矩阵*向量 == 向量*矩阵的转置，所以这儿使用左乘即可，节省了转置操作
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));//使用向量左乘，节省了一次矩阵转置
												
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed halfLambert = 0.5*dot(worldNormal, worldLight) + 0.5; //half lambert将dot(n,l)映射到[0,1]
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert; 

				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
