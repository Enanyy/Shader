// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Flow" {
	Properties {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_FlowTex("Flow (RGB)", 2D) = "white" {}
		_SpeedX("Speed X", Range(0,100)) = 0.5
		_SpeedY("Speed Y", Range(0,100)) = 0.5
		_Factor("Factor", Range(0,1)) = 0.5
		
	
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
				float2 uv1:TEXCOORD1;
				
			};

			fixed4 _Color;
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST  
			float4 _MainTex_ST;

			sampler2D _FlowTex;
			float4 _FlowTex_ST;


			float _SpeedX;
			float _SpeedY;
			float _Factor;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.texcoord, _FlowTex);
			

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				
				float2 offset = fixed2(_SpeedX, _SpeedY) * _Time.y;
				
				
				fixed4 flow = tex2D(_FlowTex, i.uv1 + offset) * _Factor;
		
				color.rgb += flow.rgb * _Color.rgb;


				return color;
			}

			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
