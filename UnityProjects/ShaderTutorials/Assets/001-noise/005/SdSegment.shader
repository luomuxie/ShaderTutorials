Shader "Custom/SdSegment" {
    Properties {
        _LineColor ("Line Color", Color) = (1,1,1,1)  // White
        _BackgroundColor ("Background Color", Color) = (0,0,0,1)  // Black
        _LineWidth ("Line Width", Range(0.01, 0.1)) = 0.01  // Line width
        //create lightDir
        _LightDir("Light Direction", Vector) = (0, 0, 1, 0)
        //create viewDir
        _ViewDir("View Direction", Vector) = (0, 0, 1, 0)
        //create specColor
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
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
            //create lightDir
            float3 _LightDir;
            //create viewDir
            float3 _ViewDir;
            //create specColor
            fixed4 _SpecColor;
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float sdSegment(float2 p, float2 a, float2 b) {
                float2 pa = p - a, ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
            }

            // 定义tanh近似函数
            float tanh_approx(float x) {
                float x2 = x * x;
                return clamp(x * (27.0 + x2) / (27.0 + 9.0 * x2), -1.0, 1.0);
            }

            // 定义平滑最小函数
            float pmin(float a, float b, float k) {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            // 高度字段函数
            float heightField(float2 p) {
                float d = sdSegment(p, float2(0.2, 0.2), float2(0.7, 0.7)); // 使用sdSegment作为df函数
                float h = (-20.0 * d);
                h = tanh_approx(h);
                h -= 1.5 * length(p);
                h = pmin(h, 0.0, 1);
                h *= 0.25;
                return h;
            }

            // 简化的法线计算
            float3 calculateNormal(float2 p) {
                float h = heightField(p);
                float hx = heightField(p + float2(0.001, 0.0)) - h;
                float hy = heightField(p + float2(0.0, 0.001)) - h;
                float3 n = normalize(float3(hx, hy, 0.001));
                return n;
            }
            
            fixed4 frag (v2f input) : SV_Target {
                float2 center = float2(0.2, 0.2);
                float2 b = float2(0.7, 0.7);
                float d = sdSegment(input.uv, center, b);

                //根据距离场生成高度信息
                // float h = hf(p);
                //
                // //calculate the normal
                // vec3 n = nf(p);
                //
                // //ligth point
                // const vec3 lp = vec3(-4.0, -5.0, 3.0);
                //
                // //ro代表的就是相机（或观察者）的位置，通常用于确定视图的原点，即你从哪里看向场景。在这个情境下
                // //相机位于Z轴上，离XY平面10个单位远，朝向原点。这对于计算从相机到场景中任意点的视线（光线）非常重要
                // const vec3 ro = vec3(0.0, 0.0, 10.0);
                //
                // //h是根据二维坐标p计算得出的，可以被看作是在心形的距离场上的高度或深度值，它为心形图形添加了立体效果。
                // //因此，vec3(p, h)是在将二维屏幕空间的点转换成三维空间中的点，这允许着色器处理像光照这样的三维效果，
                // //因为这需要知道每个点在三维空间中的位置。在这里，p3代表了屏幕上每个像素对应的三维世界中的点，这对于接下来计算光照和渲染效果至关重要。
                // vec3 p3 = vec3(p, h); 
                //
                // //view direction
                // vec3 rd = normalize(p3-ro);
                // //light direction
                // vec3 ld = normalize(lp-p3);
                //
                // //calculate reflection
                // vec3 r = reflect(rd, n);
                //
                // //calculate the diffuse color
                // float diff = max(dot(ld, n), 0.0);
                //
                // //包装heart函数，对位置进行缩放和偏移处理
                // float d = df(p);
                
                // vec3 dbcol = iHeartColor;    
                // vec3 dcol = dbcol*mix(vec3(0.15), vec3(1.0), diff);
                //
                // //calculate the specular color
                // float spe = pow(max(dot(ld, r), 0.0), 3.0);
                // vec3 scol = spe*sbcol;

                float3 lightDir = _LightDir;
                float3 viewDir = _ViewDir;

                // float h = heightField(input.uv);
                float3 normal = calculateNormal(input.uv);

                 float diff = max(dot(lightDir, normal), 0.0);  // 漫反射计算
                
                float spec =0.5* pow(max(dot(reflect(-lightDir, normal), viewDir), 0.0), 32);  // 高光计算

                _LineColor+=  diff;
                _LineColor += _SpecColor * spec;
                // 这里修正了颜色应用顺序
                fixed4 col = lerp(_LineColor,_BackgroundColor, smoothstep(_LineWidth, _LineWidth + 0.005, d));
                //col += fixed4(1,1,1,1) * spec * 0.5;  // 添加高光成分
                
                // fixed4 col = lerp(_LineColor, _BackgroundColor, smoothstep(_LineWidth, _LineWidth+0.005, d));
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
