void setup() {
  size(600, 600, P3D);
  frameRate(2);
}


void draw() {
  translate (width/2, height/2);
  rotateX(PI/3);
  background(255, 192, 255);
  strokeWeight(3);

  int r = 100 ;

  for (int i=-r; i<=r; i++) {
    float a = i/50.0*2*PI;

    beginShape(QUAD_STRIP); //EXO 2
    for (int j=-r; j<=r; j++) { 
      
      float b = j/50.0*2*PI; 
      float R2 = 100+50*cos(b); 
      float R3 = 50*sin(b); 

      stroke(0, 255, 0);

      //EXO 1
      float a1 = (i+1)/50.0*2*PI; //EXO 4

      // vertex(R2*cos(a1), R2*sin(a1), R3);
      // vertex(R2*cos(a), R2*sin(a), R3);

      //EXO 5
      vertex(R2*cos(a1), R2*sin(a1), R3+a1*16);
      vertex(R2*cos(a), R2*sin(a), R3+a*16);
    }
    endShape();
  }
}
