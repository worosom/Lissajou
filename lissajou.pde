import ddf.minim.AudioInput;
import ddf.minim.Minim;

public static boolean INVERT_COLORS = true; 

public static float SIZE = 2.f;
public static int BUFFERSIZE = 512;
public static float SAMPLERATE = 44100;
public static int BITDEPTH = 16;

Minim minim;
AudioInput in;

float buffer[][] = new float[2][BUFFERSIZE];
float buffer1[][] = new float[2][BUFFERSIZE];
float volume;

float scale;

public void setup() {
  fullScreen();
  hint(ENABLE_STROKE_PURE);
  background(255);
  smooth(8);

  scale = width;
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, BUFFERSIZE, SAMPLERATE, BITDEPTH);

  noCursor();
  shapeMode(CENTER);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  noFill();
  stroke(INVERT_COLORS ? 0 : 255);
}

public void update() {
  volume = ease(volume, in.mix.level(), .1);

  buffer[0] = in.left.toArray();
  buffer[1] = in.right.toArray();

  // fraction of input volume
  float vf = 6.f;
  // easing constant
  float ec = .76f;
  buffer1[0] = ease(buffer1[0], buffer[0], in.mix.level() / vf, ec);
  buffer1[1] = ease(buffer1[1], buffer[1], in.mix.level() / vf, ec);
}

public void draw() {
  update();
  background(INVERT_COLORS ? 255 : 0);

  translate(width / 2, height / 2);
  rotate(-PI / 4.f);

  beginShape();
  for (int i = 0; i < BUFFERSIZE; i++) {
    float weight = .5f;
    weight += abs(buffer[1][i] - buffer[0][i]) * 10.f;
    strokeWeight(weight);
    float r = SIZE * (scale - volume / 2.f);
    float x = buffer1[1][i] * r;
    float y = buffer1[0][i] * r;
    curveVertex(x, y);
  }
  endShape();

  // surface.setTitle((int)frameRate + " fps");
}

public float[] ease(float[] a, float[] b, float offset, float mult) {
  int size = a.length;
  float out[] = new float[size];
  for (int i = 0; i < size; i++) {
    float rb;
    if (i + 1 < BUFFERSIZE) {
      // the bigger the difference between the current value
      // and the next one is, the higher rb is.
      rb = abs(b[i] - b[i + 1]);
    } else // assume periodicity
    rb = abs(b[i] - b[0]);

    rb *= mult;
    rb += offset;
    out[i] = a[i] + (b[i] - a[i]) * rb;
  }
  return out;
}

public float ease(float a, float b, float r) {
  if (b > a)
    return b;
  float d = b - a;
  return a + d * r;
}