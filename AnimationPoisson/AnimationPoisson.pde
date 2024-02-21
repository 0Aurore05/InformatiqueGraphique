int i = 0;
PImage[] imgs;

void setup() {
    size(400, 400);
    imgs = new PImage[23];
    for (i=1; i<24; i++) {
      imgs[i-1]= loadImage("fish00"+(i<10?"0":"")+i+".png");
    }

    // remet le compteur a 0
    i=0;
    int v=10;
frameRate(v);
}

void draw() {
    background(0, 0, 128);
    image(imgs[i%23], 0, 0);                          // normal
    //image(imgs[(i/2)%23], width/2, 0);                //ralenti
    //image(imgs[22-i%23], 0, height/2);                //à l'envers
    //image(imgs[abs((i%23)*2-22)], width/2, height/2); //dans les 2 sens
    i++; // incremente le compteur
}
