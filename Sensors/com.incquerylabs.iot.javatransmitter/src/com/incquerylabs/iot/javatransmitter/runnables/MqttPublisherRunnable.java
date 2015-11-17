package com.incquerylabs.iot.javatransmitter.runnables;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;
import org.eclipse.viatra.cep.mqtt.commons.mqtt.Publisher;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;

public class MqttPublisherRunnable implements Runnable {

	protected BlockingQueue<String> queue = null;
	protected boolean isRunning = true;
	protected final Publisher publisher;
	private InputParameters parameters;

	private static final Logger log4jLogger = Logger.getLogger(MqttPublisherRunnable.class);
	protected static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
	
	public MqttPublisherRunnable(BlockingQueue<String> queue, InputParameters parameters) {
		this.queue = queue;
		this.parameters = parameters;
		publisher = new Publisher(this.parameters.broker, this.parameters.sensorID);
		publisher.connect();
	}

    @Override
	public void run() {
		while (isRunning) {
			try {
				String rawData = queue.take();
				System.out.println(rawData);
			} catch (InterruptedException e) {
				LOGGER.error("Interrupted", e);
			}
		}
	}
	
	public synchronized void finish(){
		isRunning = false;
	}

}