Shader "Custom/CircleWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //create a property for the radius
        _Radius ("Radius", Range(0.0,1.0)) = 0.5
        //create a property for the width
        _Width ("Width", Range(0.0,0.1)) = 0.01
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
            float4 _MainTex_ST;
            float _Radius;
            float _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2 random2(float2 st){
                st = float2( dot(st,float2(127.1,311.7)),
                          dot(st,float2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            //create a noise2d function
            float noise2d(float2 st) {
                float2 i = floor(st);
                float2 f = frac(st);

                // Four corners in 2D of a tile
                float a = random2(i);
                float b = random2(i + float2(1.0, 0.0));
                float c = random2(i + float2(0.0, 1.0));
                float d = random2(i + float2(1.0, 1.0));

                float2 u = f*f*(3.0-2.0*f);

                return lerp(a, b, u.x) +
                        (c-a)* u.y * (1.0 - u.x) +
                        (d-b) * u.x * u.y;
            }

            float shape(float2 st, float radius) {
                st = float2(0.5,0.5)-st;
                float r = length(st)*2.0;
                float a = atan2(st.y,st.x);//回的是点(st.x, st.y)和原点(0, 0)之间的角度，单位是弧度。
                float m = abs(fmod(a+_Time.y*2.,3.14*2)-3.14)/3.6;
                float f = radius;
                //f += noise2d(st+_Time.y*.2).r*.1;
                f += sin(a*50.)*noise2d(st+_Time.y*.2).r*.1;
                f += sin(a*20.)*.1*pow(m,2.);
                return 1.-smoothstep(f,f+0.007,r);
            }

            float shapeBorder(float2 st, float radius, float width) {
                return shape(st,radius)-shape(st,radius-width);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 col = fixed3(1,1,1) * shapeBorder(i.uv,_Radius,_Width);
                return fixed4(1-col,1);
            }
            
            ENDCG
        }
    }
}
