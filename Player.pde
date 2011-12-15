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
  float speed_scale = .5;
  
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
    Bullet b = new Bullet((int)(cos(-dir+(3.14/2))*point_size+x), (int)(sin(-dir+(3.14/2))*point_size+y), cos(-dir+(3.14/2)), sin(-dir+(3.14/2)), this.m, weapon);
    m.add_bullet(b);
  }
  
  public void loseLife(){
    lives--;
    if(lives<1) alive = false;
  }
  
  public void render(){

    
    if(pc!=null){
       sc_x = m.getScreenX(x);
       sc_y = m.getScreenY(y);
    }
    
    if(alive){
      if(pc==null) fill(255);
      else fill(127);
      line(sc_x,sc_y,cos(-dir+(3.14/2))*point_size+sc_x, sin(-dir+(3.14/2))*point_size+sc_y);
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
