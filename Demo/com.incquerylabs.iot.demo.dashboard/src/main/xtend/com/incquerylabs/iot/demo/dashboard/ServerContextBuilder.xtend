package com.incquerylabs.iot.demo.dashboard

import org.eclipse.jetty.server.handler.DefaultHandler
import org.eclipse.jetty.server.handler.HandlerCollection
import org.eclipse.jetty.server.session.SessionHandler
import org.eclipse.jetty.servlet.DefaultServlet
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder

class ServerContextBuilder {
	
	static def buildHandlers() {
		val context = new ServletContextHandler(ServletContextHandler.SESSIONS)
		context.sessionHandler = new SessionHandler
		context.contextPath = "/";
		
		val freeboardHolder = new ServletHolder("freeboard", DefaultServlet);
        freeboardHolder.setInitParameter("resourceBase", "freeboard");
        freeboardHolder.setInitParameter("dirAllowed","true");
        freeboardHolder.setInitParameter("pathInfoOnly","true");
        context.addServlet(freeboardHolder, "/*");
		
		val handlers = new HandlerCollection();
		handlers.setHandlers(#[context, new DefaultHandler]);
		handlers
	}
	
}
