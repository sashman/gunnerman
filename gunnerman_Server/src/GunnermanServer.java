import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.*;
import java.util.ArrayList;
import java.util.Scanner;

public class GunnermanServer {

	GameState gs;
	ServerSocket ss;
	Socket s;
	DatagramSocket udpServerSocket;
	ArrayList<Socket> connected = new ArrayList<Socket>();
	ArrayList<DatagramSocket> udp_connected = new ArrayList<DatagramSocket>();
	ArrayList<doComms> threads = new ArrayList<doComms>();
	int port;
	private static int maxConnections = 5;
	public static int game_start_delay = 5;

	byte[] receiveData = new byte[1024];
	byte[] sendData = new byte[1024];
	
	boolean close_server = false;

	public GunnermanServer(int port) {
		System.out.println("Starting gunnerman server");

		this.port = port;

		try {
			ss = new ServerSocket(port);
			ss.setSoTimeout(100);
			System.out.println("Started on "
					+ InetAddress.getLocalHost().getHostAddress() + ":" + port);
			gs = new GameState();

			int i = 0;
			while (true) {
				if (i++ < maxConnections) {
					// doComms connection;

					if (close_server)
						break;

					try {
						s = ss.accept();

						s.setSoTimeout(100);

						connected.add(s);
						doComms conn_c = new doComms(this, s);
						threads.add(conn_c);

						Thread t = new Thread(conn_c);
						t.start();
					} catch (SocketTimeoutException e) {
					}

				}
			}

			udpServerSocket = new DatagramSocket(port + 1);
			udpServerSocket.setSoTimeout(100);

			if (getState() == GameState.GAME_STATE) {
				System.out.println("GAME");
				
				while (true) {
					try {
						DatagramPacket receivePacket = new DatagramPacket(
								receiveData, receiveData.length);

						udpServerSocket.receive(receivePacket);

						String sentence = new String(receivePacket.getData());
						System.out.println("RECEIVED from "
								+ receivePacket.getAddress().getHostAddress()
								+ ": " + sentence.trim());
						resolveMsg(sentence.trim(), receivePacket.getAddress()
								.getHostAddress(), gs.players.get(receivePacket.getAddress().getHostAddress()));
						/*
						 * InetAddress IPAddress = receivePacket.getAddress();
						 * int port = receivePacket.getPort(); String
						 * capitalizedSentence = sentence.toUpperCase();
						 * sendData = capitalizedSentence.getBytes();
						 * DatagramPacket sendPacket = new DatagramPacket(
						 * sendData, sendData.length, IPAddress, port);
						 * udpServerSocket.send(sendPacket);
						 */
					} catch (SocketTimeoutException e) {

					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();

						// TODO: handle exception
					}
				}
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void broadcast(String msg) {
		System.out.println("SENDING TO ALL:: " + msg);
		for (Socket s : connected) {
			try {
				new PrintStream(s.getOutputStream()).println(msg);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public void udp_broadcast(String msg, int id) {
		for (doComms dc : threads) {
			if (dc.getPid() == id)
				continue;
			try {

				// System.out.println("TO " + dc.getP().ip);
				DatagramPacket sendPacket = new DatagramPacket(msg.getBytes(),
						msg.length(), new InetSocketAddress(dc.getP().ip,
								port + 1));
				udpServerSocket.send(sendPacket);

			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	synchronized public void setState(int s) {
		gs.current_state = s;
	}

	synchronized public int getState() {
		return gs.current_state;
	}

	/**
	 * @param args
	 *            - args[0] port number
	 */
	public static void main(String[] args) {
		int port;
		if (args.length > 0)
			port = Integer.parseInt(args[0]);
		else
			port = 55555;
		new GunnermanServer(port);

	}

	synchronized public void add_udp_socket(DatagramSocket s) {
		udp_connected.add(s);
	}

	synchronized public boolean isServerClosed() {
		return close_server;
	}

	synchronized public void setCloseServer(boolean b) {
		close_server = b;
	}

	public void resolveMsg(String msg, String ip, Player from_player) {
		Scanner sc = new Scanner(msg);
		if (!sc.hasNext()) {
			System.out.println("Empty message");
			return;
		}
		String type = sc.next();
		if (type.equals("pos")) {
			int x = sc.nextInt();
			int y = sc.nextInt();
			int dx = sc.nextInt();
			int dy = sc.nextInt();
			float dir = sc.nextFloat();

			// System.out.println("no. of udp sockets " + udp_connected.size());
			for (Player p : gs.players.values()) {
				System.out.println(p.id +"@" + p.ip + " " + ip);
				if (p.ip.equals(ip))
					continue;

				String msg_to_send = new String("playerpos " + from_player.id + " " + x
						+ " " + y + " " + dx + " " + dy + " " + dir);
				
				sendData = msg_to_send.getBytes();
				
				try {
					DatagramPacket sendPacket = new DatagramPacket(
							sendData, sendData.length,
							new InetSocketAddress(p.ip, port + 1));
					System.out.println("\tSENDING: " + msg_to_send);
					System.out.println("\tTO: id " + p.id + " " + sendPacket.getAddress() + ":"
							+ sendPacket.getPort());
					
					udpServerSocket.send(sendPacket);

				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (NullPointerException e) {
					System.err.println("No udp server " + p.id);// + " @ " +
																// msg.getAddress()
																// + " : " +
																// msg.getPort());
					System.err.println(e.getMessage());
				}
			}


		} else if (type.equals("fire")) {
			int x = sc.nextInt();
			int y = sc.nextInt();
			float dir = sc.nextFloat();
			for (Player p : gs.players.values()) {
				System.out.println(p.id +"@" + p.ip + " " + ip);
				if (p.ip.equals(ip))
					continue;

				String msg_to_send = new String("playerfire " + from_player.id + " " + x
						+ " " + y + " " + " " + dir);
				
				sendData = msg_to_send.getBytes();
				
				try {
					DatagramPacket sendPacket = new DatagramPacket(
							sendData, sendData.length,
							new InetSocketAddress(p.ip, port + 1));
					System.out.println("\tSENDING: " + msg_to_send);
					System.out.println("\tTO: id " + p.id + " " + sendPacket.getAddress() + ":"
							+ sendPacket.getPort());
					
					udpServerSocket.send(sendPacket);

				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (NullPointerException e) {
					System.err.println("No udp server " + p.id);// + " @ " +
																// msg.getAddress()
																// + " : " +
																// msg.getPort());
					System.err.println(e.getMessage());
				}
			}
		}

	}

}

class doComms implements Runnable {

	private Socket server;
	private String line, input;
	private Player p;
	PrintStream out;
	GunnermanServer master;

	doComms(GunnermanServer master, Socket server) {
		this.server = server;
		this.master = master;

		System.out.println("New connection "
				+ server.getInetAddress().getHostAddress());
		p = master.gs.new_player(server);

	}

	@Override
	public void run() {

		input = "";

		try {
			// Get input from the client
			DataInputStream in = new DataInputStream(server.getInputStream());
			BufferedReader d = new BufferedReader(new InputStreamReader(in));
			out = new PrintStream(server.getOutputStream());

			send("joined " + p.id);
			if (master.gs.players.size() > 1) {
				for (Player player : master.gs.players.values()) {
					if (p.id == player.id)
						continue;
					send("playerjoined " + player.id + " " + player.ready);
				}
			}

			master.broadcast("playerjoined " + p.id + " " + p.ready);

			if (master.getState() == GameState.LOBBY_STATE) {
				System.out.println("LOBBY");

				// lobby state
				while (true) {
					if (master.isServerClosed()) {
						server.close();
						break;
					}

					try {

						input = "";
						input = d.readLine();

						/*
						 * while((line = in.readLine()) != null){
						 * 
						 * input = input + line;
						 * 
						 * }
						 */
						if (input.length() > 0) {
							resolveMsg(input);
						}

						Thread.sleep(100);

					} catch (NullPointerException e) {
						System.out.println("SOCKET DISCONNECTED");
						break;
					} catch (InterruptedException e) {

						e.printStackTrace();
					} catch (SocketTimeoutException e) {
						// System.out.println("Waiting...");
					}

				}
			}

			System.out.println("Closed TCP id: " + p.id + " finishing thread");

			// 
		} catch (IOException ioe) {
			System.out.println("IOException on socket listen: " + ioe);
			ioe.printStackTrace();
		}
	}

	public void resolveMsg(String msg) {
		Scanner sc = new Scanner(msg);
		if (!sc.hasNext()) {
			System.out.println("Empty message");
			return;
		}

		String type = sc.next();
		if (type.equals("ready")) {
			p.ready = p.ready ? false : true;
			master.broadcast("playerready " + p.id);
			if (p.ready)
				master.gs.ready_count++;
			else
				master.gs.ready_count--;

			if (master.gs.players.size() > 1
					&& master.gs.ready_count >= master.gs.players.size()) {

				System.out.println("All players ready! Starting game");
				master.broadcast("gamestarting "
						+ GunnermanServer.game_start_delay);
				try {
					Thread.sleep(GunnermanServer.game_start_delay * 1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				master.broadcast("gamestart");
				master.setState(GameState.GAME_STATE);
				master.setCloseServer(true);

			}
		}
	}

	public Player getP() {
		return p;
	}

	public int getPid() {
		return p.id;
	}

	public void send(String s) {
		System.out.println("SENDING::: " + s);
		out.println(s);
	}

}