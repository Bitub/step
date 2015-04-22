# bitub.step
EXPRESS M2M Ecore Generator and Model Resource Implementation

## Goals

This project combines both grammars of EXPRESS (ISO 10303-11) and its persistency spec P21 (ISO 10303-21) 
into a single M2M approach. The EXPRESS parser feature evaluates EXPRESS schema and generates Xcore 
specifications.
 
The P21 parser feature can evaluate a P21 textual representation. In association with a given EXPRESS scheme 
as an Ecore model, a model instance can be read or written as P21 physical file.

## General

The main purpose of this project is to formulize a M2M approach having an EXPRESS scheme as initial
model. As an example the IFC4 specification is taken (ISO 16739, March 2013).

In Building Information Modeling the IFC is utilized as exchange product model and reference model to
build up a virtual building. The IFC has more than 600 entities. Most of them are abstract. Actually, EXPRESS 
is a "non-alive" OO language. It has a lot features, which cannot be embedded into an "alive" object oriented
language (i.e. Java) directly. Taking Java as primary goal, for instance select types (a type switch at runtime) cannot be
implemented directly, since the classes are strong typed and must have a consistent supertype hierarchy.

The M2M approach produces a Xcore specification with new "bridge" types and classes to handle specific problems. A more 
future goal will be to embedded runtime behavior (functions etc.),too.

## Road map
### Version 0.1

The first implementation does not transform derived attributes. Any rule-based partitions of the underlying EXPRESS model
will not be embedded into Xcore. So, no validation rules (WHERE) are present. The main goal is to produce an Xcore
specification to be able to read a P21 textual representation by a custom EMF resource implementation.

### Future

... to be continued ....

## Build

### P2 update site for Eclipse 

Building manually for Eclipse Luna (default). This command will produce a local (default) update site.

```
	cd de.bitub.step.build-resources
	mvn clean install
```

The repository will be mirrored to a local folder below user's profile in "./p2/repository/<targetplatform>" whereas the
target platform is defined by the profile. By default it is set to "luna". Future release will have multiple platforms.

If you like to publish the artifacts to another folder (CI builds etc.) set up the build variable manually:

```
	mvn -DupdatesiteLocal=<local writeable folder> clean install
```

