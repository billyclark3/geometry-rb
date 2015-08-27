
require 'spec_helper'
require 'rubygeom'

describe Rubygeom do
  describe Rubygeom::Point do
    it "should initialize with x and y coordinates" do
      point_test = Rubygeom::Point.new(10,20)
      point_test.x.should equal(10)
      point_test.y.should equal(20)
    end
    it "should tell if it is inside a given shape" do
      point_test = Rubygeom::Point.new(0,0)
      outline_points =  [
        Rubygeom::Point.new(0,2),
        Rubygeom::Point.new(4, -1),
        Rubygeom::Point.new(-4, -1)
      ]
      s = Rubygeom::Shape.new(outline_points)
      point_test.in_shape?(s).should be true
    end
    it "should tell if it is not inside a given shape" do
      point_test = Rubygeom::Point.new(0,10)
      outline_points =  [
        Rubygeom::Point.new(0,6),
        Rubygeom::Point.new(5,5),
        Rubygeom::Point.new(6,0),
        Rubygeom::Point.new(5,-5),
        Rubygeom::Point.new(0,-6),
        Rubygeom::Point.new(-5,-5),
        Rubygeom::Point.new(-6,0),
        Rubygeom::Point.new(-5,5)
      ]
      s = Rubygeom::Shape.new(outline_points)
      point_test.in_shape?(s).should be false 
    end    
    it "should tell if it is inside a given range of x-coordinates" do
      point_left = Rubygeom::Point.new(-1,-1)
      point_right = Rubygeom::Point.new(1,1)
      point_test = Rubygeom::Point.new(0,0)
      point_test.in_x_range?([point_left, point_right]).should be true
    end
    it "should tell if it is not inside a given range of x-coordinates" do
      point_left = Rubygeom::Point.new(-1,-1)
      point_right = Rubygeom::Point.new(1,1)
      point_test = Rubygeom::Point.new(2,0)
      point_test.in_x_range?([point_left, point_right]).should be false
    end  
    it "should tell if it is inside a given range of y-coordinates" do
      point_left = Rubygeom::Point.new(-1,-1)
      point_right = Rubygeom::Point.new(1,1)
      point_test = Rubygeom::Point.new(0,0)
      point_test.in_y_range?([point_left, point_right]).should be true
    end
    it "should tell if it is not inside a given range of y-coordinates" do
      point_left = Rubygeom::Point.new(-1,-1)
      point_right = Rubygeom::Point.new(1,1)
      point_test = Rubygeom::Point.new(0,2)
      point_test.in_y_range?([point_left, point_right]).should be false
    end  
  end

  describe Rubygeom::Shape do 
    it "should initialize" do
      outline_points =  [
        Rubygeom::Point.new(0,6),
        Rubygeom::Point.new(5,5),
        Rubygeom::Point.new(6,0),
        Rubygeom::Point.new(5,-5),
        Rubygeom::Point.new(0,-6),
        Rubygeom::Point.new(-5,-5),
        Rubygeom::Point.new(-6,0),
        Rubygeom::Point.new(-5,5)
      ]
      s = Rubygeom::Shape.new(outline_points)
      s.points.should_not be nil
    end
    it "should return a list of segments that represent its sides" do

      pointA = Rubygeom::Point.new(1,0)
      pointB = Rubygeom::Point.new(0,1)
      pointC = Rubygeom::Point.new(0,-1)
    
      outline_points =  [
        pointA,
        pointB,
        pointC
      ]
      s = Rubygeom::Shape.new(outline_points)
      segs = s.segments
      segs.should include([pointA,pointB])
      segs.should include([pointB,pointC])
      segs.should include([pointC,pointA])
    
    end
    it "should be able to determine if it intersects with other shapes" do
      outline_points_1 =  [
        Rubygeom::Point.new(1,1),
        Rubygeom::Point.new(2,1),
        Rubygeom::Point.new(2,4)
      ]
      shape_1 = Rubygeom::Shape.new(outline_points_1)
      outline_points_2 =  [
        Rubygeom::Point.new(2,1),
        Rubygeom::Point.new(3,1),
        Rubygeom::Point.new(3,4)
      ]
      shape_2 = Rubygeom::Shape.new(outline_points_2)
      shape_1.intersects?(shape_2).should be true

    end
    
    it "should be able to determine if it does not intersect with other shapes" do
      outline_points_1 =  [
        Rubygeom::Point.new(1,1),
        Rubygeom::Point.new(2,1),
        Rubygeom::Point.new(2,4)
      ]
      shape_1 = Rubygeom::Shape.new(outline_points_1)
      outline_points_2 =  [
        Rubygeom::Point.new(-1,-1),
        Rubygeom::Point.new(-2,-1),
        Rubygeom::Point.new(-2,-4)
      ]
      shape_2 = Rubygeom::Shape.new(outline_points_2)
      shape_1.intersects?(shape_2).should be false

    end
  end
  
  
  describe Rubygeom::Line do
    it "should initialize for a non-vertical line" do
      point_0 = Rubygeom::Point.new(0,0)
      point_1 = Rubygeom::Point.new(5,2)
      line = Rubygeom::Line.new([point_0, point_1])
      line.vert.should be false
      line.b.should eq(0)
      line.m.should eq(2.0/5)
      line.x_int.should be_nil
    end
    it "should initialize for a vertical line" do
      point_0 = Rubygeom::Point.new(0,0)
      point_1 = Rubygeom::Point.new(0,2)
      line = Rubygeom::Line.new([point_0, point_1])
      line.vert.should be true
      line.b.should be nil
      line.m.should be nil
      line.x_int.should eq(0)
    end
  end
  
  describe Rubygeom::Intersection do
    it "should initialize for two segments that intersect" do
      point_0 = Rubygeom::Point.new(0,0)
      point_1 = Rubygeom::Point.new(4,4)
      point_2 = Rubygeom::Point.new(0,4)
      point_3 = Rubygeom::Point.new(4,0)      
      i = Rubygeom::Intersection.new([point_0, point_1], [point_2, point_3])
      i.x.should eq(2)
      i.y.should eq(2)
      i.did_intersect.should be true
      i.tangent.should_not be true
    end
    it "should initialize for two segments that do not intersect" do
      point_0 = Rubygeom::Point.new(0,0)
      point_1 = Rubygeom::Point.new(4,4)
      point_2 = Rubygeom::Point.new(0,5)
      point_3 = Rubygeom::Point.new(4,20)      
      i = Rubygeom::Intersection.new([point_0, point_1], [point_2, point_3])
      i.x.should be_nil
      i.y.should be_nil
      i.did_intersect.should be false
      i.tangent.should_not be true      
    end
    it "should initialize for two segments that are tangent to each other" do
      point_0 = Rubygeom::Point.new(0,0)
      point_1 = Rubygeom::Point.new(4,4)
      point_2 = Rubygeom::Point.new(2,2)
      point_3 = Rubygeom::Point.new(6,6)      
      i = Rubygeom::Intersection.new([point_0, point_1], [point_2, point_3])
      i.x.should be_nil
      i.y.should be_nil
      i.did_intersect.should be true
      i.tangent.should be true        
    end
  end
end
# Notes to self
# use 2 points, not array as arg for initializing line
# vert? use question mark for bool
# naming? shape/polygon? line/segment?
# overload intersection? take actual segs?
# reorganize tests with factories and before :each blocks?