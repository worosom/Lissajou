import processing.core.PApplet;
import processing.core.PImage;
import processing.opengl.PShader;
import ddf.minim.AudioInput;
import ddf.minim.Minim;


public static int BUFFERSIZE = 512;
public static float SAMPLERATE = 44100;
public static int BITDEPTH = 16;

Minim minim;
AudioInput in;

float buffer[][] = new float[2][BUFFERSIZE];
float buffer1[][] = new float[2][BUFFERSIZE];

PShader shad;
boolean drawshad = false;

PImage noCurse;

float scale;

public void setup() {
  size(displayWidth, displayHeight, P2D);
  background(255);
  smooth(4);
  
  scale = width / 1920.f;
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, BUFFERSIZE, SAMPLERATE, BITDEPTH);

  shad = loadShader("program.fsh");
  noCurse = loadImage("noCursor.png");
  cursor(noCurse);
  shapeMode(CENTER);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  noFill();
  stroke(0);
}

public void draw() {
  background(255);

  buffer[0] = in.left.toArray();
  buffer[1] = in.right.toArray();

  buffer1[0] = ease(buffer1[0], buffer[0], (in.mix.level()) / 6.f, .76f);
  buffer1[1] = ease(buffer1[1], buffer[1], (in.mix.level()) / 6.f, .76f);
  
  translate(width / 2, height / 2);
  rotate(-PI / 4.f);

  beginShape();
  for (int i = 0; i < BUFFERSIZE; i++) {
    strokeWeight(.5f + abs(buffer[1][i] - buffer[0][i]) * 10.f);
    curveVertex(buffer1[0][i] * 4500.f * scale, buffer1[1][i] * 4500.f * scale);
  }
  endShape();

  if (drawshad) {
    shad.set("resolution", (float) width, (float) height);
    shad.set("texture", g);
    shad.set("max_distort", in.mix.level() * 2.2f);
    filter(shad);
  }
  
  frame.setTitle((int)frameRate + " fps");
}

public float[] ease(float[] a, float[] b, float offset, float mult) {
  int size = a.length;
  float out[] = new float[size];
  for (int i = 0; i < size; i++) {
    float rb;
    if (i + 1 < BUFFERSIZE) {
      // the bigger the difference between the current value in the buffer
      // and the next one is, the higher rb is.
      rb = abs(b[i] - b[i + 1]);
    } else
      rb = abs(b[i] - b[i - 1]);
    
    rb *= mult;
    rb += offset;
    out[i] = a[i] + (b[i] - a[i]) * rb;
  }
  return out;
}

public void mouseMoved() {
  cursor(noCurse);
}

public void keyReleased() {
  if (key == 's' || key == 'S') {
    drawshad = !drawshad;
  }
}

