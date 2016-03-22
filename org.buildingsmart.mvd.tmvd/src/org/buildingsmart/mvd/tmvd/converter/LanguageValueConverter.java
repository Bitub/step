package org.buildingsmart.mvd.tmvd.converter;

import org.eclipse.emf.ecore.xml.type.internal.RegEx.RegularExpression;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.util.Strings;

public class LanguageValueConverter implements IValueConverter<String>
{
  private RegularExpression re = new RegularExpression("[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*");

  @Override
  public String toValue(String string, INode node) throws ValueConverterException
  {
    if (Strings.isEmpty(string)) {
      throw new ValueConverterException("Couldn't convert empty string to an language value.", node, null);
    }
    if (re.matches(string)) {
      throw new ValueConverterException("Couldn't convert string to an valid language value.", node, null);
    }
    return string;
  }

  @Override
  public String toString(String value) throws ValueConverterException
  {
    return value;
  }

}
