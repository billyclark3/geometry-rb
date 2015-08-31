require "rubygeom/version"

module Rubygeom

    class Point
      attr_accessor :x, :y
      def initialize(x0,y0)
        @x = x0
        @y = y0
      end
      def in_shape?(shape) # uses ray-casting algorithm
        #find offset, as we can represent ray as a segment that continues from point of origin by a large enough offset so as to definitely pass any edge that might contain it
        xoffset = 0
        yoffset = 0
        shape.points.each do |pt|
          if (pt.x - @x).abs > xoffset
            xoffset = (pt.x - @x).abs
          end
          if (pt.y - @y).abs > yoffset
            yoffset = (pt.y - @y).abs
          end
        end
        x0 = @x
        y0 = @y
        x1 = x0 + xoffset*2
        y1 = y0 + yoffset*2
        # now the ray starts from (x0 and y0), and goes through (x1,y1) to (+inf,+inf), but we only consider the segment of it that ends at (x1,y1)
        m0 = (y1-y0).to_f / ((x1-x0).to_f)
        b0 = y0 - m0*(x0.to_f)
        intersects_points = false
        shape.points.each do |p|
          if p.y.to_f == (m0*(p.x.to_f) + b0.to_f)
            intersects_points = true
          end
        end
        if intersects_points
          while intersects_points do
            y1 += 1 # edge the ray up by increasing the upper-right endpoint's y-coordinate by one unit
            m0 = (y1-y0).to_f / ((x1-x0).to_f)
            b0 = y0.to_f - m0*(x0.to_f)   
            intersects_points = false
            shape.points.each do |p|
              if p.y.to_f == m0*(p.x.to_f) + b0.to_f
                intersects_points = true
              end     
            end
          end
        end
        ray_segment = [Point.new(x0,y0),Point.new(x1,y1)]
        edges_touched = 0
        shape.segments.each do |shape_segment|
          intsc = Intersection.new(shape_segment, ray_segment)
          if intsc.did_intersect
            edges_touched += 1 
          end
        end
        edges_touched.odd? #this is the crux of the ray-casting algorithm: if the point is inside the polygon, any ray that is cast from the point will intersect the polygon an odd number of times; otherwise, such a ray will produce zero or an even number of intersections.
      end
      def in_x_range?(segment)
        (([segment[0].x,segment[1].x]).min <= @x) && (@x <= ([segment[0].x,segment[1].x]).max)
      end

      def in_y_range?(segment)
        (([segment[0].y,segment[1].y]).min <= @y) && (@y <= ([segment[0].y,segment[1].y]).max)
      end
    end

    class Shape
      attr_accessor :points
      def initialize(points_arr=[])  # point arr is array of 2-d arrays, representing points, ordered
        @points = points_arr
      end
      def segments # array of 2-d arrays, each of which represents a segment and contains endpoints
        segs = []
        @points.each_with_index do |p, i|
          new_i = case (i == @points.length() - 1) # if the index is at the end of the collection, point to the first element; the last point should connect to the first
            when true then 0
            else i+1
          end
          segs.push([p, @points[new_i]])
        end
        segs
      end
      def intersects?(shape2)
        intersection_found = false
        combined_indices = segments.product(shape2.segments) # Array.product will yield combinations of segments between two arrays of segments
        segs_intersect = false
        combined_indices.each do |i_comb|
          seg1 = i_comb[0]
          seg2 = i_comb[1]
          int = Intersection.new(seg1,seg2)
          if int.did_intersect
            segs_intersect = true
          end
        end
        segs_intersect
      end
    end

    class Line
      attr_accessor :m, :b, :vert, :x_int # y = mx + b; or vert=true if vertical, with x_int as defined x-intercept
      def initialize(seg) # seg is a 2-d array of points, representing a segment
        x0 = seg[0].x
        y0 = seg[0].y
        x1 = seg[1].x
        y1 = seg[1].y
        vert0 = (x0 == x1)
        case vert0
          when true
            m0 = nil
            b0 = nil
            x_int0 = x0
          else
            m0 = (y1-y0).to_f/((x1-x0).to_f)
            b0 = y0.to_f - m0*(x0.to_f)
            x_int0 = nil
        end
        @m = m0
        @b = b0
        @x_int = x_int0
        @vert = vert0
      end 
    end

    class Intersection
      attr_accessor :x, :y, :did_intersect, :tangent
      def initialize(seg1, seg2) # arguments are segments represented as 2-d arrays of points
        intersect = false
        is_tangent = nil
        xf = nil
        yf = nil
        line1 = Line.new(seg1)
        line2 = Line.new(seg2)
        if line1.vert && line2.vert # both are vertical
          if line1.x_int != line2.x_int
            intersect = false
            xf = nil
            yf = nil
          else
            intersect = seg2[0].in_y_range?(seg1) || seg2[1].in_y_range?(seg1) # arbitrary -- we could alternately test that segment 2 contains either endpoint of segment 1
            case intersect
            when true
              is_tangent = true
              xf = line1.x_int
              yf = nil
            else
              xf = nil
              yf = nil
            end
          end
        elsif line1.vert && !line2.vert # only line1 is vertical
          x0 = line1.x_int
          y0 = line2.m*(x0.to_f) + (line2.b.to_f)
          int_pt = Point.new(x0,y0)
          intersect = int_pt.in_x_range?(seg1) && int_pt.in_x_range?(seg2) && int_pt.in_y_range?(seg1) && int_pt.in_y_range?(seg2)
          case intersect
          when true
            xf = x0
            yf = y0
            is_tangent = false
          else
            xf = nil
            yf = nil
          end
        elsif line2.vert && !line1.vert # only line2 is vertical
          x0 = line2.x_int
          y0 = line1.m*(x0.to_f) + (line1.b.to_f)
          int_pt = Point.new(x0,y0)
          intersect = int_pt.in_x_range?(seg1) && int_pt.in_x_range?(seg2) && int_pt.in_y_range?(seg1) && int_pt.in_y_range?(seg2)
          case intersect
          when true
            xf = x0
            yf = y0
            is_tangent = false
          else
            xf = nil
            yf = nil
          end
        else # neither is vertical
          m1 = line1.m
          m2 = line2.m
          b1 = line1.b
          b2 = line2.b
          if m1 == m2
            if b1 == b2 # lines containing segments are tangent, the same
              intersect = seg2[0].in_x_range?(seg1) || seg2[1].in_x_range?(seg1)
              is_tangent = true
              xf = nil
              yf = nil
            else # are parallel but not tangent
              intersect = false
              xf = nil
              yf = nil
            end
          else # lines containing segments are intersecting and not tangent
            x0 = (b2-b1).to_f / (m1-m2)
            y0 = m1*(x0.to_f) + (b1.to_f)
            int_pt = Point.new(x0,y0)
            intersect = int_pt.in_x_range?(seg1) && int_pt.in_x_range?(seg2) && int_pt.in_y_range?(seg1) && int_pt.in_y_range?(seg2)
            case intersect
            when true
              xf = x0
              yf = y0
              is_tangent = false
            else
              xf = nil
              yf = nil
            end
          end      
        end
        @x = xf
        @y = yf
        @did_intersect = intersect
        @tangent = is_tangent
      end
    end

    class Region
      attr_accessor :bounds
      def initialize(lambdas)
        @bounds = lambdas
      end
      def getFilter
        @bounds.inject(lambda {|x,y| true }) {|result, lamb| lambda {|x,y| result.call(x,y) && lamb.call(x,y) } }
      end
      def contains_point?(point)
        getFilter.call(point.x,point.y)
      end
    end  

end
