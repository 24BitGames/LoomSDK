/*
 * ===========================================================================
 * Loom SDK
 * Copyright 2011, 2012, 2013
 * The Game Engine Company, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ===========================================================================
 */


#pragma once

#include "math.h"
#include "loom/script/loomscript.h"

namespace Loom2D
{
struct Point
{
public:

    static Type *typePoint;

    static lua_Number xOrdinal;
    static lua_Number yOrdinal;

    static Point tempPoint;

    float x;
    float y;


    Point(float _x = 0.0f, float _y = 0.0f)
    {
        x = _x;
        y = _y;
    }

    inline float get_lengthSquared() const
    {
        return (x*x + y*y);
    }

    inline float get_length() const
    {
        return sqrtf(this->get_lengthSquared());
    }

    const char *toString()
    {
        static char toStringBuffer[256];
        snprintf(toStringBuffer, 255, "[Point %.6f, %.6f]", x, y);
        return toStringBuffer;
    }

    inline bool equals(Point *other)
    {
        return ((x != other->x) || (y != other->y)) ? false : true;
    }

    inline Point *clone()
    {
        return new Point(x, y);
    }

    inline float distanceSquaredToLineSegment(Point *start, Point *end)
    {
        Point lineSeg = end->subtract(start);
        Point toPoint = this->subtract(start);
        float invLineLen = 1.0f / lineSeg.get_lengthSquared();
        float u = Point::dot(&toPoint, &lineSeg) * invLineLen;
        if(u > 1.0f) u = 1.0f; else if(u < 0.0f) u = 0.0;
        tempPoint = *start;
        tempPoint.x += (lineSeg.x * u) - x;   
        tempPoint.y += (lineSeg.y * u) - y;
        return tempPoint.get_lengthSquared();
    }

    inline float distanceToLineSegment(Point *start, Point *end)
    {
        return sqrtf(distanceSquaredToLineSegment(start, end));
    }

    inline void normalize(float thickness = 1.0f)
    {
        float oldLength = get_lengthSquared();
        if (oldLength == 0.0f) return;
        
        float thickNessOverLength = thickness / sqrt(oldLength);
        x *= thickNessOverLength;
        y *= thickNessOverLength;
    }
 
    inline void offset(float dx, float dy)
    {
        x += dx;
        y += dy;
    }
 
    inline void scale(float s)
    {
        x *= s;
        y *= s;
    }

    inline Point subtract(Point *other)
    {
        tempPoint.x = x - other->x;
        tempPoint.y = y - other->y;
        return tempPoint;
    }
 
    inline Point add(Point *other)
    {
        tempPoint.x = x + other->x;
        tempPoint.y = y + other->y;
        return tempPoint;
    }

    void opPlusAssignment(Point *p)
    {
        x += p->x;
        y += p->y;
    }

    void opMinusAssignment(Point *p)
    {
        x -= p->x;
        y -= p->y;
    }

    void opMultiplyAssignment(float s)
    {
        x *= s;
        y *= s;
    }

    void opDivideAssignment(float s)
    {
        float invS = 1.0f / s;
        x *= invS;
        y *= invS;
    }

    static void opAssignment(Point *a, Point *b)
    {
        *a = *b;
    }

    static Point opPlus(Point *a, Point *b)
    {
        tempPoint.x = a->x + b->x;
        tempPoint.y = a->y + b->y;        
        return tempPoint;
    }

    static Point opMinus(Point *a, Point *b)
    {
        tempPoint.x = a->x - b->x;
        tempPoint.y = a->y - b->y;        
        return tempPoint;
    }
  
    static float distanceSquared(Point *p1, Point *p2)
    {
        float dx = p2->x - p1->x;
        float dy = p2->y - p1->y;
        return dx*dx + dy*dy;
    }

    static float distance(Point *p1, Point *p2)
    {
        return sqrtf(Point::distanceSquared(p1, p2));
    }

    static float dot(Point *p1, Point *p2)
    {
        return p1->x*p2->x + p1->y*p2->y;
    }
   
    static Point interpolate(Point *p1, Point *p2, float t)
    {
        tempPoint.x = p2->x + ((1.0f - t) * (p1->x - p2->x));
        tempPoint.y = p2->y + ((1.0f - t) * (p1->y - p2->y));
        return tempPoint;
    }
   
    static Point polar(float len, float angle)
    {
        tempPoint.x = len * cosf(angle);
        tempPoint.y = len * sinf(angle);
        return tempPoint;
    }


    static void initialize(lua_State *L)
    {
        typePoint = LSLuaState::getLuaState(L)->getType("loom2d.math.Point");
        lmAssert(typePoint, "unable to get loom2d.math.Point type");

        xOrdinal = typePoint->getMemberOrdinal("x");
        yOrdinal = typePoint->getMemberOrdinal("y");
    }
};
}
