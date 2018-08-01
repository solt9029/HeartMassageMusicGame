import processing.serial.*;
import ddf.minim.*;
import ddf.minim.effects.*;

Serial myPort;

Minim minim;
AudioPlayer music;
AudioSample dong;

boolean isStarted = false;
final int BPM = 190;
final int OFFSET = 50;
final int NPM = BPM * 4; // 1分間に流れるノーツの数
final float MPN = 60000.0 / (float)NPM; // ノート1個が流れるのに要する時間（ミリ秒）
int [] notes = {
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
};
int [] hits; // 1がGreat・2がGood・3がBad
String judge = "";
int judgeTime = 0;


PImage img;

void setup() {
  
  myPort = new Serial(this, Serial.list()[0], 9600);
  size(1000, 1200);
  background(255);
  minim = new Minim(this);
  music = minim.loadFile("music.mp3");
  music.setGain(-15);
  hits = new int [notes.length];
  dong = minim.loadSample("dong.wav");
  
  
  img = loadImage("heart.jpg");
  
  textSize(200);
}

void draw() {
  if (!isStarted) {
    return;
  }
  
  background(255);
  line (0, 1000, width, 1000);
  int notePosition = getNotePosition();
  for (int i = notePosition - 10; i < notes.length; i++) {
    if (i >= 0 && notes[i] > 0 && hits[i] == 0) {
      image(img, 400, 1000 - 80 - (i - notePosition) * 20);
    }
  }
  
  if (judgeTime < 10) {
    if (judge.equals("Bad")) {
      fill(0,0,255);
    } else {
      fill(255,0,0);
    }
    text(judge, 300, 1000);
    judgeTime++;
  } else {
    judge = "";
  }
  
  // 2個前でまだヒットされていなかったらBadとする
  //int notePosition = getNotePosition();
  if (notePosition - 2 >= 0) {
    if (notes[notePosition - 2] > 0 && hits[notePosition - 2] == 0) {
      hits[notePosition - 2] = 3;
      judge = "Bad";
      judgeTime = 0;
    }
  }
  
}

int getNotePosition() {
  int notePosition = 0;
  if (int((music.position() - OFFSET) / MPN - 0.5) >= 0) {
    notePosition = int((music.position() - OFFSET) / MPN - 0.5);
  }
  return notePosition;
}

void keyPressed() {
  dong.trigger();
  int notePosition = getNotePosition();
  for (int rangeIndex = -1; rangeIndex <= 1; rangeIndex++) {
    if (notePosition + rangeIndex >= 0 && notePosition + rangeIndex < notes.length) {
      if (notes[notePosition + rangeIndex] == 1 && hits[notePosition + rangeIndex] == 0) {
        hits[notePosition + rangeIndex] = 1 + abs(rangeIndex);
        if (1 + abs(rangeIndex) == 1) {
          judge = "Great!";
          judgeTime = 0;
          //fill(255, 0, 0);
          //textMode(CENTER);
          //text("Great!", 200 + (notes[notePosition + rangeIndex] - 1) * 400, 1000);
        } else if (1 + abs(rangeIndex) == 2) {
          judge = "Good!";
          judgeTime = 0;
          //fill(255, 0, 0);
          //textMode(CENTER);
          //text("Good!", 200 + (notes[notePosition + rangeIndex] - 1) * 400, 1000);
        }
        break;
      }
    }
  }
  
  if (keyCode == 32) {
    if (!isStarted) {
      music.play();
      isStarted = true;
    }
  }
  
}

void serialEvent(Serial p) {
    dong.trigger();
  int notePosition = getNotePosition();
  for (int rangeIndex = -1; rangeIndex <= 1; rangeIndex++) {
    if (notePosition + rangeIndex >= 0 && notePosition + rangeIndex < notes.length) {
      if (notes[notePosition + rangeIndex] == 1 && hits[notePosition + rangeIndex] == 0) {
        hits[notePosition + rangeIndex] = 1 + abs(rangeIndex);
        if (1 + abs(rangeIndex) == 1) {
          judge = "Great!";
          judgeTime = 0;
          //fill(255, 0, 0);
          //textMode(CENTER);
          //text("Great!", 200 + (notes[notePosition + rangeIndex] - 1) * 400, 1000);
        } else if (1 + abs(rangeIndex) == 2) {
          judge = "Good!";
          judgeTime = 0;
          //fill(255, 0, 0);
          //textMode(CENTER);
          //text("Good!", 200 + (notes[notePosition + rangeIndex] - 1) * 400, 1000);
        }
        break;
      }
    }
  }
}

void stop() {
  music.close();
   dong.stop();
  minim.stop();
 
  super.stop();
}

 