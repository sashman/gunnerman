package processing.android.test.gunnerman;

import processing.core.*; 
import processing.xml.*; 

import android.view.*; 
import java.util.*; 
import java.io.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class gunnerman extends PApplet {





int pad_size = 150;
int subpad_size = 50;
int left_spad_x;
int left_spad_y;

int right_spad_x;
int right_spad_y;

int left_xinit;
int left_yinit;
int right_xinit;
int right_yinit;

//player acc
int ax = 0;
int ay = 0;

int outer_t_dx;  //outer analog stick threshold, used to assign multi touch id to analog sticks
int inner_t_dx; //inner analog stick threshhold

int rst; //right sesitivity threshold
int left_dx,right_dx; //actual distance from the centre of the analog stick

boolean l_press = false;
boolean r_press = false;
boolean fired = false;

Player player;
GameMap game_map;


PFont font = createFont("Arial Bold",48);

public void setup() {
  game_map = new GameMap("map0");
  player = new Player(game_map.sizeX/2, game_map.sizeY/2, game_map, null);
  
  left_xinit = (int)(pad_size/1.5f);
  left_yinit = height-(int)(pad_size/1.5f);
  right_xinit = width-(int)(pad_size/1.5f);
  right_yinit = height-(int)(pad_size/1.5f);
  
  left_spad_x = left_xinit;
  left_spad_y = left_yinit;
  right_spad_x = right_xinit;
  right_spad_y = right_yinit;
  
  outer_t_dx = (pad_size);
  inner_t_dx = (pad_size/2);
  
  rst = (pad_size/4);
  
  orientation(LANDSCAPE);
  //size(800, 480);
  smooth();
}

public void draw() {
  
  background(240);
  
  
  if (mousePressed) {
    if(!l_press && r_press){
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0; 
    }
    
  } else {
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0;
  }
  
  player.moveXY(ax,ay);
  player.update();
  game_map.update();
  
  fill(255);
  player.render();
  game_map.render();
  draw_controls();
  
  textFont(font,10);
  fill(0);
  text("FPS " + PApplet.parseInt(frameRate),10,10);
  

}


public void draw_controls(){
  ellipse((pad_size/1.5f), height-(pad_size/1.5f), pad_size,pad_size);
  ellipse(width-(pad_size/1.5f), height-(pad_size/1.5f), pad_size,pad_size);
  ellipse(left_spad_x, left_spad_y, subpad_size,subpad_size);
  ellipse(right_spad_x, right_spad_y, subpad_size,subpad_size);
}


public boolean surfaceTouchEvent(MotionEvent me) {
  boolean reset_left = true;
  r_press = false;
  l_press = false;
  // Number of places on the screen being touched:
  int numPointers = me.getPointerCount();
  for(int i=0; i < numPointers; i++) {
    int pointerId = me.getPointerId(i);
    int x = (int)me.getX(i);
    int y = (int)me.getY(i);
    left_dx = (int)sqrt((int)(pow(left_xinit-x, 2) + (int)pow(left_yinit-y, 2)));  
    right_dx  = (int)sqrt((int)(pow(right_xinit-x, 2) + (int)pow(right_yinit-y, 2)));  
    
    //find out which analog stick the event corrsponds to
    if(outer_t_dx > left_dx){
      l_press = true;
      //left analog
      if(inner_t_dx > left_dx){
        left_spad_x = x;
        left_spad_y = y;
        reset_left = false;
      }
      ax = (x - left_xinit)/10;
      ay = (y - left_yinit)/10;

    } else if(outer_t_dx > right_dx){
      r_press = true;
      //right analog
      if(inner_t_dx > right_dx){
         right_spad_x = x;
         right_spad_y = y;
         player.dir = atan2(x-right_xinit,y-right_yinit);
         player.fire();
      }
    }
    
    if(reset_left){
      left_spad_x = left_xinit;
      left_spad_y = left_yinit;
      ax = 0;
      ay = 0;
    }
    
  }  
  return super.surfaceTouchEvent(me);
}

class Bullet extends GameObject{
 
 float x_dir;
 float y_dir;
 
 int type;
 int speed = 10;
 
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
 

 
 public void moveXY(){
   if(!alive) return;
   
   if(type == 0){
     x+=(int)(this.x_dir*speed);
     y+=(int)(this.y_dir*speed);
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



class GameMap {
  int sizeX =0;
  int sizeY =0;

  public int vpX = 0;
  public int vpY = 0;

  float vpMoveScreenRatio = .3f;
  public int left_t = (int)(width*vpMoveScreenRatio);
  public int right_t = (int)(width*(1-vpMoveScreenRatio));
  public int top_t = (int)(height*vpMoveScreenRatio);
  public int bottom_t = (int)(height*(1-vpMoveScreenRatio));

  
  private ArrayList<Wall> walls = new ArrayList<Wall>();
  private ArrayList<Bullet> bullets = new ArrayList<Bullet>();

  int cell_w = 4;  
  int cell_h = 4;

  private LinkedList<GameObject>[][] cells = new LinkedList[cell_w+1][cell_h+1];

  public GameMap(String fname) {
    loadMap(fname);
  }

  public void loadMap(String fname) {
    //set up collision cells
    for(int i = 0; i <= cell_w; i++){
     for(int j = 0; j <= cell_h; j++){
       cells[i][j] = new LinkedList<GameObject>();
     }
    }
    
    //load from file
    try {
      String[] maplines = loadStrings(dataPath("/sdcard/gunnerman/maps/"+fname));
      //highScore = int(scores[0]);
      sizeX = Integer.parseInt(maplines[0]);
      sizeY = Integer.parseInt(maplines[1]);
      
      for(int i = 2; i < maplines.length; i++){
        //println(maplines[i]);
         Scanner sc = new Scanner(maplines[i]);
         if(!sc.hasNext()){
            println("Bad wall line: " + maplines[i]);
            continue;
         }
         
         if(sc.next().equals("wall")){
           int wallx = sc.nextInt();
           int wally = sc.nextInt();
           int wallwidth = sc.nextInt();
           int wallheight = sc.nextInt();
           Wall w = new Wall(wallx,wally,wallwidth,wallheight, this);
           walls.add(w);
           add_to_collision_cells(w);
           
         } else {
           println("Bad wall line: " + maplines[i]);
         }
      }
      
      
    }catch (NullPointerException e){
      println("Error: " + e.getMessage());
    }
    
  }
  
  public void add_to_collision_cells(GameObject o){
    int i1 = (int)(((float)o.x/(float)sizeX)*cell_w);
    int j1 = (int)(((float)o.y/(float)sizeY)*cell_h);
    int i2 = (int)((float)(o.x+o.width)/(float)sizeX*cell_w);
    int j2 = (int)((float)(o.y+o.height)/(float)sizeY*cell_h);
    
    println("Adding new wall");
//    println("x=" + o.x + " y=" + o.y);
    //sprintln("i1 = " + i1 + " j1 = " + j1 + " i2 = " + i2 + " j2 = " + j2 );
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cells[i][j].contains(o)){
          println("\t cell " + i + ","+j);  
          cells[i][j].add(o);
        }
      }
    }
  }
  
  public void add_bullet(Bullet b){
    bullets.add(b);
  }
  
  public void update(){
    for(int i = 0; i < bullets.size(); i++) bullets.get(i).moveXY();
  }
  
  public void render(){
    renderWalls();
    renderBullets();
  }
  
  public void renderWalls(){
   for(int i = 0; i < walls.size(); i++) walls.get(i).render();
  }
  
  public void renderBullets(){
   for(int i = 0; i < bullets.size(); i++) bullets.get(i).render();
  }
  
  

  public int getScreenX(int x) {
    return x-vpX;
  }

  public int getScreenY(int y) {
    return y-vpY;
  }

  public void changeVpX(int change) {
    vpX += change;
  }

  public void changeVpY(int change) {
    vpY += change;
  }
  
  public LinkedList<LinkedList<GameObject>> getCellObjects(int x, int y, int w, int h){
    int i1 = (int)(((float)x/(float)sizeX) * cell_w);
    int j1 = (int)(((float)y/(float)sizeY) * cell_h);
    int i2 = (int)(((float)(x+w)/(float)sizeX) * cell_w);
    int j2 = (int)(((float)(y+h)/(float)sizeY) * cell_h);
    LinkedList<LinkedList<GameObject>> cellList = new LinkedList();
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cellList.contains(cells[i][j])){
          cellList.add(cells[i][j]);
        }
      }
    }
    return cellList;
  }
}

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
class Player extends GameObject{
  boolean show_coords = true;
  
  int sc_x;
  int sc_y;
  
  int size = 20;
  float dir = 0;
  int point_size = 20;
  
  int speed_cap = 10;
  float speed_scale = .5f;
  
  int ax=0;
  int ay=0;
  int dx=0;
  int dy=0;
  int friction = 1;
  
  //life
  private int max_lives = 5;
  int lives = max_lives;
  
  //weapons
  //0 Pistol
  int weapon;
  
  boolean fired;
  int fire_count = 0;
  int pistol_delay = 1000;
  
  PFont font = createFont("Arial Bold",48);
  
  //null for human controling 
  PlayerControl pc;
  
  Player(int x, int y, GameMap m, PlayerControl pc){
     this.alive = true;
     this.x=x;
     this.y=y;
     this.m=m;
     this.weapon = 0;
     fired = false;
     this.pc = pc;
     if(pc==null) show_coords = false;
  }
  
  public void moveXY(int ax_, int ay_){
    ax = ax_;
    ay = ay_;
  }
  
  private void update_pos(){

    dx = constrain(-speed_cap, dx, speed_cap);
    dy = constrain(-speed_cap, dy, speed_cap);
    dx*=speed_scale;
    dy*=speed_scale;
    
    if(dx==0 && dy==0) return;
    this.x += (dx);
    int c;
    if((c = check_collision(true))!=-999) this.x = c;
       
    this.y += (dy);
    if((c = check_collision(false))!=-999) this.y = c;

    if(pc==null){
      sc_x = m.getScreenX(x);
      sc_y = m.getScreenY(y);
      
      
      if(sc_x<m.left_t){
        sc_x = m.left_t;
        m.changeVpX(dx-1);

      }
      else if(sc_x>m.right_t){
        sc_x = m.right_t;
        m.changeVpX(dx+1);
      }
      
      if(sc_y<m.top_t){
        sc_y = m.top_t;
        m.changeVpY(dy-1);
        //println("sc_y " + sc_y + " m.top_t " + m.top_t);
      }
      else if(sc_y>m.bottom_t){
        sc_y = m.bottom_t;
        m.changeVpY(dy+1);
      }
    }
   }
   
 
  public int check_collision(boolean x_dir){
    LinkedList<LinkedList<GameObject>> local_objs = m.getCellObjects(x-this.size/2,y-this.size/2,this.size,this.size);
    
    //if (local_objs.size() == 0) return -999;
    
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
    if (x+size/2 > obj.x && x < obj.x+obj.width+size/2
      && y+size/2 > obj.y && y < obj.y+obj.height+size/2){
        if(x_dir){
          if(oc_x < x) return obj.x+obj.width+size/2;
          else return obj.x - size/2;
        } else {
          if(oc_y < y) return obj.y+obj.height+size/2;
          else return obj.y - size/2;
        }
    }
    return -999;
  }
  
  
  public void update(){
    
    dx+=ax;
    dy+=ay;
    
    update_pos();
    
    if(fired){
      if(millis() - fire_count >= pistol_delay){
       fired=false;
       fire_count = 0;
       //println("READY") ;
      }
    }   
    
    if(pc!=null){
      pc.update(this);
    }
   
  }
  
  public void fire(){
   
   if(!fired){
     fired=true;
     launch_bullet();
     if(weapon==0) fire_count = millis();
   }
    
  }
  
  private void launch_bullet(){
    //println("New bullet x " +x + " y " + y + " dir_x " + cos(-dir+(3.14/2))+sc_x + " dir_y " + sin(-dir+(3.14/2))+sc_y + " type " + weapon);
    Bullet b = new Bullet((int)(cos(-dir+(3.14f/2))*point_size+x), (int)(sin(-dir+(3.14f/2))*point_size+y), cos(-dir+(3.14f/2)), sin(-dir+(3.14f/2)), this.m, weapon);
    m.add_bullet(b);
  }
  
  public void render(){

    if(pc!=null){
       sc_x = m.getScreenX(x);
       sc_y = m.getScreenY(y);
    }
    
    line(sc_x,sc_y,cos(-dir+(3.14f/2))*point_size+sc_x, sin(-dir+(3.14f/2))*point_size+sc_y);
    ellipse(sc_x, sc_y, size,size);
    renderHUD();
  }
  
  private void renderHUD(){
    textFont(font,24);
     switch(weapon){
       case 0:
         text("Pistol", 50, 20);
         fill(0);
         rect(50,30, 40, 10);
         fill(255);
         if(fired)
           rect(50,30, (float)(millis()-fire_count)/(float)pistol_delay * 40, 10);
         else rect(50,30, 40, 10);
         break;
     }

    fill(0);
    for(int i=0; i<max_lives; i++) ellipse(50+(i*10), 50, 8, 8);
    fill(256);
    for(int i=0; i<lives; i++) ellipse(50+(i*10), 50, 8, 8);
    
    if(show_coords){
      textFont(font,12);
      fill(0);
      text("ax " + ax + " ay " + ay, 12, 65);
      text("vx " + dx + " vy " + dy, 12, 75);
      text("x " + x + " y " + y, 12, 85);
      text("scx " + sc_x + " scy " + sc_y, 12, 95);
      text("vpx " + m.vpX + " vpy " + m.vpY, 12, 105);      
    }
    
  }
}
interface PlayerControl {
  
  public void update(Player p);
  
}
class ViewPort{
  
  
}
class Wall extends GameObject{
  
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

}
