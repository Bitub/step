package de.bitub.step.generator

import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import java.util.List
import java.util.Set
import org.apache.log4j.Logger
import javax.inject.Inject
import de.bitub.step.generator.util.XcoreUtil

class ExpressInterpreter {

	@Inject XcoreUtil util;

	/** ~~~~~~~~~~~~~~~~~~~~~~~~~ LOGGER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	//
	var static Logger LOGGER = Logger.getLogger(ExpressInterpreter);

	/** ~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC MEMBERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	// Flattened concept set of selects
	//
	public var resolvedSelectsMap = <Type, Set<ExpressConcept>>newHashMap

	// Inverse references
	//
	public val inverseReferenceMap = <Attribute, Set<Attribute>>newHashMap

	// Inverse super type substitution
	//
	public val inverseSupertypeMap = <Entity, List<Attribute>>newHashMap

	// Nested proxies as Attribute to <Class name of proxy, name of opposite Xcore attribute>
	//
	public val nestedProxiesQN = <Attribute, Pair<String, String>>newHashMap

	// Nested aggregation as QN to Xcore class name
	//
	public val nestedAggregationQN = <String, String>newHashMap()

	// Maps the type aliases
	//
	public val aliasConceptMap = <Type, ExpressConcept>newHashMap

	/** ~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC METHODS ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	//
	/**
	 * Start processing schema for collecting and analyzing the given schema.
	 * The XcoreGenerator make makes model transformation based on this data. 
	 */
	public def process(Schema schema) {

		// Filter for simplified type selects
		//
		LOGGER.info("Processing select types ...")
		for (Type t : schema.types.filter[it.datatype instanceof SelectType]) {

			val conceptSet = selectSet(t)
			LOGGER.debug("~> Type definition of \"" + t.name + "\" resolved to " + conceptSet.size + " sub concept(s).")

			resolvedSelectsMap.put(t, conceptSet)
		}

		LOGGER.info("Finished. Found " + resolvedSelectsMap.size + " select(s) in schema.")
		LOGGER.info("Processing inverse relations ...")

		for (Entity entity : schema.entities.filter[attributes.exists[opposite != null]]) {

			// Filter for both sided collection types, omit any restriction (cardinalities etc.)
			//
			for (Attribute attribute : entity.attributes.filter[opposite != null]) {

				val oppositeEntity = attribute.opposite.eContainer as ExpressConcept

				LOGGER.debug(
					"~> " + (attribute.eContainer as Entity).name + "." + attribute.name + " <--> " + oppositeEntity.name + "." +
						attribute.opposite.name)

				// Inverse super-type references
				//
				val refConcept = util.refersConcept(attribute.opposite.type)
				if (refConcept instanceof Entity && !refConcept.equals(entity)) {

					// TODO (Bernold Kraft) Inheritance checking
					//
					var aList = inverseSupertypeMap.get(entity)
					if (null == aList) {
						aList = newArrayList
						inverseSupertypeMap.put(refConcept as Entity, aList)
					}
					aList += attribute
				}

				// Add opposite versus declaring attribute
				//
				var inverseAttributeSet = inverseReferenceMap.get(attribute.opposite)
				if (null == inverseAttributeSet) {
					inverseAttributeSet = newHashSet
					inverseReferenceMap.put(attribute.opposite, inverseAttributeSet)
				}

				inverseAttributeSet += attribute
			}
		}

		LOGGER.info(
			"Finished. Found " + inverseReferenceMap.size + " relation(s) with " + inverseReferenceMap.values.filter [
				size > 1
			].size + " non-unique left hand side (select on right hand).")
	}

	/**
	 * True if a refers to an inverse relation.
	 */
	def isInverseRelation(Attribute a) {

		inverseReferenceMap.containsKey(a) || null != a.opposite
	}

	/**
	 * Returns the local QN of opposite attribute, if there's any.
	 */
	def String getOppositeRef(Attribute a) {

		if (a.inverseRelation) {
			if (a.inverseManyToManyRelation || a.leftNonUniqueRelation) {

				return nestedProxiesQN.get(a).value

			} else {

				return a.anyInverseAttribute.name
			}
		}
	}

	/** 
	 * Get inverse attribute
	 */
	def Attribute getAnyInverseAttribute(Attribute a) {

		return if (null != a.opposite)
			a.opposite
		else
			inverseReferenceMap.get(a)?.findFirst[it != null]
	}

	def boolean isLeftNonUniqueRelation(Attribute a) {
		val knownDeclaring = if (null != a.opposite)
				inverseReferenceMap.get(a.opposite)
			else
				inverseReferenceMap.get(a)

		return if(null == knownDeclaring) false else knownDeclaring.size > 1
	}

	/**
	 * True, if a is part of an inverse relation with many-to-many relation.
	 */
	def isInverseManyToManyRelation(Attribute a) {

		a.inverseRelation && util.isOneToManyRelation(a) && util.isOneToManyRelation(a.anyInverseAttribute)
	}

	def Set<Attribute> getInverseAttributeSet(Attribute a) {

		if (null != a.opposite) {

			return newHashSet(a.opposite)
		} else {

			val inverseSet = inverseReferenceMap.get(a)
			if (!inverseSet.empty) {

				return inverseSet
			} else {

				return newHashSet
			}
		}
	}

	/**
	 * Returns the opposite attribute(s) of given attribute or null, if there's no inverse
	 * relation.
	 */
	def Set<Attribute> refersOppositeAttribute(Attribute a) {

		if (null != a.opposite) {

			newHashSet(a.opposite)
		} else {

			if (inverseReferenceMap.containsKey(a)) {

				inverseReferenceMap.get(a)
			}
		}
	}

	/** ~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE METHODS ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	//
	/**
	 * Determines the set of express concepts represented by given Select statement.
	 */
	def private static Set<ExpressConcept> selectSet(ExpressConcept t) {

		val uniqueTypeSet = <ExpressConcept>newHashSet

		if (t instanceof Type) {
			if (t.datatype instanceof SelectType) {
				
				var selectType = t.datatype as SelectType;

				// Self evaluation
				var set = selectType.select.filter [
					!(it instanceof Type && (it as Type).datatype instanceof SelectType)
				].toSet;

				// Recursion (filter all SELECTs)
				selectType.select.filter [
					it instanceof Type && (it as Type).datatype instanceof SelectType
				].forEach[uniqueTypeSet += selectSet(it)]

				uniqueTypeSet += set
			}
		}

		uniqueTypeSet
	}
}