import java.util.*;
import java.io.*;

class GameMap {
  int sizeX =0;
  int sizeY =0;

  int vpX = 0;
  int vpY = 0;

  float vpMoveScreenRatio = .3;
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

