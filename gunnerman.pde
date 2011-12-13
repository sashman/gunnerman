

import android.view.*;

//game states
int current_state;
int START_STATE = 0;
int CONNECT_STATE = 1;
int LOBBY_STATE = 2;
int GAME_STATE = 3;
int SCORE_SCREEN = 4;


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

//player acc
int ax = 0;
int ay = 0;

int outer_t_dx;  //outer analog stick threshold, used to assign multi touch id to analog sticks
int inner_t_dx; //inner analog stick threshhold

int rst; //right sesitivity threshold
int left_dx,right_dx; //actual distance from the centre of the analog stick

boolean l_press = false;
boolean r_press = false;
boolean fired = true;

Player player;
ArrayList<Player> opponents;
GameMap game_map;


PFont font = createFont("Arial Bold",48);

void setup() {
  game_map = new GameMap("map0");
  player = new Player(game_map.sizeX/2, game_map.sizeY/2, game_map, null);
  game_map.add_to_collision_cells(player);
  opponents = new ArrayList<Player>();
  opponents.add(new Player(game_map.sizeX/2, game_map.sizeY/2+50, game_map, new RandomAI()));
  for(int i = 0; i < opponents.size(); i++)
    game_map.add_to_collision_cells(opponents.get(i));
  
  left_xinit = (int)(pad_size/1.5);
  left_yinit = height-(int)(pad_size/1.5);
  right_xinit = width-(int)(pad_size/1.5);
  right_yinit = height-(int)(pad_size/1.5);
  
  left_spad_x = left_xinit;
  left_spad_y = left_yinit;
  right_spad_x = right_xinit;
  right_spad_y = right_yinit;
  
  outer_t_dx = (pad_size);
  inner_t_dx = (pad_size/2);
  
  rst = (pad_size/4);
  
  orientation(LANDSCAPE);
  //size(800, 480);
  smooth();
}

void draw() {
  
  background(240);
  
  //UPDATES
  if (mousePressed) {
    if(!l_press){
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0; 
    }
    
    if(!r_press && !fired){
      player.fire();
      fired = true;
    }
    
  } else {
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0;
      if(!fired){
        player.fire();
        fired = true;
      }
  }
  
  player.moveXY(ax,ay);

  player.update();
  
  for(int i=0; i<opponents.size(); i++) opponents.get(i).update();
  game_map.update();
  
  //RENDERING 
  fill(255);
  player.render();
  for(int i=0; i<opponents.size(); i++) opponents.get(i).render();
  game_map.render();
  draw_controls();
  
  textFont(font,10);
  fill(0);
  text("FPS " + int(frameRate),10,10);
  player.renderHUD();

}


public void draw_controls(){
  fill(255,255,255,100);
  ellipse((pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(width-(pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(left_spad_x, left_spad_y, subpad_size,subpad_size);
  ellipse(right_spad_x, right_spad_y, subpad_size,subpad_size);
}


public boolean surfaceTouchEvent(MotionEvent me) {
  boolean reset_left = true;
  r_press = false;
  l_press = false;
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
      l_press = true;
      //left analog
      if(inner_t_dx > left_dx){
        left_spad_x = x;
        left_spad_y = y;
        reset_left = false;
      } else {
        float a = atan2(left_xinit-x, left_yinit-y);
        left_spad_x = (int)(cos(-a-PI/2)*inner_t_dx)+left_xinit;
        left_spad_y = (int)(sin(-a-PI/2)*inner_t_dx)+left_yinit;
      }
      ax = (x - left_xinit)/10;
      ay = (y - left_yinit)/10;

    } else if(outer_t_dx > right_dx){
      r_press = true;
      //right analog
      if(inner_t_dx > right_dx){
         right_spad_x = x;
         right_spad_y = y;
         player.dir = atan2(x-right_xinit,y-right_yinit);
         fired = false;
      }
    }
    
    /*
    if(reset_left){
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0;
    }
    */
    
  }  
  return super.surfaceTouchEvent(me);
}

