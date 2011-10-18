class Player extends GameObject{
  
  int size = 20;
  Player(int x, int y){
     this.alive = true;
     this.x=x;
     this.y=y;
  }
  
  public void render(){
     ellipse(x, y, size,size);
  }
}
