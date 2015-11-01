package org.eclipse.viatra.cep.mqtt.commons.mqtt;

import java.io.UnsupportedEncodingException;

import org.apache.log4j.Logger;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

public class Publisher {

	protected MqttClient client;
	protected MqttConnectOptions connOpts;
	MemoryPersistence persistance = new MemoryPersistence();

	private static final Logger log4jLogger = Logger.getLogger(Publisher.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);

	public Publisher(String brokerUrl, String clientId) {
		try {
			client = new MqttClient(brokerUrl, clientId, persistance);
		} catch (MqttException e) {
			LOGGER.error("Could not create MQTTClient.", e);
		}
		connOpts = new MqttConnectOptions();
		connOpts.setCleanSession(true);
	}

	public void connect() {
		try {
			client.connect(connOpts);
		} catch (MqttException e) {
			LOGGER.error("Could not connect to MQTT broker.", e);
			System.exit(0);
		}
	}

	public void publish(String topic, String payload, int qos) {
		try {
			publish(topic, payload.getBytes("UTF-8"), qos);
		} catch (UnsupportedEncodingException e) {
			LOGGER.error("Could not encode message. [" + payload + "]", e);
		}
	}
	
	public void publish(String topic, String payload) {
		this.publish(topic, payload);
	}
	
	public void publish(String topic, byte[] payload, int qos) {
		MqttMessage message = new MqttMessage(payload);
		message.setQos(qos);
		message.setRetained(false);
		try {
			client.publish(topic, message);
		} catch (MqttException e) {
			LOGGER.error("Could not publish MQTT message.", e);
		}
	}
	
	public void publish(String topic, byte[] payload) {
		this.publish(topic, payload, 0);
	}

	public boolean isConnected() {
		if(client != null)
			return client.isConnected();
		else
			return false;
	}
	
	public void disconnect() {
		try {
			client.disconnect();
		} catch (MqttException e) {
			LOGGER.error("Could not disconnect from MQTT broker.", e);
		}
	}

}
