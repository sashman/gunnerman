class Wall{
  public int x;
  public int y; 
  public int width;
  public int height;
  GameMap m;
  public Wall(int x,int y,int width,int height, GameMap m){
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.m = m;
  }
  
  public void render(){
     int sc_x = m.getScreenX(x);
     int sc_y = m.getScreenY(y);
     
     rect(sc_x,sc_y,this.width,this.height);
  }
}
