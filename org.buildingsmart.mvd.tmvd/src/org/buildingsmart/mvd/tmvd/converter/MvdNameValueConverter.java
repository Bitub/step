package org.buildingsmart.mvd.tmvd.converter;

import org.eclipse.emf.ecore.xml.type.util.XMLTypeUtil;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.util.Strings;

public class MvdNameValueConverter implements IValueConverter<String>
{

  @Override
  public String toValue(String string, INode node) throws ValueConverterException
  {
    if (Strings.isEmpty(string))
      throw new ValueConverterException("Couldn't convert empty string to an UUID value.", node, null);
    try {
      return XMLTypeUtil.normalize(string.substring(1, string.length() - 1), false);
    }
    catch (IllegalArgumentException e) {
      throw new ValueConverterException("Couldn't convert " + string + " to an UUID value.", node, null);
    }
  }

  @Override
  public String toString(String value) throws ValueConverterException
  {
    return value.toString();
  }

}
