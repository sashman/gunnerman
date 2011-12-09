class Bullet extends GameObject{
 
 float x_dir;
 float y_dir;
 
 int type;
 
 public Bullet(int x, int y, float x_dir, float y_dir, GameMap m, int type){
   
   this.x = x;
   this.y = y;
   this.x_dir = x_dir;
   this.y_dir = y_dir;
   this.m = m;

   this.type = type;
   
   this.height = 2;
   this.width = 2;
   
   this.alive = true;
   
 }
 

 
 void moveXY(){
   if(!alive) return;
   
   if(type == 0){
     x+=(int)(this.x_dir*5);
     y+=(int)(this.y_dir*5);
     int c;
     if((c = check_collision(true))!=-999){
       alive = false;
       x = -100;
       y = -100;
     }
   }
   
 }
  
 public void render(){
   
   if(alive){
     int sc_x = m.getScreenX(x);
     int sc_y = m.getScreenY(y);
     
     if(type==0){
       //println("sc_x " + sc_x + " sc_y " + sc_y );
       ellipse(sc_x, sc_y, this.height,this.width);
     }
   }
 }
}
