package de.bitub.step.xcore

import de.bitub.step.express.ExpressConcept
import java.util.function.BiFunction
import org.eclipse.xtext.naming.QualifiedName
import java.util.Optional

/**
 * This partition delegate will add all concepts into a single (default) namespace.
 */
class XcoreDefaultPartitionDelegate implements BiFunction<ExpressConcept, QualifiedName, Optional<XcorePackageDescriptor>> {
	
	
	override apply(ExpressConcept t, QualifiedName u) {
		
		Optional.<XcorePackageDescriptor>empty		
	}
	
}