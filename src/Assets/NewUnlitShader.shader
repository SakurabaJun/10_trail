Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mix("Mix",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        cull Off

        GrabPass{"_backgroundTexture"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float4 grabPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _backgroundTexture;
            float4 _MainTex_ST;
            float _Mix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 decal = tex2D(_MainTex,i.uv);
                // sample the texture
                fixed4 col = tex2Dproj(_backgroundTexture, i.grabPos
                    + 100.0
                    * (decal.a + 0.5)
                    * float4(ddx(i.uv.x), ddy(i.uv.x),0, 0)
                );
                col.a = decal.a;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col + (decal * _Mix);
            }
            ENDCG
        }
    }
}
