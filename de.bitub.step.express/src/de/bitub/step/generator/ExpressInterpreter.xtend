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
	val static Logger LOGGER = Logger.getLogger(ExpressInterpreter);

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

		for (Entity e : schema.entities.filter[attribute.exists[opposite != null]]) {

			// Filter for both sided collection types, omit any restriction (cardinalities etc.)
			//
			for (Attribute a : e.attribute.filter[opposite != null]) {

				val oppositeEntity = a.opposite.eContainer as ExpressConcept

				LOGGER.debug(
					"~> " + (a.eContainer as Entity).name + "." + a.name + " <--> " + oppositeEntity.name + "." +
						a.opposite.name)

				// Inverse super-type references
				//
				val refConcept = util.refersConcept(a.opposite.type)
				if (refConcept instanceof Entity && !refConcept.equals(e)) {

					// TODO (Bernold Kraft) Inheritance checking
					//
					var aList = inverseSupertypeMap.get(e)
					if (null == aList) {
						aList = newArrayList
						inverseSupertypeMap.put(refConcept as Entity, aList)
					}
					aList += a
				}

				// Add opposite versus declaring attribute
				//
				var inverseAttributeSet = inverseReferenceMap.get(a.opposite)
				if (null == inverseAttributeSet) {
					inverseAttributeSet = newHashSet
					inverseReferenceMap.put(a.opposite, inverseAttributeSet)
				}

				inverseAttributeSet += a
			}
		}

		LOGGER.info(
			"Finished. Found " + inverseReferenceMap.size + " relation(s) with " + inverseReferenceMap.values.filter [
				size > 1
			].size + " non-unique left hand side (select on right hand).")
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

				// Self evaluation
				var set = (t.datatype as SelectType).select.filter [
					!(it instanceof Type && (it as Type).datatype instanceof SelectType)
				].toSet;

				// Recursion
				(t.datatype as SelectType).select.filter [
					it instanceof Type && (it as Type).datatype instanceof SelectType
				].forEach[uniqueTypeSet += selectSet(it)]

				uniqueTypeSet += set
			}
		}

		uniqueTypeSet
	}
}