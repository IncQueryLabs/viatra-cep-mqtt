package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MqttSetup
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils

class JavaGenerator {

	public def generateJavaFiles(MqttSetup setup, Sensor sensor, String path) {
		val rootFolder = FileUtils.createFolder(path)
		val projectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.generated.java").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		createSubscribers(setup, sensor, srcFolder)
	}

	public def generateGeneralSubscriber(String path) {
		val rootFolder = FileUtils.createFolder(path)
		val projectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.generated.java").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		val subscriberFile = FileUtils.createFile(srcFolder, "Subscriber.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.java;
			
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			
			class Subscriber {
				
				private MqttClient client;
				private MqttConnectOptions connOpts;
				private MemoryPersistence persistance;
				
				public Subscriber(String brokerUrl, String clientId) {				
					persistance = new MemoryPersistence();
					client = new MqttClient(brokerUrl, clientId, persistance);
					connOpts = new MqttConnectOptions();
					connOpts.setCleanSession(true);
				}
				
				public void setCallback(MqttCallback callback) {
					client.setCallback(callback);
				}
				
				public void connect() {
					client.connect(connOpts);
				}
				
				public void subscribe(String topic) {
					client.subscribe(topic);
				}
				
				public void unsubscribe(String topic) {
					client.unsubscribe(topic);
				}
				
				public void disconnect() {
					client.disconnect();
				}
				
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	public def generateGeneralPublisher(String path) {
		val rootFolder = FileUtils.createFolder(path)
		val projectFolder = FileUtils.createFolder(new File(rootFolder, "hu.bme.thesis.generated.java").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		val subscriberFile = FileUtils.createFile(srcFolder, "Publisher.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.java;
			
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			
			class Publisher {
				
				private MqttClient client;
				private MqttConnectOptions connOpts;
				private MemoryPersistence persistance;
				
				public Publisher(String brokerUrl, String clientId) {				
					persistance = new MemoryPersistence();
					client = new MqttClient(brokerUrl, clientId, persistance);
					connOpts = new MqttConnectOptions();
					connOpts.setCleanSession(true);
				}
				
				public void connect() {
					client.connect(connOpts);
				}
				
				public void publish(String topic, byte[] payload, int qos) {
					client.publish(topic, payload, qos, false);
				}
				
				public void disconnect() {
					client.disconnect();
				}
				
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	public def generateGeneralCallback(String path) {
		val rootFolder = FileUtils.createFolder(path)
		val projectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.generated.java").absolutePath)
		val srcFolder = FileUtils.createFolder(new File(projectFolder, "src").absolutePath)
		val subscriberFile = FileUtils.createFile(srcFolder, "GeneralCallback.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.java;
			
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttMessage;
			import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
			
			class GeneralCallback implements MqttCallback {
				
				@Override
				public void deliveryComplete(IMqttDeliveryToken token) {
					System.out.println("Delivery completed!");
				}
				
				@Override
				public void messageArrived(String topic, MqttMessage message) throws Exception {
					arrived(topic, message.getPayload());
				}
				
				public void arrived(String topic, byte[] message);
				
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	private def createSubscribers(MqttSetup setup, Sensor sensor, File srcFolder) {
		val subscriberFile = FileUtils.createFile(srcFolder, sensor.name.toFirstUpper + "Receiver.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.generated.java;
			
			import com.fasterxml.jackson.core.JsonFactory;
			import com.fasterxml.jackson.databind.ObjectMapper;
			import org.eclipse.viatra.cep.mqtt.generated.java.GeneralCallback;
			import org.eclipse.viatra.cep.mqtt.generated.java.Subscriber;
			
			class «sensor.name»Receiver extends GeneralCallback {
				
				private Subscriber subscriber;
				
				public «sensor.name»Receiver() {				
					subscriber = new Subscriber("«setup.brokerUrl»", "«sensor.name.toUpperCase»_SUBSCRIBER");
					subscriber.setCallback(this);
				}
				
				public void connect() {
					subscriber.connect();
				}
				
				public void subscribe() {
					subscriber.subscribe(«sensor.name»);
				}
				
				public void unsubscribe() {
					subscriber.unsubscribe(«sensor.name»);
				}
				
				public void disconnect() {
					subscriber.disconnect();
				}
				
				@Override
				public void arrived(String topic, byte[] message) {
					String msg = new String(message);
					ObjectMapper mapper = new ObjectMapper(new JsonFactory());
					System.out.println("Get msg: " + msg);
					/*
					ThermoMessage thermoMessage = mapper.readValue(msg, ThermoMessage.class);
					System.out.println("temperature: " + thermoMessage.getTemperature());
					*/
				}
			}
		'''
		writer.write(fileContent)
		writer.close
	}

}