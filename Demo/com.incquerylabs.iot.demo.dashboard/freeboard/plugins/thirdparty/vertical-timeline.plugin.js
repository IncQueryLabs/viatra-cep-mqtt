// Best to encapsulate your plugin in a closure, although not required.
(function() {
	// ## A Widget Plugin
	//
	// -------------------
	// ### Widget Definition
	//
	// -------------------
	// **freeboard.loadWidgetPlugin(definition)** tells freeboard that we are
	// giving it a widget plugin. It expects an object with the following:
	freeboard
			.loadWidgetPlugin({
				// Same stuff here as with datasource plugin.
				"type_name" : "vertical_timeline_plugin",
				"display_name" : "Vertical Timeline",
				"description" : "Vertical timeline plugin to visualize event stream!",
				// **external_scripts** : Any external scripts that should be
				// loaded before the plugin instance is created.
				"external_scripts" : [
						"http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js",
						"http://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/jquery-ui.min.js",
						"plugins/thirdparty/vertical-timeline/src/jquery.timeline.js" ],
				// **fill_size** : If this is set to true, the widget will fill
				// be allowed to fill the entire space given it, otherwise it
				// will contain an automatic padding of around 10 pixels around
				// it.
				"fill_size" : true,
				"settings" : [ {
					"name" : "event_message",
					"display_name" : "Event Message",
					"type" : "calculated"
				} ],
				// Same as with datasource plugin, but there is no
				// updateCallback parameter in this case.
				newInstance : function(settings, newInstanceCallback) {
					newInstanceCallback(new verticalTimelineWidgetPlugin(
							settings));
				}
			});

	// ### Widget Implementation
	//
	// -------------------
	// Here we implement the actual widget plugin. We pass in the settings;
	var verticalTimelineWidgetPlugin = function(settings) {
		var self = this;
		var currentSettings = settings;

		// Here we create an element to hold the text we're going to display.
		// We're going to set the value displayed in it below.
		var timelineElement = $("<div id=\"timeline_element\" style=\"overflow: scroll\"></div>");
		timelineElement.id = "timelineElement";

		// **render(containerElement)** (required) : A public function we must
		// implement that will be called when freeboard wants us to render the
		// contents of our widget. The container element is the DIV that will
		// surround the widget.
		self.render = function(containerElement) {
			// Here we append our text element to the widget container element.
			$(containerElement).append(timelineElement);
			$("#timeline_element").timeline({
				data : []
			});
		}

		// **getHeight()** (required) : A public function we must implement that
		// will be called when freeboard wants to know how big we expect to be
		// when we render, and returns a height. This function will be called
		// any time a user updates their settings (including the first time they
		// create the widget).
		//
		// Note here that the height is not in pixels, but in blocks. A block in
		// freeboard is currently defined as a rectangle that is fixed at 300
		// pixels wide and around 45 pixels multiplied by the value you return
		// here.
		//
		// Blocks of different sizes may be supported in the future.
		self.getHeight = function() {
			console.log("Get height called!")
			return 10;
		}

		// **onSettingsChanged(newSettings)** (required) : A public function we
		// must implement that will be called when a user makes a change to the
		// settings.
		self.onSettingsChanged = function(newSettings) {
			currentSettings = newSettings;
		}

		// **onCalculatedValueChanged(settingName, newValue)** (required) : A
		// public function we must implement that will be called when a
		// calculated value changes. Since calculated values can change at any
		// time (like when a datasource is updated) we handle them in a special
		// callback function here.
		self.onCalculatedValueChanged = function(settingName, newValue) {
			if (settingName == "event_message") {
				if (newValue["event_type"].valueOf() == "HIGHLIGHTED".valueOf()) {
					$("#timeline_element").timeline("add", [ {
						time : newValue["timestamp"],
						css : 'highlighted',
						content : newValue["event_msg"]
					} ]);
				} else {
					$("#timeline_element").timeline("add", [ {
						time : newValue["timestamp"],
						css : 'success',
						content : newValue["event_msg"]
					} ]);
				}
			}
		}

		// **onDispose()** (required) : Same as with datasource plugins.
		self.onDispose = function() {
		}
	}
}());
