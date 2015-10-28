package com.incquerylabs.iot.javatransmitter.runnables;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

import com.incquerylabs.iot.javatransmitter.utils.LoggerUtil;

public class SerialPortEmulator implements Runnable {

	protected BlockingQueue<String> queue = null;
    private boolean isRunning = true;

    private static final Logger log4jLogger = Logger.getLogger(SerialPortEmulator.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
    
    public SerialPortEmulator(BlockingQueue<String> queue) {
        this.queue = queue;
    }

    private class SensorValues {
    	public boolean pb1 = false;
		public boolean pb2 = false;
    	public boolean pb3 = false;
    	public int pot1 = 0; // 0 - 1023
    	
    	public SensorValues() {
			// TODO Auto-generated constructor stub
		}
    	
    	public SensorValues(String pb1, String pb2, String pb3, String pot1) {
			super();
			this.pb1 = convertToBooleanValue(pb1);
			this.pb2 = convertToBooleanValue(pb2);
			this.pb3 = convertToBooleanValue(pb3);
			try{
				this.pot1 = Integer.parseInt(pot1);
			}catch(NumberFormatException e){
				this.pot1 = 0;
			}
		}
    	
    	private boolean convertToBooleanValue(String input){
    		return (input != null && input.equals("1")) ? true : false;
    	}
    	
    	@Override
    	public String toString() {
    		return "  "+convertToOnOffValue(pb1)+"\t\t  "+convertToOnOffValue(pb2)+"\t\t  "+convertToOnOffValue(pb3)+"\t\t       " + pot1;
    	}
    	
    	private String convertToOnOffValue(boolean b){
    		return b ? "ON" : "OFF";
    	}
    	
    	public void print(){
    		System.out.println(this);
    	}
    	
    	public int getPb1IntValue() {
			return pb1 ? 1 : 0;
		}
    	
    	public int getPb2IntValue() {
			return pb2 ? 1 : 0;
		}
    	
    	public int getPb3IntValue() {
			return pb3 ? 1 : 0;
		}
    	
    };
    
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
        		queue.put("{\"pb1\" : {\"value\" : "+values.getPb1IntValue()+"}, \"pb2\" : {\"value\" : "+values.getPb2IntValue()+"}, \"pb3\" : {\"value\" : "+values.getPb3IntValue()+"}, \"pot1\" : {\"value\" : "+values.pot1+"}}");
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
