// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//在片元着色器计算漫反射模型
//逐像素光照可以改善逐顶点光照的锯齿，得到更加平滑的效果。
//缺点：背光面全黑，无明暗变化
Shader "Custom/DiffusePixelLevel" {
	Properties{
		_Diffuse("Color", Color) = (1,1,1,1)

	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma vertex vert			//声明顶点着色器
				#pragma fragment frag		//声明片元着色器

				#include "Lighting.cginc"	//包含内置光照文件

				fixed4 _Diffuse;			//声明访问属性的变量

				//顶点着色器的输入参数，由Unity填充
				struct a2v {
					//顶点，模型空间
					float4 vertex:POSITION;
					//顶点法线
					float3 normal:NORMAL;
				};

				struct v2f {
					//顶点在齐次剪裁空间下的坐标，由顶点着色器计算变换
					float4 pos:SV_POSITION;

					fixed3 worldNormal : TEXCOORD0;
				};
				
				v2f vert(a2v v)
				{
					v2f o;
					//将顶点坐标从模型空间转换到齐次剪裁空间的坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//将顶点法线从模型空间转换到世界空间
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

					return o;
				}

				fixed4 frag(v2f i):SV_Target
				{
					//环境光颜色
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					//归一化法线
					fixed3 worldNormal = normalize(i.worldNormal);

					//世界空间坐标的光线方向，归一化
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

					//计算漫反射，公式：diffuse = (入射光 * 漫反射系数) * max(0, dot(法线(世界空间), 光源方向(世界空间)))
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

					fixed3 color = ambient + diffuse;

					return fixed4(color, 1.0);
				}

				ENDCG
	}

	
	}
	FallBack "Diffuse"
}
