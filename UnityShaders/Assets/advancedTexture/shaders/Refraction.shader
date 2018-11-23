Shader "custom/advancedTexture/Refraction"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_RefractColor("Refraction Color", Color) = (1,1,1,1)
		_RefractAmount("Refraction Amount", Range(0,1)) = 1
		_RefractRatio("Refraction Ratio", Range(0.1, 1)) = 0.5
		_Cubemap("Refraction Cubemap", Cube) = "_Skybox"{}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }


		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			fixed _RefractAmount;
			fixed _RefractRatio;
			samplerCUBE _Cubemap;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos: TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				fixed3 worldRefractDir : TEXCOORD2;
				SHADOW_COORDS(3)
			};



			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				fixed3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				// compute the refract dir in world space
				o.worldRefractDir = refract(-normalize(worldViewDir), normalize(o.worldNormal), _RefractRatio);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				// Use the refract dir in world space to access the cubemap
				fixed3 refraction = texCUBE(_Cubemap, i.worldRefractDir).rgb * _RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				// Mix the diffuse color with the reflected color
				fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;
	
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}

	FallBack "Reflective/VertexLit"
}
