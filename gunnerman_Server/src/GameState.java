import java.net.Socket;
import java.util.HashMap;


public class GameState {
	
	public static final int LOBBY_STATE = 0;
	public static final int GAME_STATE = 1;
	public static final int SCORE_STATE = 2;
	int current_state = LOBBY_STATE;
	
	public int ready_count = 0;
	
	HashMap<String, Player> players = new HashMap<String, Player>();
	
	
	
	

	
	synchronized public Player new_player(Socket s){
		Player p = new Player(players.size(), false, 0, 0, 0, 0, 0, s.getInetAddress().getHostAddress(), s.getPort());
		players.put(s.getInetAddress().getHostAddress(), p);
		return p;
	}
}

class Player{
	
	public int id;
	public boolean ready;
	public int x;
	public int y;
	public int vx;
	public int vy;
	public float dir;
	
	public String ip;
	public int port;
	
	public Player(int id, boolean ready, int x, int y, int vx, int vy, float dir, String ip, int port) {
		super();
		this.id = id;
		this.ready = ready;
		this.x = x;
		this.y = y;
		this.vx = vx;
		this.vy = vy;
		this.dir = dir;
		this.ip = ip;
		this.port = port;
		
	}
	
	
	
}