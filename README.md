xproc-grddl
===========

A simple GRDDL implementation in XProc.

Usage
-----

The pipeline has the following signature:

    <p:declare-step type="xg:grddl" version="1.0"
                    xmlns:p="http://www.w3.org/ns/xproc"
                    xmlns:xg="http://github.com/vojtechtoman/xproc-grddl">
      <p:input port="source"/>
      <p:output port="result" sequence="true"/>
      <p:option name="xml-glean" select="'true'"/>
      <p:option name="xmlns-glean" select="'true'"/>
      <p:option name="xhtml-glean" select="'true'"/>
      <p:option name="xhtml-profile-glean" select="'true'"/>
      ...
    </p:declare-step>

It takes an XML document on the `source` input port and produces a sequence of RDF/XML documents on the `result` output port. The optional options `xml-glean`, `xmlns-glean`, `xhtml-glean`, and `xhtml-profile-glean` specify which of the GRDDL glean methods to apply. By default, all methods are enabled.

The pipeline can be invoked directly or as part of a larger XProc pipeline:

    <p:declare-step version="1.0"
                    xmlns:p="http://www.w3.org/ns/xproc"
                    xmlns:xg="http://github.com/vojtechtoman/xproc-grddl">
      <p:input port="source"/>
      <p:output port="result" sequence="true"/>
      <p:import href="grddl.xpl"/>

      <xg:grddl xhtml-profile-glean="false"/>
    </p:declare-step>

The pipeline uses only standard XProc facilities, no extensions are necessary for XProc processors that implement the complete XProc standard.

