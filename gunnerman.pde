

int pad_size = 150;
int subpad_size = 50;
int left_spad_x;
int left_spad_y;

int right_spad_x;
int right_spad_y;

int left_xinit; //= (int)(pad_size/1.5);
int left_yinit; //= height-(int)(pad_size/1.5);
int right_xinit; //= width-(int)(pad_size/1.5);
int right_yinit; //= height-(int)(pad_size/1.5);

Player player;


void setup() {
  player = new Player(width/2, height/2);
  
  left_xinit = (int)(pad_size/1.5);
  left_yinit = height-(int)(pad_size/1.5);
  right_xinit = width-(int)(pad_size/1.5);
  right_yinit = height-(int)(pad_size/1.5);
  
  left_spad_x = left_xinit;
  left_spad_y = left_yinit;
  right_spad_x = right_xinit;
  right_spad_y = right_yinit;
  //left_spad_x = 100;
  //left_spad_y = 100;
  
  size(800, 480);
  smooth();
}

void draw() {
  
  background(240);
  
  player.render();
  draw_controls();
  
  
  
  
  if (mousePressed) {
    int t_dx = (pad_size/2);//threshhold
    int dx = (int)sqrt((int)(pow(left_xinit-mouseX, 2) + (int)pow(left_yinit-mouseY, 2)));
    if(t_dx > dx){
      left_spad_x = mouseX;
      left_spad_y = mouseY;
      
    }
  } else {
    left_spad_x = left_xinit;
    left_spad_y = left_yinit;
  }
  
  /*
  ellipse(mouseX, mouseY, 80, 80);
  */
}


public void draw_controls(){
  ellipse((pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(width-(pad_size/1.5), height-(pad_size/1.5), pad_size,pad_size);
  ellipse(left_spad_x, left_spad_y, subpad_size,subpad_size);
  ellipse(right_spad_x, right_spad_y, subpad_size,subpad_size);
}
