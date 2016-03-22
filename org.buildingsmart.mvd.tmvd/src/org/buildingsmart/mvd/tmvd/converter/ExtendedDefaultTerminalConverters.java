package org.buildingsmart.mvd.tmvd.converter;

import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.impl.STRINGValueConverter;

import com.google.inject.Inject;
import com.google.inject.Singleton;

@Singleton
public class ExtendedDefaultTerminalConverters extends DefaultTerminalConverters
{

//  @Inject
//  private UUIDValueConverter uuidValueConverter;

  @ValueConverter(rule = "UUID")
  public IValueConverter<String> Uuid()
  {
    return normalizedStringValueConverter;
  }

  @Inject
  private NormalizedStringValueConverter normalizedStringValueConverter;

  @ValueConverter(rule = "NORMALIZED_STRING")
  public IValueConverter<String> NormalizedString()
  {
    return normalizedStringValueConverter;
  }

//  @Inject
//  private MvdNameValueConverter mvdNameValueConverter;
//
//  @ValueConverter(rule = "MVD_NAME")
//  public IValueConverter<String> MvdName()
//  {
//    return mvdNameValueConverter;
//  }

  @Inject
  private STRINGValueConverter stringValueConverter;

  @ValueConverter(rule = "SchemaName")
  public IValueConverter<String> SchemaName()
  {
    return stringValueConverter;
  }

  @ValueConverter(rule = "STRING0")
  public IValueConverter<String> String0()
  {
    return stringValueConverter;
  }
}
