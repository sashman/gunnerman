class RemotePlayer implements PlayerControl{

  int packet_delay;
  int motion_count = 0;
  
  boolean reset_pos = false;
  int x;
  int y;
  int dx;
  int dy;
  float dir;
  boolean fire = false;
  
 public RemotePlayer(int packet_delay){
   this.packet_delay = packet_delay;
 }
 
 public void setPos(int x, int y, int dx, int dy, float dir){
   motion_count = millis();
   reset_pos = true;
   this.x = x;
   this.y = y;
   this.dx = dx;
   this.dy = dy;
   this.dir = dir;
 }
 
 public void fire(int x, int y, float dir){
   fire = true;
   this.x = x;
   this.y = y;
   this.dir = dir;
 }

 public void update(Player p){
   if(motion_count > 0 && millis()- motion_count < packet_delay){
     if(reset_pos){
         reset_pos = false;
         p.x =x;
         p.y =y;
         p.dir = dir;
     }
     p.moveXY(dx,dy);
   }
   if(fire){
     fire = false;
     p.x = x;
     p.y = y;
     p.dir = dir;
     p.fire();
     
   }
   
 } 
  
}
