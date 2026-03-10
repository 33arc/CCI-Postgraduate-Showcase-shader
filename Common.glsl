
float read(sampler2D tex, ivec2 res, ivec2 coord, ivec2 offset, vec4 mouse)
{
    ivec2 r = res;
    ivec2 c = coord + offset;
    
    // is there a better way to mirror the coordinates? :(
    if (c.x < 0)
        c.x = -c.x;
    else if (c.x > r.x)
        c.x = r.x - (c.x - r.x);
        
    if (c.y < 0)
        c.y = -c.y;
    else if (c.y > r.y)
        c.y = r.y - (c.y - r.y);
    
    // it doesn't get stuck anymore!
    float ui = clamp(1.0 - length(vec2(c) - mouse.xy) / 20.0, 0.0, 1.0);
    if ( mouse.z < 0.0 && mouse.w < 0.0 ) {
    ui=0.0;
    }
    float h = texelFetch(tex, c, 0).r;
    
    return h + ui;
}

float process(sampler2D bufferIn, sampler2D bufferOut, ivec2 res, vec4 mouse, ivec2 p)
{
    float l = read(bufferIn, res, p, ivec2(-1,  0), mouse);
    float r = read(bufferIn, res, p, ivec2( 1,  0), mouse);
    float u = read(bufferIn, res, p, ivec2( 0, -1), mouse);
    float d = read(bufferIn, res, p, ivec2( 0,  1), mouse);
    
    float c = read(bufferOut, res, p, ivec2(0), mouse);

    // random drop
    float dropRate = 0.002;
    float t = float(frame) * dropRate;
    vec2 dropPos = fract(floor(t) * vec2(0.456665, 0.708618)) * vec2(res);
    float amp = 1.0 - step(0.05, fract(t));
    float drop = 0.0;
    for (int i = 0; i < 5; i++) {
	    float t = float(frame) * dropRate + float(i) * 1.7391;
	    vec2 dropPos = fract(floor(t) * vec2(0.456665 + float(i)*0.113, 0.708618 + float(i)*0.097)) * vec2(res);
	    float amp = 1.0 - step(0.05, fract(t));
	    drop += amp * smoothstep(8.0, 0.0, length(vec2(p) - dropPos));
    }

    float damp = 0.985;
    
    return ((l + r + u + d) / 2.0 - c) * damp + drop;
}
