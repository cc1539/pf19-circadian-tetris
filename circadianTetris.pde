import processing.sound.*;

public TetrisGrid tg;
public int score;
public int lines;
public boolean gameOver;
public int interval = 64;
public boolean keyDown;
public int currentPowerup;
public int maxPowerups = 0;
public boolean day;
public PImage sun;
public PImage moon;
public PImage stars;

public int[][][] pieces = new int[][][]{
  {{4,0},{3,0},{5,0},{6,0}},
  {{4,0},{5,0},{4,1},{5,1}},
  {{4,0},{5,0},{3,0},{3,1}},
  {{4,0},{5,0},{4,1},{3,1}},
  {{4,0},{5,0},{3,0},{4,1}},
  {{4,0},{3,0},{4,1},{5,1}},
  {{4,0},{5,0},{3,0},{5,1}},
};

public void drawStandalone(int[][] piece, int xoffset, float x, float y, float w, float h)
{
  for(int i=0;i<piece.length;i++) {
    rect(x+w*(piece[i][0]-xoffset),y+h*piece[i][1],w,h);
  }
}

public void setup()
{
  size(480,640);
  noSmooth();
  background(255);
  textFont(createFont("courier new bold",12));
  surface.setTitle("Circadian Tetris");
  surface.setResizable(true);
  surface.setIcon(loadImage("icon.png"));
  tg = new TetrisGrid(10,22);
  tg.reset();
  sun = loadImage("sun.png");
  moon = loadImage("moon.png");
  day = true;
  //stars = loadImage("stars.jpg");
  //new SoundFile(this,"24.mp3").play();
}

public void keyPressed()
{
  switch(keyCode) {
    case 'w'-32: case UP   : tg.rotateRight(); /*tg.moveUp   ();*/ break;
      case 's'-32: case DOWN : tg.moveDown (); break;
      case 'a'-32: case LEFT : tg.moveLeft (); break;
      case 'd'-32: case RIGHT: tg.moveRight(); break;
      case 'q'-32: tg.rotateLeft (); break;
      case 'e'-32: tg.rotateRight(); break;
    case 'c'-32:
      tg.clearAll();
      tg.reset();
    break;
    case ' ': tg.shoot(); break;
    case 'r'-32:
      gameOver = false;
      tg.reset();
    break;
  }
  keyDown = true;
}

public void keyReleased()
{
  keyDown = false;
}

public void draw()
{
  if(frameCount<=100) {
    pushMatrix();
    translate(width/2,height/2);
    rotate(-frameCount/100.*TWO_PI);
    translate(-width/2,-height/2);
    noStroke();
    fill(0);
    float expand = 1000;
    rect(-expand,-expand,width+expand*2,height/2+expand);
    fill(255);
    rect(-expand,height/2,width+expand*2,height/2+expand);
    popMatrix();
    fill((frameCount/8%2)==0?255:0);
    textAlign(CENTER,CENTER);
    text("Y O U   D O N ' T   C L E A R   L I N E S",width/2,height/2);
    for(int i=0;i<10;i++) {
      float angle = (frameCount+i/10.)/100.*TWO_PI;
      float dx = sin(angle)*200;
      float dy = cos(angle)*200;
      imageMode(CENTER);
      tint(255,32);
      float radius = 100;
      image(sun,width/2+dx,height/2+dy,radius,radius);
      image(moon,width/2-dx,height/2-dy,radius,radius);
    }
    tint(255);
  } else {
    //background(255);
    if(gameOver) {
      background(0);
      textAlign(CENTER,CENTER);
      fill(255);
      text("lol u lost\nu got "+score+" points\npress 'r' to restart",width/2,height/2);
    } else {
      noStroke();
      float time = sin(frameCount/300.);
      if(day!=(day=time>0)) {
        tg.changing = 0;
      }
      fill(time*128+128,128);
      rect(0,0,width,height);
      float dx = -time*height;
      float dy = -cos(frameCount/300.)*height;
      imageMode(CENTER);
      image(sun,width/2+dx,height*2+dy);
      image(moon,width/2-dx,height*2-dy);
      float w = 200;
      float h = 400;
      float x = (width-w)/2-50;
      float y = (height-h)/2;
      tg.draw(x,y,w,h);
      tg.propagateWave();
      if(frameCount%interval==0) {
        tg.moveDown();
      }
      textAlign(LEFT,BOTTOM);
      fill(255-(time*128+128));
      //text("SCORE: "+score+"\nLINES CLEARED: "+lines,x,y-6);
      text("SCORE: "+score,x,y-6);
      for(int i=0;i<tg.pieceList.length;i++) {
        noFill();
        stroke(255-(time*128+128),512./(i*3+1));
        drawStandalone(pieces[tg.pieceList[i]],3,x+w+40,y+h/5*(i+.25),20,20);
      }
      if((int)random(0,10)==0) {
        tg.addPowerup();
      }
    }
  }
  
  //saveFrame("movies/####.png");
}
