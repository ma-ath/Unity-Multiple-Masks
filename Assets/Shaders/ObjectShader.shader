Shader "SunAndMoon/ObjectShader"
{
    Properties
    {
        _MainTex("My Texture", 2D) = "white" { }
        ///_MaskLayer é sempre uma potencia de 2**x , x = layer. Pense em bits:
        /// 00000001 = layer 1, 00000010 = layer 2 ...
        /// Caso eu queira que o objeto apareça na intercessão de 2 mascaras, basta escolher o numero apropriado:
        /// ex: intercessao da mascara 1 e 2: 00000001 + 00000010 = 00000011 => _MaskLayer = 3
        _MaskLayer("Mask Layer", int) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Geometry" "RenderType" = "Opaque"}
        LOD 100

        /// Cada pixel tem 8 bits
        /// Cada mascara escreve em 1 dos 8 bits disponiveis. Dessa forma podemos ter até 8 mascaras diferentes, uma sobre a outra
        /// Nesse Stencil nos comparamos a referencia com o stencil buffer e deixamos apenas quando iguais. Assim, a figura aparece dentro da mascara.
        Stencil
        {
            Ref [_MaskLayer]
            Comp equal
            Pass keep
            ReadMask[_MaskLayer]
            WriteMask[_MaskLayer]
        }

        /// Não faço ideia do que isso faz mas funciona
        /// Copiado e colado de um 'Unlit Shader'
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}