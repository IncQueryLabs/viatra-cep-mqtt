package org.eclipse.viatra.cep.mqtt.midl.viatra

import java.io.File
import org.eclipse.viatra.cep.mqtt.midl.utils.FileUtils
import java.io.FileWriter
import org.eclipse.emf.common.util.EList
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor

class JavaGenerator {

	File rootFolder
	File publisherFolder

	new(String rootPath) {
		rootFolder = FileUtils.createFolder(new File(rootPath))
		publisherFolder = FileUtils.createFolder(new File(rootFolder, "PublisherFolder"))
	}

	public def generatePublisher(EList<Sensor> sensors) {
		val publisherFile = FileUtils.createFile(publisherFolder, "MqttPublisherRunnable.java")
		val writer = new FileWriter(publisherFile)
		val fileContent = '''
			package com.incquerylabs.iot.javatransmitter.runnables;
			
			import java.util.concurrent.BlockingQueue;
			
			import org.apache.log4j.Logger;
			
			import com.eclipsesource.json.JsonArray;
			import com.eclipsesource.json.JsonObject;
			import com.eclipsesource.json.JsonValue;
			import com.incquerylabs.iot.javatransmitter.data.InputParameters;
			import com.incquerylabs.iot.javatransmitter.mqtt.Publisher;
			import com.incquerylabs.iot.javatransmitter.utils.LoggerUtil;
			
			public class MqttPublisherRunnable implements Runnable {
			
				protected BlockingQueue<String> queue = null;
				private boolean isRunning = true;
				private final Publisher publisher;
				private InputParameters parameters;
			
				private static final Logger log4jLogger = Logger.getLogger(MqttPublisherRunnable.class);
				private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
				
				public MqttPublisherRunnable(BlockingQueue<String> queue, InputParameters parameters) {
					this.queue = queue;
					this.parameters = parameters;
					publisher = new Publisher(parameters.broker, parameters.sensorID);
					publisher.connect();
				}
			
			    @Override
				public void run() {
					try {
					   	System.out.println("Start sending messages...");
				   	   	while(isRunning) {
					   	   	String rawData = queue.take();
					   	   	JsonObject sensors = JsonObject.readFrom(rawData);
							for (String sensorName : sensors.names()) {
								JsonArray messageList = sensors.get(sensorName).asArray();
								for (JsonValue messageObject : messageList.values()) {
									for (String messageName : messageObject.asObject().names()) {
										JsonObject parameterObject = messageObject.asObject().get(messageName).asObject();
										for (String parameterName : parameterObject.names()) {
											«FOR sensor : sensors»
											if (sensorName.equals("«sensor.name»")) {
												«FOR message : sensor.messages»
													«FOR parameter : message.dataParameters»
														«IF parameter.type.equals("string")»
														String value = parameterObject.get(parameterName).asString();
														«ELSE»
														«parameter.type» value = parameterObject.get(parameterName).as«parameter.type.toFirstUpper»();
														«ENDIF»
														JsonObject param = new JsonObject().add("«parameter.name»", value);
														JsonObject msg = new JsonObject().add("«message.name»", param);
														publisher.publish("«sensor.name»", msg.toString());
													«ENDFOR»
												«ENDFOR»
											}
											«ENDFOR»
										}
									}
								}
							}
						}
					} catch (InterruptedException e) {
				   		LOGGER.error("Interrupted", e);
					}
				}
				
				public synchronized void finish(){
					isRunning = false;
				}

			}
		'''
		writer.write(fileContent)
		writer.close
	}

}