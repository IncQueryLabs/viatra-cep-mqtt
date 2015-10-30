package com.incquerylabs.iot.javatransmitter.runnables;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

import com.eclipsesource.json.JsonObject;
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
					if (sensorName.equals("pb1")) {
						JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
						JsonObject jsonValue = jsonMessage.get("messageName").asObject();
						JsonObject param = new JsonObject().add("value", jsonValue.get("value").asInt());
						JsonObject msg = new JsonObject().add("btn1_msg", param);
						publisher.publish("btn1", msg.toString());
					}
					if (sensorName.equals("pb2")) {
						JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
						JsonObject jsonValue = jsonMessage.get("messageName").asObject();
						JsonObject param = new JsonObject().add("value", jsonValue.get("value").asInt());
						JsonObject msg = new JsonObject().add("btn2_msg", param);
						publisher.publish("btn2", msg.toString());
					}
					if (sensorName.equals("pb3")) {
						JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
						JsonObject jsonValue = jsonMessage.get("messageName").asObject();
						JsonObject param = new JsonObject().add("value", jsonValue.get("value").asInt());
						JsonObject msg = new JsonObject().add("btn3_msg", param);
						publisher.publish("btn3", msg.toString());
					}
					if (sensorName.equals("pot1")) {
						JsonObject jsonMessage = sensors.get(sensorName).asArray().get(0).asObject();
						JsonObject jsonValue = jsonMessage.get("messageName").asObject();
						JsonObject param = new JsonObject().add("value", jsonValue.get("value").asInt());
						JsonObject msg = new JsonObject().add("pot_msg", param);
						publisher.publish("pot", msg.toString());
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
