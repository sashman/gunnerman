class Player extends GameObject{
  
  int size = 20;
  float dir = 0;
  int point_size = 20;
  Player(int x, int y, Map m){
     this.alive = true;
     this.x=x;
     this.y=y;
     this.m=m;
  }
  
  public moveXY(int x_, int y_){
    this.x += x_;
    this.y += y_;
    
   }
  
  public void render(){
    int sc_x = m.getScreenX(x);
    int sc_y = m.getScreenX(y);
    
    line(sc_x,sc_y,cos(-dir+(3.14/2))*point_size+sc_x, sin(-dir+(3.14/2))*point_size+sc_y);
    ellipse(sc_x, sc_y, size,size);
     
  }
}
