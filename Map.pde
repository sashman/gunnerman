class Map{
  int sizeX;
  int sizeY;
  
  int vpX = 0;
  int vpY = 0;
  
  float vpMoveScreenRatio = .3;
  public int left_t = width*vpMoveScreenRatio;
  public int right_t = width*(1-vpMoveScreenRatio);
  public int top_t = height*vpMoveScreenRatio;
  public int bottom_t = heigh*(1-vpMoveScreenRatio);
  
  public Map(int x, int y){
    sizeX = x;
    sizeY = y;
  }
  
  public int getSceenX(int x){
    return x-vpX;
  }
  
  public int getScreeny(int y){
    return y-vpY;
  }
  
  public void changeVpX(int change){
    vpX += change;
  }
  
  public void changeVpY(int change){
    vpY += change;    
  }
  
  
}

