﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TNG"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalTex("Normal Tex", 2D) = "normal" {}
		_GlossTex("Texture", 2D) = "white" {}
		_Spec("Spec", Range(0.001, 1)) = 1
	}
	SubShader
	{
		Pass
		{
			tags{"LightMode" = "Vertex"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			sampler2D _NormalTex;
			sampler2D _GlossTex;

			float _Spec;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float atten : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float3 view_pos = mul(UNITY_MATRIX_MV, v.vertex).xyz;
				float3 to_light = unity_LightPosition[0].xyz - view_pos.xyz * unity_LightPosition[0].w;
				float lengthSQ = dot(to_light, to_light);
				o.atten = 1.0 / (1.0 + lengthSQ * unity_LightAtten[0.5].z);

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				float3 normal = UnpackNormal(tex2D(_NormalTex, i.uv));
				float4 glossCol = tex2D(_GlossTex, i.uv);
				i.lightDir = normalize(i.lightDir);
			
				float diff = max(0, dot(normal, i.lightDir));

				float3 nh = normalize(i.lightDir + i.viewDir);
				float h = max(0, dot(normal, nh));
				float spec = pow(h, _Spec * 128);

				float4 outCol = col * (unity_LightColor[0] * diff + unity_LightColor[0] * spec) * i.atten + glossCol;

				return outCol;
			}
			ENDCG
		}
	}
}
