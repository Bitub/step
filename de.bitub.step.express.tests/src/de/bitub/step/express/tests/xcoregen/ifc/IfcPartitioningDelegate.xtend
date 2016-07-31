package de.bitub.step.express.tests.xcoregen.ifc

import de.bitub.step.express.ExpressConcept
import de.bitub.step.xcore.XcoreDefaultPartitionDelegate
import de.bitub.step.xcore.XcorePackageDescriptor
import java.util.Optional
import org.eclipse.xtext.naming.QualifiedName

class IfcPartitioningDelegate extends XcoreDefaultPartitionDelegate {
	
	override apply(ExpressConcept t, QualifiedName u) {
		
		Optional.<XcorePackageDescriptor>empty		
	}

}