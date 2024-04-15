Shader "Custom/Noise" {
    Properties {
        _LineColor ("Line Color", Color) = (1,1,1,1)  // White
        _BackgroundColor ("Background Color", Color) = (0,0,0,1)  // Black
        _LineWidth ("Line Width", float) = 0.01  // Line width
        _GridCount ("Grid Count", float) = 10  // Grid size 10x10
        //create a slider for line count
        _LineCount ("Line Count", Range(1, 100)) = 10
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _LineColor;
            fixed4 _BackgroundColor;
            float _LineWidth;
            float _GridCount;
            float _LineCount;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Distance field function for a line segment
            float sdSegment(float2 p, float2 a, float2 b) {
                float2 pa = p - a, ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
            }

            float noise(float2 st) {
                return frac(sin(dot(st, float2(12.9898,78.233))) * 43758.5453123);
            }

            fixed4 frag (v2f input) : SV_Target {
                float gridSize = 1.0 / _GridCount;
                float2 st = input.uv;

                // Find the center of each grid cell
                float2 gridCenter = floor(st * _GridCount) / _GridCount + gridSize * 0.5;

                float mask = 0.0;
                for (int i = 0; i < _LineCount; i++) {
                    // Calculate noise for the angle of the line
                    float angle = noise(gridCenter + i*0.1) * 2.0 * 3.14159;  // Convert noise value to angle
                    float length = lerp(0.1, 0.9, noise(gridCenter*(i+40+_Time.y))); 
                    float2 dir = float2(cos(angle), sin(angle));

                    
                    // Calculate the distance to the line segment starting from grid center
                    float d = sdSegment(st, dir, gridCenter + dir * gridSize * length);

                    // Create a mask based on the distance
                    mask += 1.0 - step(_LineWidth, d);
                }

                // Normalize the mask to the range [0, 1]
                mask = clamp(mask / 5, 0.0, 1.0);

                // Mix the line and the background
                fixed4 color = lerp(_BackgroundColor, _LineColor, mask);
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
