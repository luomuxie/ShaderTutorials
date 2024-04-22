Shader "Custom/RandomWalker"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // 初始纹理
        _InputTex ("Input Texture", 2D) = "white" {} // 处理输入纹理
        //create a speed property
        _Speed ("Speed", Range(0, 0.1)) = 0.001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            sampler2D _InputTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float sdSegment(float2 p, float2 a, float2 b) {
                float2 pa = p - a, ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
            }
            
            /*
            float noise(float2 st) {
                return frac(sin(dot(st, float2(12.9898,78.233))) * 43758.5453123);
            }
            */

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
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Sample the appropriate texture
                fixed4 col = tex2D(_InputTex, i.uv);

                // Draw a line segment using noise
                float2 a = float2(noise(_Time.y), noise(_Time.x));
                //get the direction of the random walker
                //float2 dir = getDirection(_Time.xy +45 );
                //move the point a to the direction
                //a += dir * 0.01;
                float2 b = float2(noise(_Time.x), noise(_Time.y));
                //b += getDirection(_Time.yx*0.01*sin(_Time.x)+50 ) ;
                float d = sdSegment(i.uv, a, b);
                
                 fixed4 colCur = tex2D(_MainTex, a);
                // Add a time-dependent color effect
                fixed4 timeColor = fixed4(sin(_Time.y), cos(_Time.y), sin(_Time.y) * cos(_Time.y), 1);
                col = lerp(colCur, col, smoothstep(0.01, 0.02, d));

                return col;
            }
            ENDCG
        }
    }
}
