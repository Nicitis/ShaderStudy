Shader "Unlit/BorderedHealthBar"
{
    Properties
    {
        _Amount ("Amount", Range(0, 1)) = 1
        _MainTex ("Health Texture", 2D) = "white" {}
        _BorderTex ("Border", 2D) = "white" {}
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

            float _Amount;
            float _FlashThreshold;
            sampler2D _MainTex;
            sampler2D _BorderTex;
            float4 _EmptyColor;
            float4 _FlashColor;

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
                float4 finalColor; // default = BLACK
                float4 border = tex2D(_BorderTex, i.uv);
                clip(border.w - 0.01);
                // 맥박하는 체력바(강의 해설)
                float healthbarMask = _Amount >= i.uv.x;

                float3 healthbarColor = tex2D(_MainTex, float2(_Amount, i.uv.y));

                if (_Amount < 0.2)
                {
                    float flash = cos(_Time.y * 4) * 0.4 + 1;
                    healthbarColor *= flash;
                }
                finalColor = float4(healthbarColor * border.x * healthbarMask, 1); // mask와 색상을 곱한다.
                
                return finalColor;
            }
            ENDCG
        }
    }
}
