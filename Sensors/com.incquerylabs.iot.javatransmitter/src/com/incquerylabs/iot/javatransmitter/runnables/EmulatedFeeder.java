package com.incquerylabs.iot.javatransmitter.runnables;

import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

import com.incquerylabs.iot.javatransmitter.data.SensorValues;
import com.incquerylabs.iot.javatransmitter.utils.LoggerUtil;

public class EmulatedFeeder implements Runnable {

	private final BlockingQueue<String> outputQueue;
	private final BlockingQueue<String> inputQueue;
    private boolean isRunning = true;

	private static final Logger log4jLogger = Logger.getLogger(EmulatedFeeder.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
	
    public EmulatedFeeder(BlockingQueue<String> inputQueue, BlockingQueue<String> outputQueue) {
        this.inputQueue = inputQueue;
		this.outputQueue = outputQueue;
    }

    @Override
	public void run() {
        try {
        	System.out.println("Start sending messages...");
        	SensorValues defaultValues = new SensorValues();
        	String lastMsg = defaultValues.createJSONString();
        	while(isRunning) {
        		// Get last message
        		String inputMsg = inputQueue.poll();
        		if(inputMsg != null){
        			lastMsg = inputMsg;
        		}
        		
        		// Send and wait
        		outputQueue.put(lastMsg);
        		Thread.sleep(10); 
        	}
        } catch (InterruptedException e) {
        	LOGGER.error("Interrupted", e);
        }
    }
    
    public synchronized void finish(){
    	isRunning = false;
    }
}
