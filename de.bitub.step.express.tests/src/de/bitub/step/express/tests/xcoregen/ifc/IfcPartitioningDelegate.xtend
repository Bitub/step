package de.bitub.step.express.tests.xcoregen.ifc

import de.bitub.step.express.EnumType
import de.bitub.step.xcore.XcoreAnalyticalPartitioningDelegate
import de.bitub.step.xcore.XcorePackageDescriptor
import de.bitub.step.express.SelectType
import de.bitub.step.express.Entity
import de.bitub.step.express.Type
import static extension de.bitub.step.util.EXPRESSExtension.*


class IfcPartitioningDelegate extends XcoreAnalyticalPartitioningDelegate {
	
	val ProceduralDescriptor ifcRootDescriptor
		
	new(XcorePackageDescriptor ifcPackageRoot) {
		
		this(new ProceduralDescriptor(ifcPackageRoot))
	}
	
	new(ProceduralDescriptor ifcRootDescriptor) {
		
		super(ifcRootDescriptor)
		this.ifcRootDescriptor = ifcRootDescriptor 
		
		init(ifcRootDescriptor)
	}

	def private init(ProceduralDescriptor ifcRootPackage) {
		
		append(ProceduralDescriptor.isDataKindOf(ifcRootPackage, typeof(EnumType), "enums"))
		append(ProceduralDescriptor.isDataKindOf(ifcRootPackage, typeof(SelectType), "selects"))
		append(ProceduralDescriptor.isTrue(ifcRootPackage, [c | if(c instanceof Entity) (c as Entity).abstract else false], "model"))
		append(ProceduralDescriptor.isTrue(ifcRootPackage, [c | if(c instanceof Entity) !(c as Entity).abstract else false], "impl"))
		append(ProceduralDescriptor.isTrue(ifcRootPackage, [c | if(c instanceof Type) (c as Type).typeAggregation else false], "aggregation"))
		append(ProceduralDescriptor.isNamedLike(ifcRootDescriptor,"Relation", "relations")) 
	}
	
}