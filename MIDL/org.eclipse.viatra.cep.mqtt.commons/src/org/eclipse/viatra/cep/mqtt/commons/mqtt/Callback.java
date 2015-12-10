package org.eclipse.viatra.cep.mqtt.commons.mqtt;

import org.apache.log4j.Logger;
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
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Payload;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringParameter;

import com.eclipsesource.json.JsonObject;
import com.eclipsesource.json.JsonValue;

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
		String msg = new String(message.getPayload());
		JsonObject object = JsonObject.readFrom(msg);
		// Use IncQuery Base Indexer to find the sensor
		Sensor selectedSensor = (Sensor) navigationHelper.findByAttributeValue(topic).iterator().next().getEObject();
		Payload sensorPayload = selectedSensor.getLastReceivedPayload();
		try {
			NavigationHelper paramNavHelper = IncQueryBaseFactory.getInstance()
					.createNavigationHelper(sensorPayload, true, null);
			// Get parameters from model using the JSON file content
			for (String parameterName : object.get(sensorPayload.getName()).asObject().names()) {
				// Use IncQuery Base Indexer to find parameter
				DataParameter paramValue = (DataParameter) paramNavHelper.findByAttributeValue(parameterName)
						.iterator().next().getEObject();
				// Get the parameter new value from the message
				JsonValue newValue = object.get(selectedSensor.getLastReceivedPayload().getName()).asObject()
						.get(parameterName);
				// Find parameter type, and set the new value
				if (paramValue.getType().equals("int")) {
					((IntParameter) paramValue).setValue(newValue.asInt());
				} else if (paramValue.getType().equals("double")) {
					((DoubleParameter) paramValue).setValue(newValue.asDouble());
				} else if (paramValue.getType().equals("string")) {
					((StringParameter) paramValue).setValue(newValue.asString());
				} else if (paramValue.getType().equals("boolean")) {
					((BooleanParameter) paramValue).setValue(newValue.asBoolean());
				}
			}
		} catch (IncQueryBaseException e) {
			LOGGER.error(e.getMessage());
		}
	}

}
