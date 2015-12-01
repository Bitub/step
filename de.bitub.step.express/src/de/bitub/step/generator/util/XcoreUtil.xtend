/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.generator.util

import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.express.EnumType

/**
 * Class with helper methods.
 */
class XcoreUtil {

	/**
	 * Whether the current data type is translated to a nested aggregation.
	 */
	def dispatch boolean isNestedAggregation(DataType c) {
		false
	}

	/**
	 * Whether the current reference type is translated to a nested aggregation.
	 */
	def dispatch boolean isNestedAggregation(ReferenceType c) {
		(c.instance instanceof Type) && (c.instance as Type).datatype.nestedAggregation
	}

	/**
	 * Whether the current collection type is translated to a nested aggregation.
	 */
	def dispatch boolean isNestedAggregation(CollectionType c) {
		c.type instanceof CollectionType
	}

	/**
	 * True, if derived.
	 */
	def isDerivedAttribute(Attribute a) {
		null != a.expression
	}

	/**
	 * True, if attribute declares the inverse relation
	 */
	def isDeclaringInverseAttribute(Attribute a) {

		null != a.opposite
	}

	/**
	 * True if attribute's type is a one to many relation
	 */
	def isOneToManyRelation(Attribute a) {

		if (a.type instanceof CollectionType) {

			val t = a.type as CollectionType

			return t.upperBound > 1 || t.many || t.upperRef != null || t.lowerRef != null ||
				t.refersConcept instanceof Type // implies Select type
		}

		false
	}

	def dispatch DataType refersTransitiveDatatype(Type t) {

		t.datatype.refersTransitiveDatatype
	}

	/**
	 * Returns the transitive associated datatype.
	 */
	def dispatch DataType refersTransitiveDatatype(DataType t) {

		if (t instanceof ReferenceType) {

			if ((t as ReferenceType).instance instanceof Type) {

				((t as ReferenceType).instance as Type).refersTransitiveDatatype
			} else {

				t
			}
		} else if (t instanceof CollectionType) {

			(t as CollectionType).type.refersTransitiveDatatype
		} else {

			t
		}
	}

	/**
	 * Whether a datatype is referable (non-datatype in Java terms).
	 */
	def isReferable(DataType t) {

		val datatype = t.refersTransitiveDatatype

		if (datatype instanceof ReferenceType) {

			// Entity only
			true

		} else if (datatype instanceof SelectType) {

			// The only class-wrapped type		
			true

		} else {

			false
		}
	}

	/**
	 * Returns the transitively referred concept, if there's any referenced
	 */
	def ExpressConcept refersConcept(DataType dataType) {

		switch (dataType) {
			ReferenceType: dataType.instance
			CollectionType: dataType.type.refersConcept
			default: null
		}
	}

	/**
	 * Returns the parent attribute of a specific data type.
	 */
	def parentAttribute(DataType t) {

		var eAttr = t.eContainer

		while (null != eAttr && !(eAttr instanceof Attribute)) {
			eAttr = eAttr.eContainer
		}
		eAttr as Attribute
	}

	/**
	 * If type is an alias type (simple type wrapper)
	 */
	def boolean isNamedAlias(ExpressConcept e) {

//		switch (e) {
//			Type:
//				switch (e.datatype) {
//					SelectType: true
//					EnumType: true
//				}
//			default:
//				false
//		}
		if (e instanceof Type) {

			val t = e as Type
			!(t.datatype instanceof SelectType || t.datatype instanceof EnumType)

		} else {

			false
		}		
	}

	/**
	 * True, if builtin type reference (primitive or aggregation)
	 */
	def dispatch boolean isBuiltinAlias(ExpressConcept e) {

		switch e {
			Type: e.datatype.builtinAlias
			default: false
		}
	}

	def dispatch boolean isBuiltinAlias(DataType t) {

		switch t {
			CollectionType: t.type.builtinAlias
			ReferenceType: t.instance.builtinAlias
			BuiltInType: true
			default: false
		}
	}
}