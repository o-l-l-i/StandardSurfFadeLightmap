Shader "Custom/StandardSurfFadeLightmap"
{
    Properties
    {
        [Header(Standard Material Parameters)]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Header(Lightmap Light)]
        _FadeLight ("Fade Lightmap Light", Range(0,1)) = 1.0
        _Gamma ("Lightmap Light Gamma", Range(1,2.2)) = 1.0
        _Contrast ("Lightmap Light Contrast", Range(0,4)) = 1.0

        [Header(Lightmap Indirect Diffuse)]
        _FadeDiffuse ("Fade Indirect Diffuse", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf StandardDefaultGI
        #include "UnityPBSLighting.cginc"

        #pragma target 3.0


        struct Input
        {
            float2 uv_MainTex;
        };


        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _FadeLight;
        float _FadeDiffuse;
        float _Gamma;
        float _Contrast;


        float3 Gamma(float3 col)
        {
            float g22 = 1.0; // Use 2.2 if not in linear color space.
            col.rgb = pow( abs(col.rgb), g22 );
            col.rgb = 255 * pow( abs(col.rgb / 255), (1.0 / _Gamma) );
            return col;
        }


        float3 Contrast(float3 col)
        {
            col.rgb = saturate(lerp(half3(0.5, 0.5, 0.5), col, _Contrast));
            return col;
        }


        inline half4 LightingStandardDefaultGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
            return LightingStandard(s, viewDir, gi);
        }


        inline void LightingStandardDefaultGI_GI( SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
            gi.light.color = lerp(1.0, gi.light.color, _FadeLight);
            gi.indirect.diffuse = lerp(1.0, gi.indirect.diffuse, _FadeDiffuse);
            gi.light.color = Gamma(gi.light.color);
            gi.light.color = Contrast(gi.light.color);
        }


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)


        // Standard surface shader program
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }

    FallBack "Diffuse"
}