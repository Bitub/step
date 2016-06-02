package org.buildingsmart.mvd.expressions.util

import com.google.inject.Guice
import java.io.ByteArrayInputStream
import java.util.UUID
import org.buildingsmart.mvd.expressions.ExpressionStringsRuntimeModule
import org.buildingsmart.mvd.expressions.expressionStrings.Expression
import org.buildingsmart.mvd.expressions.expressionStrings.ExpressionStringsPackage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet

class IOUtil {

	private XtextResourceSet resourceSet;

	new() {
		setup()
	}

	def setup() {
		var injector = Guice.createInjector(new ExpressionStringsRuntimeModule)
		resourceSet = injector.getInstance(XtextResourceSet);

		EPackage.Registry.INSTANCE.put(ExpressionStringsPackage.eNS_URI, ExpressionStringsPackage.eINSTANCE);
		resourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("mvdrule",
			injector.getInstance(XtextResourceFactory))
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
	}

	def parse(String parameters) {
		var resource = resourceSet.createResource(URI.createURI("dummy:/" + UUID.randomUUID + ".mvdrule"))
		var in = new ByteArrayInputStream(parameters.bytes)
		resource.load(in, resourceSet.loadOptions)
		resource.contents.get(0) as Expression
	}
}
