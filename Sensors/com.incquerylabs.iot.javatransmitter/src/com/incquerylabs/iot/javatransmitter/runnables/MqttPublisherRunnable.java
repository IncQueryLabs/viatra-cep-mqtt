package com.incquerylabs.iot.javatransmitter.runnables;

import java.util.concurrent.BlockingQueue;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;
import com.incquerylabs.iot.javatransmitter.mqtt.Publisher;

public class MqttPublisherRunnable implements Runnable {

	protected BlockingQueue<String> queue = null;
    private boolean isRunning = true;
	private final Publisher publisher;
	private InputParameters parameters;

    public MqttPublisherRunnable(BlockingQueue<String> queue, InputParameters parameters) {
        this.queue = queue;
		this.parameters = parameters;
        publisher = new Publisher(parameters.broker, parameters.sensorID);
        publisher.connect();
    }

    @Override
	public void run() {
        try {
        	while(isRunning) {
        		String rawData = queue.take();
        		publisher.publish(parameters.topic, rawData);
        	}
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    
    public synchronized void finish(){
    	isRunning = false;
    }
}
