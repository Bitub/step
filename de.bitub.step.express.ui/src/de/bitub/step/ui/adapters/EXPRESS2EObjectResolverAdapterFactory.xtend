/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.ui.adapters

import com.google.inject.Inject
import org.eclipse.core.runtime.IAdapterFactory
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.XtextDocument
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.jface.text.TextSelection

class EXPRESS2EObjectResolverAdapterFactory implements IAdapterFactory {

	@Inject
	protected EObjectAtOffsetHelper eObjectAtOffsetHelper;


	def override getAdapter(Object adaptableObject, Class adapterType) {

		if (adaptableObject instanceof EObjectNode) {
			
      	 	return adapt(adaptableObject as EObjectNode); 
	  	}
	  	if(adaptableObject instanceof TextSelection) {
	  		
	  		// TODO
	  	}
    }
    
    def EObject adapt(EObjectNode node) {
    	
      	 val URI eObjectURI = node.EObjectURI;
      	 val IUnitOfWork<EObject,XtextResource> unitOfWork = new IUnitOfWork<EObject,XtextResource>() {
      	 	
			def override EObject exec(XtextResource resource) throws Exception {
				if (resource != null && !resource.getContents().isEmpty()) {
					resource.getEObject(eObjectURI.fragment());
				}
			}
		}
		
		node.document.readOnly(unitOfWork);     	
    }
    
    def EObject adapt(XtextDocument resource, int offset) {
    	resource.readOnly(new IUnitOfWork<EObject, XtextResource>() {
			def override EObject exec(XtextResource localResource) throws Exception {
				return eObjectAtOffsetHelper.resolveElementAt(localResource, offset);
			}
		});
    }
	
	def override Class<?>[] getAdapterList() {
		#{ typeof(EObject) };
	}
	
}
	