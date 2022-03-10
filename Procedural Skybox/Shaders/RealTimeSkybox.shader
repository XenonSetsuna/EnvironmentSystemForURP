Shader "Custom/RealTimeSkybox"
{
    //������ǰ��
    //֮ǰдʲô�����Ҷ���ϲ��дע�ͣ��ҵ�Ч�������϶��Ǿ����������ĸ���ʽ�Ӽ��������
    //��Щ������̲���ʲô����Ĺ�ʽ�������ڵ����޸Ĺ�����һ������Ʋ����Ľ��
    //����ע���һ������Ѿ�û�취�ü��仰˵������
    //������볢�Զ�д��ע�ͣ�ϣ���ܶ�������������
    
    Properties
    {
        _TimeMapping ("Time Mapping", Range(-1, 1)) = 0//��������ǽű����ι����ģ�����ȫ���ı仯���̣�
        //-1 �� 0 ��ʾ 00:00 �� 06:00��0 �� 1 ��ʾ 06:00 �� 12:00
        //1 �� 0 ��ʾ 12:00 �� 18��00��0 �� -1 ��ʾ 18:00 �� 24:00
        //0 ǰ���΢С�����ʾ��ҹ����Ĺ��Ȳ���
        //-1 �� 1������΢С����ֱ��ʾ ��ҹ �� ���� �Ĺ��Ȳ���

        [Header(Sky Settings)]
        _NoiseTexture ("Noise Texture", 2D) = "black"{}
        _DaySkyColor ("Day Sky Color", Color) = (0.25, 0.75, 0.9, 1)
        _NightSkyColor ("Night Sky Color", Color) = (0.06, 0.09, 0.12, 1)

        [Header(Horizon Settings)]
        _HorizonStrength ("Horizon Strength", Range(100, 200)) = 200
        _HorizonContract ("Horizon Contract", Range(10, 100)) = 50
        _HorizonBias ("Horizon Bias", Range(-1, 1)) = 0

        _DayHorizonColor ("Day Horizon Color", Color) = (0.5, 0.8, 1, 1)
        _SunsetHorizonColor ("Sunset Horizon Color", Color) = (1, 0.6, 0.3, 1)
        _NightHorizonColor ("Night Horizon Color", Color) = (0.04, 0.02, 0.1, 1)
        _GroundLineColor ("Ground Line Color", Color) = (1, 1, 1, 1)

        [Header(Sun and Moon Settings)]
        _SunColor ("Sun Color", Color) = (1, 0.6, 0, 1)
        _SunRadius ("Sun Radius", Range(1, 10)) = 3
        _SunIntensity ("Sun Intensity", Range(1, 10)) = 4

        _MoonColor ("Moon Color", Color) = (0.5, 0.5, 0.5, 1)
        _MoonRadius ("Moon Radius", Range(1, 10)) = 1.5
        _MoonIntensity ("Moon Intensity", Range(1, 10)) = 2
        _MoonMask ("Moon Mask", Range(-1, 1)) = 0.15

        [Header(Stars Settings)]
        _StarsBrightness ("Stars Brightness", Range(1, 1000)) = 100
        _StarsHeight ("Stars Height", Range(0, 1)) = 0.2
        _StarsScale ("Stars Scale", Range(1, 5)) = 2.5

        [Header(Testing Properties)]
        //���²������ڲ��Ե���ϸ��Ч��������������Ǹ�����뱣����Ĭ����ֵ��ʹ�þ�����ε��Ժ��Ч��
        //������²���Ӱ����������Shader���뽫����ȫ����Ϊ��Χ�����е�ֵ��half�������㷨�У��� Range(-0.5, 0.5) ����Ϊ = 0

        _ShiftHorizonColorRampBias ("Shift Horizon Color Ramp Bias", Range(-0.5, 0.5)) = -0.2
        _ShiftHorizonIntensityRamp ("Shift Horizon Intensity Ramp", Range(0, 1)) = 0.8
        _SunsetHorizonColorRamp ("Day Horizon Color Ramp", Range(0, 1)) = 1
        _ShiftSunAndMoonColorRamp ("Shift Sun And Moon Color Ramp", Range(0, 1)) = 0.75
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType" = "Opaque"
        }
        /**Pass
        {
            
            Cull Back
            ZWrite Off

            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            float _TimeMapping;

            half4 _DaySkyColor;
            half4 _NightSkyColor;

            int _HorizonStrength;
            int _HorizonContract;

            half4 _DayHorizonColor;
            half4 _SunsetHorizonColor;
            half4 _NightHorizonColor;
            
            half4 _SunColor;
            half _SunRadius;
            half _SunIntensity;

            half4 _MoonColor;
            half _MoonRadius;
            half _MoonIntensity;
            half _MoonMask;

            half _ShiftHorizonColorRampBias;
            half _ShiftHorizonIntensityRamp;
            half _SunsetHorizonColorRamp;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float3 uv :TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 uv : TEXCOORD2;
            };
            
            Varyings vert(Attributes v)
            {
                Varyings o;
                ZERO_INITIALIZE(Varyings, o);
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.uv = v.uv;
                return o;
            }            

            half4 frag(Varyings i): SV_Target
            {
                Light light = GetMainLight();

                half3 normal = normalize(i.normalWS);
                half3 lightDirection = normalize(light.direction);

                half NdotL = dot(normal, lightDirection);

                half horizonControlFactor = pow(1 - i.uv.y, _HorizonContract / min(abs(_TimeMapping * 10) + 0.5 - _ShiftHorizonColorRampBias, 1)) * saturate(i.uv.y) * _HorizonStrength;//���Ƶ�ƽ������Ĳ������㣬�����֪������ɶ������ֱ�����ĳһ��ɫ�������Ȼ��Ч��

                _SunsetHorizonColor += half4((_DayHorizonColor.rgb - _SunsetHorizonColor.rgb) * pow(_SunsetHorizonColorRamp, 5) * saturate(_TimeMapping), 0);//���ڿ��ƴ��ճ������쵽����ĵ�ƽ����ɫ�仯

                half3 dayHorizonColor = _SunsetHorizonColor.rgb * horizonControlFactor * (0.5 + _ShiftHorizonColorRampBias + max(min(_TimeMapping * 10, (0.5 - _ShiftHorizonColorRampBias)), -0.5 - _ShiftHorizonColorRampBias));
                half3 nightHorizonColor = _NightHorizonColor.rgb * horizonControlFactor * (0.5 - _ShiftHorizonColorRampBias - max(min(_TimeMapping * 10, 0.5 + _ShiftHorizonColorRampBias), -0.5 + _ShiftHorizonColorRampBias));
                half3 horizionColor =dayHorizonColor + nightHorizonColor;//��ҹ����ʱ��ҹ��ƽ�߻�ɫ����
                horizionColor *= min(pow(_TimeMapping * 20, 4), _ShiftHorizonIntensityRamp) + (1 - _ShiftHorizonIntensityRamp);//��ҹ����ʱ��ƽ����ɫ��������
                half3 dayColor = (_DaySkyColor.rgb) * smoothstep(0, 0.4, saturate(dot(normalize(light.direction), half3(0, 1, 0))));
                half3 nightColor = (_NightSkyColor.rgb) * smoothstep(0, 0.4, saturate(dot(normalize(light.direction), half3(0, 1, 0))));

                half3 sunColor = _SunColor.rgb * 100 * _SunIntensity * saturate((1 - distance(i.uv.xyz, lightDirection) / (0.01 * _SunRadius))) * min(pow(saturate(i.uv.y), 1.5), 1);

                half3 moonColor = _MoonColor.rgb * 100 * _MoonIntensity * saturate((1 - distance(i.uv.xyz, -lightDirection) / (0.01 * _MoonRadius))) * min(pow(saturate(i.uv.y), 1.5), 1);
                half3 moonMask = -_MoonColor.rgb * 100 * _MoonIntensity * saturate((1 - distance(i.uv.xyz - half3(0.1 * _MoonMask, 0, 0), lightDirection) / (0.01 * _MoonRadius))) * min(pow(saturate(i.uv.y), 1.5), 1);
                moonColor += moonMask;
                moonColor = saturate(moonColor);


                half3 color = dayColor * ceil(_TimeMapping) + nightColor * ceil(-_TimeMapping) + horizionColor;

                return half4(color, 1);
            }

            ENDHLSL
            
        }**/



        //���������պе�ʱ��HLSL�ǳ������������޷������������λ�CG�ˣ��󲿷�bug���Լ�����ˣ�������İ�Unity
        Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			#pragma shader_feature MIRROR
			#pragma shader_feature ADDCLOUD

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
                float3 uv : TEXCOORD1;
			};

			//debug
            float _TimeMapping;

            sampler2D _NoiseTexture;
            fixed4 _NoiseTexture_ST;
            fixed4 _DaySkyColor;
            fixed4 _NightSkyColor;

            int _HorizonStrength;
            int _HorizonContract;
            fixed _HorizonBias;

            fixed4 _DayHorizonColor;
            fixed4 _SunsetHorizonColor;
            fixed4 _NightHorizonColor;
            fixed4 _GroundLineColor;
            
            fixed4 _SunColor;
            fixed _SunRadius;
            fixed _SunIntensity;

            fixed4 _MoonColor;
            fixed _MoonRadius;
            fixed _MoonIntensity;
            fixed _MoonMask;

            fixed _StarsBrightness;
            fixed _StarsHeight;
            fixed _StarsScale;

            fixed _ShiftHorizonColorRampBias;
            fixed _ShiftHorizonIntensityRamp;
            fixed _SunsetHorizonColorRamp;
            fixed _ShiftSunAndMoonColorRamp;

			Varyings vert(Attributes v)
			{
				Varyings o;
				o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.positionWS = mul(unity_ObjectToWorld, v.positionOS);
                o.uv = v.uv;
				return o;
			}

			fixed4 frag(Varyings i): SV_Target
			{
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0);
                fixed4 noise = 0.5 * tex2D(_NoiseTexture, (i.uv.xz * 5 - fixed2(_TimeMapping * 0.25, 0)) / _StarsScale) + 0.5 * tex2D(_NoiseTexture, (i.uv.xz * 4 - fixed2(0, _TimeMapping * 0.25)) / _StarsScale);
                fixed yFactor = min(i.uv.y + _HorizonBias * 0.5, 1);
                fixed3 stars = pow(noise.rgb, 50) * _StarsBrightness * saturate(yFactor - _StarsHeight) * pow(abs(_TimeMapping), 0.75);
                fixed horizonControlFactor = pow(1 - yFactor, _HorizonContract / min(abs(_TimeMapping * 10) + 0.5 - _ShiftHorizonColorRampBias, 1)) * saturate(yFactor) * _HorizonStrength;//���Ƶ�ƽ������Ĳ������㣬�����֪������ɶ������ֱ�����ĳһ��ɫ�������Ȼ��Ч��

                _SunsetHorizonColor += fixed4((_DayHorizonColor.rgb - _SunsetHorizonColor.rgb) * pow(_SunsetHorizonColorRamp, 5) * saturate(_TimeMapping), 0);//���ڿ��ƴ��ճ������쵽����ĵ�ƽ����ɫ�仯

                fixed sunDistance = saturate(1.5 - distance(i.uv.xyz, lightDirection));
                fixed moonDistance;

                fixed3 dayHorizonColor = _SunColor.rgb * horizonControlFactor * (0.5 + _ShiftHorizonColorRampBias + max(min(_TimeMapping * 10, (0.5 - _ShiftHorizonColorRampBias)), -0.5 - _ShiftHorizonColorRampBias)) * sunDistance;
                dayHorizonColor += _SunsetHorizonColor.rgb * horizonControlFactor * (0.5 + _ShiftHorizonColorRampBias + max(min(_TimeMapping * 10, (0.5 - _ShiftHorizonColorRampBias)), -0.5 - _ShiftHorizonColorRampBias));
                fixed3 nightHorizonColor = _NightHorizonColor.rgb * horizonControlFactor * (0.5 - _ShiftHorizonColorRampBias - max(min(_TimeMapping * 10, 0.5 + _ShiftHorizonColorRampBias), -0.5 + _ShiftHorizonColorRampBias));
                fixed3 horizionColor =dayHorizonColor + nightHorizonColor;//��ҹ����ʱ��ҹ��ƽ�߻�ɫ����
                horizionColor *= min(pow(_TimeMapping * 20, 4), _ShiftHorizonIntensityRamp) + (1 - _ShiftHorizonIntensityRamp);//��ҹ����ʱ��ƽ����ɫ��������
                fixed3 dayColor = (_DaySkyColor.rgb) * smoothstep(0, 0.4, saturate(dot(normalize(lightDirection), fixed3(0, 1, 0)))) * ceil(yFactor);
                fixed3 nightColor = (_NightSkyColor.rgb) * smoothstep(0, 0.4, saturate(dot(normalize(lightDirection), fixed3(0, 1, 0)))) * ceil(yFactor);
                nightColor += stars;

                fixed3 groundColor = _GroundLineColor.rgb * abs(_TimeMapping) * (ceil(_TimeMapping) * (_DaySkyColor.r + _DaySkyColor.g + _DaySkyColor.b) / 3 + ceil(-_TimeMapping) * (_NightSkyColor.r + _NightSkyColor.g + _NightSkyColor.b) / 3) * ceil(-yFactor);

                fixed3 sunColor = _SunColor.rgb * 100 * _SunIntensity * max((1 - distance(i.uv.xyz, lightDirection) / (0.01 * _SunRadius)), 0) * pow(saturate(yFactor), _ShiftSunAndMoonColorRamp);
                fixed3 moonColor = _MoonColor.rgb * 10 * _MoonIntensity * saturate((1 - distance(i.uv.xyz, -lightDirection) / (0.025 * _MoonRadius)) * 50) * pow(saturate(yFactor), _ShiftSunAndMoonColorRamp);
                fixed3 moonMask = -_MoonColor.rgb * 10 * _MoonIntensity * saturate((1 - distance(i.uv.xyz + fixed3(0.1 * _MoonMask, 0.1 * _MoonMask, 0.1 * _MoonMask), -lightDirection) / (0.025 * _MoonRadius)) * 50) * pow(saturate(yFactor), _ShiftSunAndMoonColorRamp);
                moonColor += moonMask;
                moonColor = max(moonColor, 0);

                sunDistance = saturate(1 - distance(i.uv.xyz, lightDirection));
                moonDistance = saturate(1 - distance(i.uv.xyz, -lightDirection));

                sunColor += _SunColor.rgb * pow(sunDistance, 2 / saturate(_TimeMapping * 10)) * ceil(yFactor);
                moonColor += _MoonColor.rgb * pow(moonDistance, 5 / saturate(-_TimeMapping * 10)) * 0.1 * ceil(yFactor);

                fixed3 color = dayColor * ceil(_TimeMapping) + nightColor * ceil(-_TimeMapping) + horizionColor + sunColor + moonColor + groundColor;

                return fixed4(color, 1);
		    }

		    ENDCG
	    }
    }
}



