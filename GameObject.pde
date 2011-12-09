class GameObject{
  protected GameMap m;
  public int x; 
  public int y;
  public int width;
  public int height;
  public boolean alive;
  
  public int check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs = m.getCellObjects(x,y,this.width,this.height);
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
    return -999;
  }
  
}
