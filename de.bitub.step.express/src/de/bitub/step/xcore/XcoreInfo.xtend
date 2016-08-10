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

package de.bitub.step.xcore

import de.bitub.step.analyzing.EXPRESSModelInfo
import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import java.util.Set
import org.eclipse.xtext.naming.QualifiedName

import static extension de.bitub.step.util.EXPRESSExtension.*

class XcoreInfo {

	val static PREFIX_DELEGATE = "Delegate"	

	val private extension EXPRESSModelInfo modelInfo
		
	val public QualifiedName rootContainerClass;
	
	/**
	 * A delegate reference.
	 */
	static class Delegate {
		
		val public String qualifiedName;
		val public Attribute targetAttribute;
		val public Attribute originAttribute;
		
		new (String qn, Attribute o, Attribute t) {
			
			qualifiedName = qn
			originAttribute = o
			targetAttribute = t
		} 
	}

	/**
	 * Stores nested delegates by 
	 * inverse attribute to <Class name of delegates, name of opposite Xcore attribute>.
	 */
	val public qualifiedNameDelegateMap = <Attribute, Set<Delegate>>newHashMap
	
	
	new (EXPRESSModelInfo info, QualifiedName rootContainer) {
		this.modelInfo = info
		this.rootContainerClass = rootContainer;
	}
	
	def int getCountOfDelegate() {
		
		countOfRelationDelegate
	}
	
	def int getCountOfRelationDelegate() {
		
		qualifiedNameDelegateMap.values.flatten.map[qualifiedName].toSet.size
	}
		
	def Set<Delegate> getRelationDelegates(Attribute a) {
	
		qualifiedNameDelegateMap.get(a)	
	}
		
	/**
	 * Registers (if needed) a bundle of delegates on an attribute a. Returns true, if any delegate 
	 * has been created. 
	 */	
	def createRelationDelegate(Attribute a) {
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.oppositeAttribute	
		
		// If no inverse or no inverse as many-to-many => reject delegate need
		if(null==declaringInverse) {
			
			false
			
		} else {	
				
			val inverseConcept = declaringInverse.opposite.eContainer as ExpressConcept
			val inverseAttribute = declaringInverse.opposite
			val declaringInverseSet = inverseAttribute.allOppositeAttributes
							
			// Add select interface if non-unique on left sides
			if(declaringInverseSet.size > 1) {
				
				val targetConcept = inverseAttribute.type.refersConcept
				val delegateInterfaceName = PREFIX_DELEGATE + inverseConcept.name.toFirstUpper + targetConcept.name.toFirstUpper
				
				createRelationDelegate(inverseAttribute, delegateInterfaceName, null)		
			}
			
			// Generate delegates for all declaring attributes
			for(Attribute origin : declaringInverseSet) {
												
				val delegateName = PREFIX_DELEGATE + origin.hostEntity.name.toFirstUpper + inverseConcept.name.toFirstUpper		
				createRelationDelegate(origin, delegateName, inverseAttribute)
			}
					
			true
		}
	}
	
	/**
	 * Returns true, if a delegate (bundle) exists already.
	 */
	def boolean hasRelationDelegate(Attribute a) {
		
		qualifiedNameDelegateMap.containsKey(a)		
	}
	
	
	def private Delegate createRelationDelegate(Attribute origin, String qualifiedName, Attribute target) {
		
		var set = qualifiedNameDelegateMap.get(origin)
 		if(null==set) {
 			
 			qualifiedNameDelegateMap.put( origin, (set = newHashSet) )
 		}
 
 		val delegate = new Delegate(qualifiedName, origin, target)
 		set += delegate
 		
 		if(null!=target) {
 			
 			set = qualifiedNameDelegateMap.get(target)
	 		if(null==set) {
	 			
	 			qualifiedNameDelegateMap.put( target, (set = newHashSet) )
	 		}
 			
 			// Add inverse
 			set += delegate
 		}
 		
 		delegate
	}

	/**
	 * Returns the local QN of opposite attribute, if there's any.
	 */
	def String getOppositeQN(Attribute a) {

		var String oppositeQualifiedName = a.oppositeAttribute?.name

		// Check whether there is a delegate
		if (a.hasRelationDelegate) {

			if(a.declaringInverseAttribute) {
				// If declaring, opposite is known
				oppositeQualifiedName = a.opposite.name	
				
			} else {
				
				// Otherwise check whether a delegate exists (n-m relationships or non-unique)
 				if(a.relationDelegates.exists[targetAttribute==null]) {
 					// Non-unique => opposite attribute in select interface is named by select hosting concept
 					oppositeQualifiedName = (a.eContainer as Entity).name
 				} 			
			}
		} 
		
		oppositeQualifiedName
	}
	
	/**
	 * Gets the references (delegate) type.
	 */
	def Delegate getRelationDelegate(Attribute a) {
		
		if(a.hasRelationDelegate) {
			
			val delegateSet = a.relationDelegates
			
			if(a.declaringInverseAttribute) {
				
				// If declaring => get delegate
				delegateSet.findFirst[targetAttribute == a.opposite]
				
			} else {
				
 				// If inverse => get interface delegate 			
 				val delegateSelect = delegateSet.findFirst[targetAttribute==null]
 				if(null!=delegateSelect) {
 					// Reference interface type
 					delegateSelect
 				} else {
 					// Unique
 					delegateSet.findFirst[originAttribute==a.oppositeAttribute]
 				}
 			}
		} else {
			
			null
		}
	}
		
		
}