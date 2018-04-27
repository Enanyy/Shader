Shader "Custom/Sphere"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CenterX("CenterX",Range(0,1)) = 0.5
		_CenterY("CenterY",Range(0,1) )= 0.5
		_Radius("Radius", Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _CenterX;
			float _CenterY;
			float _Radius;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				
				float2 direction = float2(_CenterX, _CenterY) - i.uv;
			
				float distance = sqrt(direction.x * direction.x + direction.y * direction.y);

				fixed4 col;

				if (distance > _Radius) {

					float2 dv =normalize( float2(0.5, 0.5) - i.uv );

					col = tex2D(_MainTex, i.uv + dv *_Radius);
				}
				else
				{
					discard;
				}
			
				return col;
			}
			ENDCG
		}
	}
}
