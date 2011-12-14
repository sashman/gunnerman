import oscP5.*;
import netP5.*;

class NetCom  implements NetListener {
  
  TcpClient myClient; 
  int dataIn; 
  
  
  public NetCom(String ip, int port) throws Exception {
    
    if(ip == "") throw new Exception("Empty address");
    
    NetAddress a = new NetAddress(ip,port);
    
    if(a.isvalid()){
    
      myClient = new TcpClient(this, ip, port);
      
    } else {
      throw new Exception(ip + " address not found"); 
    }
  }
  
  public void quit(){
    myClient.dispose(); 
  }
  
  void netStatus(NetStatus theStatus){
    println("net status"); 
  }
  
  void netEvent(NetMessage msg){
    println("sdfsdsvd");
  }
  
}
