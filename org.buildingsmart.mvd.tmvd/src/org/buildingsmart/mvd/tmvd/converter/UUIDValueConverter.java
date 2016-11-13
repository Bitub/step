package org.buildingsmart.mvd.tmvd.converter;

import java.util.UUID;

import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.util.Strings;

public class UUIDValueConverter implements IValueConverter<UUID>
{

  @Override
  public UUID toValue(String string, INode node) throws ValueConverterException
  {
    if (Strings.isEmpty(string))
      throw new ValueConverterException("Couldn't convert empty string to an UUID value.", node, null);
    try {
      return UUID.fromString(string);
    }
    catch (IllegalArgumentException e) {
      throw new ValueConverterException("Couldn't convert " + string + " to an UUID value.", node, e);
    }
  }

  @Override
  public String toString(UUID value) throws ValueConverterException
  {
    return value.toString();
  }

}
