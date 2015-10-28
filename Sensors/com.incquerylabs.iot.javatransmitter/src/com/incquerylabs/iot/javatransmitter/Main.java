package com.incquerylabs.iot.javatransmitter;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;
import com.incquerylabs.iot.javatransmitter.runnables.MqttPublisherRunnable;
import com.incquerylabs.iot.javatransmitter.runnables.SerialPortListener;
import com.incquerylabs.iot.javatransmitter.utils.ArgumentUtils;

public class Main {
	public static void main(String[] args) throws Exception {
		InputParameters parsedArgs = ArgumentUtils.parseArgs(args);
		if(ArgumentUtils.validateParsedArgs(parsedArgs)){
			if(parsedArgs.help){
				displayHelp();
				System.exit(1);
			}else{
				ArgumentUtils.displayParsedArgs(parsedArgs);
				BlockingQueue<String> queue = new ArrayBlockingQueue<String>(1024);
	
				SerialPortListener serialListener = new SerialPortListener();
				serialListener.listen(parsedArgs, queue);
				
				MqttPublisherRunnable publisher = new MqttPublisherRunnable(queue, parsedArgs);
				new Thread(publisher).start();
			}
		}else{
			System.err.println("Invalid porgram arguments.");
			System.exit(0);
		}
		
	}

	private static void displayHelp() {
		System.out.println("=============== HELP ===============");
		System.out.println("-h | -help: Display help message.");
		System.out.println();
		System.out.println("-port: Specify the name of the SerialPort.");
		System.out.println("   e.g.:");
		System.out.println("      Windows: COM3");
		System.out.println("      Mac OS X: /dev/tty.usbserial-A9007UX1");
		System.out.println("      Linux: /dev/ttyUSB0");
		System.out.println();
		System.out.println("-broker: Specify the url of the MQTT broker. (e.g.: tcp://localhost:1883)");
		System.out.println();
		System.out.println("-topic: Specify the target topic. (e.g.: data/LH)");
		System.out.println();
		System.out.println("-sensorID: Specify the SensorID. (e.g.: LH)");
		System.out.println();
		System.out.println("====================================");
	}
}
