package com.incquerylabs.iot.sensorcodes;

import org.eclipse.viatra.cep.core.metamodels.events.Event;

public interface IEventStreamProvider {
	
	public void pushEvent(Event event);
	
}
