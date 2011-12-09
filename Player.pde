class Player extends GameObject{
  
  int sc_x;
  int sc_y;
  
  int size = 20;
  float dir = 0;
  int point_size = 20;
  
  int speed_cap = 5;
  float speed_scale = .5;
  
  
  //life
  private int max_lives = 5;
  int lives = max_lives;
  
  //weapons
  //0 Pistol
  int weapon;
  
  boolean fired;
  int fire_count = 0;
  int pistol_delay = 1000;
  
  PFont font = createFont("Arial Bold",48);
  
  Player(int x, int y, GameMap m){
     this.alive = true;
     this.x=x;
     this.y=y;
     this.m=m;
     this.weapon = 0;
     fired = false;
  }
  
  public void moveXY(int x_, int y_){
    /*
    if(x_>speed_cap) x_ = speed_cap;
    if(x_<-speed_cap) x_ = -speed_cap;
    if(y_>speed_cap) y_ = speed_cap;
    if(y_<-speed_cap) y_ = -speed_cap;
    */
    
    this.x += (x_ * speed_scale);
    int c;
    if((c = check_collision(true))!=-999) this.x = c;
       
    this.y += (y_ * speed_scale);
    if((c = check_collision(false))!=-999) this.y = c;

    
      sc_x = m.getScreenX(x);
      sc_y = m.getScreenY(y);
      
      if(sc_x<m.left_t){
        sc_x = m.left_t;
        m.changeVpX(x_);
      }
      else if(sc_x>m.right_t){
        sc_x = m.right_t;
        m.changeVpX(x_);
      }
      
      if(sc_y<m.top_t){
        sc_y = m.top_t;
        m.changeVpY(y_);
      }
      else if(sc_y>m.bottom_t){
        sc_y = m.bottom_t;
        m.changeVpY(y_);
      }
    
    //}
   }
   
 
  public int check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs = m.getCellObjects(x-this.size/2,y-this.size/2,this.size,this.size);
    
    //if (local_objs.size() == 0) return -999;
    
    while(local_objs.size()>0){
      LinkedList<GameObject> l = local_objs.removeFirst();

      for(int i = 0; i < l.size(); i++){
        int t = collision(l.get(i), x_dir);
        if(t != -999) return t;
      }
    }

    
    return -999;
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
    
    
    if(fired){
      if(millis() - fire_count >= pistol_delay){
       fired=false;
       fire_count = 0;
       //println("READY") ;
      }
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
  
  public void render(){

    line(sc_x,sc_y,cos(-dir+(3.14/2))*point_size+sc_x, sin(-dir+(3.14/2))*point_size+sc_y);
    ellipse(sc_x, sc_y, size,size);
    
  }
  
  private void renderHUD(){
    textFont(font,24);
     switch(weapon){
       case 0:
         text("Pistol", 50, 20);
         fill(0);
         rect(50,30, 40, 10);
         fill(255);
         if(fired)
           rect(50,30, (float)(millis()-fire_count)/(float)pistol_delay * 40, 10);
         else rect(50,30, 40, 10);
         break;
     }

    fill(0);
    for(int i=0; i<max_lives; i++) ellipse(50+(i*10), 50, 8, 8);
    fill(256);
    for(int i=0; i<lives; i++) ellipse(50+(i*10), 50, 8, 8);
  }
}
