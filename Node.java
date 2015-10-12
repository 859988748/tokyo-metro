package com.itouchchina.metro;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class Node {
	//站点
	private Station station;
	//所有可到达的节点
	private ArrayList<Node> next = new ArrayList<Node>();
	//所有前置节点，即prev中所有节点都可以到当前节点
	private ArrayList<Node> prev = new ArrayList<Node>();
	//到站时间
	private int time;
	//线路id，不同routeId直接需要换乘，有换乘时间
	private int routeId;
	//是否被访问到
	private boolean visited;
	private boolean backVisited;
	private Node prevNode;
	//班次id
	private int tripId;
	private int value;

	public Node(Station station, int time, int routeId, int tripId) {
		this.station = station;
		this.time = time;
		this.routeId = routeId;
		this.tripId = tripId;
	}
	
	public int getRouteId(){
		return routeId;
	}
	
	public int getTime(){
		return time;
	}
	
	public void setTime(int time){
		this.time = time;
	}
	
	public static void link(Node from, Node to){
		from.next.add(to);
		to.prev.add(from);
	}
	
	public Station getStation(){
		return station;
	}
	
	public void init(){
		this.visited = false;
		this.backVisited = false;
		this.value = Integer.MAX_VALUE;
	}
	
	public boolean isVisited(){
		return visited;
	}
	
	public boolean isBackVisited(){
		return backVisited;
	}
	
	public void backVisit(){
		if(this.backVisited){
			return;
		}
		this.backVisited = true;
		for(int i = 0;i<prev.size();i++){
			prev.get(i).backVisit();
		}
	}
	
	//访问所有可到达的节点，把visited标记为true
	public void visit(){
		if(this.visited){
			return;
		}
		this.visited = true;
		for(int i = 0;i<next.size();i++){
			next.get(i).visit();
		}
	}
	
	public String getTimeStr(){
		int time = this.time;
		String s = "";
		s = time % 60 + "";
		time = time / 60;
		s = time % 60 + ":" + s;
		time = time / 60;
		s = time % 60 + ":" + s;
		return s;
	}
	
	public Node[] getForwardPath(){
		LinkedList<Node> list = new LinkedList<Node>();
		Node node = this;
		boolean trans = true;
		while(true){
			list.add(node);
			Node next = node.findNext(trans);
			if(next == null){
				break;
			}
			if(trans && next.getStation() == node.getStation()){
				list.removeLast();
			}
			trans = next.tripId != node.tripId;
			node = next;
		}
		return filter(list.toArray(new Node[0]));
	}
	
	private int getPriority(Node node, boolean trans){
		if(node == null){
			return 0;
		}
		if(trans){
			if(node.station != this.station){
				return 1;
			}
			if(node.routeId != this.routeId){
				return 2;
			}
			return 3;
		} else {
			if(node.tripId == node.tripId){
				return 3;
			}
			if(node.routeId == node.routeId){
				return 2;
			}
			return 1;
		}
	}

	private Node findPrev(boolean trans){
		Node best = null;
		for(int i = 0;i<prev.size();i++){
			Node p = prev.get(i);
			if(p.visited){
				if(this.getPriority(best, trans) < this.getPriority(p, trans)){
					best = p;
				}
			}
		}
		return best;
	}
	
	private Node findNext(boolean trans){
		Node best = null;
		for(int i = 0;i<next.size();i++){
			Node p = next.get(i);
			if(p.backVisited){
				if(this.getPriority(best, trans) < this.getPriority(p, trans)){
					best = p;
				}
			}
		}
		return best;
	}
	
	private static Node[] filter(Node[] nodes){
		LinkedList<Node> list = new LinkedList<Node>();
		boolean trans = true;
		for(int i = 0;i<nodes.length;i++){
			list.addLast(nodes[i]);
			if(i + 1 >= nodes.length){
				if(trans){
					list.removeLast();
				}
				break;
			}
			if(trans && nodes[i + 1].tripId != nodes[i].tripId){
				list.removeLast();
			}
			trans = nodes[i + 1].tripId != nodes[i].tripId;
		}
		return list.toArray(new Node[0]);
	}

	/**
	 * @return
	 */
	public Node[] getBackwardPath(){
		LinkedList<Node> list = new LinkedList<Node>();
		Node node = this;
		boolean trans = true;
		while(true){
			list.addFirst(node);
			Node next = node.findPrev(trans);
			if(next == null){
				break;
			}
			trans = next.tripId != node.tripId;
			node = next;
		}
		return filter(list.toArray(new Node[0]));
	}
	
	/**
	 * 用Dijkstra算法找到换乘最少的路径
	 */
	public Node[] getBestPath(Node end){
		LinkedList<Node> list = new LinkedList<Node>();
		//更新所有换乘节点的换乘次数
		updateTransValue(null, this, 0);
		//更新所有节点的换乘次数
		updateValue(null, this, 0);
		Node node = end;
		while(true){
			list.addFirst(node);
			node = node.prevNode;
			if(node == null){
				return filter(list.toArray(new Node[0]));
			}
		}
	}
	
	public List<Node> getNextNodes(){
		return next;
	}
	
	/**
	 * 更新最少换乘次数
	 * @param node
	 * @param value 最少换乘次数
	 */
	private void updateValue(Node prevNode, Node node, int value){
		if(node.value > value){
			node.prevNode = prevNode;
			node.value = value;
			for(Node child : node.next){
				if(child.backVisited && child.visited){
					if(child.station == node.station){
						//如果是换乘次数+1
						updateTransValue(node, child, value + 1);
						updateValue(node, child, value + 1);
					} else {
						//如果不是换乘，则换乘次数不变
						updateValue(node, child, value);
					}
				}
			}
		}
	}
	
	/**
	 * 更新所有换乘节点的最少换乘次数
	 * @param node
	 * @param value 最少换乘次数
	 */
	private void updateTransValue(Node prevNode, Node node, int value){
		for(Node child : node.next){
			if(child.backVisited && child.visited && child.station == node.station){
				updateTransValue(prevNode, child, value);
				updateValue(prevNode, child, value);
			}
		}
	}
	
	public int getTripId(){
		return tripId;
	}
	
	public String toString() {
		return station.getId() + "\t"+station.getName() + "\t" + getTimeStr() + "\t" + this.routeId + "号线(班次"+tripId+")";
	}
}
