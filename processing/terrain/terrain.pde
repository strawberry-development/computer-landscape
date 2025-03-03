import peasy.*;

PeasyCam cam;
int cols, rows;
int scl = 20;
int w = 5000;
int h = 1600;
float[][] terrain;
float flying = 0;
float noiseScale = 0.1;
float noiseSpeed = 0.05;
int lastScreenshotTime = 0;
PGraphics terrainBuffer;
boolean shouldUpdateTerrain = true;
boolean spinning = false;
float spinAngle = 0;

void setup() {
  size(700, 900, P3D);
  smooth(4);
  
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
  
  // Initialize off-screen buffer
  terrainBuffer = createGraphics(width, height, P3D);
  
  // Camera setup
  cam = new PeasyCam(this, 0, 0, 0, 1200);
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(3000);
  cam.rotateX(-0.5);
  
  // Create output folder
  File outputFolder = new File(sketchPath("output"));
  if (!outputFolder.exists()) {
    outputFolder.mkdir();
  }
  
  // Pre-calculate initial terrain
  updateTerrain();
}

void draw() {
  background(0);
  
  // Only update terrain when necessary
  if (shouldUpdateTerrain) {
    flying -= noiseSpeed;
    updateTerrain();
  }
  
  // Lighting setup
  lights();
  directionalLight(255, 255, 255, 0, 1, -1);
  
  // Draw scene
  drawScene();
  
  // Screenshot logic
  if (millis() - lastScreenshotTime >= 5000) {
    saveFrame("output/screenshot_####.png");
    lastScreenshotTime = millis();
  }
  
  // Update camera spin angle if spinning
  if (spinning) {
    spinAngle += 0.01;
    cam.rotateY(0.01);
  }
}

void updateTerrain() {
  float yoff = flying;

  noiseDetail(4, 0.5);
  
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      // Cache noise calculations
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100);
      xoff += noiseScale;
    }
    yoff += noiseScale;
  }
}

void drawScene() {
  pushMatrix();
  translate(-w/2, -h/2, 0);
  
  beginShape(TRIANGLE_STRIP);
  for (int y = 0; y < rows - 1; y++) {
    for (int x = 0; x < cols; x++) {
      float h1 = terrain[x][y];
      float h2 = terrain[x][y + 1];
      
      int terrainColor = color(
        map(h1, -100, 100, 50, 200),
        map(h1, -100, 100, 100, 255),
        0
      );
      
      fill(terrainColor);
      vertex(x * scl, y * scl, h1);
      vertex(x * scl, (y + 1) * scl, h2);
    }
    // Reset strip for next row to avoid artifacts
    endShape();
    beginShape(TRIANGLE_STRIP);
  }
  endShape();
  
  fill(0, 0, 255, 100);
  beginShape(QUADS);
  vertex(0, 0, -50);
  vertex(w, 0, -50);
  vertex(w, h, -50);
  vertex(0, h, -50);
  endShape();
  
  popMatrix();
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    cam.reset();
  }
  
  // Toggle camera spinning
  else if (key == 's' || key == 'S') {
    spinning = !spinning;
  }
  else if (keyCode == UP) {
    noiseScale = constrain(noiseScale + 0.01, 0.01, 0.5);
    shouldUpdateTerrain = true;
  }
  else if (keyCode == DOWN) {
    noiseScale = constrain(noiseScale - 0.01, 0.01, 0.5);
    shouldUpdateTerrain = true;
  }
  else if (keyCode == RIGHT) {
    noiseSpeed = constrain(noiseSpeed + 0.01, 0.01, 0.2);
    shouldUpdateTerrain = true;
  }
  else if (keyCode == LEFT) {
    noiseSpeed = constrain(noiseSpeed - 0.01, 0.01, 0.2);
    shouldUpdateTerrain = true;
  }
}
