package org.eclipse.viatra.cep.mqtt.commons.utils;

import org.apache.log4j.Logger;

public class LoggerUtil {

	private final Logger logger;

	public LoggerUtil(Logger logger) {
		this.logger = logger;
	}

	public void error(String msg) {
		System.err.println(msg);
		logger.error(msg);
	}

	public void error(String msg, Throwable t) {
		System.err.println(msg);
		logger.error(msg, t);
	}

	public void info(String msg) {
		System.out.println(msg);
		logger.info(msg);
	}

	public void debug(String msg) {
		logger.debug(msg);
	}

}
