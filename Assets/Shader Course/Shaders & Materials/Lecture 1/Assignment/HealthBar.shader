Shader "Unlit/HealthBar"
{
    Properties
    {
        _Amount ("Amount", Range(0, 1)) = 1
        _StartColor ("Start Color", Color) = (1,0,0,1)
        _EndColor ("End Color", Color) = (0,1,0,1)
        _EmptyColor("Empty Color", Color) = (0,0,0,1)
        _MinThreshold("Min Color Threshold", Range(0,1)) = 0.2
        _MaxThreshold("Max Color Threshold", Range(0,1)) = 0.8
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            /* Transparent(way 1)
            "RenderType"="Transparent"
            "Queue"="Transparent"
            */
        }
        Pass
        {
            // Blend SrcAlpha OneMinusSrcAlpha // Transparent(way 1)

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Amount;
            float4 _StartColor;
            float4 _EndColor;
            float4 _EmptyColor;
            float _MinThreshold;
            float _MaxThreshold;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // inside of health bar
                float4 col = _EmptyColor; // default = BLACK
                float w = saturate((_Amount - _MinThreshold) / (_MaxThreshold - _MinThreshold));
                // clip(_Amount - i.uv.x); // Transparent (way 2)
                if (i.uv.x <= _Amount)
                {
                    col = lerp(_StartColor, _EndColor, w);
                }
                return col;
            }
            ENDCG
        }
    }
}
