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

import static org.junit.Assert.*

abstract class AbstractXcoreGeneratorTest {
	
	static Logger myLog = Logger.getLogger(AbstractXcoreGeneratorTest)
	
	@Inject XcoreGenerator underTest	
	@Inject ParseHelper<Schema> parseHelper	
	
	val protected ResourceSet resourceSet = new ResourceSetImpl	
	
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
		val xcoreModel = underTest.compileSchema(model)
		
		dumpGeneratedToWorkspace(model.name+".xcore", xcoreModel)
		
		return xcoreModel		
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
		xtextResource.load(new ByteArrayInputStream( xcoreModel.toString.bytes ), newHashMap)
		
		val packageInstance = xtextResource.contents.findFirst[it instanceof XPackage] as XPackage;
		
		var succeeded = true
		if(null!=packageInstance) {			
			myLog.info("Validating generated Xcore model <"+packageInstance.name+"> ...")
			val issues = xcoreResourceValidator.validate(xtextResource,CheckMode.EXPENSIVE_ONLY,CancelIndicator.NullImpl)
			
			// Ignore Code 24 (EObject resolving fails)
			for(Issue i : issues.filter[severity==Severity.ERROR && code != "org.eclipse.emf.ecore.model.24"]) {
				
				myLog.error(String.format("(%s) Line %d. %s",packageInstance.name, i.lineNumber, i.message))
				succeeded = false
			}	
			for(Issue i : issues.filter[severity==Severity.WARNING]) {
				
				myLog.warn(String.format("(%s) Line %d. %s",packageInstance.name, i.lineNumber, i.message))
			}	
		}
		
		assertTrue("Xcore validation reported error(s) in generated files.", succeeded)
	}
	
	
	protected def dumpGeneratedToWorkspace(String name, CharSequence model) {
				
		val root = ResourcesPlugin.getWorkspace().getRoot()
		val project = root.getProject(class.simpleName)
		
		if(!project.exists) {
			project.create(new NullProgressMonitor)
		}
		if(!project.open) {
			project.open(new NullProgressMonitor)
		}
				
		val localFile = project.getFile( new Path(name) )
		localFile.create( new ByteArrayInputStream( model.toString.bytes ), true, new NullProgressMonitor)
	}
	
}