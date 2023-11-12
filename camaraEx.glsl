float DistLine(vec3 ro, vec3 rd, vec3 p)
{
    return length(cross(p - ro, rd) / length(rd));
}

float DrawPoint( vec3 ro, vec3 rd, vec3 p)
{
    float d = DistLine( ro, rd, p);
    d = smoothstep(0.06, 0.05, d);
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = vec3(uv.x, uv.y, -2.0) - ro;
 
    float t = iGlobalTime;
    
    float d = 0.0;
    d += DrawPoint(ro, rd, vec3(0.0, 0.0, 0.0));
    d += DrawPoint(ro, rd, vec3(0.0, 0.0, 1.0));
    d += DrawPoint(ro, rd, vec3(0.0, 1.0, 0.0));
    d += DrawPoint(ro, rd, vec3(0.0, 1.0, 1.0));
    d += DrawPoint(ro, rd, vec3(1.0, 0.0, 0.0));
    d += DrawPoint(ro, rd, vec3(1.0, 0.0, 1.0));
    d += DrawPoint(ro, rd, vec3(1.0, 1.0, 0.0));
    d += DrawPoint(ro, rd, vec3(1.0, 1.0, 1.0));
    fragColor = vec4(d);
}