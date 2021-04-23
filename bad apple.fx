/*
    bad apple.fx for ReShade by kingeric1992 (Aprl.23.2021)
*/

#define SIZE_X  480
#define SIZE_Y  360
#define WIDTH   8192

#define HEIGHT  8247
#define MAXVEC  76497
#define FRAME   6561

namespace badApple {
    texture texI < source = "data.png"; > { Width=WIDTH; Height=HEIGHT; }; sampler sampI  { Texture = texI; };
    texture texO { Width=SIZE_X; Height=SIZE_Y; Format=R8; }; sampler sampO { Texture = texO; };

    /**********************************************************
    *  functions
    **********************************************************/

    uniform int  framecount < source = "framecount"; >;
    uniform bool bPlay = true;
    uniform int  iframe < ui_type = "slider"; ui_min=0; ui_max=FRAME_2 - 1;> = 0;

    uint  getFID() { return bPlay? (framecount/2) % FRAME_2 : iframe; }
    uint2 getPOS(uint idx, uint width) { return uint2(idx % width, idx / width); }

    float4 vs_main(uint vid, sampler sampIn, uint h, uint fid)
    {
        float2 size = rcp(float2(SIZE_X,SIZE_Y));
        uint2  vec  = mul(uint2x4(                                     // vecID of first vec in current & next frame
            tex2Dfetch(sampIn, uint2(fid-1, h-1)).argb * 255,
            tex2Dfetch(sampIn, uint2(fid, h-1)).argb * 255), uint4(1<<24, 1<<16, 1<<8, 1<<0));
        [branch] if(vid >= (vec.y - vec.x)) return float4(0,0,-2,1);   // culling out-of-bound vecs

        // get unrolled endpoint pos (0, 482*360]
        uint   sPos = dot(uint3(tex2Dfetch(sampIn, getPOS(vec.x + vid, WIDTH)).bgr*255), uint3(1<<16, 1<<8, 1<<0));
        return float4( getPOS(sPos, SIZE_X + 3) * size*float2(2,-2) - float2(size.x * 2 + 1, size.y - 1 ), 0, 1);
    }
    float4 ps_main(uint vid, sampler sampIn, uint h)
    {
        uint vec = dot( // absolute vecID of start of current frame.
            uint4(tex2Dfetch(sampIn, uint2(getFID()-1, h-1)).argb * 255),
            uint4(1<<24, 1<<16, 1<<8, 1<<0));
        return tex2Dfetch(sampIn, getPOS(vec + vid, WIDTH)).a;
    }

    /**********************************************************
    *  shaders
    **********************************************************/
    float4 vs_mainI( uint vid : SV_VERTEXID, out float vOut : TEXCOORD) : SV_POSITION {
        return vOut = vid, vs_main(vid, sampI, HEIGHT, getFID());
    }
    float4 ps_mainI( float4 vpos : SV_POSITION, float vid : TEXCOORD ) : SV_TARGET {
        return ps_main(vid, sampI, HEIGHT);
    }
    float4 vs_view( uint vid : SV_VERTEXID ) : SV_POSITION {
        return uint4(2,1,0,0) == vid? float4(3,-3,0,1):float4(-1,1,0,1);
    }
    float4 ps_view(float4 vpos : SV_POSITION ) : SV_TARGET {
        return tex2Dfetch(sampO, vpos.xy).r;
    }
    /**********************************************************
    *  technique
    **********************************************************/
    technique run
    {
        pass p0 {
            PrimitiveTopology = LINESTRIP;
            VertexCount       = MAXVEC;
            VertexShader      = vs_mainI;
            PixelShader       = ps_mainI;
            RenderTarget      = texO;
        }
        pass view {
            VertexShader      = vs_view;
            PixelShader       = ps_view;
        }
    }
}