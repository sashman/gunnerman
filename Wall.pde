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
