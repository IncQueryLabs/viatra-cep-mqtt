package org.eclipse.viatra.cep.mqtt.commons.utils;

import org.apache.log4j.Logger;

/**
 * 
 * General logging utility class based on Apache Log4j logger.
 * 
 * @author Zoltan Selmeczi
 *
 */
public class LoggerUtil {

	private final Logger logger;

	/**
	 * The constructor of the class.
	 * @param logger
	 */
	public LoggerUtil(Logger logger) {
		this.logger = logger;
	}
	
	/**
	 * Logs an error message
	 * and print it to the console as an error message.
	 * @param msg
	 */
	public void error(String msg) {
		System.err.println(msg);
		logger.error(msg);
	}

	/**
	 * Logs an error message (with Throwable)
	 * and print it to the console as an error message.
	 * @param msg
	 * @param t
	 */
	public void error(String msg, Throwable t) {
		System.err.println(msg);
		logger.error(msg, t);
	}

	/**
	 * Logs an info message
	 * and print it to the console as a simple message.
	 * @param msg
	 */
	public void info(String msg) {
		System.out.println(msg);
		logger.info(msg);
	}

	/**
	 * Logs a debug message.
	 * @param msg
	 */
	public void debug(String msg) {
		logger.debug(msg);
	}

}
