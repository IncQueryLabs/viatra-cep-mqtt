package com.incquerylabs.iot.sensorcodes;

import org.apache.log4j.Logger;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.viatra.cep.core.metamodels.events.Event;
import org.eclipse.viatra.cep.mqtt.commons.utils.LoggerUtil;

import com.google.gson.Gson;
import com.incquerylabs.iot.sensorcodes.events.CepFactory;

public class DirectPushCallback implements MqttCallback {

	private static final Logger log4jLogger = Logger.getLogger(DirectPushCallback.class);
	private static final LoggerUtil LOGGER = new LoggerUtil(log4jLogger);
	
	private Gson gson;
	
	private int stateTreshold = 200;
	
	private IEventStreamProvider stream;
	
	public DirectPushCallback(IEventStreamProvider stream) {
		gson = new Gson();
		this.stream = stream;
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
			
			SensorData sensorData = gson.fromJson(new String(message.getPayload()), SensorData.class);
			
			if(sensorData.getTap() == 0) return;
			
			String sensorId = topic.split("/")[2];
			
			Event stateEvent = null;
			
			if(sensorData.getZ() < -stateTreshold) {			// Z LOW
				stateEvent = createState_4_Event(sensorId); 
			} else if(sensorData.getX() > stateTreshold) {		// X HIGH
				stateEvent = createState_5_Event(sensorId);
			} else if (sensorData.getY() < -stateTreshold) {	// Y LOW
				stateEvent = createState_3_Event(sensorId);
			} else if (sensorData.getY() > stateTreshold) {		// Y HIGH
				stateEvent = createState_2_Event(sensorId);
			} else if (sensorData.getZ() > stateTreshold) {		// Z HIGH
				stateEvent = createState_0_Event(sensorId);
			} else if (sensorData.getX() < -stateTreshold) {	// X LOW
				stateEvent = createState_1_Event(sensorId);
			}
			
			if(stateEvent != null)
				stream.pushEvent(stateEvent);
			
		} catch (Exception e) {
			LOGGER.error(e.getMessage());
		}
	}
	
//	private Event createTAPEvent(String sensorId) {
//		switch (sensorId) {
//		case "HEAD": return CepFactory.getInstance().createSensor_A_tap_Event();
//		case "LH"  : return CepFactory.getInstance().createSensor_B_tap_Event();
//		case "RH"  : return CepFactory.getInstance().createSensor_C_tap_Event();
//		case "LL"  : return CepFactory.getInstance().createSensor_D_tap_Event();
//		default    : return null;
//		}
//	}
	
	private Event createState_0_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_0_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_0_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_0_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_0_Event();
		default    : return null;
		}
	}
	
	private Event createState_1_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_1_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_1_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_1_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_1_Event();
		default    : return null;
		}
	}
	
	private Event createState_2_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_2_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_2_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_2_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_2_Event();
		default    : return null;
		}
	}
	
	private Event createState_3_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_3_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_3_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_3_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_3_Event();
		default    : return null;
		}
	}
	
	private Event createState_4_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_4_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_4_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_4_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_4_Event();
		default    : return null;
		}
	}
	
	private Event createState_5_Event(String sensorId) {
		switch (sensorId) {
		case "HEAD": return CepFactory.getInstance().createSensor_A_state_5_Event();
		case "LH"  : return CepFactory.getInstance().createSensor_B_state_5_Event();
		case "RH"  : return CepFactory.getInstance().createSensor_C_state_5_Event();
		case "LL"  : return CepFactory.getInstance().createSensor_D_state_5_Event();
		default    : return null;
		}
	}
	
}
