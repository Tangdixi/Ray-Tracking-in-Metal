#include <metal_stdlib>
using namespace metal;

constant half3 horizontal = half3(4,0,0);
constant half3 vertical = half3(0,2,0);
constant half3 leftBottomCorner = half3(-2,-1,-1);
constant half3 rayOrigin = half3(0,0,0);

class Ray {
public:
    Ray() {}
    Ray(const half3 origin, const half3 direction) {
        _origin = origin;
        _direction = direction;
    }
    
    half3 origin() const { return _origin; }
    half3 direction() const { return _direction; }
    
    half3 _origin;
    half3 _direction;
};

bool hitSphere(const half3 origin, half radius, const Ray ray) {
    half3 oc = ray.direction() - origin;
    half a = dot(ray.direction(), ray.direction());
    half b = 2.0 * dot(oc, ray.direction());
    half c = dot(oc, oc) - pow(radius, 2);
    half delta = pow(b,2) - 4*a*c;
    return delta>0;
}

half3 scan(const Ray ray) {
    if (hitSphere(half3(0,0,1), 0.5, ray)) {
        return half3(1, 0.57, 0);
    }
    half3 direction = normalize(ray.direction());
    half t = 0.5*(direction.y+1);
    return (1.0-t)*half3(0.4,0.7,1) + t*half3(1,1,1);
}

kernel
void compute(texture2d<half, access::write> destination [[ texture(0) ]],
             ushort2 gid [[ thread_position_in_grid ]]) {
    
    half width = half(destination.get_width());
    half height = half(destination.get_height());
    
    half u = half(gid.x)/width;
    half v = half(gid.y)/height;
    
    half3 direction = half3(leftBottomCorner + u*horizontal + v*vertical);
    Ray ray = Ray(rayOrigin, direction);
    
    half4 color = half4(scan(ray), 1);
    destination.write(color, gid);
}
