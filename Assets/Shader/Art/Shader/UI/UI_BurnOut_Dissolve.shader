﻿Shader "LDJ/UI/Burnout Dissolve" {
	Properties {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//_NormalMap("Normal Map",2D) = "black" {}
		_NoiseMap("Noise Map",2D) = "black" {}
		_Cutout("Cut Out",Range(0,1.1)) = 0.2
		[HDR]_BurnColor("Burn edge Color",Color) = (1,0,0,1)
	
	}
	SubShader {
		Tags {"Queue" = "AlphaTest" "RenderType"="TransparentCutout" }

		cull off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard alphatest:_Cutoff nofog noambient
		
		fixed4 _Color;

		sampler2D _MainTex;
		//sampler2D _NormalMap;
		sampler2D _NoiseMap;

		float4 _BurnColor;

		float _Cutout;


		struct Input {
			float2 uv_MainTex;
			//float2 uv_NormalMap;
			float2 uv_NoiseMap;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {

			// basic albedo settings
			//o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Emission = c.rgb  * _Color;


			// get burn opacity percentage
			float opacity = tex2D(_NoiseMap,IN.uv_NoiseMap).r;

			_Cutout = pow(_Cutout,2);

			if(opacity < _Cutout * 1.2)
			{
				o.Emission = _BurnColor;
			}

			if(opacity < _Cutout)
			{
				o.Alpha = -0.1;
			}
			else
			{
				o.Alpha = c.a;
			}			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
