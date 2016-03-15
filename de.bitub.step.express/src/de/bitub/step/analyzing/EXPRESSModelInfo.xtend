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
package de.bitub.step.analyzing

import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.util.EXPRESSExtension
import java.util.Set

class EXPRESSModelInfo {
	
	val private extension EXPRESSExtension modelExtension = new EXPRESSExtension
	
	public val Schema schema;
	
	/**
	 * Flattened concept set of SELECTS where all select types are resolved to ordinary types or enitities. 
	 */
	public val resolvedSelectsMap = <Type, Set<ExpressConcept>>newHashMap

	/**
	 * Mapping of declared inverse (opposite) attribute versus declaring inverse attribute (having an opposite reference)
	 */
	public val inverseReferenceMap = <Attribute, Set<Attribute>>newHashMap

	 
	/**
	 * Maps the type aliases which act as pure aliases.
	 */
	public val aliasConceptMap = <Type, ExpressConcept>newHashMap
	
	new(Schema s) {
		schema = s
	}	
	
	def int getCountSelects() {
		
		resolvedSelectsMap.size
	}
	
	def int getCountNonUniqueReferences() {
	
		inverseReferenceMap.keySet.filter[ nonUniqueRelation ].size
	}
	
	def int getCountInverseNMReferences(){
		
		inverseReferenceMap.keySet.filter[ null!=it && isInverseManyToManyRelation ].size
	}
	
	def int getCountAliasedConcepts() {
		
		aliasConceptMap.size
	}
	
	
	def boolean isAliasType(Type t) {
		
		null != aliasConceptMap.get(t)
	}
	
	
	/**
	 * Returns the opposite attribute(s) of given attribute or null, if there's no inverse
	 * relation.
	 */
	def Set<Attribute> getAllOppositeAttributes(Attribute a) {

		if (null != a.opposite) {

			newHashSet(a.opposite)
		} else {

			if (inverseReferenceMap.containsKey(a)) {

				inverseReferenceMap.get(a)
			} else {
				
				newHashSet
			}
		}
	}
	
	
	
	/** 
	 * Get first opposite attribute if existing
	 */
	def Attribute getOppositeAttribute(Attribute a) {

		if (null != a.opposite)
			a.opposite
		else
			inverseReferenceMap.get(a)?.findFirst[it != null]
	}


	/**
	 * Check whether there are any entity concepts inside set.
	 */
	def isEntityCompositeSelect(Set<ExpressConcept> selects) {	
		
		selects.exists[it instanceof Entity]	
	}
	
	def getFlattenedConceptSet(SelectType s) {
		
		if(resolvedSelectsMap.containsKey(s.eContainer)) resolvedSelectsMap.get(s) else newHashSet
	}

	/**
	 * True if a refers to an inverse relation.
	 */
	def isInverseRelation(Attribute a) {

		inverseReferenceMap.containsKey(a) || null != a.opposite
	}
	
	/**
	 * Gets the inverse declared attribute
	 */
	def getInverseRelationAttribute(Attribute a) {
		
		if(a.declaringInverseAttribute) 
			a.opposite 
		else
			if(inverseReferenceMap.containsKey(a)) 
				a 
	}
	
	/**
	 * Gets the inverse declaring attributes.
	 */
	def getDeclaringInverseRelationAttribute(Attribute a) {
		
		if(a.declaringInverseAttribute) 
			inverseReferenceMap.get(a.opposite)
		else 
			if(inverseReferenceMap.containsKey(a))
				inverseReferenceMap.get(a)
			else
				newImmutableSet				
	}
	
	
	/**
	 * True, if a represents a one-to-many relation (which might also be an inverse many-to-many relation)
	 */
	def isInverseOneToManyRelation(Attribute a) {
		
		a.inverseRelation && (a.isOneToManyRelation || a.allOppositeAttributes.exists[ isOneToManyRelation ])
	}

	/**
	 * True,if a represents in any reference a many-to-many relation.
	 */
	def isInverseManyToManyRelation(Attribute a) {
		
		a.inverseRelation && (a.isOneToManyRelation && a.allOppositeAttributes.exists[ isOneToManyRelation ])
	}
	
	/**
	 * True, if the relation ship is not unique to its opposite in case of 
	 * <ul>
	 * <li>more than one declaring inverse attribute</li>
	 * <li>or "a" references a select branch</li>
	 * <li>or "a" references a supertype of its opposite
	 * </ul>
	 */
	def isInverseNonUniqueDirectedRelation(Attribute a) {
		
		a.inverseRelation && 
			(a.allOppositeAttributes.size > 1 // More than 1 opposite
				|| a.select 	// A select
				|| EXPRESSExtension.isSupertypeOf(a.type.refersConcept as Entity, a.oppositeAttribute.eContainer as Entity) // refers supertype of opposite container
			)		
	}
	
	/**
	 * True, if this attribute references an supertype entity of its inverse relation.
	 */
	def isSupertypeOppositeDirectedRelation(Attribute a) {
		
		a.inverseRelation && EXPRESSExtension.isSupertypeOf(a.refersConcept as Entity, a.oppositeAttribute.eContainer as Entity) // refers supertype of opposite container
	}

	/**
	 * True, if a marks a unique inverse relation ship (such that no delegate is needed) 
	 */
	def isInverseUniqueRelation(Attribute a) {
		
		// If all Entities of all declaring attributes are target reference of inverse relation attribute => only if unique
		a.inverseRelation && a.declaringInverseRelationAttribute.forall[ eContainer == (a.inverseRelationAttribute.refersConcept as Entity) ]
	}
	
	
	/**
	 * True, if any end of relation is non-unique.
	 */
	def isNonUniqueRelation(Attribute a) {
		
		a.isInverseNonUniqueDirectedRelation || a.allOppositeAttributes.exists[ isInverseNonUniqueDirectedRelation ]		
	}
}