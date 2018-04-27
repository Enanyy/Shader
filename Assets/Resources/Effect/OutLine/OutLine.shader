// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OutLine" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Width("Width", Range(0,0.5)) = 0.05
		
	
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass {
		
			ZWrite On
			Cull Front
			//Offset 1,1
			CGPROGRAM
			#pragma vertex vert  
			#pragma fragment frag  
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;		
			
			};

			fixed4 _Color;
			float _Width;
		

			v2f vert(a2v v)
			{
				v2f o;
				//顶点向法线方向外扩
				//v.vertex.xyz += v.normal * _Width;

				o.pos = UnityObjectToClipPos(v.vertex);
				//法线由模型空间转到剪裁空间
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.vertex);
				//
				float2 direction = TransformViewToProjection(normal.xy);
				o.pos.xy += direction * _Width;

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				return _Color;
			}

			ENDCG
		}
		Pass{
			Tags{ "LightMode" = "ForwardBase" }

			//Offset 3,1

			CGPROGRAM
			#pragma vertex vert  
			#pragma fragment frag  
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;

				float2 uv:TEXCOORD0;

			};

		
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST  
			float4 _MainTex_ST;


			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}

			ENDCG
		}
		

		
	}
	FallBack "Diffuse"
}
