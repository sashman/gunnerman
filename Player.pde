class Player extends GameObject{
  
  int sc_x;
  int sc_y;
  
  int size = 20;
  float dir = 0;
  int point_size = 20;
  
  int speed_cap = 5;
  float speed_scale = .5;
  Player(int x, int y, GameMap m){
     this.alive = true;
     this.x=x;
     this.y=y;
     this.m=m;
     
     
  }
  
  public void moveXY(int x_, int y_){
    if(x_>speed_cap) x_ = speed_cap;
    if(x_<-speed_cap) x_ = -speed_cap;
    if(y_>speed_cap) y_ = speed_cap;
    if(y_<-speed_cap) y_ = -speed_cap;
    
    this.x += (x_ * speed_scale);
    int c;
    if((c = check_collision(true))!=-999) this.x = c;
       
    this.y += (y_ * speed_scale);
    if((c = check_collision(false))!=-999) this.y = c;
   
    //int[] carray = check_collision();
    //if(carray[0] != -999 || carray[1] != -999){

    //  this.x = carray[0];
    //  this.y = carray[1];
    //}else{
    
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
      /*while(l.size()>0){
        int t = collision(l.removeFirst(), x_dir);
        if(t != -999) return t;
      }*/
      for(int i = 0; i < l.size(); i++){
        int t = collision(l.get(i), x_dir);
        if(t != -999) return t;
      }
    }
    
    /*
    for(int i = 0; i < local_objs.length; i++){
      int t = collision(local_objs.get(i), x_dir);
      if(t != -999) return t;
    }
    */
    
    return -999;
  }
  
  private int collision(GameObject obj, boolean x_dir){
    int colx = -999;
    int coly = -999;

    int oc_x = obj.x+obj.width/2;
    int oc_y = obj.y+obj.height/2;
    if (x+size/2 > obj.x && x < obj.x+obj.width+size/2
      && y+size/2 > obj.y && y < obj.y+obj.height+size/2){
        //println("Collision");
        if(x_dir){
          if(oc_x < x) return obj.x+obj.width+size/2;
          else return obj.x - size/2;
        } else {
          if(oc_y < y) return obj.y+obj.height+size/2;
          else return obj.y - size/2;
        }
        /*
          if(oc_x < x) colx = obj.x+obj.width;
          else colx = obj.x - size/2;
          if(oc_x < x) colx = obj.x+obj.width;
          else colx = obj.x - size/2
          */
    }
    
    return -999;
    //int[] r = {colx,coly};
    //return r;
  }
  
  public void render(){
    //int sc_x = m.getScreenX(x);
    //int sc_y = m.getScreenY(y);
    
    line(sc_x,sc_y,cos(-dir+(3.14/2))*point_size+sc_x, sin(-dir+(3.14/2))*point_size+sc_y);
    ellipse(sc_x, sc_y, size,size);
     
  }
}
