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
package de.bitub.step.xcore

import de.bitub.step.analyzing.EXPRESSModelInfo
import de.bitub.step.express.CollectionType
import de.bitub.step.express.Schema
import org.eclipse.xtext.naming.QualifiedName

import static extension de.bitub.step.util.EXPRESSExtension.*
import de.bitub.step.express.DataType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Type
import de.bitub.step.express.ExpressConcept

final class XcorePackage {

	val public Schema baseSchema;

	val public String packageNsURI;
	val public String packageName;
	val public QualifiedName packageQN;
	
	var public textModel = ''''''
	
	val public importRegistry = <QualifiedName>newHashSet()
	
	val private extension EXPRESSModelInfo modelInfo
	val private nestedCollectorMap = <QualifiedName, String>newHashMap
	
	protected new(EXPRESSModelInfo info, Schema s, String name, QualifiedName packageQN, String nsURI) {
		
		this.modelInfo = info
		this.baseSchema = s
		this.packageNsURI = nsURI
		this.packageQN = packageQN
		this.packageName = name
	}	
	
	def protected String createNestedCollector(CollectionType c) {
	
		var String nestedCollectorClass
		if(c.nestedAggregation) {
			
			val QualifiedName qn = c.qualifiedReference			
			nestedCollectorClass = qn.skipLast(1).segments.join.toFirstUpper.replace('''[]''','''InList''')
			
			nestedCollectorMap.put( qn, nestedCollectorClass )
		}		
		
		nestedCollectorClass
	}
	
	def String getNestedCollector(CollectionType c) {
		
		nestedCollectorMap.get(c.qualifiedReference)
	}
	
	def dispatch boolean hasNestedCollector(DataType c) {
		
		false
	}
	
	def dispatch boolean hasNestedCollector(CollectionType c) {
		
		nestedCollectorMap.containsKey(c.qualifiedReference)			
	}
	
	def dispatch boolean hasNestedCollector(ExpressConcept c) {
		
		switch(c) {
			
			Type: {
				
				c.aggregation && c.datatype.hasNestedCollector
			}
			default: {
				
				false
			}
		}
		
	}
	
	def dispatch boolean hasNestedCollector(ReferenceType r) {
				
		r.instance.hasNestedCollector
	}
	
}