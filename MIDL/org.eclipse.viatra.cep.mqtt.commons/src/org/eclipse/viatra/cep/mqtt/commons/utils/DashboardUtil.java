package org.eclipse.viatra.cep.mqtt.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.Logger;
import org.eclipse.viatra.cep.mqtt.commons.mqtt.Publisher;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

import com.eclipsesource.json.JsonObject;

public class DashboardUtil {

	private final static SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");
	private static final Logger log4jLogger = Logger.getLogger(DashboardUtil.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);

	public static String brokerAddress = "";
	
	private static Publisher publisher = new Publisher(brokerAddress, "IOT_CEP_DASHBOARD");;
	
	public static void publishSimpleEvent(String eventMessage) {
		publish(eventMessage, "SIMPLE");
	}
	
	public static void publishHighlightedEvent(String eventMessage) {
		publish(eventMessage, "HIGHLIGHTED");
	}
	
	private static void publish(String eventMessage, String marker) {
		try {
			if (!publisher.isConnected()) {
				publisher.connect();
			}
			JsonObject eventMsg = new JsonObject();
			JsonObject event = new JsonObject();
			event.add("event_msg", eventMessage);
			event.add("event_type", marker);
			event.add("timestamp", sdf.format(new Date()));
			eventMsg.add("CEP_EVENT_MESSAGE", event);
			publisher.publish("dashboard/cep", eventMsg.toString().getBytes());
			
		} catch (Exception ex) {
			LOGGER.error("Unable publish message to dashboard: " + ex.getMessage());
		}
	}

}