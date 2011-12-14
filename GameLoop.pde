import apwidgets.*;

class GameLoop{
  
  processing.android.test.gunnerman.gunnerman top_level;
  
  //game states
  final int START_STATE = 0;
  final int CONNECT_STATE = 1;
  final int LOBBY_STATE = 2;
  final int GAME_STATE = 3;
  final int SCORE_STATE = 4;
  
  int change_to_state = -1;
  
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
  int join_height = 36;
  
  //join screen
  APWidgetContainer widgetContainer; 
  APEditText ipField;
  
  int connect_x;
  int connect_y;
  int connect_width = 150;
  int connect_height = 36;
  
  int no_connect_count;
  int no_connect_max = 2000;
  
  NetCom netcom;
  
  
  
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

  PFont font = createFont("Arial Bold",48);
  
  public GameLoop(int width, int height, processing.android.test.gunnerman.gunnerman top_level){
    this.width = width;
    this.height = height;
    this.top_level = top_level;
    
    //title
    title_delay = millis();
    join_y = height - 54;
    
    //connect
    connect_x = width/2;
    connect_y = height/2 + 105;
    
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
            netcom = new NetCom(ipField.getText(),55555);
            state = LOBBY_STATE;
          } catch (Exception e){
            println(e.getMessage());
            no_connect_count = millis();
          }
        }
      }
      
      
      break;
      case LOBBY_STATE:
      
      
      break;
      case GAME_STATE:
      
      
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
        text("join", 20, height - 36 - 10, join_width, join_height);
      
      
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
        background(50);
        fill(245);
        textFont(font,42);
        text("Lobby" , connect_x - 40, connect_y - 55);
      
      
      break;
      case GAME_STATE:
      
      
      break;
      case SCORE_STATE:
      
      
      break;
    }
    
  }
  
  
  public void draw_controls(){
    fill(255,255,255,100);
    ellipse((pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
    ellipse(width-(pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
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
            //join
            widgetContainer = new APWidgetContainer(top_level); //create new container for widgets
            ipField = new APEditText(width/2, height/2, 150, 75); //create a textfield from x- and y-pos., width and height
            widgetContainer.addWidget(ipField); //place textField in container
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
      
      
      break;
      case GAME_STATE:
      
      
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
  
}
