Shader "Unlit/LightingTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass // 기본적으로 첫 번째 pass에서는 directional light만 다룰 수 있다.
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            // 위 두 개 cginc는 light 위치를 계산해준다. 빛을 다루려면 둘 중 하나는 사용해야 하니 기억하자.

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // diffuse lighting
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz; // actually a direction
                float3 diffuseLight = saturate(dot(N, L)) * _LightColor0.xyz; // be equal to 'max(0, dot(N, L))'

                // specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 R = reflect(-L, N);
                float specularLight = saturate(dot(V, R));

                specularLight = pow(specularLight, _Gloss); // specular exponent

                return float4(specularLight.xxx, 1);
                
                return float4(diffuseLight, 1);
                // float4 col = tex2D(_MainTex, i.uv);
                // return col;
            }
            ENDCG
        }
    }
}
