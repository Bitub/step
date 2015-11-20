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

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
  public FileDescription fileDescription = null;
  public FileName fileName = null;
  public FileSchema fileSchema = null;

  public Header()
  {
    fileDescription = this.new FileDescription();
    fileName = this.new FileName();
    fileSchema = this.new FileSchema();
  }

  public class FileDescription
  {
    // LIST [1:?] OF STRING (256);
    //
    public List<String> description = new ArrayList<>();

    // STRING (256)
    //
    public String implementationLevel;

    /**
     * Get conformance class from implementation level.
     * Possible values are 1 and 2.
     * 
     * @return
     */
    public Integer conformanceClass()
    {
      return Integer.valueOf(implementationLevel.split(";")[1]);
    }

    /**
     * Get version number from implementation level.
     * Possible values are 1, 2 and 3.
     * 
     * @return
     */
    public Integer versionNumber()
    {
      return Integer.valueOf(implementationLevel.split(";")[0]);
    }

    @Override
    public String toString()
    {
      return "FileDescription [description=" + description + ", implementationLevel=" + implementationLevel + "]";
    }
  }

  public class FileName
  {
    // STRING (256)
    //
    public String name = "";

    // STRING (256)
    //
    Date timeStamp = null; // not empty date format ISO 8601

    // LIST [1:?] OF STRING (256);
    //
    public List<String> author = new ArrayList<>();

    // LIST [1:?] OF STRING (256);
    //    
    public List<String> organization = new ArrayList<>();

    // STRING (256)
    //
    public String preprocessorVersion = "";

    // STRING (256)
    //
    public String originatingSystem = "";

    // STRING (256)
    //
    public String authorization = "";

    public Date getTimeStamp()
    {
      return this.timeStamp;
    }

    public void setTimeStamp(String timeStamp) throws IllegalArgumentException
    {
      this.timeStamp = DatatypeConverter.parseDateTime(timeStamp).getTime();
    }

    @Override
    public String toString()
    {
      return "FileName [name=" + name + ", timeStamp=" + timeStamp + ", author=" + author + ", organization=" + organization
          + ", preprocessorVersion=" + preprocessorVersion + ", originatingSystem=" + originatingSystem + ", authorization="
          + authorization + "]";
    }
  }

  public class FileSchema
  {
    // LIST [1:?] OF UNIQUE STRING(1024);
    // 
    public List<String> schemaIdentifiers = new ArrayList<>(); // e.g. IFC2X3, IFCX4

    @Override
    public String toString()
    {
      return "FileSchema [schemaIdentifiers=" + schemaIdentifiers + "]";
    }
  }

  // !!!!!!!!!!!! NOT USED IN ANY IFC VERSION !!!!!!!!!!!!!!!!!

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

  @Override
  public String toString()
  {
    return "Header [\nfileDescription=" + fileDescription + ",\n fileName=" + fileName + ",\n fileSchema=" + fileSchema + "\n]";
  }

}
