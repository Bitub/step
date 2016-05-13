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
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.Entity
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Type
import java.util.Set
import org.eclipse.xtext.naming.QualifiedName

import static extension de.bitub.step.util.EXPRESSExtension.*

class XcoreInfo {

	val private extension EXPRESSModelInfo modelInfo
		
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

	/**
	 * Nested aggregation as qualified name to Xcore class name.
	 */
	val public qualifiedNameAggregationMap = <QualifiedName, String>newHashMap
	
	
	new (EXPRESSModelInfo info) {
		this.modelInfo = info
	}
	
	def int getCountOfDelegate() {
		
		countOfAggregationDelegate + countOfRelationDelegate
	}
	
	def int getCountOfRelationDelegate() {
		
		qualifiedNameDelegateMap.values.flatten.map[qualifiedName].toSet.size
	}
	
	def int getCountOfAggregationDelegate() {
		
		qualifiedNameAggregationMap.size
	}
	
		
	def String getDelegateQN(CollectionType c) {
				
		// Inline aggregation
		qualifiedNameAggregationMap.get(c.qualifiedReference)
	}
	
	def Set<Delegate> getDelegates(Attribute a) {
	
		qualifiedNameDelegateMap.get(a)	
	}
	
	def String getDelegateQN(Attribute a, Attribute b) {
		
		qualifiedNameDelegateMap.get(a)?.findFirst[targetAttribute == b].qualifiedName
	}
	
	def dispatch boolean hasDelegate(Entity o) {
		
		false
	}

	def dispatch boolean hasDelegate(DataType o) {
		
		false
	}
	
	
	def dispatch boolean hasDelegate(ReferenceType r) {
				
		switch(r.instance) {
			
			Type: {
			
				val type = r.instance as Type
				type.aggregation &&	type.datatype.hasDelegate				
			}
			
			default:
				false
		}
	}
	
	def dispatch boolean hasDelegate(CollectionType c) {
		
		// Inline aggregation
		qualifiedNameAggregationMap.containsKey(c.qualifiedReference)
	}
	
	def dispatch boolean hasDelegate(Attribute a) {
		
		qualifiedNameDelegateMap.containsKey(a)
	}
	
	def dispatch boolean hasDelegate(Type a) {
		
		a.datatype.hasDelegate
	}
	
	def String createNestedDelegate(CollectionType c) {
	
		var QualifiedName qn = c.qualifiedReference
		
		if(qualifiedNameAggregationMap.containsKey(qn)) {
			
			return qualifiedNameAggregationMap.get(qn)
		}
		
		var String nestedQN
//		if(c.typeAggregation) {
//					
//			nestedQN = qn.segments.join.toFirstUpper.replace('''[]''','''Array''')
//		} else {
			
			nestedQN = qn.skipLast(1).segments.join.toFirstUpper.replace('''[]''','''InList''')			
//		}
		
		qualifiedNameAggregationMap.put( qn, nestedQN )
		
		nestedQN			
	}
	
	
	def Delegate createDelegate(Attribute origin, String qualifiedName, Attribute target) {
		
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
 			
 			set += new Delegate(qualifiedName, target, origin)
 		}
 		
 		delegate
	}

	/**
	 * Returns the local QN of opposite attribute, if there's any.
	 */
	def String getOppositeQN(Attribute a) {

		if (a.hasDelegate) {

			if(a.declaringInverseAttribute) {
			
				a.opposite.name	
				
			} else {
				
 				val delegate = qualifiedNameDelegateMap.get(a).findFirst[targetAttribute==null]
 				if(null!=delegate) {
 					// Non-unique => opposite is named as invers concept
 					(a.eContainer as Entity).name
 				} else {
 					// Unique
 					a.oppositeAttribute?.name
 				}				
			}

		} else {

			a.oppositeAttribute?.name
		}
	}
	
	/**
	 * Gets the references (delegate) type.
	 */
	def String getDelegateQN(Attribute a) {
		
		if(a.hasDelegate) {
			
			if(a.declaringInverseAttribute) {
				// If declaring => get delegate
				getDelegateQN(a, a.opposite)
			} else {
 				// If inverse => get interface delegate
 				val delegate = qualifiedNameDelegateMap.get(a).findFirst[targetAttribute==null]
 				if(null!=delegate) {
 					// Non-unique
 					delegate.qualifiedName
 				} else {
 					// Unique
 					qualifiedNameDelegateMap.get(a).findFirst[targetAttribute==a.oppositeAttribute]?.qualifiedName
 				}
 			}
		} else {
			
			// non-delegate
			a.refersConcept?.name
		}
	}
		
		
}