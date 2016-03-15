package de.bitub.step.xcore

import de.bitub.step.express.Attribute
import de.bitub.step.analyzing.EXPRESSModelInfo
import java.util.Set
import de.bitub.step.util.EXPRESSExtension
import javax.inject.Inject
import de.bitub.step.express.Entity
import org.eclipse.xtext.naming.QualifiedName

class XcoreInfo {

	/**
	 * The associated EXPRESS model info.
	 */
	val public extension EXPRESSModelInfo modelInfo;
	
	@Inject extension EXPRESSExtension
	
	
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
	val public qualifiedNameAggregationMap = <String, String>newHashMap
	
	
	new (EXPRESSModelInfo info) {
		modelInfo = info
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
	
	def String getDelegateQN(QualifiedName qn) {
		
		qualifiedNameAggregationMap.get(qn.toString)
	}
	
	def Set<Delegate> getDelegates(Attribute a) {
	
		qualifiedNameDelegateMap.get(a)	
	}
	
	def String getDelegateQN(Attribute a, Attribute b) {
		
		qualifiedNameDelegateMap.get(a)?.findFirst[targetAttribute == b].qualifiedName
	}
	
	def boolean hasDelegate(QualifiedName qn) {
		
		qualifiedNameAggregationMap.containsKey(qn.toString)
	}
	
	def boolean hasDelegate(Attribute a) {
		
		qualifiedNameDelegateMap.containsKey(a)
	}

	def String addNestedDelegate(QualifiedName qn) {
	
		var nestedQN = qualifiedNameAggregationMap.get(qn.toString)
		if(null==nestedQN) { 
			
			nestedQN = qn.toString.replace('.','_').toFirstUpper
			qualifiedNameAggregationMap.put( qn.toString, nestedQN )			
		}	
		
		nestedQN
	}
	
	def Delegate addDelegate(Attribute origin, String qualifiedName, Attribute target) {
		
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
			a.refersConcept.name
		}
	}
		
	def String getAggregationQN() {
		
	}
	
		
}