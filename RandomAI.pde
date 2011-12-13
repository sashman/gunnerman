class RandomAI implements PlayerControl{

  //movement
 int dir_choice_count = 0;
 int dir_choice_change = 1000;
 int acc_range = 3;
 
 int r_ax = 0;
 int r_ay = 0;
 
 //aiming and shooting
 Player target;
 int fire_count = 0;
 int fire_change = 2500;
 
 
  
 public RandomAI(){
   dir_choice_count = millis(); 
   fire_count = millis();
   
 }
 
 public void update(Player p){
   
   //direction
   if(millis() - dir_choice_count > dir_choice_change){
     dir_choice_count = millis();
     r_ax = (int)(random(-acc_range, acc_range));
     r_ay = (int)(random(-acc_range, acc_range));
   } else {

   }
   
   p.moveXY(r_ax,r_ay);
   
   setAim(p);
   
   //firing
   if(millis() - fire_count > fire_change){
     target = p.m.players.get((int)random(0, p.m.players.size()));
     while(target.x == p.x && target.y == p.y) target = p.m.players.get((int)random(0, p.m.players.size()));
     fire_count = millis();
     p.dir = atan2(target.x-p.x,target.y-p.y)+random(-0.3,0.3);
     p.fire();
     
   } else {

   }
   
 }
 
 private void setAim(Player p){
   
   if(target!=null)
     p.dir = atan2(target.x-p.x,target.y-p.y);
   
 }

 
  
}
