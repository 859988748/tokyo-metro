package com.itouchchina.metro;

import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

public class Station {
	
	private static final int transTime = 100;//换乘时间，单位是秒，必须>0，不同线路之间换乘暂时认为是统一的换乘时间
	
	private String name;//站名
	
	private String id;
	
	/**
	 * 节点Map<到站时间, 节点>
	 */
	private Map<Long, Node> nodeMap = new TreeMap<Long, Node>();
	
	/**
	 * 所有节点
	 */
	private Node[] nodes = null;

	public Station(String id, String name){
		this.id = id;
		this.name = name;
	}
	
	public String getName(){
		return name;
	}
	
	public String getId(){
		return id;
	}
	
	public Node setNode(int arriveTime, int routeId, int tripId){
		long key = arriveTime * 50000 + tripId;
		Node node = nodeMap.get(key);
		if(node == null){
			node = new Node(this, arriveTime, routeId, tripId);
			nodeMap.put(key, node);
		}
		return node;
	}
	
	public int getNodeCount(){
		return nodes.length;
	}
	
	public Node getNode(int index){
		return nodes[index];
	}
	
	public int getTransTime(int route_from, int route_to){
		if(route_from == route_to){
			return 0;
		}
		return Station.transTime;
	}
	
	/**
	 * 对站内等待或者换乘的节点进行连接
	 * 如果两个节点是同一站，同一线路，不需要考虑换乘时间
	 * 如果两个节点是同一站的不同路线，需要考虑换乘时间
	 * 对于同一路线只连接最相邻的两个节点
	 * 对于不同路线只连接最相邻的两个节点
	 */
	public void selfLink(){
		nodes = nodeMap.values().toArray(new Node[0]);
		Set<Integer> routes = new TreeSet<Integer>();
		for(int i = 0;i<nodes.length;i++){
			routes.add(nodes[i].getRouteId());
		}
		for (int i = 0; i < nodes.length; i++) {
			Node from = nodes[i];
			for (int route : routes) {
				int trans = getTransTime(from.getRouteId(), route);
				for (int j = 0; j < nodes.length; j++) {
					Node to = nodes[j];
					if(to.getRouteId() == route){
						if(to.getTime() > from.getTime() + trans){
							Node.link(from, to);
							break;
						}
					}
				}
			}
		}
		
	}
	
	public void init(){
		for(int i = 0;i<nodes.length;i++){
			nodes[i].init();
		}
	}
		
	public Node getBestNode(){
		for(int i = 0;i<nodes.length;i++){
			if(nodes[i].isVisited()){
				return nodes[i];
			}
		}
		return null;
	}
}
