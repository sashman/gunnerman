

import android.view.*;

//game loop object
GameLoop gl;

//game states
int current_state;
int START_STATE = 0;
int CONNECT_STATE = 1;
int LOBBY_STATE = 2;
int GAME_STATE = 3;
int SCORE_STATE = 4;




void setup() {
  current_state = START_STATE;
  gl = new GameLoop(width,height,this);
  
  orientation(LANDSCAPE);
  smooth();
  
  
  /*
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
  
  */
  

}

void draw() {
  
  
  current_state = gl.update(current_state, mousePressed);
  
  gl.render(current_state);
  
  
  /*
  
  
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
  */

}





public boolean surfaceTouchEvent(MotionEvent me) {
  
  gl.touchEvent(current_state, me);
  return super.surfaceTouchEvent(me);
}

