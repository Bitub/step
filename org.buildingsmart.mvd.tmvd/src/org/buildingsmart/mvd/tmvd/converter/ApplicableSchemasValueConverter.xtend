package org.buildingsmart.mvd.tmvd.converter

import java.util.Arrays
import java.util.List
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.nodemodel.INode

class ApplicableSchemasValueConverter implements IValueConverter<List<String>> {

	override toString(List<String> list) throws ValueConverterException {
		list.join(";")
	}

	override toValue(String string, INode node) throws ValueConverterException {
		if (string.isEmpty)
			throw new ValueConverterException("Couldn't convert empty list to an applicable schema value.", node, null);
		try {
			return Arrays.asList(string.split(";")).map[it.trim]
		} catch (IllegalArgumentException e) {
			throw new ValueConverterException("Couldn't convert " + string + " to an schema values.", node, e);
		}
	}

}
