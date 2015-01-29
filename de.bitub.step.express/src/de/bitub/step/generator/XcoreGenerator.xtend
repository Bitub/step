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
import java.util.Set
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.ReferenceType

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
		new Pair(ExpressPackage.Literals.BINARY_TYPE, "Binary"),
		new Pair(ExpressPackage.Literals.REAL_TYPE, "double"),
		new Pair(ExpressPackage.Literals.STRING_TYPE, "String")
	);
	
	
	var m_builtinSelectTypeMap = <Type, String>newHashMap()
	var m_compositeSelectTypeMap = <Type, Set<ExpressConcept>>newHashMap()
	var m_multiOppositeReferencesMap = <Attribute, String>newHashMap()
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
							
		myLog.info("Generating XCore representation of "+schema.name)
		fsa.generateFile(schema.name+".xcore", schema.compileSchema)
	}
	
	def compile(Resource resource) {
		
		// TODO Get resource folder
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		schema.compileSchema
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
	
	
	def static Set<ExpressConcept> selectSet(ExpressConcept t) {
		
		val uniqueTypeSet = <ExpressConcept>newHashSet
		
		if(t instanceof Type) {
			if(t.datatype instanceof SelectType) {
				
				// Self evaluation
				var set = (t.datatype as SelectType).select
					.filter[!(it instanceof Type && (it as Type).datatype instanceof SelectType)]
					.map[].toSet;
				
				// Recursion
				(t.datatype as SelectType).select
					.filter[it instanceof Type && (it as Type).datatype instanceof SelectType]
					.forEach[uniqueTypeSet+=selectSet(it)]
				
				uniqueTypeSet += set	
			}
		}
		
		uniqueTypeSet
	}
	
	def static isMultiSelectType(Set<ExpressConcept> selects) {
		
		var isMulti = selects.exists[it instanceof Entity] 
		isMulti || selects
			.filter[it instanceof Type 
				&& ((it as Type).datatype instanceof BuiltInType || (it as Type).datatype instanceof CollectionType)
			]
			.map[(it as Type).datatype.class].toSet.size > 1		
	}
	
	
	def static builtinSelectTypeEClass(Set<ExpressConcept> selects) {
	
		var datatypeSet = selects
			.filter[it instanceof Type 
				&& ((it as Type).datatype instanceof BuiltInType || (it as Type).datatype instanceof CollectionType)
			]
			.map[(it as Type).datatype.eClass].toSet
			
		return if(datatypeSet.size == 1) datatypeSet.get(0) else null	
	}
	
	
	def precompile(Schema s) {
		
		// Filter for simplified type selects
		myLog.info("Processing selects...")
		for(Type t : s.types.filter[it.datatype instanceof SelectType]) {
			
			val conceptSet = selectSet(t)
			if(isMultiSelectType(conceptSet)) {
				
				myLog.debug("~~> Composite select: "+t.name)
				m_compositeSelectTypeMap.put(t, conceptSet)
			} else {
				
				val eClass = builtinSelectTypeEClass(conceptSet)
				if(builtinTypeMapping.containsKey(eClass)) {
					
					myLog.debug("~~> Simple select: "+t.name)
					m_builtinSelectTypeMap.put(t, builtinTypeMapping.get(eClass))
				} else {
					
					myLog.warn("~~> Found unknown builtin type mapping "+eClass.name)
				}
			}
		}
		
		myLog.info("Processing inverse non-unique n-m relations ...")
		for(Entity e : s.entities.filter[it.attribute.exists[it.opposite!=null]]) {
						
			for(Attribute a : e.attribute.filter[
				opposite!=null && type instanceof CollectionType && opposite.type instanceof CollectionType  			
			]) {

				myLog.debug("~~> "+e.name+"."+a.name+" <-> "+(a.eContainer as ExpressConcept).name+"."+a.opposite.name)				
				m_multiOppositeReferencesMap.put(a.opposite, e.name.toFirstUpper + (a.eContainer as ExpressConcept).name.toFirstUpper)
			}
		}
	}
		
	/**
	 * Pre-compilation phase.
	 */
	def compileSchema(Schema s) {

		// Precompilation
		s.precompile
		
		'''«header("<project folder>",s)»
		
		package «s.name.toFirstLower» 
				
		// Additional datatype for binary
		
		type Binary wraps java.util.BitSet
				
		// Base container of «s.name»
		
		@GenModel(documentation="Generated container class of «s.name»")
		class «s.name» {
			
			«FOR t:m_compositeSelectTypeMap.keySet
				»contains ordered «t.name»[]«
			ENDFOR»
			
			«FOR e:s.entities
				»contains ordered «e.name»[]«
			ENDFOR»
		}
				
		// Enumerations of «s.name»
					
		«FOR en : s.types.filter[t | t.datatype instanceof EnumType]»
		@GenModel(documentation="Enumeration of «en.name»")
		enum «en.name.toFirstUpper» {
			
			«(en.datatype as EnumType).compile»
		}
		«ENDFOR»
		
		// Composite select types of «s.name»
		
		«FOR entry : m_compositeSelectTypeMap.entrySet»
		@GenModel(documentation="Generated composite multi-select «entry.key.name»")
		class «entry.key.name.toFirstUpper» {
			
			«FOR c : entry.value»«
				IF c instanceof Entity
					»refers«
				ENDIF
				» «c.name.toFirstUpper» «c.name.toFirstLower»
			«ENDFOR»
		}
		«ENDFOR»
					
		// Entities of «s.name»
							
		«FOR e : s.entities»«e.compileEntity»«ENDFOR»
		'''
	}
	
	def compileAttribute(Attribute a) {

		'''«IF null!=a.opposite && m_multiOppositeReferencesMap.containsKey(a.opposite)
				»contains «
			ELSEIF a.type instanceof ReferenceType || a.type instanceof CollectionType
				»refers «
			ENDIF»«
			IF null!=a.expression
				»derived «
			ENDIF»«
			 
			a.type.compile» «a.name.toFirstLower» «
			
			IF null!=a.opposite && !m_multiOppositeReferencesMap.containsKey(a.opposite)
				»opposite «a.opposite.name.toFirstLower»«ENDIF»'''		
	}
	
	def parentAttribute(DataType t) {

		var eAttr = t.eContainer
		while(null!=eAttr && !(eAttr instanceof Attribute)) {
			eAttr = eAttr.eContainer
		}
		eAttr as Attribute
	}
	
	
	def dispatch compile(ReferenceType r) {
						
		val parent = r.parentAttribute
		'''«IF m_multiOppositeReferencesMap.containsKey(parent)
				»«m_multiOppositeReferencesMap.get(parent)»«
			ELSEIF m_multiOppositeReferencesMap.containsKey(parent.opposite)
				»«m_multiOppositeReferencesMap.get(parent.opposite)»«
			ELSE
				»«r.instance.name.toFirstUpper»«
			ENDIF»'''
	}
		
	def dispatch compile(CollectionType c) {
		
		val parent = c.parentAttribute
		'''«IF !#["ARRAY","LIST"].contains(c.name)
				»un«
			ENDIF
			»ordered «
			IF "SET"==c.name
			»unique «
			ENDIF
			»«c.type.compile»[]'''
	}
	
		
	def compileEntity(Entity e) {
		
		'''
		@GenModel(documentation="Entity of «e.name»")
		«IF e.abstract»abstract«ENDIF» class «e.name.toFirstUpper»«IF !e.supertype.empty» extends «e.supertype.map[name].join(', ')» «ENDIF» {

			«»
					
		}
		'''
	}
	
	def dispatch compile(BuiltInType builtin) {
		
		'''«builtinTypeMapping.get(builtin.eClass)»'''
	}
		
	def dispatch compile(EnumType t) {
		
		'''«t.literal.map[name].join(", ")»'''
	}
}		