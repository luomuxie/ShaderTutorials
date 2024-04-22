Shader "Custom/NoiseBlurEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //create a slider to control the division of the texture
        _Division("Division", Range(1, 10)) = 1
        //create a slider to control the blur cnt
        _BlurCnt("BlurCnt", Range(2, 200)) = 32
        // create a lightDic with v2
        _Light("Light", Vector) = (0.707, 0.707, 0, 0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Division;
            float _BlurCnt;
            float4 _Light;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }

            float noise(float2 x)
            {
                float2 p = floor(x);
                float2 f = frac(x);
                f = f * f * (3.0 - 2.0 * f);
                float n = p.x + p.y * 57.0;
                return lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
                            lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
            }
            
            float2 map(float2 uv, float time)
            {
                uv.x += 0.1 * sin(time + 2.0 * uv.y);
                uv.y += 0.1 * sin(time + 2.0 * uv.x);

                float angel = noise(uv * 1.5 + sin(0.01 * time)) * 6.2831;
                angel -= time;
                return float2(cos(angel), sin(angel));
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv*_Division;
                float acc = 0.0;
                float3 col = float3(0,0, 0);
                for (int j = 0; j < _BlurCnt; j++)
                {
                    
                    float hight = float(j) / _BlurCnt;
                    float wight = 4.0 * hight * (1.0 - hight);
                    float3 colorTexture = wight * tex2D(_MainTex, uv).xyz;
                    //colorTexture *= lerp(float3(0.6, 0.7, 0.7), float3(1.0, 0.95, 0.9), 0.5 - 0.5 * dot(reflect(float3(dir, 0.0), float3(1.0, 0.0, 0.0)).xy, float2(0.707, 0.707)));
                    col += wight * colorTexture;
                    acc += wight;
                    
                    float2 dir = map(uv, _Time.y);
                    uv += 0.008 * dir;
                }
                
                col /= acc;
                float2 normal = map(uv, _Time.y);
                col *= 0.65 + 0.35 * dot(normal, float2(_Light.x, _Light.y));
                //col *= 0.20 + 0.80 * pow(4.0 * p.x * (1.0 - p.x), 0.1);
                col *= 1.7;
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
