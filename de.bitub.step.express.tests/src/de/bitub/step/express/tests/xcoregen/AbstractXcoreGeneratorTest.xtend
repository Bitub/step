package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.express.Schema
import de.bitub.step.xcore.XcoreGenerator
import java.io.BufferedReader
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.io.InputStreamReader
import org.apache.log4j.Logger
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xcore.XPackage
import org.eclipse.emf.ecore.xcore.XcoreStandaloneSetup
import org.eclipse.emf.ecore.xcore.validation.XcoreResourceValidator
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.Issue

import de.bitub.step.analyzing.EXPRESSModelInfo
import org.apache.log4j.Level
import de.bitub.step.express.EnumType
import de.bitub.step.express.SelectType
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.CollectionType

import static org.junit.Assert.*
import static extension de.bitub.step.util.EXPRESSExtension.*


abstract class AbstractXcoreGeneratorTest {

	static Logger myLog = Logger.getLogger(AbstractXcoreGeneratorTest)
	
	@Inject protected XcoreGenerator generator	
	@Inject protected ParseHelper<Schema> parseHelper	
	
	val protected ResourceSet resourceSet = new ResourceSetImpl
	
	var protected String generatedXcoreFilename	
	
	def protected printInfoFor(EXPRESSModelInfo info, Schema ifc){
		myLog.level = Level.INFO

		myLog.info('''Entities in total «ifc.entity.size»''')
		myLog.info('''	Abstract entities «ifc.entity.filter[abstract].size»''')
		myLog.info(''' 	Non-abstract entities «ifc.entity.filter[!abstract].size»''')
		myLog.info('''Types in total «ifc.type.size»''')
		myLog.info(''' 	Collection types «ifc.type.filter[aggregation].size»''')
		myLog.info(''' 	Enum types «ifc.type.filter[datatype instanceof EnumType].size»''')
		myLog.info(''' 	Select types «ifc.type.filter[datatype instanceof SelectType].size»''')
		myLog.info('''		Contained referenced selects «info.reducedSelectsMap.keySet.size»''')
		myLog.info('''	Aliased builtins «ifc.type.filter[it.refersDatatype instanceof BuiltInType].size»''')
		myLog.info('''	Aliased concepts «ifc.type.filter[it.refersDatatype instanceof ReferenceType].size»''')
		myLog.info('''	Aliased aggregations «ifc.type.filter[it.refersDatatype instanceof CollectionType].size»''')

		myLog.info('''Inverse relations «info.countInverseNMReferences»''')
		myLog.info('''	Non-unique inverse relations «info.countNonUniqueReferences»''')

		val superTypeRefs = info.supertypeInverseRelations.toList
		myLog.info('''		Declaring supertype non-unique inverse relations: «superTypeRefs.size»''')

		for (a : superTypeRefs) {
			myLog.info(
				'''			- «a.hostEntity.name».«a.name» -> «a.opposite.hostEntity.name».«a.opposite.name» -> «a.opposite.
					refersConcept.name»''')
		}

		val invalidRefs = info.invalidNonuniqueInverseRelations.toList
		myLog.info('''		Unknown non-unique inverse relations: «invalidRefs.size»''')

		for (e : invalidRefs) {

			for (inv : e.value) {
				myLog.info('''			- «inv.hostEntity.name».«inv.name» - «e.key.hostEntity.name».«e.key.name»''')
			}
		}

		val incompleteSelectRefs = info.incompleteInverseSelectReferences.toList
		myLog.info('''		Incomplete inverse selects «incompleteSelectRefs.size»''')

		for (e : incompleteSelectRefs) {

			for (inv : e.value) {
				myLog.info('''			- «inv.hostEntity.name».«inv.name» - «e.key.hostEntity.name».«e.key.name»''')
			}
		}
	}
	
	
	/**
	 * Reads a model.
	 */
	def CharSequence readModel(InputStream in) {

		val reader = new BufferedReader(new InputStreamReader(in))

		var String line
		var StringBuilder buffer = new StringBuilder
		while ((line = reader.readLine()) != null) {

			buffer.append(line).append('\n');
		}
		return buffer
	}

	def generateEXPRESS(CharSequence schema) {
		parseHelper.parse(schema, resourceSet)
	}

	/**
	 * Generates an Xcore model.
	 */
	def generateXCore(CharSequence schema) {

		val model = generateEXPRESS(schema)
		if(!generator.options.containsKey(XcoreGenerator.Options.PACKAGE)) {
			generator.options.put(XcoreGenerator.Options.PACKAGE, '''tests.xcore.«model.name.toLowerCase»''')		
		} 
		val xcoreModel = generator.compileSchema(model)

		saveXcore(model.name, xcoreModel)

		return xcoreModel
	}

	def saveXcore(String name, CharSequence xcoreModel) {
				
		writeToWorkspace(if(null==generatedXcoreFilename) name+".xcore" else generatedXcoreFilename, xcoreModel)
	}
	
	def createXtextProject() {
		
		
	}

	/**
	 * Validates the generated files.
	 */
	def validateXCore(CharSequence xcoreModel) {

		val injector = new XcoreStandaloneSetup().createInjectorAndDoEMFRegistration

		val xcoreResourceSet = injector.getInstance(XtextResourceSet);
		val xcoreResourceValidator = injector.getInstance(XcoreResourceValidator)

		xcoreResourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		val xtextResource = resourceSet.createResource(URI.createURI("test.xcore"))
		xtextResource.load(new ByteArrayInputStream(xcoreModel.toString.bytes), newHashMap)

		val packageInstance = xtextResource.contents.findFirst[it instanceof XPackage] as XPackage;

		var succeeded = true
		if (null != packageInstance) {

			myLog.info('''Validating generated Xcore model «packageInstance.name» ...''')

			val issues = xcoreResourceValidator.validate(
				xtextResource,
				CheckMode.EXPENSIVE_ONLY,
				CancelIndicator.NullImpl
			)

			// Ignore Code 24 (EObject resolving fails)
			for(Issue i : issues.filter[severity==Severity.ERROR && code != "org.eclipse.emf.ecore.model.24"]) {
				
				myLog.error(
					'''(«packageInstance.name») Line «i.lineNumber». «i.message»; Code «i.code»'''
				)
				succeeded = false
			}
			for (Issue i : issues.filter[severity == Severity.WARNING]) {

				myLog.warn(
					'''(«packageInstance.name») Line «i.lineNumber». «i.message»; Code «i.code»'''
				)
			}
		}

		assertTrue("Xcore validation reported error(s) in generated files.", succeeded)
	}

	protected def writeToWorkspace(String name, CharSequence model) {

		val root = ResourcesPlugin.getWorkspace().getRoot()
		val project = root.getProject(class.simpleName)

		if (!project.exists) {
			project.create(new NullProgressMonitor)
		}
		if (!project.open) {
			project.open(new NullProgressMonitor)
		}

		val localFile = project.getFile(new Path(name))
		if (localFile.exists) {
			localFile.delete(true, new NullProgressMonitor)
		}
		localFile.create(new ByteArrayInputStream(model.toString.bytes), true, new NullProgressMonitor)
	}

}
