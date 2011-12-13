import java.util.*;
import java.io.*;

class GameMap {
  int sizeX =0;
  int sizeY =0;

  public int vpX = 0;
  public int vpY = 0;

  float vpMoveScreenRatio = .3;
  public int left_t = (int)(width*vpMoveScreenRatio);
  public int right_t = (int)(width*(1-vpMoveScreenRatio));
  public int top_t = (int)(height*vpMoveScreenRatio);
  public int bottom_t = (int)(height*(1-vpMoveScreenRatio));

  
  private ArrayList<Wall> walls = new ArrayList<Wall>();
  private ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  public ArrayList<Player> players = new ArrayList<Player>();

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
           //println("Wall " + wallx + " " + wally + " " + wallwidth + " " + wallheight);
           Wall w = new Wall(wallx,wally,wallwidth,wallheight, this);
           walls.add(w);
           add_to_collision_cells(w);
           
         } else {
           println("Bad wall line: " + maplines[i]);
         }
      }
      
      
    }catch (Exception e){
      println("Error: " + e.getMessage());
      println("Creating map!");
      sizeX = 1000;
      sizeY = 500;
      Wall w = new Wall(0,0,1000,10,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(0,500,1000,10,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(0,0,10,500,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(1000,0,10,500,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(333,100,10,300,this);
      walls.add(w);
      add_to_collision_cells(w);
      w = new Wall(666,100,10,300,this);
      walls.add(w);
      add_to_collision_cells(w);
    }
    
  }
  
  public void add_to_collision_cells(GameObject o){
    int i1 = (int)(((float)o.x/(float)sizeX)*cell_w);
    int j1 = (int)(((float)o.y/(float)sizeY)*cell_h);
    int i2 = (int)((float)(o.x+o.width)/(float)sizeX*cell_w);
    int j2 = (int)((float)(o.y+o.height)/(float)sizeY*cell_h);
    
    //println("Adding new wall");
//    println("x=" + o.x + " y=" + o.y);
    //println("i1 = " + i1 + " j1 = " + j1 + " i2 = " + i2 + " j2 = " + j2 );
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cells[i][j].contains(o)){
          //println("\t cell " + i + ","+j);  
          cells[i][j].add(o);
        }
      }
    }
  }
  
  public void add_to_collision_cells(Player p){
    int i1 = (int)(((float)(p.x-(p.size/2))/(float)sizeX)*cell_w);
    int j1 = (int)(((float)(p.y-(p.size/2))/(float)sizeY)*cell_h);
    int i2 = (int)((float)(p.x+(p.size/2))/(float)sizeX*cell_w);
    int j2 = (int)((float)(p.y+(p.size/2))/(float)sizeY*cell_h);
    
    //println("i1 = " + i1 + " j1 = " + j1 + " i2 = " + i2 + " j2 = " + j2 );
    
    if(p.relevant_cells.size()>0 && p.relevant_cells.getFirst()[0] == i1 && p.relevant_cells.getFirst()[1] == j1 &&
                                    p.relevant_cells.getLast()[0] == i2 && p.relevant_cells.getLast()[1] == j2) return;
                                    else{
                                      for(int i = 0; i<p.relevant_cells.size(); i++){
                                        cells[p.relevant_cells.get(i)[0]][p.relevant_cells.get(i)[1]].remove(p);
                                      }
                                      p.relevant_cells = new LinkedList<int[]>();
                                    }
    

    //println("Player in added in");
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        int[] cellpair = {i,j};
        p.relevant_cells.add(cellpair);
        if(!cells[i][j].contains(p)){
          //println("\t cell " + i + ","+j);  
          cells[i][j].add(p);
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
   for(int i = 0; i < bullets.size(); i++){

     bullets.get(i).render();
     if(!bullets.get(i).alive) bullets.remove(i);
   }
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
    try{    
    for(int i = i1; i<=i2; i++){
      for(int j = j1; j<=j2; j++){
        
        if(!cellList.contains(cells[i][j])){
          cellList.add(cells[i][j]);
        }
      }
    }
    } catch (ArrayIndexOutOfBoundsException e){
      println("ArrayIndexOutOfBoundsException: " + e.getMessage() + " i1 " + i1 + " j1 " + j1 + " i2 " + i2 + " j2 " +j2 + " x " + x + " y " + y);
    }
    return cellList;
  }
}

