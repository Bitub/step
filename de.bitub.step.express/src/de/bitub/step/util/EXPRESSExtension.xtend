/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.util

import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import java.util.Set

import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * Shorthand utility method to derive more information about model elements of EXPRESS.
 */
class EXPRESSExtension {
	
		
	/**
	 * True, if sup is a supertype of sub.
	 */
	def static isSupertypeOf(Entity sup, Entity sub) {
		
		if(sup == sub) {
			
			return false;
		}
		
		var queue = newLinkedList(sub)
		while(!queue.empty) {
		
			var e = queue.poll
			if(e == sup) {
				
				return true
			} else {
				
				queue += e.supertype
			}
		}
		
		false
	}

	/**
	 * True, if sub is a subtype of sup.
	 */
	def static isSubtypeOf(Entity sub, Entity sup) {
		
		if(sup == sub) {
			
			return false;
		}
		
		var queue = newLinkedList(sub)
		while(!queue.empty) {
		
			var e = queue.poll
			if(e == sub) {
				
				return true
			} else {
				
				queue += e.subtype
			}
		}
		
		false
	}
	

	/**
	 * Get the antity container for the given attribute.
	 */
	def static getHostEntity(Attribute attribute) {
		
		attribute.getContainerOfType(typeof(Entity))
	}

	/**
	 * Get all derived attributes of the given entity.
	 */
	def static getDerivedAttribute(Entity entity) {
		
		entity.attribute.filter[it.expression != null]
	}

	/**
	 * Get all inverse attributes of the given entity.
	 */
	def static getDeclaringInverseAttribute(Entity entity) {
		
		entity.attribute.filter[it.opposite != null]
	}

	/**
	 * Whether the current data type is translated to a nested aggregation.
	 */
	def static dispatch boolean isNestedAggregation(DataType c) {
		
		false
	}

	/**
	 * Whether the current reference type is translated to a nested aggregation.
	 */
	def static dispatch boolean isNestedAggregation(ReferenceType c) {
		
		(c.instance instanceof Type) && (c.instance as Type).datatype.nestedAggregation
	}

	/**
	 * Whether the current collection type is translated to a nested aggregation.
	 */
	def static dispatch boolean isNestedAggregation(CollectionType c) {
		
		c.type instanceof CollectionType
	}

	def static boolean isTypeAggregation(Type c) {
		
		c.datatype.typeAggregation
	}

	def static boolean isTypeAggregation(DataType c) {
		
		switch(c) {
			CollectionType:
				c.typeAggregation
			default:
				false
		}
	}
	
	/**
	 * True, if collection type references a type wrapper pattern.
	 */
	def static boolean isTypeAggregation(CollectionType c) {
		
		c.type.builtinAlias
	}


	/**
	 * True, if derived.
	 */
	def static isDerivedAttribute(Attribute a) {
		
		null != a.expression
	}

	/**
	 * True, if attribute declares the inverse relation
	 */
	def static isDeclaringInverseAttribute(Attribute a) {

		null != a.opposite
	}
	

	/**
	 * True, if attribute's type is a one to many relation in the cases of
	 * <ul> 
	 * <li>either given unbound upper bounds</li>
	 * <li>bound to more than 1</li>
	 * <li>defined lower or upper reference bound (i.e. given runtime thresholds via attribute)</li>
	 * </ul>
	 */
	def static isOneToManyRelation(Attribute a) {

		if (a.type instanceof CollectionType) {

			val t = a.type as CollectionType

			return t.upperBound > 1 || t.many || t.upperRef != null || t.lowerRef != null 				
		}

		false
	}
	
	def static dispatch DataType refersDatatype(Attribute a) {
		
		a.type.refersDatatype
	}

	/**
	 * Computes the final referenced datatype (i.e. a collection of collection of some data type)
	 */
	def static dispatch DataType refersDatatype(Type t) {

		t.datatype.refersDatatype
	}

	/**
	 * Returns the transitive associated datatype.
	 */
	def static dispatch DataType refersDatatype(DataType t) {

		if (t instanceof ReferenceType) {

			if ((t as ReferenceType).instance instanceof Type) {

				((t as ReferenceType).instance as Type).refersDatatype
			} else {

				t
			}
		} else if (t instanceof CollectionType) {

			(t as CollectionType).type.refersDatatype
		} else {

			t
		}
	}

	/**
	 * Whether a datatype is referable (non-datatype in Java terms).
	 */
	def static isReferable(ExpressConcept t) {

		switch(t) {
			
			Type:
				t.referable
			default:
				true			
		}
	}

	/**
	 * Whether a datatype is referable (non-datatype in Java terms).
	 */
	def static isReferable(Type t) {

		switch(t.refersDatatype) {
			
			ReferenceType:
				// Entity only
				true
			SelectType:
				// The only class-wrapped type		
				true
			default:
				false			
		}
	}
	

	/**
	 * Whether a datatype is referable (non-datatype in Java terms).
	 */
	def static isReferable(DataType t) {

		switch(t.refersDatatype) {
			
			ReferenceType:
				// Entity only
				true
			SelectType:
				// The only class-wrapped type		
				true
			default:
				false			
		}
	}
	
	def static isSelect(Attribute a) {
		
		a.type.refersDatatype instanceof SelectType
	}
	
	def static isEnum(Attribute a) {
		
		a.refersDatatype instanceof EnumType
	}	
	
	def static isHostedByEntity(Attribute a) {
		
		null != a.getContainerOfType(typeof(Entity))
	}
	
	
	def static dispatch ExpressConcept refersConcept(Attribute c) {
		
		c.type.refersConcept
	}

	/**
	 * Returns the transitively referred concept, if there's any referenced
	 */
	def static dispatch ExpressConcept refersConcept(ExpressConcept c) {
	
		switch(c) {
			
			Type: 
				(c as Type).datatype.refersConcept
			default: 
				c
		} 		
	}	

	/**
	 * Returns the transitively referred concept, if there's any referenced
	 */
	def static dispatch ExpressConcept refersConcept(DataType dataType) {

		switch (dataType) {
			
			ReferenceType: 
				dataType.instance.refersConcept
				
			CollectionType: 
				dataType.type.refersConcept
			
			default: 
				
				if(dataType.eContainer instanceof Type) {
					
					dataType.eContainer as Type
				} else {
					
					null
				}
		}
	}

	/**
	 * Returns the parent attribute of a specific data type.
	 */
	def static getHostAttribute(DataType t) {

		t.getContainerOfType(typeof(Attribute))
	}
	
	def static isHostedByAttribute(DataType t) {
		
		null != t.getContainerOfType(typeof(Attribute)) 
	}
	
	def static boolean isAggregation(ExpressConcept c) {
		
		switch(c) {
			
			Type:
				(c as Type).datatype.isAggregation
			default:
				false
		}
	}
	
	def static boolean isAggregation(DataType t){
		
		switch(t){
			
			ReferenceType:
				(t as ReferenceType).instance.isAggregation
			CollectionType:
				true
			default:
				false
		}
	}

	/**
	 * True, if given concept is an alias (reference wrapper) to another concept.
	 */
	def static boolean isNamedAlias(ExpressConcept e) {

		switch(e) {
			Type:
				e.datatype instanceof ReferenceType			
			default:
				false
		}
	}

	/**
	 * True, if concept is a reference to a primitive data type.
	 */
	def static dispatch boolean isBuiltinAlias(ExpressConcept e) {

		switch e {
			Type: 
				e.datatype.builtinAlias
			default: 
				false
		}
	}

	/**
	 * True, if concept is a reference to a primitive data type.
	 */
	def static dispatch boolean isBuiltinAlias(DataType t) {

		switch t {
			CollectionType: 
				t.type.builtinAlias
			ReferenceType: 
				t.instance.builtinAlias
			BuiltInType: 
				true
			default: 
				false
		}
	}
	
	/**
	 * Determines the flat set of EXPRESS concepts represented by given Select statement.
	 */
	def static Set<ExpressConcept> flattenSelect(SelectType selectType) {

		val uniqueTypeSet = <ExpressConcept>newHashSet


		// Self evaluation
		var set = selectType.select.filter [
			!(it instanceof Type && (it as Type).datatype instanceof SelectType)
		].toSet;

		// Recursion (filter all SELECTs)
		selectType.select.filter [
			it instanceof Type && (it as Type).datatype instanceof SelectType
		].forEach[uniqueTypeSet += flattenSelect((it as Type).datatype as SelectType)]

		uniqueTypeSet += set
		
		return uniqueTypeSet
	}
	
}