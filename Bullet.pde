class Bullet extends GameObject{
 
 float x_dir;
 float y_dir;
 
 int type;
 int speed = 10;
 
 public Bullet(int x, int y, float x_dir, float y_dir, GameMap m, int type){
   //this.coltype = "bullet";
   this.x = x;
   this.y = y;
   this.x_dir = x_dir;
   this.y_dir = y_dir;
   this.m = m;

   this.type = type;
   
   this.height = 2;
   this.width = 2;
   

   
   if(x+2 > m.sizeX || x< 0 || y+2 > m.sizeY || y < 0) this.alive = false;
   else this.alive = true;
   
 }
 

 
 void moveXY(){
   if(!alive) return;
   
   if(type == 0){
     x+=(int)(this.x_dir*speed);
     y+=(int)(this.y_dir*speed);
     
     if(x+2 > m.sizeX || x< 0 || y+2 > m.sizeY || y < 0){
       alive = false;
       x = -100;
       y = -100;
     }
     Collision c = check_collision(true);
     if(c.value !=-999){
       alive = false;
       x = -100;
       y = -100;
       if(c.type == "player"){
         GameObject colobj = c.o;
         colobj.loseLife();
       }
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
