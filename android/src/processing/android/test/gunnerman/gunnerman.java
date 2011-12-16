package processing.android.test.gunnerman;

import processing.core.*; 
import processing.xml.*; 

import android.view.*; 
import apwidgets.*; 
import java.util.*; 
import java.util.*; 
import java.io.*; 
import oscP5.*; 
import netP5.*; 
import java.io.PrintStream; 

import apwidgets.*; 
import oscP5.*; 
import netP5.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class gunnerman extends PApplet {





//game loop object
GameLoop gl;

//game states
int current_state;
int START_STATE = 0;
int CONNECT_STATE = 1;
int LOBBY_STATE = 2;
int GAME_STATE = 3;
int SCORE_STATE = 4;




public void setup() {
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

public void draw() {
  
  
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

class Bullet extends GameObject{
 
 float x_dir;
 float y_dir;
 
 int type;
 int speed = 10;
 
 public Bullet(int x, int y, float x_dir, float y_dir, GameMap m, int type){
   //this.coltype = "bullet";
   this.x = x;
   this.y = y;
   this.x_dir = x_dir;
   this.y_dir = y_dir;
   this.m = m;

   this.type = type;
   
   this.height = 2;
   this.width = 2;
   

   
   if(x+2 > m.sizeX || x< 0 || y+2 > m.sizeY || y < 0) this.alive = false;
   else this.alive = true;
   
 }
 

 
 public void moveXY(){
   if(!alive) return;
   
   if(type == 0){
     x+=(int)(this.x_dir*speed);
     y+=(int)(this.y_dir*speed);
     
     if(x+2 > m.sizeX || x< 0 || y+2 > m.sizeY || y < 0){
       alive = false;
       x = -100;
       y = -100;
     }
     Collision c = check_collision(true);
     if(c.value !=-999){
       alive = false;
       x = -100;
       y = -100;
       if(c.type == "player"){
         GameObject colobj = c.o;
         colobj.loseLife();
       }
     }
   }
   
 }
  
 public void render(){
   
   if(alive){
     int sc_x = m.getScreenX(x);
     int sc_y = m.getScreenY(y);
     
     if(type==0){
       //println("sc_x " + sc_x + " sc_y " + sc_y );
       fill(0);
       stroke(0);
       ellipse(sc_x, sc_y, this.height,this.width);
     }
   }
 }
}
class Collision{
  public int value = 0;
  public String type = "";
  public GameObject o;
  
  public Collision(int value, String type, GameObject o){
    this.value = value;
    this.type = type;
    this.o = o;
  }
  
}



class GameLoop{
  
  processing.android.test.gunnerman.gunnerman top_level;
  
  //game states
  final int START_STATE = 0;
  final int CONNECT_STATE = 1;
  final int AI_SELECT_STATE = 6;
  final int LOBBY_STATE = 2;
  final int GAME_STATE = 3;
  final int SCORE_STATE = 4;
  
  int change_to_state = -1;
  
  boolean multiplayer =false;
  
  int width;
  int height;
  
  
  //title screen
  int title_min = 50;
  int title_max = 245;
  int title_delay = 0;
  int title_delay_max = 7000;
  
  int join_x = 20;
  int join_width = 70;
  int join_y;
  int join_height = 50;
  
  int vsai_x = 20;
  int vsai_width = 70;
  int vsai_y;
  int vsai_height = 50;
  
  //join screen
  APWidgetContainer widgetContainer; 
  APEditText ipField;
  
  int connect_x = 20;
  int connect_y;
  int connect_width = 150;
  int connect_height = 36;
  
  int no_connect_count;
  int no_connect_max = 2000;
  
  //ai_select
  int ai_count = 1;
  int ai_min = 1;
  int ai_max = 3;
  
  int ai_count_display_x;
  int ai_count_display_y;
  
  int ai_count_up_x;
  int ai_count_up_y;
  int ai_count_down_x;
  int ai_count_down_y;
  
  int ai_count_width = 50;
  int ai_count_height = 50;
  
  int start_x = 20;
  int start_y;
  int start_width = 100;
  int start_height = 50;
  
  boolean ai_count_up_press = false;
  boolean ai_count_down_press = false;
  boolean start_press = false;
  
  
  //lobby
  NetCom netcom;
  int self_id = -1;
  int player_count = 0;
  HashMap lobbymembers = new HashMap();
  
  int ready_x = 20;
  int ready_width = 100;
  int ready_y;
  int ready_height = 50;
  
  boolean ready_press = false;
  int ready_sent_count;
  int ready_sent_max = 500;
  
  int game_start_count = -1;
  int game_start_max;
  HashMap netControllers = new HashMap();
  
  
  //delay for movement packets
  int packet_delay_count;
  int packet_delay_max = 250;
  
  //game state
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

  boolean connect_press = false;
  
  boolean l_press = false;
  boolean r_press = false;
  boolean fired = true;

  Player player;
  ArrayList<Player> opponents;
  GameMap game_map;
  
  
  //score
  boolean game_finished = false;
  int game_over_count = -1;
  int game_over_max = 1500;

  PFont font = createFont("Arial Bold",48);
  
  public GameLoop(int width, int height, processing.android.test.gunnerman.gunnerman top_level){
    this.width = width;
    this.height = height;
    this.top_level = top_level;
    
    //title
    title_delay = millis();
    join_y = height - 54;
    
    vsai_y = height - 100;
    
    //ai_select
    start_y = height - 70;
    
    ai_count_display_x = width/2;
    ai_count_display_y = height/2;
    
    ai_count_up_x = width/2 + 50;
    ai_count_up_y = height/2;
    
    ai_count_down_x = width/2 - 75;
    ai_count_down_y = height/2;
    
    //connect
    connect_x = width/2;
    connect_y = height/2 + 105;
    
    //lobby
    ready_y = height - 70;
    
  }
  
  //must return state
  public int update(int state, boolean mousePressed){
    
    if(change_to_state!=-1){
      state = change_to_state;
      change_to_state = -1;
    }
    
    switch(state){
      case START_STATE:
      
      
      break;
      case CONNECT_STATE:
      
      
      if(!mousePressed){
        
        if(connect_press){
          connect_press = false;
          println("CONNECT");
          try{
            netcom = new NetCom(this, ipField.getText(),55555);
            state = LOBBY_STATE;
          } catch (Exception e){
            println(e.getMessage());
            no_connect_count = millis();
          }
        }
      }
      
      break;
      case AI_SELECT_STATE:
      
      
      if(!mousePressed){
        
        if(ai_count_down_press){
          ai_count_down_press = false;
          ai_count--;
          ai_count = constrain(ai_count, ai_min, ai_max);
          
        }
        
        if(ai_count_up_press){
          ai_count_up_press = false;
          ai_count++;
          ai_count = constrain(ai_count, ai_min, ai_max);
          
        }

      }
      
      
      
      break;
      case LOBBY_STATE:
      
      if(!mousePressed){
        
        if(ready_press){
          ready_press = false;
          if(millis() - ready_sent_count > ready_sent_max){
            ready_sent_count = millis();
            try{
              println("READY");
              netcom.send("ready");
            } catch (Exception e){
              println(e.getMessage());
            }
          }
        }
      }
      
      
      
      break;
      case GAME_STATE:
        if(game_map==null || player == null) break;
      
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
              if(multiplayer) netcom.udp_send("fire " + player.x + " " + player.y + " " + player.dir);
              fired = true;
            }
        }
        
        player.moveXY(ax,ay);
      
        player.update();
        
        
        for(int i=0; i<opponents.size(); i++) opponents.get(i).update();
        game_map.update();
        
        
        if(multiplayer && millis() - packet_delay_count > packet_delay_max){
          packet_delay_count = millis();
          netcom.udp_send("pos " + player.x + " " + player.y + " " + player.ax + " " + player.ay + " " + Math.round(player.dir*100.0f) / 100.0f);
        }
        
        if(!game_finished && game_map.player_count == 1){
          game_over_count = millis(); //state = SCORE_STATE;
          game_finished = true;
          println("GAME OVER");
        }
        
        if(game_over_count>-1 && millis() - game_over_count > game_over_max){
          state = SCORE_STATE;
        }
      
      break;
      case SCORE_STATE:
      
      
      
      break;
    }
    
    
    return state;
  }
  
  public void render(int state){
    
    switch(state){
      case START_STATE:
        background(50);
      
      
        //draw title
        fill( constrain ((float)(millis()-title_delay)/(float)title_delay_max * title_max, title_min, title_max) );
        textFont(font,42);
        text("gunnerman", width/2, height/2);
        
        //draw join button
        fill(245);
        textFont(font,36);
        text("vsAI", vsai_x, vsai_y, join_width, join_height);
        
        //draw vs ai button
        fill(245);
        textFont(font,36);
        text("join", 20, height - 36 - 10, join_width, join_height);
        
      break;
      case AI_SELECT_STATE:
        background(50);
        fill(245);
        textFont(font,36);
        text("Select number of enemies" , 40, 50);
        
        text(ai_count, ai_count_display_x, ai_count_display_y+36);
        
        triangle(ai_count_down_x, (ai_count_down_y+ai_count_height/2),
                 ai_count_down_x + ai_count_width , ai_count_down_y,
                 ai_count_down_x + ai_count_width , ai_count_down_y + ai_count_height
                );
        triangle(ai_count_up_x+ ai_count_width, (ai_count_up_y+ai_count_height/2),
                 ai_count_up_x , ai_count_up_y,
                 ai_count_up_x , ai_count_up_y + ai_count_height
                );
        
        
        
        text("Start", start_x, start_y, start_width, start_height);
      
      
      break;
      case CONNECT_STATE:
        background(50);
        
        //text(ipField.getText(), 50, 50);
        fill(245);
        textFont(font,36);
        text("IP" , connect_x - 40, connect_y - 55);
        text("connect", connect_x, connect_y, connect_width, connect_height);
        
        int a = constrain (255-(int)((float)(millis()-no_connect_count)/(float)no_connect_max * 255), 0, 255);
        noStroke();
        fill(255,0,0,a);
        ellipse(connect_x+175, connect_y-75, 40, 40);
        
        
        if(connect_press){
          stroke(255);
          noFill();
          rect(connect_x, connect_y, connect_width, connect_height);
          stroke(0);
        }
      
      break;
      case LOBBY_STATE:
        widgetContainer.hide();
      
        background(50);
        fill(245);
        textFont(font,42);
        text("Lobby" , 40, 50);
        if(self_id>-1){
          textFont(font,14);
          text("Your id: " + self_id, 40, 80);
        }
        
        textFont(font, 36);
        text("Ready", ready_x, ready_y, ready_width, ready_height);
        
        if(game_start_count > -1){
          if(millis() - game_start_count < game_start_max){
            textFont(font, 36);
            text("Starting game", 40, 120);
            fill(255);
            arc(300, 100, 40,40, 0, (float)(millis() - game_start_count)/(float)game_start_max * TWO_PI);
            
          } else game_start_count = -1;
        }
        
        int j = 0;
        Iterator i = lobbymembers.entrySet().iterator();  // Get an iterator
        while (i.hasNext()) {
          Map.Entry me = (Map.Entry)i.next();
          textFont(font,36);
          String r = (Boolean)me.getValue() ? " is ready" : " is not ready";
          text("Player " + me.getKey() +  r, width/2, j*36  +40);
          
          j++;
        }
      
      
      break;
      case GAME_STATE:
        if(game_map==null || player==null) break;

        background(245); 
        stroke(0);
        
        player.render();
        for(int k=0; k<opponents.size(); k++) opponents.get(k).render();
        game_map.render();
        draw_controls();
        
        textFont(font,10);
        fill(0);
        text("FPS " + PApplet.parseInt(frameRate),10,10);
        player.renderHUD();
      
      /*
      player.render();
      for(int i=0; i<opponents.size(); i++) opponents.get(i).render();
      game_map.render();
      draw_controls();
      
      textFont(font,10);
      fill(0);
      text("FPS " + int(frameRate),10,10);
      player.renderHUD();
      */
      
      
      break;
      case SCORE_STATE:
        background(50);
        
        fill(245);
        textFont(font,42);
        text("Game over" , 40, 50);
        if(player.alive)
          text("You win" , 40, 100);
        else{
          for(int k = 0; k<opponents.size(); k++) {
            if(opponents.get(k).alive){
              text("Player " + (k+1) + " wins" , 40, 100);
            }
          }
        }
      
      
      break;
    }
    
  }
  
  
  public void draw_controls(){
    fill(255,255,255,100);
    ellipse((pad_size/1.5f), height-(pad_size/1.5f), pad_size,pad_size);
    ellipse(width-(pad_size/1.5f), height-(pad_size/1.5f), pad_size,pad_size);
    ellipse(left_spad_x, left_spad_y, subpad_size,subpad_size);
    ellipse(right_spad_x, right_spad_y, subpad_size,subpad_size);
  }
  
  public void touchEvent(int state, MotionEvent me){
    
    
    switch(state){
      case START_STATE:
      
      if(me.getPointerCount()>0){
        int x = (int)me.getX(0);
        int y = (int)me.getY(0);
        
        //click join
        if(x > join_x && x < join_x + join_width &&
          y > join_y && y < join_y + join_height){
            
            println("JOIN");
            change_to_state = CONNECT_STATE;
            multiplayer =true;
            //join

            widgetContainer = new APWidgetContainer(top_level); //create new container for widgets
            widgetContainer.show();
            ipField = new APEditText(width/2, height/2, 150, 75); //create a textfield from x- and y-pos., width and height
            widgetContainer.addWidget(ipField); //place textField in container
          }
          
          //click join
        if(x > vsai_x && x < vsai_x + vsai_width &&
          y > vsai_y && y < vsai_y + vsai_height){
            
            println("vsAI");
            change_to_state = AI_SELECT_STATE;
            multiplayer = false;

          }
        
      }
      
      break;
      case AI_SELECT_STATE:
      
      if(me.getPointerCount()>0){
        int x = (int)me.getX(0);
        int y = (int)me.getY(0);
        
        //click up
        if(x > ai_count_up_x && x < ai_count_up_x + ai_count_width &&
          y > ai_count_up_y && y < ai_count_up_y + ai_count_width){
            ai_count_up_press = true;
          }
          
        //click down
        if(x > ai_count_down_x && x < ai_count_down_x + ai_count_width &&
          y > ai_count_down_y && y < ai_count_down_y + ai_count_width){
            ai_count_down_press = true;
          }
       
         if(x > start_x && x < start_x + start_width &&
          y > start_y && y < start_y + start_width){
             println("Game started");
            change_to_state = GAME_STATE;
            
            init_game();
          }    
      }
      
      
      break;
      case CONNECT_STATE:
      

        if(me.getPointerCount()>0){
          int x = (int)me.getX(0);
          int y = (int)me.getY(0);
          
          //click connect
          if(x > connect_x && x < connect_x + connect_width &&
            y > connect_y && y < connect_y + connect_height){
              connect_press = true;
            }
          
        }
      
      
      break;
      case LOBBY_STATE:
      
        if(me.getPointerCount()>0){
          int x = (int)me.getX(0);
          int y = (int)me.getY(0);
          
          //click connect
          
          if(x > ready_x && x < ready_x + ready_width &&
            y > ready_y && y < ready_y + ready_height){
              ready_press = true;
            }
          
        }
      
      
      break;
      case GAME_STATE:
      if(game_map==null) break;
      
      //game state
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
      
        }
      
      
      
      break;
      case SCORE_STATE:
      
      
      break;
    }
    
  }
  
  private void init_game(){
    game_map = new GameMap("map0");
    player = new Player(game_map.sizeX/2, game_map.sizeY/2, game_map, null);
    game_map.add_to_collision_cells(player);
    opponents = new ArrayList<Player>();
    
    if(multiplayer){
      int j = 1;
      Iterator i = lobbymembers.entrySet().iterator();  // Get an iterator
      while (i.hasNext()) {
  
        Map.Entry me = (Map.Entry)i.next();
        if((Integer)me.getKey() == self_id) continue;
        //opponents.add(new Player(game_map.sizeX/2, game_map.sizeY/2+50, game_map, new RandomAI()));
        RemotePlayer rp = new RemotePlayer(packet_delay_max);
        Player player = new Player(game_map.sizeX/2, game_map.sizeY/2+(50*j), game_map, rp);
        player.net_id = (Integer)me.getKey();
        opponents.add(player);
        netControllers.put(player.net_id, rp);
        j++;
      }
    } else {
      for(int i = 0; i < ai_count; i++){
        
        Player player = new Player(game_map.sizeX/2, game_map.sizeY/2+(50*(i+1)), game_map, new RandomAI());
        opponents.add(player);
      }
    }
    
    game_map.player_count = opponents.size()+1;
    
    
    for(int k = 0; k < opponents.size(); k++)
      game_map.add_to_collision_cells(opponents.get(k));
    
    left_xinit = (int)(pad_size/1.5f);
    left_yinit = height-(int)(pad_size/1.5f);
    right_xinit = width-(int)(pad_size/1.5f);
    right_yinit = height-(int)(pad_size/1.5f);
    
    left_spad_x = left_xinit;
    left_spad_y = left_yinit;
    right_spad_x = right_xinit;
    right_spad_y = right_yinit;
    
    outer_t_dx = (pad_size);
    inner_t_dx = (pad_size/2);
    
    rst = (pad_size/4);
    
    if(!multiplayer)
     packet_delay_count = millis();
  }
  
  
  synchronized public void resolveMessage(String msg){
    Scanner sc = new Scanner(msg);
    if(!sc.hasNext()){
      println("Empty message");
      return;
    }
    
    String type=sc.next();
    if(type.equals("joined")){
        int id = sc.nextInt();
      
        println("Joined the lobby with id " + id);
        self_id = id;
    } else if(type.equals("playerjoined")){
       int id = sc.nextInt();
       String ready_string = sc.next();
       boolean ready = ready_string.equals("true") ? true : false;
       
       println("Player joined with id " + id + " ready status " + ready);
       lobbymembers.put(id, ready);
       
    } else if(type.equals("playerready")){
      int id = sc.nextInt();
      
      println("Player " + id + " sent ready");
      boolean r = (Boolean)lobbymembers.get(id) ? false : true;
      lobbymembers.put(id, r);
      
    } else if(type.equals("gamestarting")){
      int start_delay = sc.nextInt();
      game_start_count = millis();
      game_start_max = start_delay*1000;
      
      println("Game starting in " + start_delay);
      
    } else if(type.equals("gamestart")){
      
      println("Game started");
      change_to_state = GAME_STATE;
      
      init_game();
      netcom.change_to_gamestate();
      
    } else if(type.equals("playerpos")){
      int id = sc.nextInt();
      int x = sc.nextInt();
      int y = sc.nextInt();
      int dx = sc.nextInt();
      int dy = sc.nextInt();
      float dir = sc.nextFloat();
      
      println("Got new position");
      if(id == self_id) println("About myself");
      else{
        RemotePlayer rp = (RemotePlayer)netControllers.get(id);
        rp.setPos(x,y,dx,dy,dir);
      }
      
    } else if(type.equals("playerfire")){
      int id = sc.nextInt();
      int x = sc.nextInt();
      int y = sc.nextInt();
      float dir = sc.nextFloat();
      
      println("Got new fire");
      if(id == self_id) println("About myself");
      else{
        RemotePlayer rp = (RemotePlayer)netControllers.get(id);
        rp.fire(x,y,dir);
      }
      
    } else println("Unknown message type " + type);
    
  }
  
}



class GameMap {
  int sizeX =0;
  int sizeY =0;

  public int vpX = 0;
  public int vpY = 0;

  float vpMoveScreenRatio = .3f;
  public int left_t = (int)(width*vpMoveScreenRatio);
  public int right_t = (int)(width*(1-vpMoveScreenRatio));
  public int top_t = (int)(height*vpMoveScreenRatio);
  public int bottom_t = (int)(height*(1-vpMoveScreenRatio));

  
  private ArrayList<Wall> walls = new ArrayList<Wall>();
  private ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  public ArrayList<Player> players = new ArrayList<Player>();
  int player_count = -1;

  int cell_w = 4;  
  int cell_h = 4;

  private LinkedList<GameObject>[][] cells = new LinkedList[cell_w+1][cell_h+1];

  public GameMap(String fname) {
    loadMap(fname);
  }

  public void loadMap(String fname) {
    //set up collision cells
    for(int i = 0; i <= cell_w; i++){
     for(int j = 0; j <= cell_h; j++){
       cells[i][j] = new LinkedList<GameObject>();
     }
    }
    
    //load from file
    try {
      String[] maplines = loadStrings(dataPath("/sdcard/gunnerman/maps/"+fname));
      //highScore = int(scores[0]);
      sizeX = Integer.parseInt(maplines[0]);
      sizeY = Integer.parseInt(maplines[1]);
      
      for(int i = 2; i < maplines.length; i++){
        //println(maplines[i]);
         Scanner sc = new Scanner(maplines[i]);
         if(!sc.hasNext()){
            println("Bad wall line: " + maplines[i]);
            continue;
         }
         
         if(sc.next().equals("wall")){
           int wallx = sc.nextInt();
           int wally = sc.nextInt();
           int wallwidth = sc.nextInt();
           int wallheight = sc.nextInt();
           //println("Wall " + wallx + " " + wally + " " + wallwidth + " " + wallheight);
           Wall w = new Wall(wallx,wally,wallwidth,wallheight, this);
           walls.add(w);
           add_to_collision_cells(w);
           
         } else {
           println("Bad wall line: " + maplines[i]);
         }
      }
      
      
    }catch (Exception e){
      println("Error: " + e.getMessage());
      println("Creating map!");
      sizeX = 1000;
      sizeY = 500;
      Wall w = new Wall(0,0,1000,10,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(0,500,1000,10,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(0,0,10,500,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(1000,0,10,500,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(333,100,10,300,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(666,100,10,300,this);
      walls.add(w);
      add_to_collision_cells(w);
    }
    
  }
  
  public void add_to_collision_cells(GameObject o){
    int i1 = (int)(((float)o.x/(float)sizeX)*cell_w);
    int j1 = (int)(((float)o.y/(float)sizeY)*cell_h);
    int i2 = (int)((float)(o.x+o.width)/(float)sizeX*cell_w);
    int j2 = (int)((float)(o.y+o.height)/(float)sizeY*cell_h);
    
    //println("Adding new wall");
//    println("x=" + o.x + " y=" + o.y);
    //println("i1 = " + i1 + " j1 = " + j1 + " i2 = " + i2 + " j2 = " + j2 );
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cells[i][j].contains(o)){
          //println("\t cell " + i + ","+j);  
          cells[i][j].add(o);
        }
      }
    }
  }
  
  public void add_to_collision_cells(Player p){
    int i1 = (int)(((float)(p.x-(p.size/2))/(float)sizeX)*cell_w);
    int j1 = (int)(((float)(p.y-(p.size/2))/(float)sizeY)*cell_h);
    int i2 = (int)((float)(p.x+(p.size/2))/(float)sizeX*cell_w);
    int j2 = (int)((float)(p.y+(p.size/2))/(float)sizeY*cell_h);
    
    //println("i1 = " + i1 + " j1 = " + j1 + " i2 = " + i2 + " j2 = " + j2 );
    
    if(p.relevant_cells.size()>0 && p.relevant_cells.getFirst()[0] == i1 && p.relevant_cells.getFirst()[1] == j1 &&
                                    p.relevant_cells.getLast()[0] == i2 && p.relevant_cells.getLast()[1] == j2) return;
                                    else{
                                      while(p.relevant_cells.size()>0){
                                        int[] c = p.relevant_cells.removeFirst();
                                        cells[c[0]][c[1]].remove(p);
                                      }
                                      /*
                                      for(int i = 0; i<p.relevant_cells.size(); i++){
                                        cells[p.relevant_cells.get(i)[0]][p.relevant_cells.get(i)[1]].remove(p);
                                      }
                                      */
                                      //p.relevant_cells = new LinkedList<int[]>();
                                    }
    

    //println("Player in added in");
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        int[] cellpair = {i,j};
        p.relevant_cells.add(cellpair);
        if(!cells[i][j].contains(p)){
          //println("\t cell " + i + ","+j);  
          cells[i][j].add(p);
        }
      }
    }
  }
  
  public void add_bullet(Bullet b){
    bullets.add(b);
  }
  
  public void update(){
    for(int i = 0; i < bullets.size(); i++) bullets.get(i).moveXY();
  }
  
  public void render(){
    renderWalls();
    renderBullets();
  }
  
  public void renderWalls(){
   for(int i = 0; i < walls.size(); i++) walls.get(i).render();
  }
  
  public void renderBullets(){
   for(int i = 0; i < bullets.size(); i++){

     bullets.get(i).render();
     if(!bullets.get(i).alive) bullets.remove(i);
   }
  }
  
  

  public int getScreenX(int x) {
    return x-vpX;
  }

  public int getScreenY(int y) {
    return y-vpY;
  }

  public void changeVpX(int change) {
    vpX += change;
  }

  public void changeVpY(int change) {
    vpY += change;
  }
  
  public LinkedList<LinkedList<GameObject>> getCellObjects(int x, int y, int w, int h){
    int i1 = (int)(((float)x/(float)sizeX) * cell_w);
    int j1 = (int)(((float)y/(float)sizeY) * cell_h);
    int i2 = (int)(((float)(x+w)/(float)sizeX) * cell_w);
    int j2 = (int)(((float)(y+h)/(float)sizeY) * cell_h);
    LinkedList<LinkedList<GameObject>> cellList = new LinkedList();
    try{    
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cellList.contains(cells[i][j])){
          cellList.add(cells[i][j]);
        }
      }
    }
    } catch (ArrayIndexOutOfBoundsException e){
      println("ArrayIndexOutOfBoundsException: " + e.getMessage() + " i1 " + i1 + " j1 " + j1 + " i2 " + i2 + " j2 " +j2 + " x " + x + " y " + y);
    }
    return cellList;
  }
}

class GameObject{
  protected String coltype ="";
  protected GameMap m;
  public int x; 
  public int y;
  public int width;
  public int height;
  public boolean alive;
  
  public Collision check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs = m.getCellObjects(x,y,this.width,this.height);
    while(local_objs.size()>0){
      LinkedList<GameObject> l = local_objs.removeFirst();
      for(int i = 0; i < l.size(); i++){
        //if(l.get(i).getColType() != "" && l.get(i).getColType() != "wall")
        //  println("coltype " + l.get(i).getColType());
        int t = collision(l.get(i), x_dir);
        if(t != -999) return new Collision(t, l.get(i).getColType(), l.get(i));
      }
    }
    return new Collision(-999, "", null);
  }
   private int collision(GameObject obj, boolean x_dir){
    if(obj.getColType() == "player"){
      
      int oc_x = obj.x;
      int oc_y = obj.y;
      
      if (x+this.width > obj.x-obj.width/2 && x < obj.x+obj.width-obj.width/2+this.width
        && y+this.height > obj.y-obj.height/2 && y < obj.y+obj.height-obj.height/2+this.height){
          if(x_dir){
            if(oc_x < x) return obj.x+obj.width/2+this.width;
            else return obj.x - obj.width/2 - this.width;
          } else {
            if(oc_y < y) return obj.y+obj.height/2+this.height;
            else return obj.y - obj.height/2 - this.height;
          }
      }
      
      
      
    } else {
      int oc_x = obj.x+obj.width/2;
      int oc_y = obj.y+obj.height/2;
      if (x+this.width > obj.x && x < obj.x+obj.width+this.width
        && y+this.height > obj.y && y < obj.y+obj.height+this.height){
          if(x_dir){
            if(oc_x < x) return obj.x+obj.width+this.width;
            else return obj.x - this.width;
          } else {
            if(oc_y < y) return obj.y+obj.height+this.height;
            else return obj.y - this.height;
          }
      }
    }
    return -999;
  }
  
  public void loseLife(){
    
  }
  
  public String getColType(){
    return this.coltype; 
  }
}





class NetCom  implements NetListener {
  
  GameLoop gl;
  TcpClient myClient;
  UdpClient udpClient;
  UdpServer udpServer;
  int dataIn;
  PrintStream out;
  String ip;
  int port;
  
  
  
  public NetCom(GameLoop gl, String ip, int port) throws Exception {
    this.ip = ip;
    this.port = port;
    
    
    if(ip == "") throw new Exception("Empty address");
    this.gl = gl;
    
    NetAddress a = new NetAddress(ip,port);
    
    if(a.isvalid()){
    
      myClient = new TcpClient(this, ip, port);
      
      try{
        out = new PrintStream(myClient.socket().getOutputStream());
      }catch (IOException e){
        
      }
      
    } else {
      throw new Exception(ip + " address not found"); 
    }
  }
  
  public void change_to_gamestate(){
    //myClient.dispose(); 
    udpClient = new UdpClient(ip, port+1);
    udpServer = new UdpServer(this, port+1);
    
  }
  
  public void netStatus(NetStatus theStatus){
    println("NetStatus:" + theStatus); 
  }
  
  public void netEvent(NetMessage msg){
    String m = msg.getString().trim();
    println(">>" + m);
    gl.resolveMessage(m);
  }
  
  public void send(String msg){
    println("sending: " + msg);
    myClient.send(msg+"\n");
  }
  
  public void udp_send(String msg){
    if(udpClient==null){
      println("no udp socket");
      return;
    }
    udpClient.send(msg+"\n");
  }
}
class Player extends GameObject{
  boolean show_coords = true;
  
  //net related
  int net_id = -1;
  boolean ready = false;
  
  int sc_x;
  int sc_y;
  
  int size = 20;
  public float dir = 0;
  int point_size = 20;
  
  int speed_cap = 5;
  float speed_scale = .5f;
  
  int ax=0;
  int ay=0;
  int dx=0;
  int dy=0;
  int friction = 1;
  
  //life
  private int max_lives = 5;
  int lives = max_lives;
  
  //weapons
  //0 Pistol
  int weapon;
  
  boolean fired;
  int fire_count = 0;
  int pistol_delay = 1000;
  
  LinkedList<int[]> relevant_cells = new LinkedList<int[]>();
  
  PFont font = createFont("Arial Bold",48);
  
  //null for human controling 
  PlayerControl pc;
  
  Player(int x, int y, GameMap m, PlayerControl pc){
     this.coltype = "player";
     this.alive = true;
     this.x=x;
     this.y=y;
     this.width = size;
     this.height = size;
     this.m=m;
     this.weapon = 0;
     fired = false;
     this.pc = pc;
     if(pc!=null) show_coords = false;
     sc_x = m.getScreenX(x);
     sc_y = m.getScreenY(y);
     
     m.players.add(this);
  }
  
  public void moveXY(int ax_, int ay_){
    ax = ax_;
    ay = ay_;
  }
  
  private void update_pos(){

    dx*=speed_scale;
    dy*=speed_scale;
    dx = constrain(dx, -speed_cap, speed_cap);
    dy = constrain(dy, -speed_cap, speed_cap);
    
    
    if(dx==0 && dy==0) return;
    this.x += (dx);
    Collision c = check_collision(true);
    if(c.value!=-999) this.x = c.value;
       
    this.y += (dy);
    c = check_collision(false);
    if(c.value!=-999) this.y = c.value;

    if(pc==null){
      sc_x = m.getScreenX(x);
      sc_y = m.getScreenY(y);
      
      
      if(sc_x<m.left_t){
        sc_x = m.left_t;
        m.changeVpX(dx-1);

      }
      else if(sc_x>m.right_t){
        sc_x = m.right_t;
        m.changeVpX(dx+1);
      }
      
      if(sc_y<m.top_t){
        sc_y = m.top_t;
        m.changeVpY(dy-1);
        //println("sc_y " + sc_y + " m.top_t " + m.top_t);
      }
      else if(sc_y>m.bottom_t){
        sc_y = m.bottom_t;
        m.changeVpY(dy+1);
      }
    }
   }
   
 
  public Collision check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs;
    try{
      local_objs = m.getCellObjects(x-this.size/2,y-this.size/2,this.size,this.size);
    }catch (ArrayIndexOutOfBoundsException e){
      //println("ArrayIndexOutOfBoundsException: " + e.getMessage());
      return new Collision(-999, "", null);
    }
    
    //if (local_objs.size() == 0) return -999;
    
    while(local_objs.size()>0){
      LinkedList<GameObject> l = local_objs.removeFirst();

      for(int i = 0; i < l.size(); i++){
        if(l.get(i).getColType() == "player") continue;
        int t = collision(l.get(i), x_dir);
        if(t != -999){
          return new Collision(t, l.get(i).getColType(), l.get(i));
        }
      }
    }

    
    return new Collision(-999, "", null);
  }
  
  private int collision(GameObject obj, boolean x_dir){
    int oc_x = obj.x+obj.width/2;
    int oc_y = obj.y+obj.height/2;
    if (x+size/2 > obj.x && x < obj.x+obj.width+size/2
      && y+size/2 > obj.y && y < obj.y+obj.height+size/2){
        if(x_dir){
          if(oc_x < x) return obj.x+obj.width+size/2;
          else return obj.x - size/2;
        } else {
          if(oc_y < y) return obj.y+obj.height+size/2;
          else return obj.y - size/2;
        }
    }
    return -999;
  }
  
  
  public void update(){
    
    if(!alive) return;
    
    dx+=ax;
    dy+=ay;
    
    update_pos();
    m.add_to_collision_cells(this);
    
    if(fired){
      if(millis() - fire_count >= pistol_delay){
       fired=false;
       fire_count = 0;
       //println("READY") ;
      }
    }   
    
    if(pc!=null){
      pc.update(this);
    }
   
  }
  
  public void fire(){
   
   if(!fired){
     fired=true;
     
     launch_bullet();
     if(weapon==0) fire_count = millis();
   }
    
  }
  
  private void launch_bullet(){
    //println("New bullet x " +x + " y " + y + " dir_x " + cos(-dir+(3.14/2))+sc_x + " dir_y " + sin(-dir+(3.14/2))+sc_y + " type " + weapon);
    Bullet b = new Bullet((int)(cos(-dir+(3.14f/2))*point_size+x), (int)(sin(-dir+(3.14f/2))*point_size+y), cos(-dir+(3.14f/2)), sin(-dir+(3.14f/2)), this.m, weapon);
    m.add_bullet(b);
  }
  
  public void loseLife(){
    if(!alive) return;
    
    lives--;
    if(lives<1){
      alive = false;
      m.player_count--;
    }
  }
  
  public void render(){

    
    if(pc!=null){
       sc_x = m.getScreenX(x);
       sc_y = m.getScreenY(y);
    }
    
    if(alive){
      if(pc==null) fill(255);
      else fill(127);
      line(sc_x,sc_y,cos(-dir+(3.14f/2))*point_size+sc_x, sin(-dir+(3.14f/2))*point_size+sc_y);
      ellipse(sc_x, sc_y, size,size);
    } else {
      textFont(font,14);
      fill(0);
      if(pc!=null) text("Opponent killed", sc_x, sc_y);
      if(pc==null) text("You have been killed", sc_x, sc_y);
    }

  }
  
  private void renderHUD(){
    textFont(font,24);
     switch(weapon){
       case 0:
         fill(0);
         text("Pistol", 50, 20);

         rect(50,30, 40, 10);
         fill(255);
         if(fired && alive)
           rect(50,30, (float)(millis()-fire_count)/(float)pistol_delay * 40, 10);
         else rect(50,30, 40, 10);
         break;
     }

    fill(0);
    for(int i=0; i<max_lives; i++) ellipse(50+(i*10), 50, 8, 8);
    fill(255);
    
    for(int i=0; i<lives; i++) ellipse(50+(i*10), 50, 8, 8);
    
    if(show_coords){
      textFont(font,12);
      fill(0);
      text("ax " + ax + " ay " + ay, 12, 65);
      text("vx " + dx + " vy " + dy, 12, 75);
      text("x " + x + " y " + y, 12, 85);
      text("scx " + sc_x + " scy " + sc_y, 12, 95);
      text("vpx " + m.vpX + " vpy " + m.vpY, 12, 105);      
    }
    
  }
}
interface PlayerControl {
  
  public void update(Player p);
  
}
class RandomAI implements PlayerControl{

  //movement
 int dir_choice_count = 0;
 int dir_choice_change = 1000;
 int acc_range = 3;
 
 int r_ax = 0;
 int r_ay = 0;
 
 //aiming and shooting
 Player target;
 int fire_count = 0;
 int fire_change = 2500;
 
 
  
 public RandomAI(){
   dir_choice_count = millis(); 
   fire_count = millis();
   
 }
 
 public void update(Player p){
   
   //direction
   if(millis() - dir_choice_count > dir_choice_change){
     dir_choice_count = millis();
     r_ax = (int)(random(-acc_range, acc_range));
     r_ay = (int)(random(-acc_range, acc_range));
   } else {

   }
   
   p.moveXY(r_ax,r_ay);
   
   setAim(p);
   
   //firing
   if(millis() - fire_count > fire_change){
     target = p.m.players.get((int)random(0, p.m.players.size()));
     while(target.x == p.x && target.y == p.y || !target.alive)
       target = p.m.players.get((int)random(0, p.m.players.size()));
     fire_count = millis();
     p.dir = atan2(target.x-p.x,target.y-p.y)+random(-0.3f,0.3f);
     p.fire();
     
   } else {

   }
   
 }
 
 private void setAim(Player p){
   
   if(target!=null)
     p.dir = atan2(target.x-p.x,target.y-p.y);
   
 }

 
  
}
class RemotePlayer implements PlayerControl{

  int packet_delay;
  int motion_count = 0;
  
  boolean reset_pos = false;
  int x;
  int y;
  int dx;
  int dy;
  float dir;
  boolean fire = false;
  
 public RemotePlayer(int packet_delay){
   this.packet_delay = packet_delay;
 }
 
 public void setPos(int x, int y, int dx, int dy, float dir){
   motion_count = millis();
   reset_pos = true;
   this.x = x;
   this.y = y;
   this.dx = dx;
   this.dy = dy;
   this.dir = dir;
 }
 
 public void fire(int x, int y, float dir){
   fire = true;
   this.x = x;
   this.y = y;
   this.dir = dir;
 }

 public void update(Player p){
   if(motion_count > 0 && millis()- motion_count < packet_delay){
     if(reset_pos){
         reset_pos = false;
         p.x =x;
         p.y =y;
         p.dir = dir;
     }
     p.moveXY(dx,dy);
   }
   if(fire){
     fire = false;
     p.x = x;
     p.y = y;
     p.dir = dir;
     p.fire();
     
   }
   
 } 
  
}
class Wall extends GameObject{
  
  public Wall(int x,int y,int width,int height, GameMap m){
    this.coltype = "wall";
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.m = m;
  }
  
  public void render(){
     int sc_x = m.getScreenX(x);
     int sc_y = m.getScreenY(y);
     
     fill(255);
     rect(sc_x,sc_y,this.width,this.height);
  }
}

}
