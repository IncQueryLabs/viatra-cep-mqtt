package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import java.io.FileWriter
import org.eclipse.viatra.cep.mqtt.midl.mIDL.MqttSetup
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import org.eclipse.emf.common.util.EList

class JavaGenerator {

	File rootFolder;
	File receiverProjectFolder;
	File receiverSrcFolder;
	File receiverTopPackage;

	new(String rootPath) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		receiverProjectFolder = FileUtils.createFolder(new File(rootFolder, "org.eclipse.viatra.cep.mqtt.receiver"))
		receiverSrcFolder = FileUtils.createFolder(new File(receiverProjectFolder, "src"))
		receiverTopPackage = FileUtils.createPackage(receiverSrcFolder, "org.eclipse.viatra.cep.mqtt.receiver")
	}

	public def generateGeneralJavaFiles() {
		generateLoggerUtil
		generateGeneralPublisher
		generateGeneralSubscriber
	}

	public def generateNonGeneralJavaFiles(MqttSetup setup, Sensor sensor, String path) {
	}

	private def generateLoggerUtil() {
		val subscriberFile = FileUtils.createFile(receiverTopPackage, "LoggerUtil.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.receiver;
			
			import org.apache.log4j.Logger;
			
			public class LoggerUtil {
			
				private final Logger logger;
			
				public LoggerUtil(Logger logger) {
					this.logger = logger;
				}
			
				public void error(String msg) {
					System.err.println(msg);
					logger.error(msg);
				}
			
				public void error(String msg, Throwable t) {
					System.err.println(msg);
					logger.error(msg, t);
				}
			
				public void info(String msg) {
					System.out.println(msg);
					logger.info(msg);
				}
			
				public void debug(String msg) {
					logger.debug(msg);
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateGeneralSubscriber() {
		val subscriberFile = FileUtils.createFile(receiverTopPackage, "Subscriber.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.receiver;
			
			import org.apache.log4j.Logger;
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.MqttException;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			import org.eclipse.viatra.cep.mqtt.receiver.LoggerUtil;
			
			public class Subscriber {
			
				protected MqttClient client;
				protected MqttConnectOptions connOpts;
				MemoryPersistence persistance = new MemoryPersistence();
			
				private static final Logger log4jLogger = Logger.getLogger(Subscriber.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				public Subscriber(String brokerUrl, String clientId) {
					try {
						client = new MqttClient(brokerUrl, clientId, persistance);
					} catch (MqttException e) {
						LOGGER.error("Could not create MQTTClient.", e);
					}
					connOpts = new MqttConnectOptions();
					connOpts.setCleanSession(true);
				}
			
				public void setCallback(MqttCallback callback) {
					client.setCallback(callback);
				}
			
				public void connect() {
					try {
						client.connect(connOpts);
					} catch (MqttException e) {
						LOGGER.error("Could not connect to MQTT broker.", e);
						System.exit(0);
					}
				}
			
				public void subscribe(String topic) {
					try {
						client.subscribe(topic);
					} catch (MqttException e) {
						LOGGER.error("Could not subscribe to the topic. [" + topic + "]", e);
					}
				}
			
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
		'''
		writer.write(fileContent)
		writer.close
	}

	private def generateGeneralPublisher() {
		val subscriberFile = FileUtils.createFile(receiverTopPackage, "Publisher.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.receiver;
			
			import java.io.UnsupportedEncodingException;
			
			import org.apache.log4j.Logger;
			import org.eclipse.paho.client.mqttv3.MqttClient;
			import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
			import org.eclipse.paho.client.mqttv3.MqttException;
			import org.eclipse.paho.client.mqttv3.MqttMessage;
			import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
			import org.eclipse.viatra.cep.mqtt.receiver.LoggerUtil;
			
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
			
					public void publish(String topic, String payload) {
					  	try {
						publish(topic, payload.getBytes("UTF-8"));
					} catch (UnsupportedEncodingException e) {
						LOGGER.error("Could not encode message. [" + payload + "]", e);
					}
					  }
			
				public void publish(String topic, byte[] payload) {
					MqttMessage message = new MqttMessage(payload);
					      message.setQos(0);
					      message.setRetained(false);
					try {
						client.publish(topic, message);
					} catch (MqttException e) {
						LOGGER.error("Could not publish MQTT message.", e);
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
		'''
		writer.write(fileContent)
		writer.close
	}

	public def generateCallback(EList<Sensor> sensors) {
		val subscriberFile = FileUtils.createFile(receiverTopPackage, "Callback.java")
		val writer = new FileWriter(subscriberFile)
		val fileContent = '''
			package org.eclipse.viatra.cep.mqtt.receiver;
			
			import java.io.IOException;
			
			import org.apache.log4j.Logger;
			import org.eclipse.emf.ecore.resource.Resource;
			import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
			import org.eclipse.paho.client.mqttv3.MqttCallback;
			import org.eclipse.paho.client.mqttv3.MqttMessage;
			import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleParameter;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Machine;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Message;
			import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;
			
			import com.fasterxml.jackson.databind.JsonNode;
			import com.fasterxml.jackson.databind.ObjectMapper;
			
			public class Callback implements MqttCallback {
			
				private static final Logger log4jLogger = Logger.getLogger(Callback.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
			
				Resource resource;
				
				Machine machine;
				«FOR sensor : sensors»
					Sensor «sensor.name»;
					«FOR message:sensor.messages»
						Message «message.name»;
						«FOR parameter:message.dataParameters»
							«parameter.type.toFirstUpper»Parameter «parameter.name»;
						«ENDFOR»
					«ENDFOR»
				«ENDFOR»
			
				public Callback(Resource resource) {
					this.resource = resource;
					getDataFromModel();
				}
			
				@Override
				public void connectionLost(Throwable t) {
					LOGGER.error("The connection lost.", t);
				}
			
				@Override
				public void deliveryComplete(IMqttDeliveryToken token) {
					LOGGER.info("The delivery completed.");
				}
			
				@Override
				public void messageArrived(String topic, MqttMessage message) {
					String msg = new String(message.getPayload());
					ObjectMapper mapper = new ObjectMapper();
					JsonNode sensor;
					try {
						sensor = mapper.readTree(msg);
						«FOR sensor : sensors»
							if (topic.equals("«sensor.name»")) {
								«FOR message:sensor.messages»
									«FOR parameter:message.dataParameters»
										«parameter.name».setValue(sensor.get("«message.name»").get("«parameter.name»").as«parameter.type.toFirstUpper»());
									«ENDFOR»
								«ENDFOR»
							}
							
						«ENDFOR»
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			
				private void getDataFromModel() {
					machine = (Machine) resource.getContents().get(0);
					
					for (Sensor sensor : machine.getSensors()) {
						«FOR sensor : sensors»
							if (sensor.getName().equals("«sensor.name»")) {
								«sensor.name» = sensor;
								for (Message message : sensor.getMessages()) {
									«FOR message:sensor.messages»
										if (message.getName().equals("«message.name»")) {
											«message.name» = message;
											for (DataParameter parameter : message.getDataParameters()) {
												«FOR parameter:message.dataParameters»
													if (parameter.getName().equals("«parameter.name»")) {
														«parameter.name» = («parameter.type.toFirstUpper»Parameter) parameter;
													}
												«ENDFOR»
											}
										}
									«ENDFOR»
								}
							}
							
						«ENDFOR»
					}
				}
			
			}
		'''
		writer.write(fileContent)
		writer.close
	}

}