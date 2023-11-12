// SURFACE_DIST : 표면과의 최조 거리 (이보다 작다면 hit로 판단)
// MAX_DIST : 무한으로 빠지지 않기위해 최대거리 설정

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

float sdCapsule (vec3 p, vec3 a, vec3 b, float r)
{
    vec3 ab = b - a;
    vec3 ap = p - a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0.0, 1.0f);

    vec3 c = a + t*ab;

    return length(p-c) - r;
}

float sdTorus (vec3 p, vec2 r)
{
    float x = length(p.xz) - r.x;
    float y = p.y;
    return length(vec2(x, y)) - r.y;
}

float dBox (vec3 p, vec3 s)
{
    return length(max(abs(p) - s, 0.0));
}

float GetDist (vec3 p)
{
    vec4 s = vec4(0, 1, 6, 1); // x, y, z, radius
    
    float sphereDist = length(p-s.xyz)-s.w;
    float planeDist = p.y;
    float capsuleDist = sdCapsule(p, vec3(-2, 0.5, 6), vec3(-0.5, 2, 5), 0.2f);
    float torusDist = sdTorus(p - vec3(0, 0.5, 6), vec2(1.5, 0.15));
    float boxDist = dBox(p - vec3(0, 0.5, 6), vec3(0.5));

    float d = min(capsuleDist, planeDist);
    d = min(d, torusDist);
    d = min(d, boxDist);
    return d;
}

float RayMarch( vec3 ro, vec3 rd )
{
    float dO = 0.;
    
    for (int i=0; i<MAX_STEPS; ++i)
    {
        vec3 p = ro + dO * rd;
        float dS = GetDist(p);
        dO += dS;
        if (dS < SURF_DIST || dO > MAX_DIST)
            break;
    }
    return dO;
}

vec3 GetNormal( vec3 p )
{
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}

float GetLight( vec3 p )
{
    vec3 lightPos = vec3(0, 5, 6);
    lightPos.xz += vec2(sin(iTime * 2.f), cos(iTime * 2.f)) * 2.0f;
    vec3 l = normalize(lightPos - p);
    vec3 n = GetNormal(p);

    float diffuse = clamp(dot(l, n), 0.0, 1.0);

    float d = RayMarch(p + n * SURF_DIST * 1.1f, l);
    if (d < length(lightPos - p))
        diffuse *= 0.1f;

    return  diffuse;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 정규화
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

   vec3 col = vec3(0);
   
   vec3 ro = vec3(2, 2, 0);
   vec3 rd = normalize(vec3(uv.x-0.3, uv.y - 0.2, 1));

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;

    float diffuse = GetLight(p);

    col = vec3(diffuse);

    fragColor = vec4(col, 1.0);
}