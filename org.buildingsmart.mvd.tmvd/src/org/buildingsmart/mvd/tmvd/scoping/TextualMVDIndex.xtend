package org.buildingsmart.mvd.tmvd.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider

class TextualMVDIndex {

	@Inject ResourceDescriptionsProvider rdp

	def getResourceDescription(EObject o) {
		val index = rdp.getResourceDescriptions(o.eResource)
		index.getResourceDescription(o.eResource.URI)
	}

	def getExportedEObjectDescriptions(EObject o) {
		o.resourceDescription.exportedObjects
	}
}
