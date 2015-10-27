package com.incquerylabs.iot.javatransmitter;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;
import com.incquerylabs.iot.javatransmitter.runnables.MqttPublisherRunnable;
import com.incquerylabs.iot.javatransmitter.runnables.SerialPortListener;

public class Main {
	public static void main(String[] args) throws Exception {
		InputParameters parsedArgs = parseArgs(args);
		validateParsedArgs(parsedArgs);
		if(parsedArgs.help){
			displayHelp();
			System.exit(1);
		}else{
			displayParsedArgs(parsedArgs);
			BlockingQueue<String> queue = new ArrayBlockingQueue<String>(1024);

			SerialPortListener serialListener = new SerialPortListener();
			serialListener.listen(parsedArgs, queue);
			
			MqttPublisherRunnable publisher = new MqttPublisherRunnable(queue, parsedArgs);
			new Thread(publisher).start();
		}
		
	}

	private static void displayParsedArgs(InputParameters parsedArgs) {
		System.out.println("Parameters: ");
		System.out.println("   Port: " + parsedArgs.port);
		System.out.println("   Broker: " + parsedArgs.broker);
		System.out.println("   Topic: " + parsedArgs.topic);
		System.out.println("   SensorID: " + parsedArgs.sensorID);
	}

	private static boolean validateParsedArgs(InputParameters parsedArgs) {
		boolean portDefined = parsedArgs.port != null && parsedArgs.port != "";
		if(parsedArgs.help || portDefined){
			return true;
		}
		
		return false;
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
		System.out.println("====================================");
	}

	private static InputParameters parseArgs(String[] args) {
		InputParameters inputParameters = new InputParameters();
		
		String argName = "";
		boolean nextIsValue = false;
		for (String arg : args) {
			// ArgValue
			if(nextIsValue){
				nextIsValue = false;
				switch (argName) {
					case "-port":
						inputParameters.port = arg;
						break;
					case "-broker":
						inputParameters.broker = arg;
						break;
					case "-topic":
						inputParameters.topic = arg;
						break;
					case "-sensorID":
						inputParameters.sensorID = arg;
						break;
	
					default:
						break;
				}
			}
			
			// ArgName
			if(arg.startsWith("-")){
				switch (arg) {
				case "-port":
					argName = arg;
					nextIsValue = true;
					break;
				case "-broker":
					argName = arg;
					nextIsValue = true;
					break;
				case "-topic":
					argName = arg;
					nextIsValue = true;
					break;
				case "-sensorID":
					argName = arg;
					nextIsValue = true;
					break;
					
				case "-h":
				case "-help":
					inputParameters.help = true;
					nextIsValue = false;
					break;
				default:
					break;
				}
			}
		}
		
		return inputParameters;
	}
}
