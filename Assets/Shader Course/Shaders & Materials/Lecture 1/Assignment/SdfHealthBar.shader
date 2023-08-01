Shader "Unlit/SdfHealthBar"
{
    Properties
    {
        _MainTex ("Health Texture", 2D) = "white" {}
        _Amount ("Amount", Range(0, 1)) = 1
        _BorderSize ("Border Size", Range(0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Amount;
            float _BorderSize;

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
                // rounded corner clipping
                float2 coords = i.uv;
                coords.x *= 8;

                float2 pointOnLineSeg = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLineSeg) * 2 - 1;
                // 둥근 직사각형
                // float2 pointOnRectSeg = float2(clamp(coords.x, 0.4, 7.6), clamp(coords.y, 0.4, 0.6));
                // float sdf = distance(coords, pointOnRectSeg) * 2 - 0.8;

                clip(-sdf);

                float borderSdf = sdf + _BorderSize;
                
                float pd = fwidth(borderSdf); // screen space partial derivative
                
                float borderMask = 1-saturate(borderSdf / pd);
                
                // healthbar
                float healthbarMask = _Amount >= i.uv.x;
                float3 healthbarColor = tex2D(_MainTex, float2(_Amount, i.uv.y));

                if (_Amount < 0.2)
                {
                    float flash = cos(_Time.y * 4) * 0.4 + 1;
                    healthbarColor *= flash;
                }
                
                return float4(healthbarColor * healthbarMask * borderMask, 1);
            }
            ENDCG
        }
    }
}
