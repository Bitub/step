package viatra.mvd.query.example

import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.IfcObject
import org.buildingsmart.ifc4.IfcPropertySet
import org.buildingsmart.ifc4.IfcWall
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.viatra.query.patternlanguage.emf.EMFPatternLanguageStandaloneSetup
import org.eclipse.viatra.query.patternlanguage.emf.eMFPatternLanguage.PatternModel
import org.eclipse.viatra.query.patternlanguage.emf.specification.SpecificationBuilder
import org.eclipse.viatra.query.patternlanguage.helper.CorePatternLanguageHelper
import org.eclipse.viatra.query.patternlanguage.patternLanguage.Pattern
import org.eclipse.viatra.query.runtime.api.AdvancedViatraQueryEngine
import org.eclipse.viatra.query.runtime.emf.EMFScope
import org.eclipse.viatra.query.runtime.exception.ViatraQueryException
import org.eclipse.viatra.query.runtime.extensibility.SingletonQuerySpecificationProvider
import org.eclipse.viatra.query.runtime.registry.QuerySpecificationRegistry
import org.eclipse.viatra.query.runtime.registry.connector.SpecificationMapSourceConnector
import org.eclipse.viatra.query.runtime.api.IPatternMatch
import java.util.Collection
import viatra.mvd.query.example.util.PropertySetsForObjectsProcessor

class QueryIfc {

	def test(IFC4 ifc4) {
		extension val queries = PropertySetsAndValues.instance

		val scope = new EMFScope(ifc4)
		val engine = AdvancedViatraQueryEngine.on(scope)
		engine.prepare

		engine.allWalls.allValuesOfWall.forEach [
			println(it + " -> ")
			if (it instanceof IfcWall) {
				val sets = engine.propertySetsForObjects.getAllValuesOfPropertySet(it, null)
				println(sets)
			}
		]

		val propertySets = engine.propertySetsForObjects.getAllValuesOfPropertySet()
		println("--")
		propertySets.forEach [
			println(it)
		]

		engine.propertySetsForObjects.forEachMatch(new PropertySetsForObjectsProcessor() {

			override process(IfcObject pObject, IfcPropertySet pPropertySet, String pName) {
				println('''«pObject.name»«IF pPropertySet.name.length<8»	«ENDIF»	| «pName»''')
			}
		});
	}

	def String executePattern() {
	}

	def String executePattern_LoadFromVQL(IFC4 model, URI fileURI, String patternFQN) {
		val StringBuilder results = new StringBuilder();
		if (model != null) {
			try {
				// get all matches of the pattern
				// create an *unmanaged* engine to ensure that noone else is going
				// to use our engine
				var engine = AdvancedViatraQueryEngine.createUnmanagedEngine(new EMFScope(model));
				// instantiate a pattern matcher through the registry, by only knowing its FQN
				// assuming that there is a pattern definition registered matching 'patternFQN'
				var Pattern p = null;

				// Initializing Xtext-based resource parser
				EMFPatternLanguageStandaloneSetup.doSetup

				// Loading pattern resource from file
				var resourceSet = new ResourceSetImpl();

				var patternResource = resourceSet.getResource(fileURI, true);

				// navigate to the pattern definition that we want
				if (patternResource != null) {
					if (patternResource.getErrors().size() == 0 && patternResource.getContents().size() >= 1) {
						var topElement = patternResource.getContents().get(0);
						if (topElement instanceof PatternModel) {
							for (Pattern _p : topElement.getPatterns()) {
								if (patternFQN.equals(CorePatternLanguageHelper.getFullyQualifiedName(_p))) {
									p = _p;
								}
							}
						}
					}
				}
				if (p == null) {
					throw new RuntimeException(String.format("Pattern %s not found", patternFQN));
				}
				var builder = new SpecificationBuilder();
				val specification = builder.getOrCreateSpecification(p);
				val registry = QuerySpecificationRegistry.instance

				var connector = new SpecificationMapSourceConnector("my.source.identifier", false);

				registry.addSource(connector);
				var provider = new SingletonQuerySpecificationProvider(specification);

				// add specification to source
				connector.addQuerySpecificationProvider(provider);

				// Initialize matcher from specification
				var matcher = engine.getMatcher(specification);

				if (matcher != null) {
					var matches = matcher.getAllMatches();
					prettyPrintMatches(results, matches);
				}

				// wipe the engine
				engine.wipe();
				// after a wipe, new patterns can be rebuilt with much less overhead than 
				// complete traversal (as the base indexes will be kept)
				// completely dispose of the engine once's it is not needed
				engine.dispose();
//				modelResource.unload();
			} catch (ViatraQueryException e) {
				e.printStackTrace();
				results.append(e.getMessage());
			}
		} else {
			results.append("Resource not found");
		}
		return results.toString();
	}

	def loadModel(String modelPath) {
		var fileURI = URI.createFileURI(modelPath);
		return loadModel(fileURI);
	}

	def loadModel(URI fileURI) {
		// Loads the resource
		var resourceSet = new ResourceSetImpl();
		var resource = resourceSet.getResource(fileURI, true);
		return resource;
	}

	def void prettyPrintMatches(StringBuilder results, Collection<? extends IPatternMatch> matches) {
		for (IPatternMatch match : matches) {
			results.append(match.prettyPrint() + ";\n");
		}
		if (matches.size() == 0) {
			results.append("Empty match set");
		}
		results.append("\n");
	}
}
