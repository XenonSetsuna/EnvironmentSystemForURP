Shader "Custom/Cloud"
{
    Properties
    {
        _CloudMove ("Cloud Move", Float) = 0
        [NoScaleOffset]_NoiseTexture ("Noise Texture", 2D) = "black"{}
        _UVScale ("UV Scale", Range(0, 0.01)) = 0.004
        _SmoothstepDown ("Smoothstep Down", Range(0, 1)) = 0.15
        _SmoothstepUp ("Smoothstep Up", Range(0, 1)) = 0.4
        _DistanceFade ("Distance Fade", Range(1, 1000)) = 1000
        _DistanceBlend ("Distance Blend", Range(0, 500)) = 250
        _Height ("Height", float) = 50
        _ThickCloudColor ("Thick Cloud Color", Color) = (0.35, 0.35, 0.35, 1)
        _ThinCloudBrightness ("Thin Cloud Brightness", Range(1, 100)) = 20
        _Transparent ("Transparent", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalRenderPipeline"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Main"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On

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
            half _CloudMove;
            half _UVScale;
            half _SmoothstepDown;
            half _SmoothstepUp;
            half _DistanceFade;
            half _DistanceBlend;
            half _Height;
            half4 _ThickCloudColor;
            half _ThinCloudBrightness;
            half _Transparent;
            CBUFFER_END

            sampler2D _NoiseTexture;
            sampler2D _NoiseTexture_ST;

            struct Attributes
            {
                half4 positionOS : POSITION;
                half2 uv :TEXCOORD0;
            };
            
            struct Varyings
            {
                half4 positionCS : SV_POSITION;
                half3 positionWS : TEXCOORD0;
                half2 uv : TEXCOORD1;
                half distanceFade : TEXCOORD2;
            };
            
            Varyings vert(Attributes v)
            {
                Varyings o;
                ZERO_INITIALIZE(Varyings, o);
                o.distanceFade = saturate((distance(half3(_WorldSpaceCameraPos.x, TransformObjectToWorld(v.positionOS.xyz).y, _WorldSpaceCameraPos.z), TransformObjectToWorld(v.positionOS.xyz)) / _DistanceFade));
                v.positionOS -= half4(0, pow(o.distanceFade, 4) * _DistanceBlend, 0, 0);
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz); 
                o.uv = o.positionWS.xz * _UVScale;
                return o;
            }            

            half4 frag(Varyings i): SV_Target
            {
                Light light = GetMainLight();

                half3 lightDirection = normalize(light.direction);
                half4 noise = tex2Dlod(_NoiseTexture, half4(i.uv + half2(_CloudMove, 0), 0, 0));

                half4 noise1 = 0.8 * noise + 0.2 * tex2Dlod(_NoiseTexture, half4(i.uv + half2(0, _CloudMove), 0, 0));
                noise1 *= 1 - 0.12 * abs(_Height - 0.1 * pow(i.distanceFade, 4) * _DistanceBlend - i.positionWS.y);
                half4 noise2 = 0.6 * noise + 0.4 * tex2Dlod(_NoiseTexture, half4(i.uv + half2(0, _CloudMove), 0, 0));
                noise2 *= 1 - 0.12 * abs(_Height - 0.1 * pow(i.distanceFade, 4) * _DistanceBlend - i.positionWS.y);
                half lightIntensity = (light.color.r + light.color.g + light.color.b) / 3;
                half distanceFade = 1 - saturate((distance(_WorldSpaceCameraPos.xyz, i.positionWS) / _DistanceFade));

                half3 color = pow(1 - noise2.r, 12 + 2 * abs(_Height - i.positionWS.y)) * (_ThickCloudColor.rgb + pow(light.color.rgb, 4) / lightIntensity) * _ThinCloudBrightness * distanceFade + _ThickCloudColor.rgb * pow(noise2.r, 0.5 - 0.1 * abs(_Height - i.positionWS.y)) * 4 * (0.9 * lightIntensity + 0.1);
                color *= (0.9 * lightIntensity + 0.1);
                half transparent = smoothstep(_SmoothstepDown, _SmoothstepUp, noise1.r) * (0.5 + saturate(pow(lightIntensity, 0.1)));
                
                return half4(color, transparent * distanceFade * _Transparent);
            }

            ENDHLSL
            
        }
        
    }

}