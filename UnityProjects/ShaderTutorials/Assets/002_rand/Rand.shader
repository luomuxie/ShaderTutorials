Shader "Unlit/Rand"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //add a float property
        _RandSeed("Rand Seed", Float) = 43758.5453
        
        [Enum(Type1,0,Type2,1,Type3,2)] _RandType("Rand Type", Float) = 0
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //get the float property
            float _RandSeed;
            //get the enum property
            float _RandType;
            

            //create a random func
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * _RandSeed);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //https://thebookofshaders.com/10/ 
                //get the random value
                float r = rand(i.uv);
                //use the random value to get the color with rgb
                fixed4 col1 = fixed4(r, r, r, 1);

                //second way to get the random value----------------------
                //uv = i.uv*10;
                float2 uv = i.uv*10;
                float2 p = floor(uv);
                float2 f = frac(uv);
                //get the random value
                float r1 = rand(p);
                fixed4 col2 = fixed4(r1, r1, r1, 1);
                //--------------------------------------------------------
                float r2 = rand(f);
                fixed4 col3 = fixed4(r2, r2, r2, 1);
                //--------------------------------------------------------
                
                //according to the enum property to choose the color
                
                if(_RandType == 0)
                    return col1;
                else if(_RandType == 1)
                    return col2;
                else if(_RandType == 2)
                    return col3;
                
                return col2;
            }
            ENDCG
        }
    }
}
