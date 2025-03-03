import java.text.SimpleDateFormat;
import java.util.Date;

float galaxyRadius = 650;
float armTightness;
float noiseScale;
int numArms;
float armOffset;
float coreSize;
float dustDensity;
color[] starColors = {
  color(255, 255, 255),    // Pure white
  color(255, 250, 240),    // Slight warm white
  color(245, 245, 255),    // Slight blue white
  color(255, 250, 230)     // Very slight warm
};

String outputFolder = "galaxy_output";
SimpleDateFormat dateFormat;

void setup() {
  size(900, 900);
  noLoop();
  noStroke();
  background(0);
  smooth();
  
  dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
  
  File folder = new File(sketchPath(outputFolder));
  if (!folder.exists()) {
    folder.mkdir();
  }
  
  armTightness = random(0.6, 0.9);
  noiseScale = random(0.015, 0.025);
  numArms = int(random(3, 10));
  armOffset = random(0.08, 0.15);
  coreSize = random(0.25, 0.35);
  dustDensity = random(200, 400);
  
  noiseDetail(4, 0.5);
}

void draw() {
  drawDeepSpace();
  
  drawStarryBackground(35000);
  
  drawGalacticCore();
  
  for(int i = 0; i < numArms; i++) {
    float armAngle = TWO_PI/numArms * i + random(-armOffset, armOffset);
    generateSpiralArm(width/2, height/2, armAngle);
  }
  
  addDustLanes();
  addStarClusters();
  addDistantStars();
  
  String timestamp = dateFormat.format(new Date());
  String filename = String.format("%s/galaxy_%s_arms%d.png", 
                                outputFolder, 
                                timestamp, 
                                numArms);
  
  save(filename);
  
  println("Generated galaxy with:");
  println("Number of arms: " + numArms);
  println("Arm tightness: " + nf(armTightness, 0, 3));
  println("Core size: " + nf(coreSize, 0, 3));
  println("Saved as: " + filename);
}

void drawDeepSpace() {
  loadPixels();
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      float n = noise(x * 0.005, y * 0.005);
      pixels[y * width + x] = color(n * 10);
    }
  }
  updatePixels();
}

void drawStarryBackground(int stars) {
  for(int i = 0; i < stars; i++) {
    float x = random(width);
    float y = random(height);
    float sz = pow(random(1), 12) * 1.5;
    float brightness = 40 + random(100) * pow(1 - sz/1.5, 2);
    color starColor = starColors[int(random(starColors.length))];
    fill(red(starColor), green(starColor), blue(starColor), brightness);
    ellipse(x, y, sz, sz);
  }
}

void drawGalacticCore() {
  float coreRadius = galaxyRadius * coreSize;
  int coreStars = 15000;
  
  for(int i = 0; i < coreStars; i++) {
    float angle = random(TWO_PI);
    float distance = pow(random(1), 2) * coreRadius;
    float x = width/2 + cos(angle) * distance;
    float y = height/2 + sin(angle) * distance;
    
    float brightness = map(distance, 0, coreRadius, 255, 100);
    float sz = map(distance, 0, coreRadius, 1.2, 0.3);
    
    color starColor = starColors[int(random(starColors.length))];
    fill(red(starColor), green(starColor), blue(starColor), brightness);
    ellipse(x, y, sz, sz);
  }
}

void generateSpiralArm(float cx, float cy, float startAngle) {
  float armLength = galaxyRadius * random(0.9, 1.1);
  float noiseIntensity = 0.4;
  
  for(float r = galaxyRadius * 0.1; r < armLength; r += 1) {
    float baseAngle = startAngle + armTightness * log(r/50);
    float noiseOffset = noise(r*noiseScale, startAngle) * TWO_PI * noiseIntensity;
    
    createArmSegment(cx, cy, r, baseAngle + noiseOffset, 1.0);
    
    // Add subtle arm variations
    if(r > armLength * 0.3) {
      float variation = map(r, armLength * 0.3, armLength, 0.2, 0.7);
      createArmSegment(cx, cy, r, baseAngle + noiseOffset * 0.7, variation);
    }
  }
}

void createArmSegment(float cx, float cy, float r, float angle, float intensity) {
  int density = int(map(r, 50, galaxyRadius, 20, 8));
  for(int i = 0; i < density; i++) {
    float offsetR = r + random(-15, 15) * intensity;
    float offsetAngle = angle + random(-0.15, 0.15) * intensity;
    
    float x = cx + cos(offsetAngle) * offsetR;
    float y = cy + sin(offsetAngle) * offsetR;
    
    float brightness = 100 + 155 * pow(1 - offsetR/galaxyRadius, 0.7);
    float sz = pow(random(1), 3) * 1.8 * intensity;
    
    if(brightness > 80) {
      color starColor = starColors[int(random(starColors.length))];
      fill(red(starColor), green(starColor), blue(starColor), 150 * intensity);
      ellipse(x, y, sz, sz);
    }
  }
}

void addDustLanes() {
  float dustOpacity = random(15, 25);
  
  for(int i = 0; i < dustDensity; i++) {
    float angle = random(TWO_PI);
    float distance = random(galaxyRadius * 0.3, galaxyRadius * 1.1);
    float x = width/2 + cos(angle) * distance;
    float y = height/2 + sin(angle) * distance;
    
    float opacity = map(distance, galaxyRadius * 0.3, galaxyRadius * 1.1, dustOpacity, dustOpacity * 0.5);
    fill(20, opacity);
    float size = random(30, 70) * map(distance, galaxyRadius * 0.3, galaxyRadius * 1.1, 1.2, 0.8);
    ellipse(x, y, size, size);
  }
}

void addStarClusters() {
  int numClusters = int(random(30, 50));
  for(int i = 0; i < numClusters; i++) {
    float angle = random(TWO_PI);
    float distance = random(galaxyRadius * 0.3, galaxyRadius * 0.8);
    float cx = width/2 + cos(angle) * distance;
    float cy = height/2 + sin(angle) * distance;
    
    int clusterStars = int(random(40, 100));
    for(int j = 0; j < clusterStars; j++) {
      float starAngle = random(TWO_PI);
      float starDistance = random(20) * pow(random(1), 0.5);
      float x = cx + cos(starAngle) * starDistance;
      float y = cy + sin(starAngle) * starDistance;
      
      float sz = pow(random(1), 4) * 2;
      color starColor = starColors[int(random(starColors.length))];
      fill(red(starColor), green(starColor), blue(starColor));
      ellipse(x, y, sz, sz);
    }
  }
}

void addDistantStars() {
  for(int i = 0; i < 6000; i++) {
    float angle = random(TWO_PI);
    float distance = random(galaxyRadius * 0.9, galaxyRadius * 1.4);
    float x = width/2 + cos(angle) * distance;
    float y = height/2 + sin(angle) * distance;
    float sz = random(0.5, 1.0);
    
    float opacity = map(distance, galaxyRadius * 0.9, galaxyRadius * 1.4, 80, 30);
    fill(255, opacity);
    ellipse(x, y, sz, sz);
  }
}
