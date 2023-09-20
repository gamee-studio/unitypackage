Shader "Custom/Proximity" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {} // Regular object texture 
        _PlayerPosition ("Player Position", Vector) = (0, 0, 0, 0) // The location of the player - will be set by script
        _VisibleDistance ("Visibility Distance", Range(1, 100)) = 10.0 // How close does the player have to be to make the object visible
        _OutlineWidth ("Outline Width", Range(0, 10)) = 3.0 // Used to add an outline around the visible area a la Mario Galaxy
        _OutlineColour ("Outline Colour", Color) = (1.0, 1.0, 0.0, 1.0) // Colour of the outline
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            // Access the shader properties
            sampler2D _MainTex;
            float4 _PlayerPosition;
            float _VisibleDistance;
            float _OutlineWidth;
            fixed4 _OutlineColour;
         
            struct appdata_t {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 position_in_world_space : TEXCOORD0;
                float4 tex : TEXCOORD1;
            };
            
            v2f vert (appdata_t v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.position_in_world_space = mul(unity_ObjectToWorld, v.vertex);
                o.tex = v.texcoord;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                // Calculate distance to player position
                float dist = distance(i.position_in_world_space, _PlayerPosition);
  
                // Return appropriate color
                if (dist < _VisibleDistance) {
                    return tex2D(_MainTex, i.tex); // Visible
                }
                else if (dist < _VisibleDistance + _OutlineWidth) {
                    return _OutlineColour; // Edge of visible range
                }
                else {
                    fixed4 tex = tex2D(_MainTex, i.tex); // Outside visible range
                    tex.a = 0;
                    return tex;
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}