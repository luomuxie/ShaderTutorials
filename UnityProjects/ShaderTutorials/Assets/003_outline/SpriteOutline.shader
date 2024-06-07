Shader "Custom/Outline"{
  Properties{
    _Color ("Tint", Color) = (0, 0, 0, 1)
    _OutlineColor ("OutlineColor", Color) = (1, 1, 1, 1)
    _OutlineWidth ("OutlineWidth", Range(0, 9)) = 0.06
    _MainTex ("Texture", 2D) = "white" {}
  }

  SubShader{
    Tags{
      "RenderType"="Transparent"
      "Queue"="Transparent"
    }

    Blend SrcAlpha OneMinusSrcAlpha

    ZWrite off
    Cull off

    Pass{
      CGPROGRAM

      #include "UnityCG.cginc"

      #pragma vertex vert
      #pragma fragment frag

      sampler2D _MainTex;
      float4 _MainTex_ST;
      float4 _MainTex_TexelSize;

      fixed4 _Color;
      fixed4 _OutlineColor;
      float _OutlineWidth;
      float _NumberSamples;

      struct appdata{
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        fixed4 color : COLOR;
      };

      struct v2f{
        float4 position : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldPos : TEXCOORD1;
        fixed4 color : COLOR;
      };

      v2f vert(appdata v){
        v2f o;
        o.position = UnityObjectToClipPos(v.vertex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.color = v.color;
        return o;
      }

      float2 uvPerWorldUnit(float2 uv, float2 space){
        float2 uvPerPixelX = abs(ddx(uv));
        float2 uvPerPixelY = abs(ddy(uv));
        float unitsPerPixelX = length(ddx(space));
        float unitsPerPixelY = length(ddy(space));
        float2 uvPerUnitX = uvPerPixelX / unitsPerPixelX;
        float2 uvPerUnitY = uvPerPixelY / unitsPerPixelY;
        return (uvPerUnitX + uvPerUnitY);
      }

      fixed4 frag(v2f i) : SV_TARGET{
      //get regular color
        fixed4 col =  tex2D(_MainTex, i.uv);
        col *= _Color;
        col *= i.color;
        //是的，sampleDistance 这里得到的是每个世界单位对应的纹理坐标的变化量，
        //然后乘以 _OutlineWidth，得到的是在纹理坐标中，轮廓宽度对应的距离。这个距离用于在纹理上进行采样，生成轮廓效果。
        // float2 sampleDistance = uvPerWorldUnit(i.uv, i.worldPos.xy) * _OutlineWidth;

        //如果你知道纹理的宽度和高度，你可以直接使用这些信息来计算每个像素在纹理坐标中的距离。
        //在这种情况下，每个像素在纹理坐标中的距离就是 (1/宽度, 1/高度)。
        //在你的代码中，你可以使用 _MainTex_TexelSize 来获取这个信息。
        //_MainTex_TexelSize 是一个内置的变量，它的值是 (1/纹理宽度, 1/纹理高度, 纹理宽度, 纹理高度)。
        float2 sampleDistance = _MainTex_TexelSize.xy * _OutlineWidth;
        
        //generate border
        float maxAlpha = 0;
        fixed perAngle = 15;
        fixed angle = 0;
        for(uint index = 0; index<23; index++){
          float2 dir = float2(cos(angle),sin(angle));
          float2 sampleUV = i.uv + dir * sampleDistance;
          maxAlpha = max(maxAlpha, tex2D(_MainTex, sampleUV).a);
          angle+=perAngle;
        }

        fixed4 colTemp =  tex2D(_MainTex, i.uv);
        //apply border
        col.rgb = lerp(_OutlineColor.rgb, colTemp.rgb, col.a);
        col.a = max(col.a, maxAlpha);

        return col;
      }
      ENDCG
    }
  }
}