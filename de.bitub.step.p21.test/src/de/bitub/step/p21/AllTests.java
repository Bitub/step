package de.bitub.step.p21;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ P21EntityListenerTest.class, IndexUtilTest.class, P21ParserPrimitivesTest.class,
    P21ParserResolveReferencesTest.class })
public class AllTests
{

}
