class GameObject{
  protected String coltype ="";
  protected GameMap m;
  public int x; 
  public int y;
  public int width;
  public int height;
  public boolean alive;
  
  public Collision check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs = m.getCellObjects(x,y,this.width,this.height);
    while(local_objs.size()>0){
      LinkedList<GameObject> l = local_objs.removeFirst();
      for(int i = 0; i < l.size(); i++){
        //if(l.get(i).getColType() != "" && l.get(i).getColType() != "wall")
        //  println("coltype " + l.get(i).getColType());
        int t = collision(l.get(i), x_dir);
        if(t != -999) return new Collision(t, l.get(i).getColType(), l.get(i));
      }
    }
    return new Collision(-999, "", null);
  }
   private int collision(GameObject obj, boolean x_dir){
    if(obj.getColType() == "player"){
      
      int oc_x = obj.x;
      int oc_y = obj.y;
      
      if (x+this.width > obj.x-obj.width/2 && x < obj.x+obj.width-obj.width/2+this.width
        && y+this.height > obj.y-obj.height/2 && y < obj.y+obj.height-obj.height/2+this.height){
          if(x_dir){
            if(oc_x < x) return obj.x+obj.width/2+this.width;
            else return obj.x - obj.width/2 - this.width;
          } else {
            if(oc_y < y) return obj.y+obj.height/2+this.height;
            else return obj.y - obj.height/2 - this.height;
          }
      }
      
      
      
    } else {
      int oc_x = obj.x+obj.width/2;
      int oc_y = obj.y+obj.height/2;
      if (x+this.width > obj.x && x < obj.x+obj.width+this.width
        && y+this.height > obj.y && y < obj.y+obj.height+this.height){
          if(x_dir){
            if(oc_x < x) return obj.x+obj.width+this.width;
            else return obj.x - this.width;
          } else {
            if(oc_y < y) return obj.y+obj.height+this.height;
            else return obj.y - this.height;
          }
      }
    }
    return -999;
  }
  
  public void loseLife(){
    
  }
  
  public String getColType(){
    return this.coltype; 
  }
}
