int generation = 0;
int totalGenerations = 20;

//0 = completely transparent (invisible)
//255 = completely opaque (solid)
//150 = about 59% opaque
float minAlpha = 150;
float maxAlpha = 255;

void setup() {
  size(800, 800);
  noLoop();
  background(30);
  
  String folderPath = createOutputFolder();
  
  while (generation < totalGenerations) {
    drawGenerativeArt();
    saveArtwork(folderPath);
    generation++;
    background(30);
  }
  
  println("Complete: " + totalGenerations + " images saved in " + folderPath);
  exit();
}

void drawGenerativeArt() {
  // Art parameters
  float noiseScale = random(0.01, 0.05);
  float gridSpacing = random(10, 20);
  float shapeSize = random(10, 20);
  float angleOffset = random(TWO_PI);
  int shapeType = int(random(3));
  color startColor = color(random(100, 255), random(100, 200), random(150, 255));
  color endColor = color(random(100, 255), random(100, 200), random(150, 255));
  
  // Draw grid of shapes
  noStroke();
  for (float x = 0; x < width; x += gridSpacing) {
    for (float y = 0; y < height; y += gridSpacing) {
      float noiseVal = noise(x * noiseScale, y * noiseScale);
      float angle = map(noiseVal, 0, 1, 0, TWO_PI);
      
      // Calculate color
      float colorPos = map(y, 0, height, 0, 1);
      color baseColor = lerpColor(startColor, endColor, colorPos);
      float alpha = map(noiseVal, 0, 1, minAlpha, maxAlpha);
      fill(red(baseColor), green(baseColor), blue(baseColor), alpha);
      
      // Draw shape
      pushMatrix();
      translate(x, y);
      rotate(angle + angleOffset);
      
      float finalSize = shapeSize * noiseVal;
      drawShape(shapeType, finalSize);
      
      popMatrix();
    }
  }
  
  // Add depth with gradient
  drawCentralGradient();
}

void drawShape(int type, float size) {
  switch(type) {
    case 0: // Rectangle
      rectMode(CENTER);
      rect(0, 0, size, size);
      break;
      
    case 1: // Circle
      ellipse(0, 0, size, size);
      break;
      
    case 2: // Triangle
      float triSize = size * 1.5;
      triangle(-triSize/2, triSize/2, 
               triSize/2, triSize/2, 
               0, -triSize/2);
      break;
  }
}

void drawCentralGradient() {
  float maxRadius = random(width * 0.3, width * 0.7);
  float gradientAlpha = random(100, 200);
  
  for (float r = maxRadius; r > 0; r -= 2) {
    float alpha = map(r, 0, maxRadius, gradientAlpha, 0);
    noFill();
    stroke(30, alpha);
    ellipse(width/2, height/2, r * 2, r * 2);
  }
}

String createOutputFolder() {
  String timestamp = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + 
                    nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
  String folderPath = timestamp;
  File folder = new File(sketchPath(folderPath));
  if (!folder.exists()) {
    folder.mkdir();
  }
  return folderPath;
}

void saveArtwork(String folderPath) {
  String filename = folderPath + "/generative_art_" + generation + ".png";
  save(filename);
  println("Saved: " + filename);
}
