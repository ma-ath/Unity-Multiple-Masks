Shader "SunAndMoon/MaskShader"
{
    Properties
    {
        _MainTex("My Texture", 2D) = "white" { }
        ///_MaskLayer é sempre uma potencia de 2**x , x = layer. Pense em bits:
        /// 00000001 = layer 1, 00000010 = layer 2 ...
        _MaskLayer("Mask Layer", int) = 1
    }

    SubShader{
        /// A mascara dever ser o primeiro a renderizar. Por isso o 'Geometry-1' 
        Tags { "Queue" = "Geometry-1" }
        LOD 100

        /// ColorMask = 0 faz com que a mascara seja invisível
        ColorMask 0
        ZWrite off

        /// Cada pixel tem 8 bits
        /// Cada mascara escreve em 1 dos 8 bits disponiveis. Dessa forma podemos ter até 8 mascaras diferentes, uma sobre a outra
        Stencil
        {
            Ref [_MaskLayer]
            Comp always
            Pass replace
            ReadMask [_MaskLayer]
            WriteMask [_MaskLayer]
        }

        /// Não faço ideia do que isso faz mas funciona
        CGPROGRAM
        #pragma surface surf Lambert
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };
        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = fixed4(1,1,1,1);
        }
        ENDCG
    }

    Fallback "Diffuse"
}