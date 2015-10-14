package com.itouchchina.metro;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;

public class Metro {

	/**
	 * <站id,站>
	 */
	private Map<String, Station> stationMap = new TreeMap<String, Station>();
	/**
	 * <班次Id,路线Id>
	 */
	private Map<Integer, Integer> tripMap = new TreeMap<Integer, Integer>();
	/**
	 * 所有的站
	 */
	private Station[] stations;

	public Metro() {
		
	}
	
	public void load() throws IOException{
		loadTrips(IOUtil.read(Metro.class.getResourceAsStream("/data/trips.txt")));
		loadStations(IOUtil.read(Metro.class.getResourceAsStream("/data/stops.txt")));
		loadStationNodes(IOUtil.read(Metro.class.getResourceAsStream("/data/stop_times.txt")));
	}
	
	private void loadTrips(String s){
		String[] lines = s.split("\n");
		for (int i = 1; i < lines.length; i++) {
			String[] items = lines[i].split(",");
			int routeId = Integer.parseInt(items[0]);
			int tripId = Integer.parseInt(items[2]);
			tripMap.put(tripId, routeId);
		}
	}

	private void loadStations(String s) {
		String[] lines = s.split("\n");
		for (int i = 1; i < lines.length; i++) {
			String[] items = lines[i].split(",");
			String id = items[0];
			String name = items[2];
			stationMap.put(id, new Station(id, name));
		}
		stations = stationMap.values().toArray(new Station[0]);
	}

	private static int getTime(String time){
		String[] item = time.split(":");
		int t = Integer.parseInt(item[0]) * 3600 + Integer.parseInt(item[1]) * 60 + Integer.parseInt(item[2]);
		return t;
	}
	
	private void loadStationNodes(String s) {
		String[] stopTimes = s.split("\n");
		int lastTrip = 0;
		Node lastNode = null;
		for(int i = 1;i<stopTimes.length;i++){
			String[] items = stopTimes[i].split(",");
			int trip = Integer.parseInt(items[0]);
			int route = tripMap.get(trip);
			int arriveTime = getTime(items[1]);
			String stationId = items[3];
			if(trip == lastTrip &&lastNode.getTime() == arriveTime){
				arriveTime += 1;
			}
			Node node = stationMap.get(stationId).setNode(arriveTime, route, trip);
			if(trip == lastTrip){//如果是同一班次，连接前后两个节点
				Node.link(lastNode, node);
			}
			lastTrip = trip;
			lastNode = node;
		}
		for(int i = 0;i<stations.length;i++){
			stations[i].selfLink();
		}
	}
	
	public Node[][] getBestPath(String start, String time, int routeId, String stop, int max){
		Station startS = null;
		Station stopS = null;
		for(int i = 0;i<stations.length;i++){
			if(stations[i].getName().equals(start)){
				startS = stations[i];
			} 
			if(stations[i].getName().equals(stop)){
				stopS = stations[i];
			}
			if(startS != null && stopS != null){
				break;
			}
		}
		int t = getTime(time);
		Node startNode = null;
		for(int i = 0;i<startS.getNodeCount();i++){
			Node n = startS.getNode(i);
			if(n.getTime() >= t && n.getRouteId() == routeId){
				startNode = n;
				break;
			}
		}
		return this.getBestPath(startNode, stopS, max);
	}
	
	private static boolean add(List<Node[]> list, Node[] path){
		for(int i = 0;i<list.size();i++){
			if(equals(list.get(i), path)){
				return false;
			}
		}
		list.add(path);
		return true;
	}
	
	private static boolean equals(Node[] p1, Node[] p2){
		if(p1.length != p2.length){
			return false;
		}
		for(int i = 0;i<p1.length;i++){
			if(p1[i] != p2[i]){
				return false;
			}
		}
		return true;
	}

	/**
	 * 获取最短时间的路径
	 * @param begin 开始的节点（站，时间）
	 * @param end 到达站点
	 * @return
	 */
	public Node[][] getBestPath(Node begin, Station end, int max){
		List<Node[]> path = new ArrayList<Node[]>();
		for(Station s: stations){
			s.init();
		}
		begin.visit();
		Node bestEnd = end.getBestNode();
		int nodeCount = 0;
		for(int j = 0;j<end.getNodeCount();j++){
			Node endNode = end.getNode(j);
			if(!endNode.isVisited()){
				continue;
			}
			nodeCount ++;
			if(nodeCount > 5){
				break;
			}
			endNode.backVisit();
			int count = 0;
			for(Station s: stations){
				for(int i = 0;i<s.getNodeCount();i++){
					if(s.getNode(i).isBackVisited() && s.getNode(i).isVisited()){
						count ++;
					}
				}
			}
			if(count < 500){//如果中间节点个数不多，则通过最短路径算法求最少换乘路径
				add(path, begin.getBestPath(bestEnd));
				if(path.size() > max){
					break;
				}
			}
			add(path, begin.getForwardPath());
			if(path.size() > max){
				break;
			}
			add(path, bestEnd.getBackwardPath());
			if(path.size() > max){
				break;
			}
		}
		return path.toArray(new Node[0][]);
	}
	
	private static class MetroPane extends JPanel implements ActionListener{

		private static final long serialVersionUID = 1L;
		private Metro m;
		private JTabbedPane tabPane;
		private MetroPane() throws IOException{
			m = new Metro();
			m.load();
			setLayout(new BorderLayout());
			tabPane = new JTabbedPane();
			add(tabPane);
			JButton btn = new JButton("查询");
			add(btn, BorderLayout.SOUTH);
			btn.addActionListener(this);
		}
		@Override
		public void actionPerformed(ActionEvent arg0) {
			System.err.println("startNode:"+m.stations[0].getNode(30).getStation().getName());
			System.err.println("EndStation:"+m.stations[212].getName());
			long t = System.currentTimeMillis();
			tabPane.removeAll();
			Node[][] path = m.getBestPath("代代木", "9:4:0", 154, "日比谷", 10);
//			Node[][] path = m.getBestPath(m.stations[0].getNode(30), m.stations[212], 10);
//			Node[][] path = m.getBestPath(m.stations[20].getNode(0), m.stations[212], 10);
			System.err.println("算法耗时:"+(System.currentTimeMillis() - t));
			for(int i = 0;i<path.length;i++){
				tabPane.addTab(""+i,new JScrollPane(new JTable(new PathTableModel(path[i]))));
			}
		}
		
	}
	
	public static void main(String[] args) throws IOException{
		
		
		JFrame f = new JFrame();
		f.addWindowListener(new WindowAdapter(){

			@Override
			public void windowClosing(WindowEvent arg0) {
				System.exit(0);
			}
			
		});
		f.setContentPane(new MetroPane());
		f.setSize(500, 500);
		f.setVisible(true);
		
	}
}
