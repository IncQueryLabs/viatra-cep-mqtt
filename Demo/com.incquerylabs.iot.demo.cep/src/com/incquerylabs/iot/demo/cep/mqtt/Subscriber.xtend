package com.incquerylabs.iot.demo.cep.mqtt

import org.eclipse.paho.client.mqttv3.MqttClient
import org.eclipse.paho.client.mqttv3.MqttConnectOptions
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence
import org.eclipse.paho.client.mqttv3.MqttCallback

class Subscriber {
	
	protected MqttClient client
	protected MqttConnectOptions connOpts
	MemoryPersistence persistance
	
	new(String broker, String clientId) {
		persistance = new MemoryPersistence
		client = new MqttClient(broker, clientId, persistance)
		connOpts = new MqttConnectOptions
	}
	
	def setCallback(MqttCallback callback) {
		client.callback = callback
	}
	
	def connect() {
		client.connect(connOpts)
	}
	
	def subscribe(String topic) {	
		client.subscribe(topic)
	}
	
	def unsubscribe(String topic) {
		client.unsubscribe(topic)
	}
	
	def disconnect() {
		client.disconnect
	}
	
}