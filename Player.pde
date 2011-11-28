class Player extends GameObject{
  
  int size = 20;
  float dir = 0;
  int point_size = 20;
  Player(int x, int y, GameMap m){
     this.alive = true;
     this.x=x;
     this.y=y;
     this.m=m;
  }
  
  public void moveXY(int x_, int y_){
    this.x += x_;
    this.y += y_;
    
    if(x<m.left_t){
      x = m.left_t;
      m.changeVpX(x_);
    }
    else if(x>m.right_t){
      x = m.right_t;
      m.changeVpX(x_);
    }
    
    if(y<m.top_t){
      y = m.top_t;
      m.changeVpY(y_);
    }
    else if(y>m.bottom_t){
      y = m.bottom_t;
      m.changeVpY(y_);
    }
   }
  
  public void render(){
    int sc_x = x;//m.getScreenX(x);
    int sc_y = y;//m.getScreenY(y);
    
    line(sc_x,sc_y,cos(-dir+(3.14/2))*point_size+sc_x, sin(-dir+(3.14/2))*point_size+sc_y);
    ellipse(sc_x, sc_y, size,size);
     
  }
}
