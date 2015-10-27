package com.incquerylabs.iot.javatransmitter.runnables;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.concurrent.BlockingQueue;

import org.apache.log4j.Logger;

import com.incquerylabs.iot.javatransmitter.data.InputParameters;
import com.incquerylabs.iot.javatransmitter.utils.LoggerUtil;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;


public class SerialPortListener implements SerialPortEventListener {
	SerialPort serialPort;
	/**
	* A BufferedReader which will be fed by a InputStreamReader 
	* converting the bytes into characters 
	* making the displayed results codepage independent
	*/
	private BufferedReader input;
	/** The output stream to the port */
	// private OutputStream output;
	/** Milliseconds to block while waiting for port open */
	private static final int TIME_OUT = 2000;
	/** Default bits per second for COM port. */
	private static final int DATA_RATE = 9600;
	
	private BlockingQueue<String> queue;

	private static final Logger log4jLogger = Logger.getLogger(SerialPortListener.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
	
	public void listen(InputParameters parsedArgs, BlockingQueue<String> queue) {
		this.queue = queue;
		CommPortIdentifier portId = null;
		Enumeration portEnum = CommPortIdentifier.getPortIdentifiers();

		if(portEnum == null){
			String msg = "Could not find any COM port.";
			LOGGER.error(msg);
			return;
		}
		
		//First, Find an instance of serial port as set in PORT_NAMES.
		while (portEnum.hasMoreElements()) {
			CommPortIdentifier currPortId = (CommPortIdentifier) portEnum.nextElement();
			if (currPortId.getName().equals(parsedArgs.port)) {
				portId = currPortId;
				break;
			}
		}
		if (portId == null) {
			LOGGER.error("Could not find "+parsedArgs.port+" port.");
			return;
		}

		try {
			// open serial port, and use class name for the appName.
			serialPort = (SerialPort) portId.open(this.getClass().getName(), TIME_OUT);

			// set port parameters
			serialPort.setSerialPortParams(DATA_RATE,
					SerialPort.DATABITS_8,
					SerialPort.STOPBITS_1,
					SerialPort.PARITY_NONE);

			// open the streams
			input = new BufferedReader(new InputStreamReader(serialPort.getInputStream()));
			// output = serialPort.getOutputStream();

			// add event listeners
			serialPort.addEventListener(this);
			serialPort.notifyOnDataAvailable(true);
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), e);
		}
	}

	/**
	 * This should be called when you stop using the port.
	 * This will prevent port locking on platforms like Linux.
	 */
	public synchronized void close() {
		if (serialPort != null) {
			serialPort.removeEventListener();
			serialPort.close();
		}
	}

	/**
	 * Handle an event on the serial port. Read the data and print it.
	 */
	@Override
	public synchronized void serialEvent(SerialPortEvent oEvent) {
		if (oEvent.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
			try {
				String inputLine = input.readLine();
				LOGGER.infoWithoutPrint("Read from serial: "+inputLine);
				queue.put(inputLine);
			} catch (Exception e) {
				serialPort.removeEventListener();
			}
		}
		// Ignore all the other eventTypes, but you should consider the other ones.
	}

}
