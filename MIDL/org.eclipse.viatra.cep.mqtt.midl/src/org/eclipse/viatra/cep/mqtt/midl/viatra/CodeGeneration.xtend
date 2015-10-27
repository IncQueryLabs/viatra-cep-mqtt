package org.eclipse.viatra.cep.mqtt.midl.viatra

import org.eclipse.incquery.runtime.api.GenericPatternGroup
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.viatra.emf.runtime.rules.batch.BatchTransformationStatements
import org.eclipse.viatra.emf.runtime.transformation.batch.BatchTransformation
import org.eclipse.viatra.cep.mqtt.midl.queries.Patterns

class CodeGeneration {
	
	extension Patterns thesisQueries = Patterns.instance
	extension BatchTransformationStatements statements
	private var initialized = false
	
	BatchTransformation transform
	IncQueryEngine engine
	RuleProvider ruleProvider
	
	def initialize(IncQueryEngine engine, String rootPath) {
		if (!initialized) {
			this.engine = engine
			
			val queries = GenericPatternGroup.of(thesisQueries)
			queries.prepare(engine)
			
			transform = BatchTransformation.forEngine(engine)
			statements = new BatchTransformationStatements(transform)
			ruleProvider = new RuleProvider(engine, statements, rootPath)
			ruleProvider.addRules(transform)
			
			initialized = true
		}
	}
	
	def fire() {
		fireAllCurrent(ruleProvider.modelRule)
	}
	
	def dispose() {
		transform?.dispose
	}
	
}