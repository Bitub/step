/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.generator

import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class XcoreGenerator implements IGenerator {
	
	val static Logger myLog = Logger.getLogger(XcoreGenerator);
	
	static val builtinTypeMapping =  <EClass, String>newHashMap(
		new Pair(ExpressPackage.Literals.INTEGER_TYPE, "int"),
		new Pair(ExpressPackage.Literals.NUMBER_TYPE, "double"),
		new Pair(ExpressPackage.Literals.LOGICAL_TYPE, "BooleanObject"),
		new Pair(ExpressPackage.Literals.BOOLEAN_TYPE, "boolean"),
		new Pair(ExpressPackage.Literals.BINARY_TYPE, "boolean[]"),
		new Pair(ExpressPackage.Literals.REAL_TYPE, "double"),
		new Pair(ExpressPackage.Literals.STRING_TYPE, "String")
	);
	
	var m_simplifiedSelectTypeMapping = <Type, String>newHashMap()
	var m_containmentRefs = <Attribute>newHashSet()
	var m_bridgeClasses = <Attribute>newHashSet()
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
							
		myLog.info("Generating XCore representation of "+schema.name)
		fsa.generateFile(schema.name+".xcore", schema.compile)
	}
	
	def compile(Resource resource) {
		
		// TODO Get resource folder
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		schema.compile
	}
		
	def header(String projectFolder, Schema s) {
		
		'''@Ecore(nsPrefix="«s.name»",nsURI="http://example.org/«s.name»")
		@Import(ecore="http://www.eclipse.org/emf/2002/Ecore")
		@GenModel(
			modelDirectory="«projectFolder»/src-gen", 
			rootExtendsInterface="org.eclipse.emf.cdo.CDOObject", 
			rootExtendsClass="org.eclipse.emf.internal.cdo.CDOObjectImpl", 
			importerID="org.eclipse.emf.importer.ecore", 
			featureDelegation="Dynamic", 
			providerRootExtendsClass="org.eclipse.emf.cdo.edit.CDOItemProviderAdapter")
			
		annotation "http://www.eclipse.org/OCL/Import" as Import @GenModel(documentation="Generated schema from «s.name».")
			'''
	}	
	
	def static boolean isEntityCompositeSelect(ExpressConcept t) {
	
		if(t instanceof Type) {
			
			if(t.datatype instanceof SelectType) {
				
				// True if any select or sub select is an entity
				return (t.datatype as SelectType).select.exists
					[x | x instanceof Entity || isEntityCompositeSelect(x) ];
			}			
		}
		
		false		
	}
	
	def static boolean isMultiBuiltinTypeSelect(ExpressConcept t) {
		
		if(t instanceof Type) {
			
			if(t.datatype instanceof SelectType) {
				
				// True if any select aggregation or sub select aggregation has different datatypes
				return (t.datatype as SelectType).select
					.filter[t1 | t1 instanceof Type]
					.filter[t2 | (t2 as Type).datatype instanceof BuiltInType || isMultiBuiltinTypeSelect(t2)]
					.map[(it as Type).datatype].toSet.size <= 1
			}
		}
		
		false
	}
	
	def precompile(Schema s) {
		
		// Filter for simplified type selects
		
		// Find containment
	}
	
	def compile(Schema s) {

		// Precompilation
		s.precompile
		
		'''«header("<project folder>",s)»
		
		package «s.name.toFirstLower» 
				
		// Enumerations of «s.name»
					
		«FOR en : s.types.filter[t | t.datatype instanceof EnumType]»
		«compile(en.name, (en.datatype as EnumType))»
		«ENDFOR»
		
		// Composite select types of «s.name»
		
		«FOR t : s.types.filter[t | isEntityCompositeSelect(t)]»
		class «t.name» {
			
			«FOR e : (t.datatype as SelectType).select»«e.name» : 
				«IF e instanceof Type && builtinTypeMapping.containsKey((e as Type).datatype)»«builtinTypeMapping.get((e as Type).datatype)»«ENDIF»
			«ENDFOR»
							
		}
		«ENDFOR»
					
		// Entities of «s.name»
							
		«FOR e : s.entities»
		«e.compile»
		«ENDFOR»
		'''
	}
		
	def compile(Entity e) {
		
		'''
		@GenModel(documentation="Entity of «e.name»")
		«IF e.abstract»abstract«ENDIF» class «e.name.toFirstUpper»«IF !e.supertype.empty» extends «e.supertype.map[name].join(', ')» «ENDIF» {

					
		}
		'''
	}
	
	def compile(String name, SelectType selectType) {

		

		'''
		class «name» {
			
			
		}
		'''		
	}
	
	def compile(String name, EnumType t) {
		
		'''
		@GenModel(documentation="Enumeration of «name»")
		enum «name.toFirstUpper»  {
			
			«t.literal.map[name].join(", ")»			
		}'''
	}
	
	def compile(Attribute a) {
	
		// Distinguish between SELECT and builtin types
		'''
		'''
	}
}		