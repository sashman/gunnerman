int pad_size = 150;
Player player;


void setup() {
  player = new Player(width/2, height/2);
  
  
  size(800, 480);
  smooth();
}

void draw() {
  
  
  
  player.render();
  draw_controls();
  
  
  
  
  /*if (mousePressed) {
    fill(0);
  } else {
    fill(255);
  }
  ellipse(mouseX, mouseY, 80, 80);
  */
}


public void draw_controls(){
  ellipse((pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(width-(pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size); 
}
