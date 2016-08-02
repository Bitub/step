package de.bitub.step.xcore

import de.bitub.step.express.ExpressConcept
import java.util.Optional
import java.util.function.Function

/**
 * This partition delegate will add all concepts into a single (default) namespace.
 */
class XcoreDefaultPartitionDelegate implements Function<ExpressConcept, Optional<XcorePackageDescriptor>> {
	
	
	override apply(ExpressConcept t) {
		
		Optional.<XcorePackageDescriptor>empty		
	}
	
}