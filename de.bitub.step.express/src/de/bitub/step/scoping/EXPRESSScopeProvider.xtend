/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.scoping

import de.bitub.step.express.Attribute
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.Entity
import de.bitub.step.express.ReferenceType
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import java.util.List
import org.apache.log4j.Logger

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class EXPRESSScopeProvider extends AbstractDeclarativeScopeProvider {

	val myLog = Logger.getLogger(EXPRESSScopeProvider)


	/**
	 * Resolve opposite attributes.
	 */
	def scope_Attribute_opposite(Attribute context, EReference r) {
		var DataType dataType = context.type		
		
		if(context.type instanceof CollectionType) {
			
		 	if((context.type as CollectionType).type instanceof ReferenceType) {
		 		
		 		dataType = (context.type as CollectionType).type;
		 	}
		}
		
		if(dataType instanceof ReferenceType) {
			
			if(dataType.instance instanceof Entity) {
				Scopes.scopeFor((dataType.instance as Entity).attribute, IScope.NULLSCOPE);
			}				
		} else {
			
			myLog.debug("No reference given.")	
		}
	}
	
	def scope_CollectionType_lowerRef(CollectionType context, EReference r) {
		
		val entity = context.eContainer.eContainer as Entity;
		if(null!=entity) {
						
			val candidates = newArrayList()
			recursiveSuperExecute(candidates ,entity)
			Scopes.scopeFor(candidates, IScope.NULLSCOPE);
		}		
	}

	def scope_CollectionType_upperRef(CollectionType context, EReference r) {
		
		val entity = context.eContainer.eContainer as Entity;
		if(null!=entity) {
						
			val candidates = newArrayList()
			recursiveSuperExecute(candidates ,entity)
			Scopes.scopeFor(candidates, IScope.NULLSCOPE);
		}		
	}

	def void recursiveSuperExecute(List<Attribute> candidates, Entity e) {
		
		candidates += e.attribute 
		e.supertype.forEach[ supertype | recursiveSuperExecute(candidates, supertype) ];
	}
}
