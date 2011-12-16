import oscP5.*;
import netP5.*;
import java.io.PrintStream;


class NetCom  implements NetListener {
  
  GameLoop gl;
  TcpClient myClient;
  UdpClient udpClient;
  UdpServer udpServer;
  int dataIn;
  PrintStream out;
  String ip;
  int port;
  
  
  
  public NetCom(GameLoop gl, String ip, int port) throws Exception {
    this.ip = ip;
    this.port = port;
    
    
    if(ip == "") throw new Exception("Empty address");
    this.gl = gl;
    
    NetAddress a = new NetAddress(ip,port);
    
    if(a.isvalid()){
    
      myClient = new TcpClient(this, ip, port);
      
      try{
        out = new PrintStream(myClient.socket().getOutputStream());
      }catch (IOException e){
        
      }
      
    } else {
      throw new Exception(ip + " address not found"); 
    }
  }
  
  public void change_to_gamestate(){
    //myClient.dispose(); 
    udpClient = new UdpClient(ip, port+1);
    udpServer = new UdpServer(this, port+1);
    
  }
  
  void netStatus(NetStatus theStatus){
    println("NetStatus:" + theStatus); 
  }
  
  void netEvent(NetMessage msg){
    String m = msg.getString().trim();
    println(">>" + m);
    gl.resolveMessage(m);
  }
  
  public void send(String msg){
    println("sending: " + msg);
    myClient.send(msg+"\n");
  }
  
  public void udp_send(String msg){
    if(udpClient==null){
      println("no udp socket");
      return;
    }
    udpClient.send(msg+"\n");
  }
}
