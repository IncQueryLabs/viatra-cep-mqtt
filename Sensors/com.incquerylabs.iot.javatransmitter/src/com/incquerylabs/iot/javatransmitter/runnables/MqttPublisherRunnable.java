package com.incquerylabs.iot.javatransmitter.runnables;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

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
        		publisher.publish(parameters.topic, rawData);
        	}
        } catch (InterruptedException e) {
        	LOGGER.error("Interrupted", e);
        }
    }
    
    public synchronized void finish(){
    	isRunning = false;
    }
}
