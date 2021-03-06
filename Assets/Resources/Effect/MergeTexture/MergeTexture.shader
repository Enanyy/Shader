﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MergeTexture" {
	Properties {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		//一个四维向量,xy存储图片的起始坐标，zw存储图片的长宽
		//这些值可以写个脚本类似NGUI的UISprite选择一个图片，然后根据图片设置
		//_Rect("Rect",Vector) = (0,0,0,0)

	
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass {
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert  
			#pragma fragment frag  
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			
				
			};

			fixed4 _Color;
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST  
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;  //对应_MainTex的纹素，(x,y) = (1/Width,1/Height)
			float4	_Rect;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
#if UNITY_UV_STARTS_AT_TOP  
				if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1 - o.uv.y;
#endif   
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				float2 uv = float2( _Rect.x *_MainTex_TexelSize.x + _Rect.z*_MainTex_TexelSize.x * i.uv.x,
									//y轴调换一下
								    1 - (_Rect.y *_MainTex_TexelSize.y + _Rect.w*_MainTex_TexelSize.y * i.uv.y));
				fixed4 color = tex2D(_MainTex, uv);
				

				return color;
			}

			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
