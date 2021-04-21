/*
    bad apple.fx by kingeric1992 (Aprl.21.2021)
*/

#define SIZE_X 480
#define SIZE_Y 360
#define MAX_SEG 76137

namespace badApple {

    // first line is seg count per frame;
    texture t0 < source = "atlas.png"; > { Width=8192; Height=7958; }; 
    texture t1 < source = "linePos.png" > { Width=8192; Height=289; };
    sampler s0 { Texture = t0; };
    sampler s1 { Texture = t0; };

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
    float4 vs_main( uint vid : SV_VERTEXID, out float val : TEXCOORD ) : SV_POSITION 
    {
        uint fid = getFID();
        uint sid = vid/2;


        uint  sid = fid / 4;
        float2 off = float2( sid % TILE_X, (sid / TILE_X) % TILE_Y);

        uv.xy = uv.zw = (vid.xx == uint2(2,1))? (2.).xx: (0.).xx;
        uv.zw = uv.zw / float2(TILE_X, TILE_Y) + off / float2(TILE_X, TILE_Y);
        return float4(uv.x * 2. - 1., 1. - uv.y * 2., 0, 1);
    }
    float4 ps_main(float4 vpos : SV_POSITION, float val : TEXCOORD) : SV_TARGET 
    { 
        return val;
    }

    /**********************************************************
    *  technique
    **********************************************************/
    technique run
    {
        pass p0 {
            PrimitiveTopology = LINELIST;
            VertexCount = 76137 * 2;

            VertexShader = vs_main;
            PixelShader = ps_main;
        }
    }
}