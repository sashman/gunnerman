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

  //private MapFile mapE;
  private ArrayList<Wall> walls = new ArrayList<Wall>();

  public GameMap() {

  }

  public void loadMap(String fname) {
    //File sdcard = Environment.getExternalStorageDirectory();
    
    String[] list = new String[3];
    list[0] = "500";
    list[1] = "500";
    list[2] = "wall 0 0 100 10";
    saveStrings("\\sdcard\\gunnerman\\maps\\"+fname, list);
    
    
    try {
      String[] maplines = loadStrings("\\sdcard\\gunnerman\\maps\\"+fname);
      //highScore = int(scores[0]);
      sizeX = Integer.parseInt(maplines[0]);
      sizeY = Integer.parseInt(maplines[1]);
      
      for(int i = 2; i < maplines.length; i++){
        println(maplines[i]);
         Scanner sc = new Scanner(maplines[i]);
         if(!sc.hasNext()){
            println("Bad wall line");
            continue;
         }
         
         if(sc.next().equals("wall")){
           int wallx = sc.nextInt();
           int wally = sc.nextInt();
           int wallwidth = sc.nextInt();
           int wallheight = sc.nextInt();
           Wall w = new Wall(wallx,wally,wallwidth,wallheight, this);
           walls.add(w);
         } else {
           println("Bad wall line");
         }
      }
      
      
    }catch (NullPointerException e){
      println("Error: " + e.getMessage());
    }
    
  }
  
  public void render(){
    renderWalls();
  }
  
  public void renderWalls(){
   for(int i = 0; i < walls.size(); i++){
     walls.get(i).render();
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
}

