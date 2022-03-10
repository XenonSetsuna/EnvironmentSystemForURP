Shader "Custom/CloudDepth"
{
    Properties
    {
        _CloudMove ("Cloud Move", Float) = 0
        [NoScaleOffset]_NoiseTexture ("Noise Texture", 2D) = "black"{}
        _UVScale ("UV Scale", Range(0, 0.01)) = 0.005
        _SmoothstepDown ("Smoothstep Down", Range(0, 1)) = 0.2
        _SmoothstepUp ("Smoothstep Up", Range(0, 1)) = 0.5
        _DistanceFade ("Distance Fade", Range(1, 1000)) = 500
        _DistanceBlend ("Distance Blend", Range(0, 1000)) = 0
        _Height ("Height", float) = 50
        _ThickCloudColor ("Thick Cloud Color", Color) = (0.35, 0.35, 0.35, 1)
        _ThinCloudBrightness ("Thin Cloud Brightness", Range(1, 100)) = 30
        _Transparent ("Transparent", Range(0, 1)) = 1
        _DepthClip ("Depth Clip", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalRenderPipeline"
            "IgnoreProjector"="True"
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

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
            half _DepthClip;
            CBUFFER_END

            sampler2D _NoiseTexture;
            sampler2D _NoiseTexture_ST;

            struct Attributes
            {
                float4 positionOS     : POSITION;
                float4 tangentOS      : TANGENT;
                float2 texcoord     : TEXCOORD0;
                float3 normal       : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float2 uv           : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv         = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz); 

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                return output;
            }

            float4 DepthNormalsFragment(Varyings input) : SV_TARGET
            {
                Light light = GetMainLight();
                half4 noise = tex2Dlod(_NoiseTexture, half4(input.positionWS.xz * _UVScale + half2(_CloudMove, 0), 0, 0));
                half4 noise1 = 0.8 * noise + 0.2 * tex2Dlod(_NoiseTexture, half4(input.positionWS.xz * _UVScale + half2(0, _CloudMove), 0, 0));
                noise1 *= 1 - 0.2 * abs(_Height - input.positionWS.y);
                half lightIntensity = (light.color.r + light.color.g + light.color.b) / 3;
                half transparent = smoothstep(_SmoothstepDown, _SmoothstepUp, noise1.r) * (0.5 + saturate(pow(lightIntensity, 0.1))) * _Transparent;
                clip(transparent - _DepthClip);

                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                return float4(PackNormalOctRectEncode(TransformWorldToViewDir(input.normalWS, true)), 0.0, 0.0);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"//Adjusted from CSDN: https://blog.csdn.net/linjf520/article/details/120757669?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-1-120757669.pc_agg_new_rank&utm_term=urp+receive+shadows&spm=1000.2123.3001.4430

            Cull [_CullMode]

            Tags 
            { 
                "LightMode" = "ShadowCaster"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            
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
            half _DepthClip;
            CBUFFER_END

            sampler2D _NoiseTexture;
            sampler2D _NoiseTexture_ST;

            struct Attributes
            {
                half4 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                half4 positionCS : SV_POSITION;
                half3 positionWS : TEXCOORD0;

            };
            


            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                half3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                half3 normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionCS = TransformWorldToHClip(positionWS);
                #if UNITY_REVERSED_Z
    			    o.positionCS.z = min(o.positionCS.z, o.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
    			    o.positionCS.z = max(o.positionCS.z, o.positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz); 

                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {
                Light light = GetMainLight();
                half4 noise = tex2Dlod(_NoiseTexture, half4(i.positionWS.xz * _UVScale + half2(_CloudMove, 0), 0, 0));
                half4 noise1 = 0.8 * noise + 0.2 * tex2Dlod(_NoiseTexture, half4(i.positionWS.xz * _UVScale + half2(0, _CloudMove), 0, 0));
                noise1 *= 1 - 0.2 * abs(_Height - i.positionWS.y);
                half lightIntensity = (light.color.r + light.color.g + light.color.b) / 3;
                half transparent = smoothstep(_SmoothstepDown, _SmoothstepUp, noise1.r) * (0.5 + saturate(pow(lightIntensity, 0.1))) * _Transparent;
                clip(transparent - _DepthClip);

                return half4(0, 0, 0, 1);
            }
            
            ENDHLSL
        }
    }
    FallBack "Packages/com.unity.render-pipelines.universal/FallbackError"
}
