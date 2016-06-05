package org.eclipse.viatra.cep.mqtt.commons.mqtt;

import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.apache.log4j.Logger;
import org.eclipse.emf.ecore.EStructuralFeature.Setting;
import org.eclipse.incquery.runtime.base.api.IncQueryBaseFactory;
import org.eclipse.incquery.runtime.base.api.NavigationHelper;
import org.eclipse.incquery.runtime.base.exception.IncQueryBaseException;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.BooleanParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DataParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.DoubleParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IntParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.IoTSystem;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.LongParameter;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Payload;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringParameter;

import com.google.common.base.Stopwatch;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * This is the callback calls of the generated MIDL project. When it got a new
 * message over MQTT, update the EMF model with the message payload. It using
 * IncQuery Base Indexer to get the correct model elements.
 * 
 * @author Zoltan Selmeczi
 *
 */
public class Callback implements MqttCallback {

	private static final Logger log4jLogger = Logger.getLogger(Callback.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);

	private IoTSystem system;
	private NavigationHelper navigationHelper;

	/**
	 * This is the constructor of the callback class. It got an IoTSystem from
	 * the MIDL created model and use it to initialize the IncQuery Base
	 * Indexer.
	 * 
	 * @param system
	 */
	public Callback(IoTSystem system) {
		this.system = system;
		try {
			navigationHelper = IncQueryBaseFactory.getInstance().createNavigationHelper(this.system, true, null);
		} catch (IncQueryBaseException e) {
			LOGGER.error(e.getMessage());
		}
	}

	@Override
	public void connectionLost(Throwable t) {
		LOGGER.error("The connection lost.", t);
	}

	@Override
	public void deliveryComplete(IMqttDeliveryToken token) {
		LOGGER.info("The delivery completed.");
	}

	@Override
	public void messageArrived(String topic, MqttMessage message) {
		try {
			
			Stopwatch sw = Stopwatch.createStarted();
			
			String msg = new String(message.getPayload());
			JsonParser parser = new JsonParser();
			JsonObject object = parser.parse(msg).getAsJsonObject();
			
			
			
			// XXX: workaround for demo!!!!
			String sensorId = topic;
			String[] segments = topic.split("/");
			if(segments.length > 2) {
				sensorId = segments[1]+segments[2];
			}
			
			long elapsed = sw.elapsed(TimeUnit.MILLISECONDS);
			if(elapsed > 5) {
				System.out.println("Phase parse: " + elapsed);
			}
			sw.reset();
			
			// Use IncQuery Base Indexer to find the sensor
			Sensor selectedSensor = (Sensor) navigationHelper.findByAttributeValue(sensorId).iterator().next().getEObject();
			
			elapsed = sw.elapsed(TimeUnit.MILLISECONDS);
			if(elapsed > 10) {
				System.out.println("Phase indexer: " + elapsed);
			}
			
			Payload sensorPayload = selectedSensor.getLastReceivedPayload();
			
			NavigationHelper paramNavHelper = IncQueryBaseFactory.getInstance()
					.createNavigationHelper(sensorPayload, true, null);
			// Get parameters from model using the JSON file content
			for (Entry<String, JsonElement> parameter : object.entrySet()) {
				// Use IncQuery Base Indexer to find parameter
				Set<Setting> settings = paramNavHelper.findByAttributeValue(parameter.getKey());
				if(settings.isEmpty()) continue;
	
				DataParameter paramValue = (DataParameter) settings.iterator().next().getEObject();
				// Get the parameter new value from the message
				JsonElement newValue = parameter.getValue();
				// Find parameter type, and set the new value
				if (paramValue.getType().equals("int")) {
					((IntParameter) paramValue).setValue(newValue.getAsInt());
				} else if (paramValue.getType().equals("double")) {
					((DoubleParameter) paramValue).setValue(newValue.getAsDouble());
				} else if (paramValue.getType().equals("string")) {
					((StringParameter) paramValue).setValue(newValue.getAsString());
				} else if (paramValue.getType().equals("boolean")) {
					((BooleanParameter) paramValue).setValue(newValue.getAsBoolean());
				} else if (paramValue.getType().equals("long")) {
					((LongParameter) paramValue).setValue(newValue.getAsLong());
				}
			}
			
			elapsed = sw.elapsed(TimeUnit.MILLISECONDS);
			if(elapsed > 10) {
				System.out.println("Phase update: " + elapsed);
			}
			
		} catch (Exception e) {
			LOGGER.error(e.getMessage());
		}
	}

}
