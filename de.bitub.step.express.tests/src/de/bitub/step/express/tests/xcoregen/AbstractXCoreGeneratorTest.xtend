package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.express.Schema
import de.bitub.step.generator.XcoreGenerator
import java.util.Map.Entry
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xcore.validation.XcoreResourceValidator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.diagnostics.Severity

import static org.junit.Assert.*
import org.apache.log4j.Logger

abstract class AbstractXCoreGeneratorTest {
	
	static Logger myLog = Logger.getLogger(AbstractXCoreGeneratorTest)
	
	@Inject XcoreResourceValidator xcoreResourceValidator	
	@Inject XcoreGenerator underTest
	@Inject ParseHelper<Schema> parseHelper
	
	val inMemoryFileSystem = new InMemoryFileSystemAccess()
	
	def generateXCore(CharSequence schema) {
		
		val model = parseHelper.parse(schema)
		underTest.doGenerate(model.eResource, inMemoryFileSystem)
	}
	
	/**
	 * Validates the generated files.
	 */
	def validateGeneratedFiles() {
		
		var rs = new ResourceSetImpl()
		
		for(Entry<String,CharSequence> file : inMemoryFileSystem.textFiles.entrySet ) {
		
			var xtextResource = rs.getResource(URI.createURI(file.key), false)
			val issues = xcoreResourceValidator.validate(xtextResource,CheckMode.ALL,CancelIndicator.NullImpl)
			
			val criticalIssues = issues.filter[severity==Severity.ERROR]
			for(Issue i : criticalIssues) {
				
				myLog.error("<"+file.key+"> reports "+i.message)
			}	
			
			assertTrue("Xcore parser error(s) in "+file.key, criticalIssues.empty)
		}
	}
	
	
	def dumpGeneratedFiles(String path) {
		
		
	}
	
}