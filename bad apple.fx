/*
    bad apple.fx by kingeric1992 (Aprl.21.2021)
*/

#define TILE_X 13
#define TILE_Y 17
#define SIZE_X 480
#define SIZE_Y 360
#define TILES (TILE_X * TILE_Y * 4) 

namespace badApple {

    texture t0 < source = "g0.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s0 { Texture = t0; };
    texture t1 < source = "g1.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s1 { Texture = t1; };
    texture t2 < source = "g2.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s2 { Texture = t2; };
    texture t3 < source = "g3.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s3 { Texture = t3; };
    texture t4 < source = "g4.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s4 { Texture = t4; };
    texture t5 < source = "g5.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s5 { Texture = t5; };
    texture t6 < source = "g6.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s6 { Texture = t6; };
    texture t7 < source = "g7.png"; > { Width  = TILE_X * SIZE_X; Height = TILE_Y * SIZE_Y; }; sampler s7 { Texture = t7; };

    /**********************************************************
    *  shaders
    **********************************************************/

    uniform int framecount < source = "framecount"; >;
    uniform bool bPlay = true;
    uniform int iframe < ui_type = "slider"; ui_min=0; ui_max=TILES - 1;> = 0;
    
    uint getFID()
    {
        return bPlay? (framecount/2) % (TILES * 8) : iframe % TILES;
    }
    float4 vs_main( uint vid : SV_VERTEXID, out float4 uv : TEXCOORD ) : SV_POSITION 
    {
        uint fid = getFID();
        uint  sid = fid / 4;
        float2 off = float2( sid % TILE_X, (sid / TILE_X) % TILE_Y);

        uv.xy = uv.zw = (vid.xx == uint2(2,1))? (2.).xx: (0.).xx;
        uv.zw = uv.zw / float2(TILE_X, TILE_Y) + off / float2(TILE_X, TILE_Y);
        return float4(uv.x * 2. - 1., 1. - uv.y * 2., 0, 1);
    }
    float4 ps_main(float4 vpos : SV_POSITION, float4 uv : TEXCOORD) : SV_TARGET 
    {   
        uint fid = getFID();
        uint cid = 3 - (fid + 1) % 4;
        float t[8] = {
            tex2D(s0, uv.zw)[cid], tex2D(s1, uv.zw)[cid], tex2D(s2, uv.zw)[cid], tex2D(s3, uv.zw)[cid],
            tex2D(s4, uv.zw)[cid], tex2D(s5, uv.zw)[cid], tex2D(s6, uv.zw)[cid], tex2D(s7, uv.zw)[cid]
        };
        return t[fid / TILES]; 
    }

    /**********************************************************
    *  technique
    **********************************************************/
    technique run
    {
        pass p0 {
            VertexShader = vs_main;
            PixelShader = ps_main;
        }
    }
}