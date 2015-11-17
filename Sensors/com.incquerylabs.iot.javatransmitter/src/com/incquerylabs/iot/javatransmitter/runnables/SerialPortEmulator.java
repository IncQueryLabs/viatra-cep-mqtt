package com.incquerylabs.iot.javatransmitter.runnables;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

import com.incquerylabs.iot.javatransmitter.data.SensorValues;

public class SerialPortEmulator implements Runnable {

	protected BlockingQueue<String> queue = null;
    private boolean isRunning = true;

    private static final Logger log4jLogger = Logger.getLogger(SerialPortEmulator.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
    
    public SerialPortEmulator(BlockingQueue<String> queue) {
        this.queue = queue;
    }

    @Override
	public void run() {
        try {
        	System.out.println("Emulator started...");
        	System.out.println();
        	System.out.println();
        	System.out.println("Type values of buttons and potentiometer. (Space separated values)");
        	System.out.println("  Buttons: 0 or 1");
        	System.out.println("  Potentiometer: 0 - 1023");
        	System.out.println("  Example: 0 1 0 200  -->  only Button 2 pushed and the value of the Potentiometer is 200");
        	System.out.println("Button 1\tButton 2\tButton 3\tPotentiometer");
        	System.out.println("  OFF\t\t  OFF\t\t  OFF\t\t       0");
        	BufferedReader consoleReader = new BufferedReader(new InputStreamReader(System.in));
        	while(isRunning) {
        		String input = consoleReader.readLine();
        		SensorValues values = parseInputLine(input);
        		values.print();
        		queue.put(values.createJSONString());
        	}
        } catch (InterruptedException e) {
        	LOGGER.error("Error occurred.", e);
        } catch (IOException e) {
        	LOGGER.error("Error occurred.", e);
		}
    }

	private SensorValues parseInputLine(String input) {
    	if(input != null && !input.isEmpty()){
    		String[] inputs = input.split(" ");
    		if(inputs.length == 4){
    			return new SensorValues(inputs[0], inputs[1], inputs[2], inputs[3]);
    		}
    	}
		return new SensorValues();
	}

	public synchronized void finish(){
    	isRunning = false;
    }
}
