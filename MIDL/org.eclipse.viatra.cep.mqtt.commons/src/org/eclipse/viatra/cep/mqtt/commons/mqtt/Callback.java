package org.eclipse.viatra.cep.mqtt.commons.mqtt;

import java.util.Collection;

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
import org.eclipse.viatra.cep.mqtt.midl.mIDL.Sensor;
import org.eclipse.viatra.cep.mqtt.midl.mIDL.StringParameter;

import com.eclipsesource.json.JsonObject;

public class Callback implements MqttCallback {

	private static final Logger log4jLogger = Logger.getLogger(Callback.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);

	private IoTSystem system;
	private NavigationHelper navigationHelper;
	
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
		Collection<Setting> sensors = navigationHelper.findByAttributeValue(topic);
		for (Setting sensor : sensors) {
			Sensor selectedSensor = (Sensor) sensor.getEObject();
			Collection<DataParameter> params = selectedSensor.getLastReceivedPayload().getDataParameters();
			for (DataParameter param : params) {
				if (param.getType().equals("int")) {
					int newValue = object.get("payload").asObject().get(param.getName()).asInt();
					((IntParameter) param).setValue(newValue);
				} else if (param.getType().equals("double")) {
					double newValue = object.get("payload").asObject().get(param.getName()).asDouble();
					((DoubleParameter) param).setValue(newValue);
				} else if (param.getType().equals("string")) {
					String newValue = object.get("payload").asObject().get(param.getName()).asString();
					((StringParameter) param).setValue(newValue);
				} else if (param.getType().equals("boolean")) {
					boolean newValue = object.get("payload").asObject().get(param.getName()).asBoolean();
					((BooleanParameter) param).setValue(newValue);
				}
			}
		}
	}
	
}
