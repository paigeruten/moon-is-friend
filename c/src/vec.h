#ifndef vec_h
#define vec_h

#define PI_F 3.14159265358979323846f

#define deg2rad(deg) ((deg) * PI_F / 180.0f)
#define rad2deg(rad) ((deg) * 180.0f / PI_F)

typedef struct Vec {
  float x;
  float y;
} Vec;

Vec vec_new(float x, float y);
Vec vec_new_polar(float length, float angle);
Vec vec_add(Vec a, Vec b);

#endif
