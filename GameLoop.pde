import apwidgets.*;
import java.util.*;

class GameLoop{
  
  processing.android.test.gunnerman.gunnerman top_level;
  
  //analysis
  boolean analyse = false;
  int max_fps = 0;
  int min_fps = 100;
  
  int fps_record_count;
  int fps_record_delay = 500;
  int max_game_time = 60000;
  LinkedList fps_record = new LinkedList();
 
  int last_fps = 0;
  
  
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
  
  int ai_count_press_delay;
  int ai_count_press_max = 500;
  
  
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
    
    fps_record_count = millis();
    
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
          if(millis() - ai_count_press_delay > ai_count_press_max){
            ai_count_press_delay = millis();
            ai_count--;
            ai_count = constrain(ai_count, ai_min, ai_max);
          }
          
        }
        
        if(ai_count_up_press){
          ai_count_up_press = false;
          if(millis() - ai_count_press_delay > ai_count_press_max){
            ai_count_press_delay = millis();
            ai_count++;
            ai_count = constrain(ai_count, ai_min, ai_max);
          }
          
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
            if(multiplayer) netcom.udp_send("fire " + player.x + " " + player.y + " " + player.dir);
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
          netcom.udp_send("pos " + player.x + " " + player.y + " " + player.ax + " " + player.ay + " " + Math.round(player.dir*100.0) / 100.0);
        }
        
        if(!game_finished && game_map.player_count == 1){
          game_over_count = millis(); //state = SCORE_STATE;
          game_finished = true;
          println("GAME OVER");
        }
        
        if(millis() > max_game_time || game_over_count>-1 && millis() - game_over_count > game_over_max){
          state = SCORE_STATE;
          
          if(analyse){
            println("max fps " + max_fps);
            println("min fps " + min_fps);
            
            String[] out = new String[fps_record.size()];
            int r_i = 0;
            int total = 0;
            while(fps_record.size()>0){
              //println(r_i++ + " " + (Integer)fps_record.removeFirst());
              int val = (Integer)fps_record.removeFirst();
              total += val;
              out[r_i] = r_i++ + " " + val;

            }
            println("avg fps " + total/out.length);
            saveStrings(dataPath("/sdcard/gunnerman/analysis/fps/last_run"), out);
            println("done saving run");
          }
        }
        
          if(analyse)
            fps_record.add((int)frameRate);
  
      
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
        
        
        
        /*
        fill(0);        
        if(millis() - fps_record_count > fps_record_delay){
          fps_record_count = millis();

          last_fps = int(frameRate);
        }
        textFont(font,10);
        text("FPS " + last_fps,10,10);
        */
        
        player.renderHUD();
        
        
        if(int(frameRate)>max_fps) max_fps = int(frameRate);
        if(int(frameRate)<min_fps) min_fps = int(frameRate);
      
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
