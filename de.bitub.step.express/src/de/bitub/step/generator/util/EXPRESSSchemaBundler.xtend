package de.bitub.step.generator.util

import com.google.common.collect.Lists
import de.bitub.step.express.Entity
import de.bitub.step.express.Schema
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Queue
import java.util.Set
import java.util.function.Function
import java.util.stream.Collectors
import java.util.stream.Stream

class EXPRESSSchemaBundler {

	private final Schema schema;

	new(Schema schema) {
		this.schema = schema;
	}

	def listEntityNames() {
		this.schema.entity.forEach[entity|System.out.println(entity)];
	}

	def collectAllEntities(Entity entity) {
	}

	def allConnected(Entity entity) {

		// get sub and super entities
		entity.family.forEach[e|System.out.println(e)]

	// get referenced entities
	// get inverse referenced entities
	}

	/**
	 * Returns a list with all sub and super types of the given entity.
	 * The entity itself is not contained.
	 */
	def directRelatives(Entity entity) {

		Stream.concat(Stream.concat(entity.subtype.stream, entity.supertype.stream), entity.disjointSubtype.stream).
			collect(Collectors.toList());
	}

	def inverseEntities(Entity entity) {
		Lists.newArrayList(XcoreUtil.inverse(entity).map[it.opposite.eContainer as Entity]) as List<Entity>
	}

	def inverseEntitiesInInheritanceChain(Entity entity) {
		entity.allSuperTypes.stream().flatMap[e|e.inverseEntities.stream].collect(Collectors.toSet).stream.
			collect(Collectors.toList);
	}

	def allSuperTypes(Entity entity) {
		entity.bfs([e|e.supertype]);
	}

	def family(Entity entity) {
		entity.bfs([e|e.directRelatives]);
	}

	def inverseComponent(Entity enitiy) {
		enitiy.bfs([e|e.inverseEntitiesInInheritanceChain])
	}

	private def bfs(Entity entity, Function<Entity, List<Entity>> function) {

		val visited = new HashSet<Entity>;
		val queue = new LinkedList<Entity> as Queue<Entity>;
		queue.add(entity);

		while (!queue.empty) {
			val current = queue.poll();
			visited.add(current);

			// add all non visited entites
			queue.addAll(function.apply(current).filter[e|!visited.contains(e)]);
		}

		visited as Set<Entity>;
	}
}
