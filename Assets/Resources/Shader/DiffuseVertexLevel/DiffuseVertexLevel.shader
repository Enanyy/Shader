// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//在顶点着色器计算漫反射模型
//缺点：细分程度较低的模型，逐顶点光照会在正光面和背光面交界处出现锯齿，
//这是由于逐顶点计算出的是每个顶点的颜色，而这些顶点没有对应到的屏幕像
//素是通过顶点的颜色和深度进行插值得到的。
Shader "Custom/DiffuseVertexLevel" {
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

					fixed3 color : Color;
				};
				
				v2f vert(a2v v)
				{
					v2f o;
					//将顶点坐标从模型空间转换到齐次剪裁空间的坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//环境光颜色
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					//将顶点法线从模型空间坐标系转换到世界空间坐标系，并归一化
					fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

					//世界空间坐标的光线方向，归一化
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					//计算漫反射，公式：diffuse = (入射光 * 漫反射系数) * max(0, dot(法线(世界空间), 光源方向(世界空间)))
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
					//世界光加上漫反射光
					o.color = ambient + diffuse;

					return o;
				}

				fixed4 frag(v2f i):SV_Target
				{
					return fixed4(i.color, 1.0);
				}

				ENDCG
	}

	
	}
	FallBack "Diffuse"
}
