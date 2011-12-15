import oscP5.*;
import netP5.*;
import java.io.PrintStream;

class NetCom  implements NetListener {
  
  GameLoop gl;
  TcpClient myClient;
  UdpClient udpClient;
  int dataIn;
  PrintStream out;
  
  
  public NetCom(GameLoop gl, String ip, int port) throws Exception {
    
    if(ip == "") throw new Exception("Empty address");
    this.gl = gl;
    
    NetAddress a = new NetAddress(ip,port);
    
    if(a.isvalid()){
    
      myClient = new TcpClient(this, ip, port);
      udpClient = new UdpClient(ip, port+1);
      try{
        out = new PrintStream(myClient.socket().getOutputStream());
      }catch (IOException e){
        
      }
      
    } else {
      throw new Exception(ip + " address not found"); 
    }
  }
  
  public void quit(){
    myClient.dispose(); 
  }
  
  void netStatus(NetStatus theStatus){
    println("NetStatus:" + theStatus); 
  }
  
  void netEvent(NetMessage msg){
    println(">>" + msg.getString());
    gl.resolveMessage(msg.getString());
  }
  
  public void send(String msg){
    
    //try{
      
      
      println("sending: " + msg);
      //out.println(msg);
      myClient.send(msg+"\n");
    //}catch (IOException e){
    //  println("IOException: " + e.getMessage());
    //}
  }
}
