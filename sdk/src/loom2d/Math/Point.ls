package loom2d.math 
{
    /**
     * 2D Point structure which has useful utility methods and is assign by value.
     */
    final public native struct Point 
    {
        public native var x:float;
        public native var y:float;



        // note that we need to new here as the default args
        // won't be setup as we're in the static initializer
        public static const ZERO:Point = new Point(0, 0);


        /**
         * Constructor for Point with optional components.
         */
        public native function Point(_x:Number = 0, _y:Number = 0);

        /**
         * Clones this Point to a new one.
         */
        public native function clone():Point;

        /**
         * Returns a string representation of the Point.
         */
        public native function toString():String;

        /**
         * Gets the length defined by the Point.
         */
        public native function get length():Number;

        /**
         * Gets the length^2 defined by the Point.
         */
        public native function get lengthSquared():Number;

        /**
         * Checks whether the Point is numerically equal to another Point.
         */        
        public native function equals(p:Point):Boolean;

        /**
         * Calculates the distance from this Point to the line segment defined by start and end
         */        
        public native function distanceToLineSegment(start:Point, end:Point):Number;

        /**
         * Calculates the distance squared from this Point to the line segment defined by start and end
         */        
        public native function distanceSquaredToLineSegment(start:Point, end:Point):Number;

        /**
         * Normalizes the Point to a specified length.
         */        
        public native function normalize(thickness:Number = 1):void;

        /**
         * Offsets the point by the given delta values.
         */
        public native function offset(dx:Number, dy:Number):void;

        /**
         * Scales the point by the given Scalar.
         */
        public native function scale(s:Number):void;

        /**
         * Subtracts the supplied Point from this Point.
         */
        public native function subtract(other:Point):Point;

        /**
         * Adds the supplied Point to this Point.
         */
        public native function add(other:Point):Point;

        /**
         * Adds Point p to this Point.
         */
        public native operator function +=(p:Point):void;

        /**
         * Subtracts Point p from this Point.
         */
        public native operator function -=(p:Point):void;

        /**
         * Multiplies This point by the scalar s.
         */
        public native operator function *=(s:Number):void;

        /**
         * Divides This point by the scalar s.
         */
        public native operator function /=(s:Number):void;

        /**
         * Assigns p2 to p1 and returns p1 (required by struct types).
         */
        public static native operator function =(p1:Point, p2:Point):Point;

        /**
         * Adds Point p2 to Point p1 and returns p1.
         */
        public static native operator function +(p1:Point, p2:Point):Point;

        /**
         * Subtracts Point p2 from Point p1 and returns the result.
         */
        public static native operator function -(p1:Point, p2:Point):Point;
    
        /**
         * Gets the distance between two Points.
         */
        public static native function distance(p1:Point, p2:Point):Number;

        /**
         * Gets the distance squared between two Points.
         */
        public static native function distanceSquared(p1:Point, p2:Point):Number;

        /**
         * Interpolates 2 points returning a new point at the specified time.
         */
        public static native function interpolate(p1:Point, p2:Point, t:Number):Point;

        /**
         * Returns the dot product between p1 and p2, as though they were Vectors
         */
        public static native function dot(p1:Point, p2:Point):Number;

        /**
         * Gets a polar Point given an angle and length.
         */         
        public static native function polar(len:Number, angle:Number):Point;
    }
}
