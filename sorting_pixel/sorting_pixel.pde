import java.io.File;
import java.util.Arrays;

PImage img;
String timestamp;

// User Configurable Settings
boolean useDiagonalSorting = true; // true for diagonal, false for horizontal/vertical
boolean useEdgeDetection = false;  // true to only sort edges
float sortingProbability = 1;      // Probability of sorting a section (0.0 - 1.0)
String sortingMode = "brightness"; // "brightness", "hue", "red", "green", "blue", "saturation", "luminance"
boolean reverseSorting = false;    // Reverse the sorting order
float edgeThreshold = 80;          // Edge detection threshold

void settings() {
  img = loadImage("image.jpg"); 
  size(img.width, img.height);
}

void setup() {
  timestamp = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
  
  File subfolder = new File(sketchPath("output/" + timestamp));
  if (!subfolder.exists()) subfolder.mkdirs();
  
  noLoop();
}

void draw() {
  image(img, 0, 0);
  img.loadPixels();
  
  // Optionally detect edges before sorting
  boolean[] edgeMap = useEdgeDetection ? detectEdges(img) : null;
  
  if (useDiagonalSorting) {
    diagonalPixelSort(img, edgeMap);
  } else {
    horizontalVerticalPixelSort(img, edgeMap);
  }

  img.updatePixels();
  image(img, 0, 0);
  
  String outputPath = "output/" + timestamp + "/sorted_image.png";
  img.save(outputPath);
  println("Saved sorted image to: " + outputPath);
}

// Diagonal Pixel Sorting with Randomization
void diagonalPixelSort(PImage img, boolean[] edgeMap) {
  float[] brightnessCache = new float[img.pixels.length];
  for (int i = 0; i < img.pixels.length; i++) {
    brightnessCache[i] = brightness(img.pixels[i]);
  }

  for (int d = 0; d < img.width + img.height - 1; d++) {
    int xStart = max(0, d - img.height + 1);
    int yStart = min(d, img.height - 1);
    int length = min(d - xStart, yStart) + 1;
    
    if (random(1) > sortingProbability * noise((xStart + yStart) * 0.1)) continue; // Procedural randomness
    
    color[] diagonalPixels = new color[length];
    for (int i = 0; i < length; i++) {
      int index = (yStart - i) * img.width + (xStart + i);
      if (edgeMap != null && !edgeMap[index]) continue; // Sort only edges
      diagonalPixels[i] = img.pixels[index];
    }

    diagonalPixels = sortPixels(diagonalPixels);
    
    for (int i = 0; i < length; i++) {
      int index = (yStart - i) * img.width + (xStart + i);
      img.pixels[index] = diagonalPixels[i];
    }
  }
}

// Horizontal & Vertical Sorting
void horizontalVerticalPixelSort(PImage img, boolean[] edgeMap) {
  for (int y = 0; y < img.height; y++) {
    if (random(1) > sortingProbability) continue;
    
    color[] rowPixels = new color[img.width];
    for (int x = 0; x < img.width; x++) {
      int index = y * img.width + x;
      if (edgeMap != null && !edgeMap[index]) continue;
      rowPixels[x] = img.pixels[index];
    }
    
    rowPixels = sortPixels(rowPixels);
    
    for (int x = 0; x < img.width; x++) {
      int index = y * img.width + x;
      img.pixels[index] = rowPixels[x];
    }
  }
}

// Sort Pixels Based on Chosen Mode
color[] sortPixels(color[] pixels) {
  Integer[] indices = new Integer[pixels.length];
  for (int i = 0; i < pixels.length; i++) indices[i] = i;

  if (reverseSorting) {
    Arrays.sort(indices, (a, b) -> Float.compare(getSortingValue(pixels[b]), getSortingValue(pixels[a])));
  } else {
    Arrays.sort(indices, (a, b) -> Float.compare(getSortingValue(pixels[a]), getSortingValue(pixels[b])));
  }
  
  color[] sortedPixels = new color[pixels.length];
  for (int i = 0; i < pixels.length; i++) sortedPixels[i] = pixels[indices[i]];
  
  return sortedPixels;
}

// Get Sorting Value Based on User Choice
float getSortingValue(color c) {
  switch (sortingMode) {
    case "hue": return hue(c);
    case "red": return red(c);
    case "green": return green(c);
    case "blue": return blue(c);
    case "saturation": return saturation(c);
    case "luminance": return (red(c) * 0.299 + green(c) * 0.587 + blue(c) * 0.114);
    default: return brightness(c);
  }
}

// Edge Detection (Sobel Filter)
boolean[] detectEdges(PImage img) {
  boolean[] edgeMap = new boolean[img.pixels.length];
  PImage grayImg = img.copy();
  grayImg.filter(GRAY);
  grayImg.loadPixels();
  
  int w = img.width;
  int h = img.height;
  int[][] sobelX = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
  int[][] sobelY = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      float gx = 0, gy = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int pixelIndex = (y + i) * w + (x + j);
          float intensity = brightness(grayImg.pixels[pixelIndex]);
          gx += intensity * sobelX[i + 1][j + 1];
          gy += intensity * sobelY[i + 1][j + 1];
        }
      }
      
      float edgeValue = sqrt(gx * gx + gy * gy);
      edgeMap[y * w + x] = edgeValue > edgeThreshold; // Threshold for edges
    }
  }
  return edgeMap;
}
