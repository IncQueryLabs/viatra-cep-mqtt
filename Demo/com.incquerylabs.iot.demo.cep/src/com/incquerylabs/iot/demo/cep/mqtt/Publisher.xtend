package com.incquerylabs.iot.demo.cep.mqtt

import org.eclipse.paho.client.mqttv3.MqttCallback
import org.eclipse.paho.client.mqttv3.MqttClient
import org.eclipse.paho.client.mqttv3.MqttConnectOptions
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence

class Publisher {
	
	protected MqttClient client
	protected MqttConnectOptions connOpts
	MemoryPersistence persistance
	
	new(String broker, String clientId) {
		persistance = new MemoryPersistence
		client = new MqttClient(broker, clientId, persistance)
		connOpts = new MqttConnectOptions
	}
	
	def setCallback(MqttCallback _callback) {
		client.callback = _callback
	}
	
	def connect() {
		client.connect(connOpts)
	}
	
	def Boolean isConnected() {
		if(client != null) {
			client.connected
		} else {
			false
		}
	}
	
	def publish(String topic, byte[] message, int qos) {
		client.publish(topic, message, qos, false)
	}
	
	def disconnect() {
		client.disconnect
	}
	
}