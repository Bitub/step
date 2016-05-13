package de.bitub.step.generator.util

import bitub.base.graph.EdgeTypeEnum
import bitub.base.graph.Graph
import bitub.base.graph.GraphFactory
import bitub.base.graph.NodeTypeEnum
import bitub.base.graph.Vertex
import com.google.common.collect.Lists
import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.util.EXPRESSExtension
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Queue
import java.util.Set
import java.util.function.Function
import java.util.stream.Collectors
import java.util.stream.Stream
import org.apache.log4j.ConsoleAppender
import org.apache.log4j.Logger

class EXPRESSSchemaBundler {

	val static final LOGGER = Logger.getLogger(EXPRESSSchemaBundler)

	private final Graph graph = GraphFactory.eINSTANCE.createGraph

	private extension EXPRESSExtension schemaUtil = new EXPRESSExtension

	new(Schema schema) {
		LOGGER.addAppender(new ConsoleAppender)
//		schema.initGraph
	}

	private def createEdgeWithName(Vertex from, Vertex to, EdgeTypeEnum edgeType, String name) {
		from.createEdgeTo(to, edgeType).setProperty("name", name)
	}

//	private def createTypedEdge(Vertex from, EdgeTypeEnum edgeTypeEnum) {
//
//		[ Attribute attr |
//			val dataType = attr.type.refersDatatype
//			val entityType = attr.type.refersConcept
//			if (attr.type.isReferable) { // Selects and Entities
//
//				if (dataType instanceof SelectType || dataType instanceof EnumType) {
//					val to = graph.getById((dataType.eContainer as Type).name)
//					from.createEdgeWithName(to, edgeTypeEnum, attr.name)
//				}
//
//				if (entityType instanceof Entity) {
//					val to = graph.getById(entityType.name)
//					from.createEdgeWithName(to, edgeTypeEnum, attr.name)
//				}
//			} else {
//				if (dataType instanceof EnumType) {
//					val to = graph.getById((dataType.eContainer as Type).name)
//					from.createEdgeWithName(to, edgeTypeEnum, attr.name)
//				}
//			}
//		]
//	}

//	private def initGraph(Schema schema) {
//
//		// prepare (Entity/Select/Enum)
//		//
//		schema.entity.forEach [
//			graph.addVertex(it.name, NodeTypeEnum.ENTITY)
//		]
//
//		schema.type.forEach [
//			val dataType = schemaUtil.refersDatatype(it)
//			if (dataType instanceof SelectType) {
//				graph.addVertex(it.name, NodeTypeEnum.SELECT)
//			}
//			if (dataType instanceof EnumType) {
//				graph.addVertex(it.name, NodeTypeEnum.ENUMERATION)
//			}
//		]
//
//		// prepare edges 
//		//
//		schema.entity.forEach [
//			val from = graph.getById(it.name)
//			//
//			// (Entity) -[EXTENDS]-> (Entity)
//			//
//			it.supertype.forEach [
//				val to = graph.getById(it.name)
//				from.createEdgeTo(to, EdgeTypeEnum.EXTENDS)
//			]
//			//
//			// (Entity) -[INVERSE]-> (Entity)
//			//
//			it.getDeclaringInverseAttribute.forEach [
//				val to = graph.getById(it.opposite.hostEntity.name)
//				from.createEdgeWithName(to, EdgeTypeEnum.INVERSE, it.name)
//			]
//			//
//			// (Entity) -[ATTR]-> (Entity/Select/Enumeration)
//			//
//			it.getExplicitAttribute.forEach [
//				from.createTypedEdge(EdgeTypeEnum.ATTRIBUTE).apply(it)
//			]
//			//
//			// (Entity) -[DERIVED]-> (Entity/Select/Enumeration)
//			//
//			it.getDerivedAttribute.forEach [
//				from.createTypedEdge(EdgeTypeEnum.DERIVED).apply(it)
//			]
//		]
//
//		// prepare edges(Select -ATTR-> Entity/Select/Enumeration)
//		//
//		schema.type.map[it.datatype].filter(typeof(SelectType)).forEach [
//			val from = graph.getById((it.eContainer as Type).name)
//			// each select
//			// 
//			(it as SelectType).select.forEach [
//				// Select -> Entity
//				if (it instanceof Entity) {
//					val to = graph.getById(it.name)
//					from.createEdgeWithName(to, EdgeTypeEnum.ATTRIBUTE, it.name)
//				}
//				// Select -> Enum / Select
//				if (it instanceof Type) {
//
//					val selectOrEnum = (it as Type).refersDatatype
//					if (selectOrEnum instanceof SelectType || selectOrEnum instanceof EnumType) {
//						val to = graph.getById((selectOrEnum.eContainer as Type).name)
//						from.createEdgeWithName(to, EdgeTypeEnum.ATTRIBUTE, it.name)
//					}
//				}
//			]
//		]
//	}

	def getGraph() {
		graph
	}

	def getAllSources() {
		graph.sources
	}

	def getAllSinks() {
		graph.sinks
	}

	def inverseDefiningVertices() {
		graph.vertices.filter[it.outgoing.exists[it.edgeType.equals(EdgeTypeEnum.INVERSE.literal)]]
	}

	def inverseComponent(String id) {
		graph.getById(id).bfs [
			val in = it.incoming.filter[it.edgeType.equals(EdgeTypeEnum.INVERSE.literal)].map[it.tail]
			val out = it.outgoing.filter[it.edgeType.equals(EdgeTypeEnum.INVERSE.literal)].map[it.head]
			return (in + out).toList
		];
	}

	private def bfs(Vertex entity, Function<Vertex, List<Vertex>> function) {

		val visited = new HashSet<Vertex>
		val queue = new LinkedList<Vertex> as Queue<Vertex>
		queue.add(entity);

		while (!queue.empty) {
			val current = queue.poll()
			visited.add(current)

			// add all non visited entites
			queue.addAll(function.apply(current).filter[e|!visited.contains(e)])
		}

		visited as Set<Vertex>
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

//	def inverseEntities(Entity entity) {
//		Lists.newArrayList(entity.getDeclaringInverseAttribute.map[it.opposite.eContainer as Entity]) as List<Entity>
//	}

//	def inverseEntitiesInInheritanceChain(Entity entity) {
//		entity.allSuperTypes.stream().flatMap[e|e.inverseEntities.stream].collect(Collectors.toSet).stream.
//			collect(Collectors.toList);
//	}

	def allSuperTypes(Entity entity) {
		entity.bfs([e|e.supertype]);
	}

	def family(Entity entity) {
		entity.bfs([e|e.directRelatives]);
	}

//	def inverseComponent(Entity enitiy) {
//		enitiy.bfs([e|e.inverseEntitiesInInheritanceChain])
//	}

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
