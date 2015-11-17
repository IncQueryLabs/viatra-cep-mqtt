package org.eclipse.viatra.cep.mqtt.midl.viatra

import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.viatra.cep.mqtt.midl.queries.Patterns
import org.eclipse.viatra.emf.runtime.rules.BatchTransformationRuleGroup
import org.eclipse.viatra.emf.runtime.rules.batch.BatchTransformationRuleFactory
import org.eclipse.viatra.emf.runtime.rules.batch.BatchTransformationStatements
import org.eclipse.viatra.emf.runtime.transformation.batch.BatchTransformation
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.emf.common.util.URI

class RuleProvider {

	static extension val Patterns codeGenQueries = Patterns.instance
	extension val BatchTransformationRuleFactory factory = new BatchTransformationRuleFactory
	extension BatchTransformationStatements statements

	IncQueryEngine engine
	String rootPath
	CepGenerator cepGenerator
	CGenerator cGenerator
	PublisherGenerator publisherGenerator

	boolean generateC = false

	new(IncQueryEngine engine, BatchTransformationStatements statements, String rootPath, URI uri) {
		this.engine = engine
		this.statements = statements
		this.rootPath = rootPath
		cepGenerator = new CepGenerator(rootPath, uri)
		cGenerator = new CGenerator
		publisherGenerator = new PublisherGenerator(rootPath, uri)
		if (generateC) {
			cGenerator.generateProjectFile(rootPath)
			cGenerator.generateCProjectFile(rootPath)
		}
	}

	@Accessors(PUBLIC_GETTER)
	val modelRule = createRule.precondition(mqttSetup).action [ match |
		cepGenerator.generateCepProject(match.mqttSetup.sensors, match.mqttSetup)
		publisherGenerator.generatePublisherProject(match.mqttSetup.sensors)
		for (sensor : match.mqttSetup.sensors) {
			if (generateC) {
				cGenerator.generateCFiles(match.mqttSetup, sensor, rootPath)
			}
		}
	].build

	public def addRules(BatchTransformation transformation) {
		val rules = new BatchTransformationRuleGroup(
			modelRule
		)

		transformation.addRules(rules)
	}

}