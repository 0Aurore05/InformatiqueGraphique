void setup() {

  size(600, 600, P3D);

  frameRate(2);

}



void draw() {

  translate (width/2, height/2-50);

  rotateX(PI/3);

  background(255, 192, 255);

  strokeWeight(3);



  int r = 100 ;



  for (int i=-r; i<=r; i++) {

    float a = i/50.0*2*PI;



    beginShape(QUAD_STRIP); 

    for (int j=-r; j<=r; j++) { 

      

      float b = j/50.0*2*PI;

      float R2 = 100-i+(30-i/4)*cos(b);

      float R3 = (30-i/4)*sin(b); 



      strokeWeight(1);

      stroke(255,255,0);

      fill(255, 155+i, 0);



      float a1 = (i+1)/50.0*2*PI;

      vertex(R2*cos(a1), R2*sin(a1), R3+a1*16);

      vertex(R2*cos(a), R2*sin(a), R3+a*16);

    }

    endShape();

  }

}
