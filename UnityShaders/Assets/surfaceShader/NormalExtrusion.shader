﻿Shader "custom/surfaceShader/NormalExtrusion"
{
    Properties
    {
        _ColorTint ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_Amount("Extrusion Amount", Range(-0.5,0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 300

		CGPROGRAM

		#pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		fixed4 _ColorTint;
		sampler2D _MainTex;
		sampler2D _BumpMap;
		half _Amount;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
        };

		void myvert(inout appdata_full v) {
			v.vertex.xyz += v.normal * _Amount;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}

		half4 LightingCustomLambert(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
			c.a = s.Alpha;
			return c;
		}

		void mycolor(Input IN, SurfaceOutput o, inout fixed4 color) {
			color *= _ColorTint;
		}

        ENDCG
    }
    FallBack "Legacy Shaders/Diffuse"
}
