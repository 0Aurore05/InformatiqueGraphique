/*
 >Q1 : dessiner joli segment rond pour serpent
 >Q2 : dessiner visage serpent (yeux, langue, etc.)
 >Q3 : materialiser bordure de scroll (carre)
 >Q4 : dessiner joli "noisette" ou "gland" pour nourriture
 >Q5 : dessiner un terrain selon perlin
 -------------------------------------- 
 Q6 : dessiner serpent "lumineux" quand "acceleration" avec la touche espace
 Q7 : animation a la mort (mieux que le game-over qui rapetisse)
 Q8 : animation au repas 
 >Q9 : dessiner l'ombre d'un quadricoptere au centre du plateau de jeu
 >Q10 : tableau des vainqueurs 
 --------------------------------------
 */

float time = 0;

// variables globales
PImage img1, img2;
boolean merge = false;
Snake snakes[];
int TerrX     = 40;
int TerrY     = 40;

int gaussR = 11; //flou de l'ombre au milieu (+/+ -> +/+flou et étendu)(0:aucun flou)
float gauss[][];
int panX = 0; //place d'apparition des autres serpents au lancement (0:centré dans le carré )
int panY = 0;

int state = 1;

int BORDER_SIZE = 200; //espace entre bords de la fenêtre et bords du carré au milieu
String names[]={"Fred", "Nicolas", "Yacine", "Olivia", "Medhi", "Christian", "Laura"};

ArrayList foods; 

// on regroupe les variables d'un serpent dans une structure
class Snake {
  ArrayList pos;
  int size = 16;
  int weight = 160;
  float dirX = 10;
  float dirY = 0;
  float speed = 10; //vitesse des autres serpents
  float r, g, b;
  String name;
  Snake(String name0, int size0, int x0, int y0, int r0, int g0, int b0, float dirX0, float dirY0) {
    r=r0;
    g=g0; 
    b=b0;

    name = name0;
    dirX = dirX0;
    dirY = dirY0;

    size = size0;
    pos = new ArrayList();
    for (int i = size; i>=0; i--) {
      Point s = new Point(x0+i*dirX, y0+i*dirY);
      pos.add(s);
    } 

    setWeight(size*10); //+élevé, +serpents gros (+gros à l'avant)
  }

  void setWeight(int weight1) {
    weight = weight1;
    for (int i = size; i>=0; i--) {
      Point s = (Point)pos.get(i);
      s.r = 10+sqrt((weight-39))/4.0; //taille des boules du corps
      if (i==1) s.r-=2;
      if (i==2) s.r--;
    }

    int acc = 8; //gère diminution de la taille des boules à la fin du corps
    for (int i = pos.size()-1; i>=3; i--) {
      Point s  = (Point)pos.get(i);
      if (acc<s.r)
        s.r = acc;
      acc+=1;
    }
  }
}


// une autre structure pour representer les segments de serpent ou les boules de nourriture 
class Point {
  float x; 
  float y;
  float r;
  Point (float x0, float y0) {
    x = x0;
    y = y0;
    r = 10;
  }
}


Point newFood() {
  float a = random(0, 10000)*PI/5000; //angle d'apparition nourriture sur cercle (10: ~concentré sur ligne/1000:sur une part de pizza, etc, zone +/+ large)
  float d = random(0, 5000); //rayon du cercle de zone d'apparition de nourriture

  Point p = new Point(d*cos(a), d*sin(a)); //zone d'apparition de la nourriture
  p.r = random(1, 5); //taille de la nourriture
  return p;
}



void setup() {  // this is run once.       
  size(1024, 1024); 

  snakes = new Snake[6]; 
  for (int k=1; k<snakes.length; k++) {
    snakes[k] = new Snake(names[k], 4+10*(k-1), width/2+(int)(300*cos(k*PI/3)), height/2+(int)(300*sin(k*PI/3)), 128+64*(k%3), 255*(k%2), 0, 10*cos((k+2)*PI/3), 10*sin((k+2)*PI/3));
  } //2e valeur:longueur /3e-4e:change zone apparition/5e-6e-7e:couleur/8e-9e:éloignement % aux autres et leurs propre corps

  foods = new ArrayList();
  for (int k=0; k<1000; k++) {
    foods.add(newFood());
  }

  gauss = new float[gaussR][gaussR];
  for (int k=0; k<gaussR; k++)
    for (int l=0; l<gaussR; l++)
      gauss[k][l] = exp(-1.0/gaussR/gaussR*((k-gaussR/2)*(k-gaussR/2)+(l-gaussR/2)*(l-gaussR/2)));

  // 2 images
  img1 = createImage(64, 64, ARGB); //(w,h,format), boules du jeu
  img2 = createImage(64+gaussR, 64+gaussR, ARGB);

  // Q1 un dessin de cercle dans la premiere image
  for (int j=0; j < img1.height; j++) {
    for (int i=0; i < img1.width; i++) {
      // forme des ronds du jeu (corps serpents et ombre au milieu)
      float d0 = dist(i, j, img1.width/2, img1.height/2);
      float d1 = dist(i, j, img1.width/4, img1.height/4);
      if (d0<img1.width/2-1) { //si i,j à une certaine distance du milieu-1 de img1
        img1.pixels[i+j*img1.width] = color(270-(d1*3)); //couleurs des serpents (0: noir et 255: couleurs)
      }
    }
  }

  // l'ombre du cercle dans la 2ieme image
  for (int j=0; j < img1.height; j++) {
    for (int i=0; i < img1.width; i++) {
      float c = alpha(img1.pixels[i+j*img1.width]);
      for (int k=0; k<gaussR; k++) {
        for (int l=0; l<gaussR; l++) {
          img2.pixels[i+l+(j+k)*img2.width] += c*gauss[k][l]; //à partir de ~*700, ombre disparaît sauf flou autout, puis flou -/- épais (~1000), puis ronds (2/3) en transparence
        }
      }
    }
  }
  int ma = img2.pixels[img2.width/2+img2.height/2*img2.width]; //si on le multiplie par un int, ombre de moins en moins obscure
  for (int j=0; j < img2.height; j++) {
    for (int i=0; i < img2.width; i++) {
      int value= img2.pixels[i+j*img2.width]; //ombre noire si on le multiplie par un int, plus d'ombre si on le divise par un int
      img2.pixels[i+j*img2.width] = color(0, 128*value/ma); // +/-128 -> ombre +/- foncée
    }
  }

  img1.updatePixels();
  img2.updatePixels();

  frameRate(25); //images par seconde
} 


void moveSnake(Snake s, float objx, float objy) {
  Point p0 = (Point) s.pos.get(0);
  Point pn = (Point) s.pos.get(s.pos.size()-1);

  float dd = dist(p0.x, p0.y, objx, objy);
  float tx = objx;
  float ty = objy;
  if (dd>s.speed) {
    tx = p0.x+(objx-p0.x)/dd*s.speed;
    ty = p0.y+(objy-p0.y)/dd*s.speed;
  }
  if (dd>0) {
    s.dirX = (objx-p0.x)/dd*s.speed;
    s.dirY = (objy-p0.y)/dd*s.speed;
  }

  // si on va "vite" on seme de la nourriture derriere soi et on perd du poids
  if (s.speed>10) {
    s.setWeight(s.weight -2); //change facteur de diminution pdt sprint (+elevé, +on rapetissit pdt sprint (ou disparait si trop élevé))
    Point f = new Point(pn.x, pn.y);
    f.r = 1; //change taille des boules éjectées pdt un sprint
    foods.add(f);

    if (s.weight<10*s.size) {
      s.size--;
      s.pos.remove(s.pos.size()-1);
    }
    if (s.weight<42) {
      s.speed=10; //change vitesse de sprint
    }
  }

  // deplace chaque segment du serpent
  float tlen = 0; //change vitesse du serpent, + élevé --> +lent jusqu'à immobile(~10)
  for (int i = 0; i<s.pos.size(); i++) {
    Point p = (Point) s.pos.get(i);
    float len = dist(p.x, p.y, tx, ty);
    if (len > tlen) {
      p.x = tx-(tx-p.x)*tlen/len;
      p.y = ty-(ty-p.y)*tlen/len;
    }
    tx = p.x; //si *int, boules confondues à width/2 et s'éloignent de +/+ à droite/gauche selon déplacement en x
    ty = p.y; //pareil mais pour height/2 et en y
    tlen = 10; //change distance entres parties du serpent : 0->confondues, +augmente, +éloignées)
  }
}


boolean testCollision(Snake s) {
  Point p0 = (Point)s.pos.get(0);
  Point pn = (Point)s.pos.get(s.pos.size()-1);

  for (int i=0; i<snakes.length; i++) {
    Snake other = snakes[i];
    if (other!=null && other!=s) {
      for (int k=0; k<other.pos.size(); k++) {
        Point p = (Point)other.pos.get(k);
        float dd = dist(p.x, p.y, p0.x, p0.y);
        if (dd<p0.r+p.r) {
          return true;
        }
      }
    }
  }

  for (int k=foods.size()-1; k>=0; k--) {
    Point f = (Point)foods.get(k);
    float dd = dist(p0.x, p0.y, f.x, f.y);
    if (dd < p0.r+f.r) {
      s.setWeight(s.weight +(int)f.r);
      if (s.weight>10*s.size) {
        s.size++;
        Point p = new Point(pn.x, pn.y);
        p.r= 8;
        s.pos.add(p);
      }

      foods.remove(k);
    }
  }
  return false;
}


void drawSnake(Snake s) {
  for (int i = s.pos.size()-1; i >= 0; i--) { //corps +/- condensé au départ
    Point p = (Point) s.pos.get(i);
    pushMatrix();
    translate( p.x-panX, p.y-panY);
    if (i==0) {
      rotate(atan2(s.dirY, s.dirX));
      stroke(0); //couleur du carré autour de l'ombre
      strokeWeight(0.8); //épaisseur
      //Q2 dessin dessous
      pushMatrix();
      scale(2.2*p.r/img1.width, 2.0*p.r/img1.width); //change forme têtes
    } else 
    scale(2.0*p.r/img1.width); //change taille corps

    if (i%2==0) {
      if (s.speed>10) {
        //image(img3, 0,0);
        tint(s.r, s.g, s.b);
        image(img1, 0, 0);
        noTint();
      } else {
        //image(img2, 0,0);
        tint(s.r/2, s.g/2, s.b/2);
        image(img1, 0, 0);
        noTint();
      }
    } else {
      if (s.speed>10) {
        //image(img3, 0,0);
        tint(255-(255-s.r)/2, 255-(255-s.g)/2, 255-(255-s.b)/2);
        image(img1, 0, 0);
        noTint();
      } else {
        //image(img2, 0,0);
        tint(s.r, s.g, s.b);
        image(img1, 0, 0);
        noTint();
      }
    }

    if (i==0) {
      popMatrix();

      //dessin tête
      translate(-2, 14);
      scale(0.05);
      rotate(-PI/2);
      strokeWeight(1);

      strokeWeight(1);
      stroke(0);
      fill(255);
      bezier(100, 150, 200, 100, 250, 150, 250, 200);
      bezier(500, 150, 400, 100, 350, 150, 350, 200);

      fill(0);
      circle(195, 170, 75);
      circle(405, 170, 75);

      fill(255);
      circle(180, 160, 20);
      circle(390, 160, 20);

      translate(-5, -80);
      scale(10);
      stroke(100, 0, 0);
      strokeWeight(2);
      line(img1.width/2, 35, img1.width/2, 50);
      strokeWeight(0);
      line(img1.width/2, 50, 25, 60);
      line(img1.width/2, 50, 39, 60);

      //Q2 dessin dessus
    }
    popMatrix();
  }


  Point p = (Point) s.pos.get(0);  
  fill(0); //ombre des noms en noir (0)
  textSize(14); //taille de police
  text(s.name+" "+(s.weight-30), p.x-panX, p.y-panY);
  fill(255); //noms en blanc par dessus leur ombre
  text(s.name+" "+(s.weight-30), p.x-panX-1, p.y-panY-1);
}

float t=0;
// Q5
void drawBg() {
      background(170, 255, 0); //couleur du background (sans les ronds)
      noStroke(); //pas de contour noir autour des ronds du background
      for (int j=-panY%20-20; j<=height; j+=20) {
        for (int i=-panX%20-20; i<=width; i+=20) {
          fill(130-100*noise(i+panX, j+panY, t), 230-50*noise(i+panX, j+panY, t), 5+2*noise(i+panX, j+panY, t)); //couleur des ronds du background
          beginShape();
          float RR=(20*(noise(i+panX, j+panY, t)+0.15));
          for (int k=0; k<6; k++) {
            vertex(((((((j+panY)/20)%2)*10+i)+RR*cos(k*(PI/3)))), (j+RR*sin(k*(PI/3))));
          }
          endShape(CLOSE);
          //ellipse(((((j+panY)/20)%2)*10+i), j, 18, 18); //leur forme
        }
        t=t+0.00015;
      }
  }

  int k=0; //pour l'helico (Q°9)
  float Px, Py; //pour la Q°7

  void draw() {  // this is run repeatedly.  

    drawBg(); //empêche de faire tout glitcher (que images précédentes ne restent pas affichées)

    textAlign(CENTER, CENTER); //empêche que acceuile & noms décentrés
    imageMode(CENTER); //empêche que tête détachée du corps

    if (snakes[0]!=null) { //avoir la position de notre serpent (Q°7)
      Px = ((Point)snakes[0].pos.get(0)).x;
      Py = ((Point)snakes[0].pos.get(0)).y;
    }

    if (state==1) {
      fill(0); //couleur du message d'acceuil
      textSize(20); //sa taille
      text("Appuyer sur une touche pour commencer", width/2, height/2);
      return;
    } else if (state>1) {
      drawBg();

      fill(0); //couleur game over
      textSize(20+state*2); // sa taille
      text("Game OVER", width/2, height/2); 
      state--; //fait diminuer le texte du game over
    } else {
      moveSnake(snakes[0], mouseX+panX, mouseY+panY);
      // si la position du serpent s'approche du bord, on prefere scoller le jeu plutot que de laisser
      // le serpent s'approcher su bord
      Point p = (Point)snakes[0].pos.get(0);
      if (p.x-panX>width-BORDER_SIZE) //bord droit
        panX = round(p.x-width+BORDER_SIZE); //si =0 , peut dépasser bord droit du carré et ne fait pas avancer écran 
      if (p.x-panX<BORDER_SIZE) //bord gauche
        panX = round(p.x-BORDER_SIZE); 
      if (p.y-panY>height-BORDER_SIZE) //bord bas
        panY = round(p.y-height+BORDER_SIZE);
      if (p.y-panY<BORDER_SIZE) //bord haut
        panY = round(p.y-BORDER_SIZE);
    }

    if (snakes[0]!=null && testCollision(snakes[0])) {
      for (int i=0; i<snakes[0].pos.size(); i++) {
        Point m = (Point)snakes[0].pos.get(i);
        m.r = 10;
        if (i%2==0) foods.add(m);
      }
      snakes[0] = null;
      state = 20;
    }



    // deplace les autres serpents de maniere aleatoire
    for (int k=1; k<snakes.length; k++)
      if (snakes[k]!=null) {
        float dx = snakes[k].dirX;
        float dy = snakes[k].dirY;
        float x = ((Point)snakes[k].pos.get(0)).x;
        float y = ((Point)snakes[k].pos.get(0)).y;
        float dd = dist(0, 0, x, y);

        float ndx = random(10.0, 15)*dx + random(-8, 8)*dy; 
        float ndy = random(10.0, 15)*dy - random(-8, 8)*dx; 
        if (dd>1000) {
          ndx += -x*(dd-1000)/dd;
          ndy += -y*(dd-1000)/dd;
        }

        moveSnake(snakes[k], x+ndx, y+ndy);
        if (testCollision(snakes[k])) {
          for (int i=0; i<snakes[k].pos.size(); i++) {
            Point m = (Point)snakes[k].pos.get(i);
            m.r = 10;
            if (i%2==0) foods.add(m);
          }
          snakes[k] = new Snake(names[k], 4, (int)random(1000), (int)random(1000), 128+64*(k%3), 255*(k%2), 0, 10*cos(k*PI/3), 10*sin(k*PI/3));
        }
      }


    for (int k=0; k<foods.size(); k++) {
      Point f = (Point)foods.get(k);
      pushMatrix();
      translate(f.x-panX, f.y-panY); //si enlève panX, la nourriture bouge en x avec nous
      scale(0.1+sqrt(f.r)/5.0); //taille de la nourriture 
      //Q4
      //noisettes
      strokeWeight(1);
      scale(0.3);

      //noix
      fill(230, 150, 50);
      beginShape();
      vertex(10, 50);
      bezierVertex( 0, 100, 0, 120, 50, 150);
      vertex(50, 150);
      bezierVertex(110, 120, 110, 120, 100, 50);
      line(100, 50, 10, 50);
      endShape();

      //ombre
      noStroke();
      fill(190, 110, 30);
      beginShape();
      vertex(10, 50);
      bezierVertex( 0, 100, 0, 120, 50, 150);
      vertex(50, 150);
      bezierVertex(15, 120, 15, 100, 25, 50);
      vertex(25, 50);
      endShape();

      stroke(0);
      noFill();
      bezier(10, 50, 0, 100, 0, 120, 50, 150);

      //chapeau
      fill(150, 80, 45);
      beginShape();
      vertex(5, 50);
      bezierVertex(50, 60, 50, 60, 105, 50);
      vertex(105, 50);
      bezierVertex(90, 20, 90, 20, 50, 30);
      vertex(50, 30);
      bezierVertex(20, 20, 20, 20, 5, 50);
      endShape();

      //ombre du chapeau
      noStroke();
      fill(105, 50, 25);
      beginShape();
      vertex(5, 50);
      bezierVertex(20, 20, 20, 20, 50, 30);
      vertex(50, 30);
      bezierVertex(30, 30, 30, 30, 30, 55);
      endShape();

      stroke(0);
      noFill();
      bezier(50, 30, 20, 20, 20, 20, 5, 50);

      //tige
      fill(150, 80, 45);
      beginShape();
      vertex(48, 30);
      vertex(46, 10);
      vertex(56, -10);
      vertex(72, -5);
      vertex(56, 13);
      vertex(53, 30);
      endShape();

      //ombre tige
      noStroke();
      fill(105, 50, 25);
      beginShape();
      vertex(72, -5);
      vertex(60, -5);
      vertex(50, 13);
      vertex(48, 30);
      vertex(46, 10);
      vertex(56, -10);
      endShape();

      stroke(0);
      noFill();
      line(72, -5, 56, -10);
      line(56, -10, 46, 10);
      line(46, 10, 48, 30);

      noStroke();
      fill(255);
      ellipse(90, 95, 10, 35);

      popMatrix();
    }

    for (int k=0; k<snakes.length; k++) {
      if (snakes[k]!=null)
        drawSnake(snakes[k]);
    }

    noFill();
    stroke(0, 128);
    //Q3 
    translate(width/2, height/2);

    int r1=440;
    int r2=825;
    int rc1= 600;        //r de la position du pt de contrôle 1
    int rc2= 480;        // '' pt de contrôle 2
    float k=(2*PI)/50;   //incrément angle
    int l = 13;          //nombre de ligne par feuille

    strokeWeight(1);
    for (float a=0; a<=PI*2; a=a+k) {
      for (float i=0; i<=k; i=i+k/l) {
        stroke(0, 130, 90, 200);
        float x1, y1; //pt de convergence des lignes d'une feuille
        x1= r1*cos(a+k/2);
        y1= r1*sin(a+k/2);
        //fill(255-20*noise(a), 255-50*noise(a,i), 0, 20);
        bezier(r2*cos(a+i), r2*sin(a+i), 
          rc1*cos(a+5*noise(a, i)*i), rc1*sin(a+5*noise(a, i)*i), 
          rc2*cos(a+2*noise(a, i)*i), rc2*sin(a+2*noise(a, i)*i), 
          (noise(time, a, i*2)/2+0.7)*x1, (noise(time, a, i*2)/2+0.7)*y1);
        //line(r2*cos(a+i), r2*sin(a+i), x1, y1
      }
      for (float j=k/2; j<=k+k/2; j=j+k/l) {
        float x2, y2; //idem décalé
        x2= r1*cos(a+k);
        y2= r1*sin(a+k);
        stroke(0, 100, 0, 200);
        //fill(255-30*noise(a), 255-60*noise(a,j), 0, 30);
        bezier(r2*cos(a+j), r2*sin(a+j), 
          rc1*cos(a+5*noise(a, j)*j), rc1*sin(a+5*noise(a, j)*j), 
          rc2*cos(a+2*noise(a, j)*j), rc2*sin(a+2*noise(a, j)*j), 
          (noise(time, a, j*2)/2+0.7)*x2, (noise(time, a, j*2)/2+0.7)*y2);
        //line(r2*cos(a+j), r2*sin(a+j), x2, y2);
      }
    }
    time=time+0.03;

    translate(-width/2, -height/2);
    noStroke();
    fill(0, 100);
    int xa = BORDER_SIZE;
    int ya = BORDER_SIZE+(624/3)+50;
    int yb = BORDER_SIZE+((2*624)/3)-50;
    int xc = BORDER_SIZE/2+50;
    int yc = (yb+ya)/2;
    triangle(xa, ya, xa, yb, xc, yc); //gauche
    //triangle(xa+50, xa, xa, xa+50, xa, xa);
    triangle(ya, xa, yb, xa, yc, xc); //haut
    //triangle(width-xa-50, xa, width-xa, xa+50, width-xa, xa);
    triangle(width-xa, ya, width-xa, yb, width-xc, yc); //droit
    //triangle(width-xa, height-xa-50, width-xa-50, height-xa, width-xa, height-xa);
    triangle(ya, height-xa, yb, height-xa, yc, height-xc); //bas
    //triangle(xa, height-50-xa, xa+50, height-xa, xa, height-xa); 


    // Q9 quadricoptere
    pushMatrix(); //saves the current coordinate system to the stack
    scale(0.2);
    translate(2050, 2400);
    noStroke();
    fill(0, 100);

    beginShape(); //moitié droite
    vertex(width/2, 5);
    bezierVertex(width/2+40, 20, width/2+40, 40, width/2+50, 200);
    vertex(width/2+50, 200);
    bezierVertex(width/2+50, 260, width/2+50, 280, width/2+10, 300);
    vertex(width/2+10, 300); 

    //queue de l'helico
    vertex(width/2+5, 450);
    vertex(width/2+55, 455);
    vertex(width/2+55, 465);
    vertex(width/2+5, 465);
    vertex(width/2, 500);
    vertex(width/2-5, 465);
    vertex(width/2-55, 465);
    vertex(width/2-55, 455);
    vertex(width/2-5, 450);
    vertex(width/2-10, 300);

    vertex(width/2-10, 300); //moitié gauche
    bezierVertex(width/2-50, 280, width/2-50, 260, width/2-50, 200);
    vertex(width/2-50, 200);
    bezierVertex(width/2-40, 40, width/2-40, 20, width/2, 5);
    endShape();

    //pales de l'helico 
    strokeWeight(10);
    translate(width/2, 100);

    if (k%2 == 0) {
      stroke(0, 100);

      line(-200, -100, -46, -23); //lignes fragmentées de part et d'autres de l'helico
      line(48, 24, 200, 100);
      line(100, -200, 34, -68);
      line(-53, 106, -100, 200);
    } else { //2eme position des pales (rotation 45°) 
      stroke(0, 30);

      line(-200, 100, -48, 24);
      line(44, -22, 200, -100);
      line(-100, -200, -35, -70);
      line( 52, 104, 100, 200);
    }

    translate(-width/2, -100);
    k++;

    translate(-2050, -2400);
    popMatrix(); //restores the prior coordinate system

    //Q10 : tableau de joueur
    //fond noir transparent
    noStroke();
    fill(0, 100);
    rect(3, 3, 120, 95);

    fill(0); //noir en dessous
    for (int s=0; s<snakes.length; s++) {
      text(names[s], 40, 9+15*s);
      if (snakes[s]!=null) {
        text(snakes[s].weight-30, 99, 9+15*s);
      } else {
        text("0", 99, 9+15*s);
      }
    }
    fill(255); //lettres blanches au dessus
    for (int s=0; s<snakes.length; s++) {
      text(names[s], 39, 10+15*s);
      if (snakes[s]!=null) {
        text(snakes[s].weight-30, 100, 10+15*s);
      } else {
        text("0", 100, 10+15*s);
      }
    }
  }

  void keyPressed() { //appuyer pour lancer le jeu
    if (state>0) {
      snakes[0] = new Snake(names[0], 4, width/2, height/2, 0, 255, 0, 10, 0); 
      state = 0;
    } else if (key==' ' && snakes[0].weight>42)
      snakes[0].speed =20; //vitesse de sprint
  }
  void keyReleased() {
    if (snakes[0]!=null && key==' ')
      snakes[0].speed =10; //vitesse normale
  }
