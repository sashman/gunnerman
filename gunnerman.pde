

import android.view.*;

int pad_size = 150;
int subpad_size = 50;
int left_spad_x;
int left_spad_y;

int right_spad_x;
int right_spad_y;

int left_xinit;
int left_yinit;
int right_xinit;
int right_yinit;

int outer_t_dx;  //outer analog stick threshold, used to assign multi touch id to analog sticks
int inner_t_dx; //inner analog stick threshhold

int rst; //right sesitivity threshold
int left_dx,right_dx; //actual distance from the centre of the analog stick

Player player;
GameMap game_map;


void setup() {
  game_map = new GameMap();
  game_map.loadMap("map0");
  player = new Player(width/2, height/2, game_map);
  
  left_xinit = (int)(pad_size/1.5);
  left_yinit = height-(int)(pad_size/1.5);
  right_xinit = width-(int)(pad_size/1.5);
  right_yinit = height-(int)(pad_size/1.5);
  
  left_spad_x = left_xinit;
  left_spad_y = left_yinit;
  right_spad_x = right_xinit;
  right_spad_y = right_yinit;
  //left_spad_x = 100;
  //left_spad_y = 100;
  
  
  outer_t_dx = (pad_size);
  inner_t_dx = (pad_size/2);
  
  rst = (pad_size/4);
  
  size(800, 480);
  smooth();
}

void draw() {
  
  background(240);
  
  
  if (mousePressed) {
    
  } else {
    
  }
  
  
  player.render();
  game_map.render();
  draw_controls();
  
  /*
  ellipse(mouseX, mouseY, 80, 80);
  */
}


public void draw_controls(){
  ellipse((pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(width-(pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(left_spad_x, left_spad_y, subpad_size,subpad_size);
  ellipse(right_spad_x, right_spad_y, subpad_size,subpad_size);
}


public boolean surfaceTouchEvent(MotionEvent me) {
  boolean reset_left = true;
  // Number of places on the screen being touched:
  int numPointers = me.getPointerCount();
  for(int i=0; i < numPointers; i++) {
    int pointerId = me.getPointerId(i);
    int x = (int)me.getX(i);
    int y = (int)me.getY(i);
    left_dx = (int)sqrt((int)(pow(left_xinit-x, 2) + (int)pow(left_yinit-y, 2)));  
    right_dx  = (int)sqrt((int)(pow(right_xinit-x, 2) + (int)pow(right_yinit-y, 2)));  
    
    //find out which analog stick the event corrsponds to
    if(outer_t_dx > left_dx){
      //left analog
      if(inner_t_dx > left_dx){
        left_spad_x = x;
        left_spad_y = y;
        reset_left = false;
      }
      player.moveXY((x - left_xinit)/10, (y - left_yinit)/10);
    } else if(outer_t_dx > right_dx){
      //right analog
      if(inner_t_dx > right_dx){
         right_spad_x = x;
         right_spad_y = y;
         player.dir = atan2(x-right_xinit,y-right_yinit);
      }
    }
    
    if(reset_left){
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
    }
  }
  return super.surfaceTouchEvent(me);
}

