package com.incquerylabs.iot.javatransmitter.utils;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;

public class ArgumentUtils {

	public static void displayParsedArgs(InputParameters parsedArgs) {
		System.out.println("Parameters: ");
		System.out.println("   Port: " + parsedArgs.port);
		System.out.println("   Broker: " + parsedArgs.broker);
		System.out.println("   Topic: " + parsedArgs.topic);
		System.out.println("   SensorID: " + parsedArgs.sensorID);
		System.out.println("   Emulate Serial: " + parsedArgs.emaulteSerial);
	}

	// TODO
	public static boolean validateParsedArgs(InputParameters parsedArgs) {
		boolean portDefined = parsedArgs.port != null && parsedArgs.port != "";
		if(parsedArgs.help || portDefined){
			return true;
		}
		
		return false;
	}

	public static InputParameters parseArgs(String[] args) {
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
				case "-es":
					inputParameters.emaulteSerial = true;
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
