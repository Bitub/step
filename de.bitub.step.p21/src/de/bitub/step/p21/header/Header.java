/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 14.07.2015.
 */
package de.bitub.step.p21.header;

import java.util.Date;

import javax.xml.bind.DatatypeConverter;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.07.2015
 */
public class Header
{
  class FileDescription
  {
    String description;
    String implementationLevel;
  }

  class FileName
  {
    String name;
    Date timeStamp; // not empty date format ISO 8601
    String author;
    String organization;
    String preprocessorVersion;
    String originatingSystem;
    String authorization;

    public Date getTimeStamp()
    {
      return this.timeStamp;
    }

    public void setTimeStamp(String timeStamp) throws IllegalArgumentException
    {
      this.timeStamp = DatatypeConverter.parseDateTime(timeStamp).getTime();
    }
  }

  class FileSchema
  {
    String schemaName; // not empty
  }

  class FilePopulation
  {
    String governing_schema;
    String determination_method;
    String governed_sections;
  }

  class SectionLanguage
  {
    String language;
  }

  class SectionContext
  {
    String context;
  }
}
