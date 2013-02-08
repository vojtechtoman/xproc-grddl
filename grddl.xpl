<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:dataview="http://www.w3.org/2003/g/data-view#"
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xg="http://www.example.org/ns/xproc/grddl"
                xmlns:xgv="http://www.example.org/ns/xproc/grddl-vocab"
                type="xg:grddl" version="1.0">

  <p:input port="source"/>
  <p:output port="result" sequence="true"/>
  <p:option name="xml-glean" select="'true'"/>
  <p:option name="xmlns-glean" select="'true'"/>
  <p:option name="xhtml-glean" select="'true'"/>
  <p:option name="xhtml-profile-glean" select="'true'"/>

  <p:declare-step type="xg:grddl-impl" name="grddl">
    <p:input port="source" primary="true"/>
    <p:input port="visited">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result" sequence="true" primary="true">
      <p:pipe step="glean" port="result"/>
    </p:output>
    <p:output port="result-visited">
      <p:pipe step="glean" port="result-visited"/>
    </p:output>
    <p:option name="xml-glean" select="'true'"/>  <!-- Perform XML glean? (boolean) -->
    <p:option name="xmlns-glean" select="'true'"/>  <!-- Perform XML Namespace glean? (boolean) -->
    <p:option name="xhtml-glean" select="'true'"/>  <!-- Perform XHTML glean? (boolean) -->
    <p:option name="xhtml-profile-glean" select="'true'"/>  <!-- Perform XHTML Profile? (boolean) -->

    <p:variable name="base-uri" select="p:base-uri()"/>

    <xg:log>
      <p:with-option name="message" select="concat('GRDDL processing: ', $base-uri)"/>
    </xg:log>

    <p:choose name="glean">
      <p:when test="/rdf:RDF">
        <!-- GRDDL, sect 3: Note that as a base case, the result of parsing
             an RDF/XML document is a GRDDL result of that document -->
        <p:output port="result">
          <p:pipe step="identity" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="update-visited" port="result"/>
        </p:output>
        <p:identity name="identity"/>
        <xg:add-visited mode="xmlns" name="update-visited">
          <p:input port="source">
            <p:pipe step="grddl" port="visited"/>
          </p:input>
          <p:with-option name="uri" select="$base-uri">
            <p:empty/>
          </p:with-option>
        </xg:add-visited>
      </p:when>

      <p:otherwise>
        <p:output port="result" sequence="true">
          <p:pipe step="xml-glean" port="result"/>
          <p:pipe step="xmlns-glean" port="result"/>
          <p:pipe step="xhtml-glean" port="result"/>
          <p:pipe step="xhtml-profile-glean" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xhtml-profile-glean" port="result-visited"/>
        </p:output>

        <!-- Perform XML glean -->
        <xg:xml-glean name="xml-glean">
          <p:input port="visited">
            <p:pipe step="grddl" port="visited"/>
          </p:input>
          <p:with-option name="enabled" select="$xml-glean">
            <p:empty/>
          </p:with-option>
        </xg:xml-glean>
        
        <!-- Perform XML Namespace glean -->
        <xg:xmlns-glean name="xmlns-glean">
          <p:input port="source">
            <p:pipe step="grddl" port="source"/>
          </p:input>
          <p:input port="visited">
            <p:pipe step="xml-glean" port="result-visited"/>
          </p:input>
          <p:with-option name="enabled" select="$xmlns-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xml-glean" select="$xml-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xmlns-glean" select="$xmlns-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xhtml-glean" select="$xhtml-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean">
            <p:empty/>
          </p:with-option>
        </xg:xmlns-glean>
        
        <!-- Perform XHTML glean -->
        <xg:xhtml-glean name="xhtml-glean">
          <p:input port="source">
            <p:pipe step="grddl" port="source"/>
          </p:input>
          <p:input port="visited">
            <p:pipe step="xmlns-glean" port="result-visited"/>
          </p:input>
          <p:with-option name="enabled" select="$xhtml-glean">
            <p:empty/>
          </p:with-option>
        </xg:xhtml-glean>

        <!-- Perform XHTML Profile glean -->
        <xg:xhtml-profile-glean name="xhtml-profile-glean">
          <p:input port="source">
            <p:pipe step="grddl" port="source"/>
          </p:input>
          <p:input port="visited">
            <p:pipe step="xhtml-glean" port="result-visited"/>
          </p:input>
          <p:with-option name="enabled" select="$xhtml-profile-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xml-glean" select="$xml-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xmlns-glean" select="$xmlns-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xhtml-glean" select="$xhtml-glean">
            <p:empty/>
          </p:with-option>
          <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean">
            <p:empty/>
          </p:with-option>
        </xg:xhtml-profile-glean>

      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <p:declare-step type="xg:xml-glean" name="xml-glean">
    <!-- See GRDDL: 2. Adding GRDDL to well-formed XML -->
    <p:input port="source" primary="true"/>
    <p:input port="visited">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result" sequence="true" primary="true">
      <p:pipe step="glean" port="result"/>
    </p:output>
    <p:output port="result-visited">
      <p:pipe step="glean" port="result-visited"/>
    </p:output>
    <p:option name="enabled" select="'true'"/>

    <p:variable name="base-uri" select="p:base-uri()"/>

    <xg:log>
      <p:with-option name="message" select="concat('XML glean: ', $base-uri)"/>
    </xg:log>

    <p:choose name="glean">
      <!-- resource already processed in the 'xml' glean mode? -->
      <p:when test="$enabled != 'true' or //xgv:resource[@uri=$base-uri and @mode='xml']">
        <p:xpath-context>
          <p:pipe step="xml-glean" port="visited"/>
        </p:xpath-context>
        <p:output port="result" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xml-glean" port="visited"/>
        </p:output>
        <xg:log message="Glean mode disabled or resource already processed"/>
        <p:sink/>
      </p:when>

      <p:otherwise>
        <p:output port="result" sequence="true">
          <p:pipe step="apply-transformations" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="update-visited" port="result"/>
        </p:output>

        <p:choose name="apply-transformations">
          <p:when test="/*/@dataview:transformation">
            <!-- found a transformation -->
            <p:output port="result" sequence="true"/>
            <xg:apply-transformations-literal>
              <p:input port="source">
                <p:pipe step="xml-glean" port="source"/>
              </p:input>
              <p:with-option name="transformations" select="/*/@dataview:transformation"/>
              <p:with-option name="base-uri" select="$base-uri">
                <p:empty/>
              </p:with-option>
              <p:with-option name="output-base-uri" select="$base-uri">
                <p:empty/>
              </p:with-option>
            </xg:apply-transformations-literal>
          </p:when>
          <p:otherwise>
            <p:output port="result" sequence="true"/>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
          </p:otherwise>
        </p:choose>

        <xg:add-visited mode="xml" name="update-visited">
          <p:input port="source">
            <p:pipe step="xml-glean" port="visited"/>
          </p:input>
          <p:with-option name="uri" select="$base-uri">
            <p:empty/>
          </p:with-option>
        </xg:add-visited>
      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <p:declare-step type="xg:xmlns-glean" name="xmlns-glean">
    <!-- See GRDDL: 3. GRDDL for XML Namespaces -->
    <p:input port="source" primary="true"/>
    <p:input port="visited">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result" sequence="true" primary="true">
      <p:pipe step="glean" port="result"/>
    </p:output>
    <p:output port="result-visited">
      <p:pipe step="glean" port="result-visited"/>
    </p:output>
    <p:option name="enabled" select="'true'"/>
    <p:option name="xml-glean" select="'true'"/>
    <p:option name="xmlns-glean" select="'true'"/>
    <p:option name="xhtml-glean" select="'true'"/>
    <p:option name="xhtml-profile-glean" select="'true'"/>

    <p:variable name="ns-uri" select="namespace-uri(/*)"/>
    <p:variable name="base-uri" select="p:base-uri()"/>

    <xg:log>
      <p:with-option name="message" select="concat('XMLNS glean: ', $ns-uri, ', base-uri: ', $base-uri)"/>
    </xg:log>

    <p:choose name="glean">
      <!-- resource already processed in the 'xmlns' glean mode? -->
      <p:when test="$enabled != 'true' or //xgv:resource[@uri=$base-uri and @mode='xmlns']">
        <p:xpath-context>
          <p:pipe step="xmlns-glean" port="visited"/>
        </p:xpath-context>
        <p:output port="result" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xmlns-glean" port="visited"/>
        </p:output>
        <xg:log message="Glean mode disabled or resource already processed"/>
        <p:sink/>
      </p:when>

      <p:when test="$ns-uri != '' and $ns-uri != $base-uri">
        <!-- document in a non-null namespace (different from the doc base uri) -->
        <p:output port="result" sequence="true">
          <p:pipe step="glean-inner" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="glean-inner" port="result-visited"/>
        </p:output>

        <p:variable name="namespace-uri" select="namespace-uri(/*)"/>

        <xg:add-visited mode="xmlns" name="update-visited">
          <p:input port="source">
            <p:pipe step="xmlns-glean" port="visited"/>
          </p:input>
          <p:with-option name="uri" select="$base-uri">
            <p:empty/>
          </p:with-option>
        </xg:add-visited>

        <xg:log>
          <p:with-option name="message" select="concat('  Retrieving namespace document: ', $namespace-uri)"/>
        </xg:log>

        <p:try name="load">
          <p:group>
            <p:output port="result"/>
            <xg:request-resource name="load-ns-doc">
              <p:with-option name="href" select="$namespace-uri"/>
            </xg:request-resource>
          </p:group>
          <p:catch>
            <!-- the namespace document does not exist/not XML/cannot be retrieved -->
            <p:output port="result" sequence="true"/>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
          </p:catch>
        </p:try>

        <p:count name="count"/>

        <p:choose name="glean-inner">
          <p:when test="/c:result=0">
            <!-- there is no namespace document to process -->
            <p:output port="result" sequence="true">
              <p:empty/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="update-visited" port="result"/>
            </p:output>
            <p:sink/>
          </p:when>

          <p:when test="/rdf:RDF">
            <!-- a RDF NSDOC: process all triples that point to the transformations -->
            <p:xpath-context>
              <p:pipe step="load" port="result"/>
            </p:xpath-context>
            <p:output port="result" sequence="true">
              <p:pipe step="apply-rdf-transformations" port="result"/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="update-visited" port="result"/>
            </p:output>

            <xg:apply-rdf-transformations name="apply-rdf-transformations"
                                          predicate-local-name="namespaceTransformation">
              <p:input port="source">
                <p:pipe step="xmlns-glean" port="source"/>
              </p:input>
              <p:input port="source-rdf">
                <p:pipe step="load" port="result"/>
              </p:input>
              <p:with-option name="subject" select="$namespace-uri">
                <p:empty/>
              </p:with-option>
              <p:with-option name="output-base-uri" select="$base-uri">
                <p:empty/>
              </p:with-option>
            </xg:apply-rdf-transformations>
          </p:when>

          <p:otherwise>
            <!-- NSDOC not a RDF document -> find its GRDDL result recursively
                 and apply the contained transformation to the source document -->
            <p:output port="result" sequence="true">
              <p:pipe step="apply-rdf-transformations" port="result"/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="grddl" port="result-visited"/>
            </p:output>

            <xg:grddl-impl name="grddl">
              <p:input port="source">
                <p:pipe step="load" port="result"/>
              </p:input>
              <p:input port="visited">
                <p:pipe step="update-visited" port="result"/>
              </p:input>
              <p:with-option name="xml-glean" select="$xml-glean"/>
              <p:with-option name="xmlns-glean" select="$xmlns-glean"/>
              <p:with-option name="xhtml-glean" select="$xhtml-glean"/>
              <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean"/>
            </xg:grddl-impl>

            <xg:apply-rdf-transformations name="apply-rdf-transformations"
                                          predicate-local-name="namespaceTransformation">
              <p:input port="source">
                <p:pipe step="xmlns-glean" port="source"/>
              </p:input>
              <p:input port="source-rdf">
                <p:pipe step="grddl" port="result"/>
              </p:input>
              <p:with-option name="subject" select="$namespace-uri">
                <p:empty/>
              </p:with-option>
              <p:with-option name="output-base-uri" select="$base-uri">
                <p:empty/>
              </p:with-option>
            </xg:apply-rdf-transformations>
          </p:otherwise>
        </p:choose>
      </p:when>
      <p:otherwise>
        <!-- document element in no namespace -->
        <p:output port="result" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xmlns-glean" port="visited"/>
        </p:output>
        <p:sink/>
      </p:otherwise>
    </p:choose>
  </p:declare-step>


  <p:declare-step type="xg:xhtml-glean" name="xhtml-glean">
    <!-- See GRDDL: 4. Using GRDDL with valid XHTML -->
    <p:input port="source" primary="true"/>
    <p:input port="visited">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result" sequence="true" primary="true">
      <p:pipe step="glean" port="result"/>
    </p:output>
    <p:output port="result-visited">
      <p:pipe step="glean" port="result-visited"/>
    </p:output>
    <p:option name="enabled" select="'true'"/>

    <p:variable name="base-uri" select="p:base-uri()"/>

    <xg:log>
      <p:with-option name="message" select="concat('XHTML glean: ', $base-uri)"/>
    </xg:log>

    <p:choose name="glean">
      <!-- resource already processed in the 'xhtml' glean mode? -->
      <p:when test="$enabled != 'true' or //xgv:resource[@uri=$base-uri and @mode='xhtml']">
        <p:xpath-context>
          <p:pipe step="xhtml-glean" port="visited"/>
        </p:xpath-context>
        <p:output port="result" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xhtml-glean" port="visited"/>
        </p:output>
        <xg:log message="Glean mode disabled or resource already processed"/>
        <p:sink/>
      </p:when>

      <p:otherwise>
        <p:output port="result" sequence="true">
          <p:pipe step="apply-transformations" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="update-visited" port="result"/>
        </p:output>

        <p:choose name="apply-transformations">
          <p:when test="/html:html/html:head[contains(concat(' ', @profile, ' '), ' http://www.w3.org/2003/g/data-view ')]">
            <p:output port="result" sequence="true"/>

            <p:variable name="xhtml-base-uri" select="p:resolve-uri(/html:html/html:head/html:base/@href, $base-uri)"/>
            
            <p:for-each>
              <p:output port="result" sequence="true"/>
              <p:iteration-source select="(//html:a|//html:link)[contains(concat(' ', @rel, ' '), ' transformation ')]"/>
              <!-- TODO: do we need to support xml:base in XHTML? -->
              <xg:apply-transformations-literal>
                <p:input port="source">
                  <p:pipe step="xhtml-glean" port="source"/>
                </p:input>
                <p:with-option name="transformations" select="/*/@href"/>
                <p:with-option name="base-uri" select="$xhtml-base-uri">
                  <p:empty/>
                </p:with-option>
                <p:with-option name="output-base-uri" select="$xhtml-base-uri">
                  <p:empty/>
                </p:with-option>
              </xg:apply-transformations-literal>
            </p:for-each>
          </p:when>
          <p:otherwise>
            <!-- Nothing to glean or not an XHTML document -->
            <p:output port="result" sequence="true"/>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
          </p:otherwise>
        </p:choose>

        <xg:add-visited mode="xhtml" name="update-visited">
          <p:input port="source">
            <p:pipe step="xhtml-glean" port="visited"/>
          </p:input>
          <p:with-option name="uri" select="$base-uri">
            <p:empty/>
          </p:with-option>
        </xg:add-visited>
      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <p:declare-step type="xg:xhtml-profile-glean" name="xhtml-profile-glean">
    <!-- See GRDDL: 5. GRDDL for HTML profiles -->
    <p:input port="source" primary="true"/>
    <p:input port="visited">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result" sequence="true" primary="true">
      <p:pipe step="glean" port="result"/>
    </p:output>
    <p:output port="result-visited">
      <p:pipe step="glean" port="result-visited"/>
    </p:output>
    <p:option name="enabled" select="'true'"/>
    <p:option name="xml-glean" select="'true'"/>
    <p:option name="xmlns-glean" select="'true'"/>
    <p:option name="xhtml-glean" select="'true'"/>
    <p:option name="xhtml-profile-glean" select="'true'"/>

    <p:declare-step type="xg:apply-profiles" name="apply-profiles">
      <p:input port="source" primary="true"/>
      <p:input port="profiles" sequence="true"/>
      <p:input port="visited">
        <p:inline><xgv:visited/></p:inline>
      </p:input>
      <p:output port="result" sequence="true" primary="true">
        <p:pipe step="apply-inner" port="result"/>
      </p:output>
      <p:output port="result-visited">
        <p:pipe step="apply-inner" port="result-visited"/>
      </p:output>
      <p:option name="xml-glean" select="'true'"/>
      <p:option name="xmlns-glean" select="'true'"/>
      <p:option name="xhtml-glean" select="'true'"/>
      <p:option name="xhtml-profile-glean" select="'true'"/>

      <p:count>
        <p:input port="source">
          <p:pipe step="apply-profiles" port="profiles"/>
        </p:input>
      </p:count>

      <p:choose name="apply-inner">
        <p:when test="/c:result = 0">
          <!-- no more profiles to apply -->
          <p:output port="result" sequence="true">
            <p:empty/>
          </p:output>
          <p:output port="result-visited">
            <p:pipe step="apply-profiles" port="visited"/>
          </p:output>
          <p:sink/>
        </p:when>
        <p:otherwise>
          <p:output port="result" sequence="true">
            <p:pipe step="apply-first" port="result"/>
            <p:pipe step="apply-rest" port="result"/>
          </p:output>
          <p:output port="result-visited">
            <p:pipe step="apply-rest" port="result-visited"/>
          </p:output>
          
          <p:split-sequence test="position() = 1" name="split">
            <p:input port="source">
              <p:pipe step="apply-profiles" port="profiles"/>
            </p:input>
          </p:split-sequence>
          
          <!-- apply the first profile -->
          <p:group name="apply-first">
            <p:output port="result" sequence="true">
              <p:pipe step="apply-profile-transformations" port="result"/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="get-grddl-result" port="result-visited"/>
            </p:output>

            <p:variable name="profile-uri" select="/c:result/text()"/>

            <xg:log>
              <p:with-option name="message"
                             select="concat('  Applying profile: ', $profile-uri)"/>
            </xg:log>
          
            <!-- TODO: check that the profile doc does exist? -->
            <xg:request-resource name="load-profile">
              <p:with-option name="href" select="$profile-uri"/>
            </xg:request-resource>

            <xg:grddl-impl name="get-grddl-result">
              <p:input port="visited">
                <p:pipe step="apply-profiles" port="visited"/>
              </p:input>
              <p:with-option name="xml-glean" select="$xml-glean"/>
              <p:with-option name="xmlns-glean" select="$xmlns-glean"/>
              <p:with-option name="xhtml-glean" select="$xhtml-glean"/>
              <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean"/>
            </xg:grddl-impl>

            <p:group name="apply-profile-transformations">
              <p:output port="result" sequence="true"/>
              <p:variable name="profile-base-uri" select="p:resolve-uri(/html:html/html:head/html:base/@href, p:base-uri())">
                <p:pipe step="load-profile" port="result"/>
              </p:variable>

              <xg:apply-rdf-transformations name="apply-rdf-transformations"
                                            predicate-local-name="profileTransformation">
                <p:input port="source">
                  <p:pipe step="apply-profiles" port="source"/>
                </p:input>
                <p:input port="source-rdf">
                  <p:pipe step="get-grddl-result" port="result"/>
                </p:input>
                <p:with-option name="subject" select="$profile-base-uri">
                  <p:empty/>
                </p:with-option>
                <p:with-option name="output-base-uri" select="p:base-uri()">
                  <p:pipe step="apply-profiles" port="source"/>
                </p:with-option>
              </xg:apply-rdf-transformations>
            </p:group>
          </p:group>
          
          <!-- apply the remaining profiles recursively -->
          <xg:apply-profiles name="apply-rest">
            <p:input port="source">
              <p:pipe step="apply-profiles" port="source"/>
            </p:input>
            <p:input port="profiles">
              <p:pipe step="split" port="not-matched"/>
            </p:input>
            <p:input port="visited">
              <p:pipe step="apply-first" port="result-visited"/>
            </p:input>
            <p:with-option name="xml-glean" select="$xml-glean">
              <p:empty/>
            </p:with-option>
            <p:with-option name="xmlns-glean" select="$xmlns-glean">
              <p:empty/>
            </p:with-option>
            <p:with-option name="xhtml-glean" select="$xhtml-glean">
              <p:empty/>
            </p:with-option>
            <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean">
              <p:empty/>
            </p:with-option>
          </xg:apply-profiles>
        </p:otherwise>
      </p:choose>
    </p:declare-step>
    
    <p:variable name="base-uri" select="p:base-uri()"/>

    <xg:log>
      <p:with-option name="message" select="concat('XHTML Profile glean: ', $base-uri)"/>
    </xg:log>

    <p:choose name="glean">
      <!-- resource already processed in the 'xhtml-profile' glean mode? -->
      <p:when test="$enabled != 'true' or //xgv:resource[@uri=$base-uri and @mode='xhtml-profile']">
        <p:xpath-context>
          <p:pipe step="xhtml-profile-glean" port="visited"/>
        </p:xpath-context>
        <p:output port="result" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="xhtml-profile-glean" port="visited"/>
        </p:output>
        <xg:log message="Glean mode disabled or resource already processed"/>
        <p:sink/>
      </p:when>

      <p:otherwise>
        <p:output port="result" sequence="true">
          <p:pipe step="glean-inner" port="result"/>
        </p:output>
        <p:output port="result-visited">
          <p:pipe step="glean-inner" port="result-visited"/>
        </p:output>

        <p:choose name="glean-inner">
          <p:when test="/html:html">
            <p:output port="result" sequence="true">
              <p:pipe step="apply-profiles" port="result"/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="apply-profiles" port="result-visited"/>
            </p:output>

            <p:variable name="xhtml-base-uri" select="p:resolve-uri(/html:html/html:head/html:base/@href, $base-uri)"/>

            <xg:log>
              <p:with-option name="message" select="concat('  Found profiles: ', /html:html/html:head/@profile)"/>
            </xg:log>

            <xg:tokenize-and-resolve name="get-profiles">
              <p:with-option name="str" select="/html:html/html:head/@profile"/>
              <p:with-option name="base-uri" select="$xhtml-base-uri"/>
            </xg:tokenize-and-resolve>

            <xg:apply-profiles name="apply-profiles">
              <p:input port="source">
                <p:pipe step="xhtml-profile-glean" port="source"/>
              </p:input>
              <p:input port="profiles">
                <p:pipe step="get-profiles" port="result"/>
              </p:input>
              <p:input port="visited">
                <p:pipe step="update-visited" port="result"/>
              </p:input>
              <p:with-option name="xml-glean" select="$xml-glean">
                <p:empty/>
              </p:with-option>
              <p:with-option name="xmlns-glean" select="$xmlns-glean">
                <p:empty/>
              </p:with-option>
              <p:with-option name="xhtml-glean" select="$xhtml-glean">
                <p:empty/>
              </p:with-option>
              <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean">
                <p:empty/>
              </p:with-option>
            </xg:apply-profiles>
          </p:when>

          <p:otherwise>
            <!-- not an XHTML document -->
            <p:output port="result" sequence="true">
              <p:empty/>
            </p:output>
            <p:output port="result-visited">
              <p:pipe step="update-visited" port="result"/>
            </p:output>
            <p:sink/>
          </p:otherwise>
        </p:choose>

        <xg:add-visited mode="xhtml-profile" name="update-visited">
          <p:input port="source">
            <p:pipe step="xhtml-profile-glean" port="visited"/>
          </p:input>
          <p:with-option name="uri" select="$base-uri">
            <p:empty/>
          </p:with-option>
        </xg:add-visited>

      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <!-- Miscellaneous helper steps -->

  <p:declare-step type="xg:log">
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    <p:option name="message" required="true"/>
    <p:option name="logging-enabled" select="'true'"/>

    <p:choose>
      <p:when test="$logging-enabled='true'">
        <p:xpath-context>
          <p:empty/>
        </p:xpath-context>
        <!-- Here you can use any "logging" facilities that are available 
             in your XProc processor of choice. -->
        <emx:message xmlns:emx="http://www.emc.com/documentum/xml/xproc">
          <p:with-option name="message" select="$message">
            <p:empty/>
          </p:with-option>
        </emx:message>
      </p:when>
      <p:otherwise>
        <!-- logging disabled -->
        <p:identity/>
      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <p:declare-step type="xg:apply-transformations-literal" name="apply-transformations-literal">
    <p:input port="source"/>
    <p:output port="result" sequence="true"/>
    <p:option name="transformations" required="true"/>
    <p:option name="base-uri" required="true"/>
    <p:option name="output-base-uri" required="true"/>

    <xg:log>
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:with-option name="message"
                     select="concat('Tokenizing and resolving: ', $transformations)"/>
    </xg:log>
    <p:sink/>

    <xg:tokenize-and-resolve name="tokenize-and-resolve">
      <p:with-option name="str" select="$transformations"/>
      <p:with-option name="base-uri" select="$base-uri"/>
    </xg:tokenize-and-resolve>

    <xg:apply-transformations>
      <p:input port="source">
        <p:pipe step="apply-transformations-literal" port="source"/>
      </p:input>
      <p:input port="transformations">
        <p:pipe step="tokenize-and-resolve" port="result"/>
      </p:input>
      <p:with-option name="output-base-uri" select="$output-base-uri">
        <p:empty/>
      </p:with-option>
    </xg:apply-transformations>
  </p:declare-step>

  <p:declare-step type="xg:tokenize-and-resolve">
    <p:output port="result" sequence="true"/>
    <p:option name="str" required="true"/>
    <p:option name="base-uri" required="true"/>
    
    <p:xslt version="2.0">
      <p:input port="source">
        <p:inline>
          <foo/>
        </p:inline>
      </p:input>
      <p:input port="stylesheet">
       <p:inline>
         <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                         xmlns:xs="http://www.w3.org/2001/XMLSchema"
                         version="2.0">
           <xsl:param name="str" as="xs:string"/>
           <xsl:param name="base-uri" as="xs:string"/>
           <xsl:template match="/">
             <foo>
               <xsl:for-each select="tokenize($str, ' ')">
                 <c:result><xsl:value-of select="resolve-uri(., $base-uri)"/></c:result>
               </xsl:for-each>
             </foo>
           </xsl:template>
         </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="str" select="$str"/>
      <p:with-param name="base-uri" select="$base-uri"/>
    </p:xslt>
    <p:filter select="//c:result"/>
  </p:declare-step>

  <p:declare-step type="xg:apply-transformations" name="apply-transformations">
    <p:input port="source" primary="true"/>
    <p:input port="transformations" sequence="true"/>
    <p:output port="result" sequence="true"/>
    <p:option name="output-base-uri" required="true"/>

    <p:count>
      <p:input port="source">
        <p:pipe step="apply-transformations" port="transformations"/>
      </p:input>
    </p:count>

    <p:choose>
      <p:when test="/c:result = 0">
        <!-- no more transformations -->
        <p:identity>
          <p:input port="source">
            <p:empty/>
          </p:input>
        </p:identity>
      </p:when>
      <p:otherwise>
        <p:split-sequence test="position() = 1" name="split">
          <p:input port="source">
            <p:pipe step="apply-transformations" port="transformations"/>
          </p:input>
        </p:split-sequence>
        
        <!-- apply the first transformation -->
        <p:group name="apply-transformation">
          <p:output port="result"/>
          <p:variable name="transformation" select="/c:result"/>

          <xg:log>
            <p:with-option name="message"
                           select="concat('Applying transformation: ', $transformation)"/>
          </xg:log>

          <!-- Here the pipeline can decide what kind of transformation it will apply.
               For the moment, it supports only XSLT.
          -->

          <xg:apply-xslt-transformation>
            <p:with-option name="transformation" select="$transformation"/>
            <p:with-option name="output-base-uri" select="$output-base-uri">
              <p:empty/>
            </p:with-option>
            <p:input port="source">
              <p:pipe step="apply-transformations" port="source"/>
            </p:input>
          </xg:apply-xslt-transformation>

        </p:group>
        
        <!-- apply the remaining transformations recursively -->
        <xg:apply-transformations name="process-rest">
          <p:input port="source">
            <p:pipe step="apply-transformations" port="source"/>
          </p:input>
          <p:input port="transformations">
            <p:pipe step="split" port="not-matched"/>
          </p:input>
          <p:with-option name="output-base-uri" select="$output-base-uri">
            <p:empty/>
          </p:with-option>
        </xg:apply-transformations>

        <p:identity>
          <p:input port="source">
            <p:pipe step="apply-transformation" port="result"/>
            <p:pipe step="process-rest" port="result"/>
          </p:input>
        </p:identity>
      </p:otherwise>
    </p:choose>
  </p:declare-step>

  <p:declare-step type="xg:apply-xslt-transformation" name="xslt-transformation">
    <p:input port="source"/>
    <p:output port="result"/>
    <p:option name="transformation" required="true"/>
    <p:option name="output-base-uri" required="true"/>

    <xg:request-resource name="load-stylesheet">
      <p:with-option name="href" select="$transformation"/>
      <p:with-option name="accept" select="'application/xslt+xml,application/xml'"/>
    </xg:request-resource>

    <p:xslt version="2.0">
      <p:input port="source">
        <p:pipe step="xslt-transformation" port="source"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe step="load-stylesheet" port="result"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-option name="output-base-uri" select="$output-base-uri">
        <p:empty/>
      </p:with-option>
    </p:xslt>
  </p:declare-step>

  <p:declare-step type="xg:apply-rdf-transformations" name="apply-rdf-transformations">
    <!-- a RDF NSDOC containing triples that bind "subject" with the
         (profile/namespace) transformation(s) -->
    <p:input port="source" primary="true"/>
    <p:input port="source-rdf" sequence="true"/> <!-- RDF documents -->
    <p:output port="result" sequence="true"/>
    <p:option name="subject" required="true"/>
    <p:option name="predicate-local-name" required="true"/>
    <p:option name="output-base-uri" required="true"/>
    
    <p:for-each name="subject-transformations">
      <p:iteration-source
          select="/rdf:RDF/rdf:Description[dataview:*[local-name()=$predicate-local-name]]">
        <p:pipe step="apply-rdf-transformations" port="source-rdf"/>
      </p:iteration-source>

      <xg:rdf-resolve-uri>
        <p:with-option name="uri" select="/*/@rdf:about"/>
        <p:with-option name="base-uri" select="p:base-uri(/*/@rdf:about)"/>
      </xg:rdf-resolve-uri>

      <p:choose>
        <p:when test="/c:result = $subject">
          <p:for-each>
            <p:iteration-source
                select="/*/dataview:*[local-name()=$predicate-local-name]">
              <p:pipe step="subject-transformations" port="current"/>
            </p:iteration-source>

            <xg:apply-transformations-literal>
              <p:input port="source">
                <p:pipe step="apply-rdf-transformations" port="source"/>
              </p:input>
              <p:with-option name="transformations" select="/*/@rdf:resource"/>
              <p:with-option name="base-uri" select="p:base-uri(/*/@rdf:resource)"/>
              <p:with-option name="output-base-uri" select="$output-base-uri"/>
            </xg:apply-transformations-literal>
          </p:for-each>
        </p:when>
        <p:otherwise>
          <p:identity>
            <p:input port="source">
              <p:empty/>
            </p:input>
          </p:identity>
        </p:otherwise>
      </p:choose>
    </p:for-each>
  </p:declare-step>

  <p:declare-step type="xg:add-visited" name="add-visited">
    <p:input port="source">
      <p:inline>
        <xgv:visited/>
      </p:inline>
    </p:input>
    <p:output port="result"/>
    <p:option name="uri" required="true"/>
    <p:option name="mode" required="true"/>

    <xg:log>
      <p:with-option name="message"
                     select="concat('  Registering visited resource: ', $uri, ', mode: ', $mode)"/>
    </xg:log>

    <p:template name="create-resource-elt">
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:input port="template">
        <p:inline>
          <xgv:resource uri="{$uri}" mode="{$mode}"/>
        </p:inline>
      </p:input>
      <p:with-param name="uri" select="$uri"/>
      <p:with-param name="mode" select="$mode"/>
    </p:template>

    <p:insert match="/*" position="last-child">
      <p:input port="source">
        <p:pipe step="add-visited" port="source"/>
      </p:input>
      <p:input port="insertion">
        <p:pipe step="create-resource-elt" port="result"/>
      </p:input>
    </p:insert>
  </p:declare-step>

  <p:declare-step type="xg:rdf-resolve-uri">
    <p:option name="uri" required="true"/>
    <p:option name="base-uri" required="true"/>
    <p:output port="result"/>

    <p:xslt version="2.0">
      <p:input port="source">
        <p:inline>
          <foo/>
        </p:inline>
      </p:input>
      <p:input port="stylesheet">
       <p:inline>
         <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                         xmlns:xs="http://www.w3.org/2001/XMLSchema"
                         version="2.0">
           <xsl:param name="uri" as="xs:string"/>
           <xsl:param name="base-uri" as="xs:string"/>
           <xsl:template match="/">
             <xsl:variable name="base-urix" select="if (starts-with($uri, '#') and ends-with($base-uri, '#'))
                                                    then (substring($base-uri, 1, string-length($base-uri)-1))
                                                    else ($base-uri)"/>
             <c:result><xsl:value-of select="if ($uri = '' or starts-with($uri, '#'))
                                             then (concat($base-urix, $uri))
                                             else (resolve-uri($uri, $base-urix))"/></c:result>
           </xsl:template>
         </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="uri" select="$uri"/>
      <p:with-param name="base-uri" select="$base-uri"/>
    </p:xslt>
  </p:declare-step>

  <p:declare-step type="xg:request-resource">
    <p:option name="href" required="true"/>
    <p:option name="accept"/>
    <p:output port="result"/>

    <p:add-attribute name="create-request" match="/*" attribute-name="href">
      <p:input port="source">
        <p:inline>
          <c:request method="GET" override-content-type="application/xml"/>
        </p:inline>
      </p:input>
      <p:with-option name="attribute-value" select="$href">
        <p:empty/>
      </p:with-option>
    </p:add-attribute>

    <p:choose>
      <p:when test="p:value-available('accept')">
        <p:add-attribute match="/*" attribute-name="value" name="create-accept-header">
          <p:input port="source">
            <p:inline>
              <c:header name="Accept"/>
            </p:inline>
          </p:input>
          <p:with-option name="attribute-value" select="$accept">
            <p:empty/>
          </p:with-option>
        </p:add-attribute>
        <p:insert match="/*" position="first-child">
          <p:input port="source">
            <p:pipe step="create-request" port="result"/>
          </p:input>
          <p:input port="insertion">
            <p:pipe step="create-accept-header" port="result"/>
          </p:input>
        </p:insert>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>

    <p:http-request/>
  </p:declare-step>

  <!-- -->

  <p:xinclude/>

  <xg:grddl-impl>
    <p:with-option name="xml-glean" select="$xml-glean"/>
    <p:with-option name="xmlns-glean" select="$xmlns-glean"/>
    <p:with-option name="xhtml-glean" select="$xhtml-glean"/>
    <p:with-option name="xhtml-profile-glean" select="$xhtml-profile-glean"/>
  </xg:grddl-impl>

</p:declare-step>
