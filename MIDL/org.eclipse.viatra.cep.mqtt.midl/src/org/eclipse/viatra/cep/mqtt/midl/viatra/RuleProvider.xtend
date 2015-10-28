package org.eclipse.viatra.cep.mqtt.midl.viatra

import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.viatra.cep.mqtt.midl.queries.Patterns
import org.eclipse.viatra.emf.runtime.rules.BatchTransformationRuleGroup
import org.eclipse.viatra.emf.runtime.rules.batch.BatchTransformationRuleFactory
import org.eclipse.viatra.emf.runtime.rules.batch.BatchTransformationStatements
import org.eclipse.viatra.emf.runtime.transformation.batch.BatchTransformation
import org.eclipse.xtend.lib.annotations.Accessors

class RuleProvider {

	static extension val Patterns codeGenQueries = Patterns.instance
	extension val BatchTransformationRuleFactory factory = new BatchTransformationRuleFactory
	extension BatchTransformationStatements statements

	IncQueryEngine engine
	String rootPath
	JavaGenerator javaGenerator
	CGenerator cGenerator
	PatternGenerator patternGenerator

	boolean generateC = false
	boolean generateJava = true
	boolean generateCep = true

	new(IncQueryEngine engine, BatchTransformationStatements statements, String rootPath) {
		this.engine = engine
		this.statements = statements
		this.rootPath = rootPath
		javaGenerator = new JavaGenerator
		cGenerator = new CGenerator
		patternGenerator = new PatternGenerator
		if (generateC) {
			cGenerator.generateProjectFile(rootPath)
			cGenerator.generateCProjectFile(rootPath)
		}
		if (generateJava) {
			javaGenerator.generateGeneralSubscriber(rootPath)
			javaGenerator.generateGeneralPublisher(rootPath)
			javaGenerator.generateGeneralCallback(rootPath)
		}
		if (generateCep) {
			patternGenerator.generateDefaultEiqFile(rootPath)
			patternGenerator.generateDefaultVeplFile(rootPath)
		}
	}

	@Accessors(PUBLIC_GETTER)
	val modelRule = createRule.precondition(machines).action [ match |
		for (sensor : match.machine.sensors) {
			if (generateC) {
				cGenerator.generateCFiles(match.machine.mqttSetup, sensor, rootPath)
			}
			if (generateJava) {
				javaGenerator.generateJavaFiles(match.machine.mqttSetup, sensor, rootPath)
			}
			if (generateCep) {
				patternGenerator.generatePatterns(sensor, rootPath)
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