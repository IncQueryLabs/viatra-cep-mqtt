package com.incquerylabs.iot.demo201606;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import com.incquerylabs.iot.sensorcodes.DemoApplication;

public class Activator implements BundleActivator {

	private static BundleContext context;
	
	DemoApplication demoApp;
	
	static BundleContext getContext() {
		return context;
	}

	/*
	 * (non-Javadoc)
	 * @see org.osgi.framework.BundleActivator#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext;
		demoApp = DemoApplication.getInstance();
		demoApp.start();
	}

	/*
	 * (non-Javadoc)
	 * @see org.osgi.framework.BundleActivator#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext bundleContext) throws Exception {
		Activator.context = null;
		if(demoApp != null)
			demoApp.stop();
	}

}
