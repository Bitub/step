package org.buildingsmart.mvd.tmvd.generator

import com.google.inject.Inject
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.mvd.expressions.transform.ExpressionString2OCL
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.TemplateRuleType
import org.buildingsmart.mvd.mvdxml.TemplateRules
import org.buildingsmart.mvd.mvdxml.ViewsType
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.ocl.OCL
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext

class MVD2OCLGenerator implements IGenerator2 {

	@Inject extension ExpressionString2OCL expr2ocl

	val ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);
	val helper = ocl.createOCLHelper

	override afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {

		val mvdXML = input.allContents.findFirst[e|e instanceof MvdXML] as MvdXML
		mvdXML.compile
	}

	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch compile(MvdXML mvdXML) {
		mvdXML.views.compile
	}

	def dispatch compile(ViewsType views) {
		views.modelView.findFirst [
			it.roots != null
		].roots.conceptRoot.findFirst [
			it != null
		].compile
	}

	def dispatch compile(ConceptRoot conceptRoot) {
		helper.context = Ifc4Package.eINSTANCE.getEClassifier(conceptRoot.applicableRootEntity)
		'''«conceptRoot.applicableRootEntity»::allInstances() -> forAll(''' + conceptRoot.concepts.concept.findFirst [
			it != null
		].compile + ''')'''
	}

	def dispatch compile(Concept concept) {
		val refTemplate = concept.template.ref

		'''''' + concept.templateRules.compile
	}

	def dispatch compile(TemplateRules rules) {

		var subTrees = rules.templateRules
		var leafs = rules.templateRule

		leafs.map [
			it.compile
		].join
	}

	def dispatch compile(TemplateRuleType rule) {
		expr2ocl.transformToOCL(rule.parameters)
	}

}
