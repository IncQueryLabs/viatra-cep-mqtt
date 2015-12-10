package org.eclipse.viatra.cep.mqtt.commons.mqtt;

import org.apache.log4j.Logger;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

/**
 * 
 * This class implements an MQTT subscriber, with basic functions.
 * 
 * @author Zoltan Selmeczi
 *
 */
public class Subscriber {

	protected MqttClient client;
	protected MqttConnectOptions connOpts;
	MemoryPersistence persistance = new MemoryPersistence();

	private static final Logger log4jLogger = Logger.getLogger(Subscriber.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);

	/**
	 * The constructor of the subscriber class.
	 * It makes an MQTT client with the given parameters.
	 * @param brokerUrl The broker url in "[protocol]://[host]:[port]" format.
	 * @param clientId The created client id.
	 */
	public Subscriber(String brokerUrl, String clientId) {
		try {
			client = new MqttClient(brokerUrl, clientId, persistance);
		} catch (MqttException e) {
			LOGGER.error("Could not create MQTTClient.", e);
		}
		connOpts = new MqttConnectOptions();
		connOpts.setCleanSession(true);
	}

	/**
	 * Sets the client callback parameter.
	 * @param callback
	 */
	public void setCallback(MqttCallback callback) {
		client.setCallback(callback);
	}

	/**
	 * This method connects the client to the MQTT broker.
	 */
	public void connect() {
		try {
			client.connect(connOpts);
		} catch (MqttException e) {
			LOGGER.error("Could not connect to MQTT broker.", e);
			System.exit(0);
		}
	}

	/**
	 * This method subscribes the client to the given topic.
	 * @param topic
	 */
	public void subscribe(String topic) {
		try {
			client.subscribe(topic);
		} catch (MqttException e) {
			LOGGER.error("Could not subscribe to the topic. [" + topic + "]", e);
		}
	}

	/**
	 * This method unsubscribe the client from the given topic.
	 * @param topic
	 */
	public void unsubscribe(String topic) {
		try {
			client.unsubscribe(topic);
		} catch (MqttException e) {
			LOGGER.error("Could not unsubscribe from the topic. [" + topic + "]", e);
		}
	}

	public void disconnect() {
		try {
			client.disconnect();
		} catch (MqttException e) {
			LOGGER.error("Could not disconnect from MQTT broker.", e);
		}
	}

}
