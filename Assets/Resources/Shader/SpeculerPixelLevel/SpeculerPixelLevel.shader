﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//在片元着色器计算高光反射模型
//
Shader "Custom/SpeculerPixelLevel" {
	Properties{
		_Diffuse("Color", Color) = (1,1,1,1)
		_Speculer("Speculer",Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(4.0, 256)) = 20

	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma vertex vert			//声明顶点着色器
				#pragma fragment frag		//声明片元着色器

				#include "Lighting.cginc"	//包含内置光照文件

				fixed4 _Diffuse;			//声明访问属性的变量
				fixed4 _Speculer;			//声明访问属性的变量
				float _Gloss;				//声明访问属性的变量

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

					//顶点在世界空间的法线
					float3 worldNormal:TEXCOORD0;
					//顶点在世界空间下的坐标
					float3 worldPos	:TEXCOORD1;
				};

				v2f vert(a2v v)
				{
					v2f o;
					//将顶点坐标从模型空间转换到齐次剪裁空间的坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//法线转换到世界空间坐标
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

					//顶点在世界空间下的坐标
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					return o;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					fixed3 worldNormal = normalize(i.worldNormal);

					//环境光颜色
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					//世界空间坐标的光线方向，归一化
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					//计算漫反射，公式：diffuse = (入射光 * 漫反射系数) * max(0, dot(法线(世界空间), 光源方向(世界空间)))
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));


					//世界光在该法线上的反射方向
					fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));

					//世界坐标视角方向
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);


					//高光反射公式：入射光* 高光反射系数 * pow(max(0, dot(视角方向,光线反射方向)),系数)
					fixed3 speculer = _LightColor0.rgb * _Speculer.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

					//最终颜色
					fixed3 color = ambient + diffuse + speculer;

					return fixed4(color, 1.0);
				}

				ENDCG
	}

	
	}
	FallBack "Diffuse"
}
