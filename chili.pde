import gab.opencv.*;
import java.awt.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.net.*;

Server s;
Kinect kinect;               //  Create Kinect object
OpenCV opencv;

float m, n, p;
int a = 0;
PImage currentImage;  // Images to display
// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  
  size(640, 480);
  s = new Server(this, 1234);
  // Initialize the kinect and video
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();

  // Display the current image
  currentImage = kinect.getVideoImage();
  image(currentImage, 0, 0);
  opencv = new OpenCV(this, 640, 480);
  //opencv.loadCascade(OpenCV.CASCADE_EYE);
  //opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  //opencv.loadCascade("C:/Users/ADMIN/Desktop/chillis2/classifier/cascade.xml", true);
  opencv.loadCascade("C:/Users/ADMIN/Documents/Processing/libraries/opencv_processing/library/cascade-files/haar_chili.xml", true);

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}
void draw() {

  opencv.loadImage(currentImage);
  image(currentImage, 0, 0 );
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  textSize(30);
  int skip = 2;
  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  Rectangle[] chillis = opencv.detect();
  for (int i = 0; i < chillis.length; i++) {
    rect(chillis[i].x, chillis[i].y, chillis[i].width, chillis[i].height);
    for (int x = 0; x < chillis[i].width; x += skip) {
      for (int y= 0; y < chillis[i].height; y += skip) {
        point (chillis[i].width/2 + chillis[i].x, chillis[i].height/2 + chillis[i].y);
        int a = chillis[i].width/2 + chillis[i].x;
        int b = chillis[i].height/2 + chillis[i].y;
        //int offset = a + b*chillis[i].width;
        int offset = a + b*kinect.width;
        // Convert kinect data to world xyz coordinate
        int rawDepth = depth[offset];
        text("DepthVal = " + rawDepth, 30, 50);
        PVector v = depthToWorld(a, b, rawDepth);
        m = v.x*1000 + 270 ;
        n = v.y*1000*(-1) -50;
        p = v.z*1000 - 100;
        text("x = " + m, 10, 100);
        text("y = " + n, 10, 150);
        text("z = " + p, 10, 200);
        //println(m, n, p);
        //sendata(m, n, p);
      }
    }
  }
  //delay(3000);
}

void mousePressed() {
  if (a == 0) {
    s.write("x" + str(m) + "y" + str(n) + "z" + str(p) + "d");
  } else {
    a = 0;
  }
}

//void sendata(float m1, float n1, float p1) {
//  if (mousePressed == true) {
//    s.write("x" + str(m1) + "y" + str(n1) + "z" + str(p1) + "d");
//  }
//}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {
  final double fx_d = (1.0 / 5.9421434211923247e+02);
  final double fy_d = (1.0 / 5.9104053696870778e+02);
  final double cx_d = (3.3930780975300314e+02);
  final double cy_d = (2.4273913761751615e+02);

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  //double depth = rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}
