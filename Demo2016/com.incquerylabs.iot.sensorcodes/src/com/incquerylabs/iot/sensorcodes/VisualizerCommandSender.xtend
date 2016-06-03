package com.incquerylabs.iot.sensorcodes

import org.eclipse.viatra.cep.mqtt.commons.mqtt.Publisher

class VisualizerCommandSender {

	public static VisualizerCommandSender instance = null
	public static String brokerUrl = "tcp://127.0.0.1:1883"
	
	enum LockingState {
		INIT,
		INCORRECT_PASS,
		CORRECT_PASS
	}
	private val String LOCKING_STATE_TOPIC = "lock/all/state"
	
	
	static def VisualizerCommandSender getInstance(){
		if(instance == null){
			return new VisualizerCommandSender(brokerUrl)
		}
		return instance;
	}
	
	val Publisher publisher
	
	private new(String brokerUrl){
		this.publisher = new Publisher(brokerUrl, "visualizer_"+System.nanoTime)
		this.publisher.connect
	}
	
	def void sendLockPositionChangeMessage(String lockID, int position){
		if(this.publisher?.isConnected){
			val topic = calculateTopic(lockID)
			val msg = createPosChangeMsg(position)
			
			this.publisher.publish(topic, msg);
		}else{
			System.err.println("Publisher is not connected (VisualizerCommandSender.sendLockPositionChangeMessage)");
		}
	}
	
	def void sendLockingStateChangeMessgae(LockingState state){
		if(this.publisher?.isConnected){
			val msg = createLockingStateMsg(state)
			this.publisher.publish(LOCKING_STATE_TOPIC, msg);
		}else{
			System.err.println("Publisher is not connected (VisualizerCommandSender.sendLockingStateChangeMessgae)");
		}
	}
	
	def String createLockingStateMsg(LockingState newState)'''{ "state" : «newState.name.toLowerCase» }'''
	
	def String createPosChangeMsg(int newPosition)'''{ "position" : «newPosition» }'''
	
	def String calculateTopic(String lockID) {
		var int sensorID = 0;
		switch (lockID) {
			case "A": {
				sensorID = 1
			}
			case "B": {
				sensorID = 2
			}
			case "C": {
				sensorID = 3
			}
			case "D": {
				sensorID = 4
			}
			default: {
				sensorID = 0 //XXX
			}
		}
		
		return "lock/" + sensorID + "/pos_change"
	}
	
}