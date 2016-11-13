package org.buildingsmart.mvd.tmvd.converter

import java.util.Arrays
import java.util.List
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.util.Strings

class ApplicableEntitiesValueConverter implements IValueConverter<List<String>> {

	override toString(List<String> list) throws ValueConverterException {
		if (list.size > 1) {
			list.join(",")
		} else {
			if (list.empty) {
				""
			} else {
				list.get(0)
			}
		}
	}

	override toValue(String string, INode node) throws ValueConverterException {

		if (Strings::isEmpty(string))
			throw new ValueConverterException("Couldn't convert empty list to an applicable entity value.", node, null)
		try {
			return Arrays.asList(string.split(",")).map[it.trim]
		} catch (IllegalArgumentException e) {
			throw new ValueConverterException("Couldn't convert " + string + " to an UUID value.", node, e)
		}
	}

}
