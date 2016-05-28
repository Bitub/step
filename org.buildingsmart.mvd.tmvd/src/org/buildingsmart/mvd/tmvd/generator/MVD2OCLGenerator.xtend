package org.buildingsmart.mvd.tmvd.generator

import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.TemplatesType
import org.buildingsmart.mvd.mvdxml.ViewsType
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.ocl.OCL
import org.buildingsmart.ifc4.Ifc4Package

class MVD2OCLGenerator implements IGenerator2 {

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
		mvdXML.templates.compile
		mvdXML.views.compile
	}

	def dispatch compile(TemplatesType templates) {
		templates.conceptTemplate.forEach[compile]
	}

	def dispatch compile(ViewsType views) {
		views.modelView.forEach[it.roots.conceptRoot.forEach[compile]]
	}

	def dispatch compile(ConceptRoot conceptRoot) {
		helper.context = Ifc4Package.eINSTANCE.getEClassifier(conceptRoot.applicableRootEntity)		
		conceptRoot.concepts.concept.forEach[compile]
	}

	def dispatch compile(Concept concept) {
		val refTemplate = concept.template.ref
		
				
	}

}
