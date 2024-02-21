void setup() {
  size(600, 300);
}

int R=0;
int G=0;
int B=0;

//essai à la con pour changer valeurs de RGB du background selon endroit où on appuie (en haut:+/en bas:-)

void draw() {
  background(R, G, B);

  stroke(0);
  line(200, 0, 200, height);
  line(400, 0, 400, height);
  line(0, 150, width, 150);
  stroke(255);
  line(201, 0, 201, height);
  line(401, 0, 401, height);
  line(0, 151, width, 151);

  fill(255, 0, 0);
  circle(100, 150, 20);
  fill(0, 255, 0);
  circle(300, 150, 20);
  fill(0, 0, 255);
  circle(500, 150, 20);

  fill(0);
  text(R, 100, 20);
  text(G, 300, 20);
  text(B, 500, 20);

  fill(255);
  text(R, 99, 19);
  text(G, 299, 19);
  text(B, 499, 19);
}

void mousePressed() {
  if (mouseX < 200) {
    if (mouseY<150) {
      if (R!=250) {
        R=R+10;
      }
    } else {
      if (R!=0) {
        R=R-10;
      }
    }
  } else if (mouseX <400) {
    if (mouseY<150) {
      if (G!=250) {
        G=G+10;
      }
    } else {
      if (G!=0) {
        G=G-10;
      }
    }
  } else {
    if (mouseY<150) {
      if (B!=250) {
        B=B+10;
      }
    } else {
      if (B!=0) {
        B=B-10;
      }
    }
  }
}
/*trucs à rajouter :
VOIR MOUSEWHEEL() POUR AUGMENTER COULEUR QUAND WHEEL VERS LE HAUT ETC
 quand on appuie dans zone de cercle, revient à 0
 si je suis chaud un jour, faire un système de frise et d'ajout plus précis 
 */
