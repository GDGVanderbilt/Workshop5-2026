float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = (p.x + p.y + p.z - s) / 3.0;
    vec3 o = p - m;
    vec3 k = min(o, 0.0);
    o = o + (k.x + k.y + k.z) * 0.5 - k * 1.5;
    o = clamp(o, 0.0, s);
    return length(p - o) * sign(m);
}

float sminExp(float a, float b, float k) {
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec3 palette(float t) {
    return .5+.5*cos(6.28318*(t+vec3(.3,.416,.557)));
}

float map(vec3 p) {

    vec2 mouse = iMouse.xy / iResolution.xy;
    mouse -= 0.5;
    mouse *= 2.0;
    mouse. x *= iResolution.x / iResolution.y;
    p.y += sin(length(p) * 0.5 * mouse.y);
    p.xy *= rot2D(length(p) * 0.2 * mouse.x);
    vec3 octPos = vec3(0.0, 0.0, 0.0 + iTime);
    p = p + octPos;
    p.xy = fract(p.xy) - .5;
    p.z =  mod(p.z, .25) - .125;
    return sdOctahedron(p, 0.15);
}

vec3 normal(vec3 p) {
    float e = 0.001;
    float dx = map(p + vec3(e, 0.0, 0.0)) - map(p - vec3(e, 0.0, 0.0));
    float dy = map(p + vec3(0.0, e, 0.0)) - map(p - vec3(0.0, e, 0.0));
    float dz = map(p + vec3(0.0, 0.0, e)) - map(p - vec3(0.0, 0.0, e));
    
    return normalize(vec3(dx, dy, dz));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    uv -= 0.5;
    uv *= 2.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 ro = vec3(0.0, 1.0, -3.0);
    vec3 rd = normalize(vec3(uv * 0.8, 1));
    float dist = 0.0;
    
    for (int i = 0; i < 300; i++) {
        vec3 p = ro + rd * dist;
        
        float next = map(p);
    
        dist += next;
        if (next < 0.001) break;
        if (dist > 500.0) break;
    }
    vec3 light = normalize(vec3(-1.0, 1.0, -1.0));
    vec3 baseColor = palette(dist * 0.1);
    vec3 color = baseColor * dot(light, normal(ro + rd * dist)) + baseColor * 0.2;

    vec3 fogColor = vec3(0.05, 0.1, 0.2);
    float fog = clamp(dist / 15.0, 0.0, 1.0);
    color = mix(color, fogColor, fog);

    fragColor = vec4(color, 1.0);
}
