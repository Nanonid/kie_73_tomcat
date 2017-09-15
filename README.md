Installation notes
==================

## KIE-WB Readme

1. Define system properties

    create setenv.sh (or setenv.bat) file inside TOMCAT_HOME/bin and add following:

    CATALINA_OPTS="-Xmx512M \
    -Djava.security.auth.login.config=$CATALINA_HOME/webapps/kie-drools-wb/WEB-INF/classes/login.config \
    -Dorg.jboss.logging.provider=jdk"

    NOTE: On Debian based systems $CATALINA_HOME needs to be replaced with $CATALINA_BASE. ($CATALINA_HOME defaults to /usr/share/tomcat8 and $CATALINA_BASE defaults to /var/lib/tomcat8/)
    NOTE: this is an example for unix like systems for Windows $CATALINA_HOME needs to be replaced with windows env variable or absolute path
    NOTE: java.security.auth.login.config value includes name of the folder in which application is deployed by default it assumes kie-drools-wb so ensure that matches real installation.
    login.config file can be externalized as well meaning be placed outside of war file.


   *******************************************************************************

2. Configure JEE security for kie-wb on tomcat (with default realm backed by tomcat-users.xml)

   2.1. Copy "kie-tomcat-integration" JAR into TOMCAT_HOME/lib (org.kie:kie-tomcat-integration)

   2.2. Copy "JACC" JAR into TOMCAT_HOME/lib (javax.security.jacc:artifactId=javax.security.jacc-api in JBoss Maven Repository)

   2.3. Copy "slf4j-api" JAR into TOMCAT_HOME/lib (org.slf4j:artifactId=slf4j-api in JBoss Maven Repository)
   2.4. Add valve configuration into TOMCAT_HOME/conf/server.xml inside Host element as last valve definition:

      <Valve className="org.kie.integration.tomcat.JACCValve" />

   2.5. Edit TOMCAT_HOME/conf/tomcat-users.xml to include roles and users, make sure there will be 'analyst' or 'admin' roles defined as it's required to be authorized to use kie-wb

  ~~~xml
  <role rolename="tomcat"/>
  <role rolename="admin"/>
  <role rolename="analyst"/>
  <role rolename="kie-server"/>
  <role rolename="manager-gui"/>
  <user username="via" password="via" roles="manager-gui,analyst,admin,kie-server"/>
  ~~~
3. Increase Java's PermGen space by adding file TOMCAT_HOME/bin/setenv.sh containing export JAVA_OPTS="-Xmx1024m -XX:MaxPermSize=256m"

## KIE Readme

Installing KIE Server on Tomcat 8

This instruction describes all steps to install KIE Server on Tomcat 8 standalone distribution - this means it's Tomcat downloaded as zip/tar.

 1. Extract Tomcat archive into desired location - TOMCAT_HOME
 2. Copy following libraries into TOMCAT_HOME/lib
   - javax.security.jacc:javax.security.jacc-api "javax.security.jacc-api-1.5.jar"
   - org.kie:kie-tomcat-integration "kie-tomcat-integration-7.3.0.Final.jar"
   - org.slf4j:artifactId=slf4j-api "slf4j-api-1.7.25.jar"
   - org.slf4j:artifactId=slf4j-jdk14 "slf4j-jdk14-1.7.25.jar"

 versions of these libraries will depend on the release, so best to check what versions are shipped with KIE

 3. Copy JDBC driver lib into TOMCAT_HOME/lib depending on the data base of your choice, as example H2 is used
  3.1. "h2-1.4.196.jar"

 4. Configure users and roles in tomcat-users.xml (or different user repository if applicable)

~~~xml
 <tomcat-users>
   <role rolename="admin"/>
   <role rolename="PM"/>
   <role rolename="HR"/>
   <role rolename="analyst"/>
   <role rolename="user"/>
   <role rolename="kie-server"/>

   <user username="testuser" password="testpwd" roles="admin,analyst,PM,HR,kie-server"/>
   <user username="kieserver" password="kieserver1!" roles="kie-server"/>
 </tomcat-users>
~~~

 5. Configure data source for data base access by jBPM extension of KIE Server
    Edit TOMCAT_HOME/conf/context.xml and add following within Context tags of the file

       <Resource name="sharedDataSource"
       		  auth="Container"
       		  type="org.h2.jdbcx.JdbcDataSource"
       		  user="sa"
              password="sa"
              url="jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MVCC=TRUE"
              description="H2 Data Source"
              loginTimeout="0"
              testOnBorrow="false"
              factory="org.h2.jdbcx.JdbcDataSourceFactory"/>

 6. Configure JACC Valve for security integration
    Edit TOMCAT_HOME/conf/server.xml and add following in Host section after last Valve declaration

    <Valve className="org.kie.integration.tomcat.JACCValve" />

 7. Create setenv.sh|bat in TOMCAT_HOME/bin with following content

    CATALINA_OPTS="-Xmx512M -Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry -Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpm -Djbpm.tm.jndi.lookup=java:comp/env/TransactionManager -Dorg.kie.server.persistence.tm=JBossTS -Dhibernate.connection.release_mode=after_transaction -Dorg.kie.server.id=tomcat-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller"

    Last three parameters might require reconfiguration as they depend on actual environment they run on:
    Actual kie server id to identify given kie server
    -Dorg.kie.server.id=tomcat-kieserver

    Actual location of the kie server over HTTP
    -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server

    Location of the controller in case kie server should run in managed mode
    -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller

 8. Configure XA Recovery

    Create xa recovery file next to the context.xml with data base configuration with following content:

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
    <properties>
        <entry key="DB_1_DatabaseUser">sa</entry>
        <entry key="DB_1_DatabasePassword">sa</entry>
        <entry key="DB_1_DatabaseDynamicClass"></entry>
        <entry key="DB_1_DatabaseURL">java:comp/env/h2DataSource</entry>
    </properties>

    Append to CATALINA_OPTS in setenv.sh|bat file following:
    -Dcom.arjuna.ats.jta.recovery.XAResourceRecovery1=com.arjuna.ats.internal.jdbc.recovery.BasicXARecovery\;abs://$CATALINA_HOME/conf/xa-recovery-properties.xml\ \;1

    BasicXARecovery supports following parameters:
     - path to the properties file
     - the number of connections defined in the properties file

## Tips

### NIO GIT
http://docs.jboss.org/jbpm/v6.2/userguide/wb.Workbench.html#wb.systemProperties
  1. org.uberfire.nio.git.dir: Location of the directory .niogit. Default: working directory

## Configuration of older 6.3 KIE and WB on Tomcat from the wild

1. Deploy applications
  Copy downloaded files into TOMCAT_HOME/webapps, while copying rename them to simplify the context paths that will be used on application server:
  rename kie-wb-distribution-wars-6.3.0.Final-tomcat7.war to kie-wb.war
  rename kie-server-6.3.0.Final-webc.war to kie-server.war
  Configure your server
  Copy following libraries into TOMCAT_HOME/lib
  btm-2.1.4
  btm-tomcat55-lifecycle-2.1.4
  h2-1.3.161
  jacc-1.0
  jta-1.1
  kie-tomcat-integration-6.3.0.Final
  slf4j-api-1.7.2
  slf4j-api-1.7.2

Create Bitronix configuration files to enable JTA transaction manager
Create file 'btm-config.properties' under TOMCAT_HOME/conf with following content
bitronix.tm.serverId=tomcat-btm-node0
bitronix.tm.journal.disk.logPart1Filename=${btm.root}/work/btm1.tlog
bitronix.tm.journal.disk.logPart2Filename=${btm.root}/work/btm2.tlog
bitronix.tm.resource.configuration=${btm.root}/conf/resources.properties
Create file 'resources.properties' under TOMCAT_HOME/conf with following content
resource.ds1.className=bitronix.tm.resource.jdbc.lrc.LrcXADataSource
resource.ds1.uniqueName=jdbc/jbpm
resource.ds1.minPoolSize=10
resource.ds1.maxPoolSize=20
resource.ds1.driverProperties.driverClassName=org.h2.Driver
resource.ds1.driverProperties.url=jdbc:h2:mem:jbpm
resource.ds1.driverProperties.user=sa
resource.ds1.driverProperties.password=
resource.ds1.allowLocalTransactions=true

Configure users
Create following users in tomcat-users.xml under TOMCAT_HOME/conf
create user
name: kieserver 
password: kieserver1!
roles: kie-server
create user to logon to workbench
name: workbench 
password: workbench!
roles: admin, kid-server

<tomcat-users>
  <role rolename="admin"/>
  <role rolename="analyst"/> 
  <role rolename="user"/>
  <role rolename="kie-server"/>
 
  <user username="workbench" password="workbench1!" roles="admin,kie-server"/>
  <user username="kieserver" password="kieserver1!" roles="kie-server"/>  
</tomcat-users>
Configure system properties
Configure following system properties in file setenv.sh under TOMCAT_HOME/bin
-Dbtm.root=$CATALINA_HOME 
-Dorg.jbpm.cdi.bm=java:comp/env/BeanManager 
-Dbitronix.tm.configuration=$CATALINA_HOME/conf/btm-config.properties 
-Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry 
-Djava.security.auth.login.config=$CATALINA_HOME/webapps/kie-wb/WEB-INF/classes/login.config 
-Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpm 
-Dorg.kie.server.persistence.tm=org.hibernate.service.jta.platform.internal.BitronixJtaPlatform 
-Dorg.kie.server.id=tomcat-kieserver 
-Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server 
-Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller

NOTE: Simple copy this into setenv.sh files to properly setup KIE Server and Workbench on Tomcat:
CATALINA_OPTS="-Xmx512M -XX:MaxPermSize=512m -Dbtm.root=$CATALINA_HOME -Dorg.jbpm.cdi.bm=java:comp/env/BeanManager -Dbitronix.tm.configuration=$CATALINA_HOME/conf/btm-config.properties -Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry -Djava.security.auth.login.config=$CATALINA_HOME/webapps/kie-wb/WEB-INF/classes/login.config -Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpm -Dorg.kie.server.persistence.tm=org.hibernate.service.jta.platform.internal.BitronixJtaPlatform -Dorg.kie.server.id=tomcat-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller"

Launching the server
Go to TOMCAT_HOME/bin and issue following command:
./startup.sh

Going beyond default setup
Disabling KIE Server extensions
And that's all to do to setup both KIE Server and Workbench on single server instance (either Wildfly or Tomcat). This article focused on fully featured KIE server installation meaning both BRM (rules) and BPM (processes, tasks) capabilities. Although KIE Server can be configured to serve only subset of the capabilities - e.g. only BRM or only BPM.

To do so one can configure KIE Server with system properties to disable extensions (BRM or BPM)

Tomcat
add following system property to setenv.sh script (must be still part of CATALINA_OPTS configuration):
disable BRM: -Dorg.drools.server.ext.disabled=true
disable BPM: -Dorg.jbpm.server.ext.disabled=true
Complete content of setenv.sh is as follows:
CATALINA_OPTS="-Xmx512M -XX:MaxPermSize=512m -Dbtm.root=$CATALINA_HOME -Dorg.jbpm.cdi.bm=java:comp/env/BeanManager -Dbitronix.tm.configuration=$CATALINA_HOME/conf/btm-config.properties -Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry -Djava.security.auth.login.config=$CATALINA_HOME/webapps/kie-wb/WEB-INF/classes/login.config -Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpm -Dorg.kie.server.persistence.tm=org.hibernate.service.jta.platform.internal.BitronixJtaPlatform -Dorg.kie.server.id=tomcat-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller -Dorg.jbpm.server.ext.disabled=true"

Changing data base and persistence settings
Since by default persistence uses just in memory data base (H2) it is good enough for first tryouts or demos but not for real usage. So to be able to change persistence settings following needs to be done:

KIE Workbench on Wildfly
Modify data source configuration in Wildfly - either via manual editing of standalone-full.xml file or using tools such as Wildfly CLI. See Wildfly documentation on how to define data sources.

Next modify persistence.xml that resides inside workbench war file. Extract the kie-wb.war file into directory with same name and in same location (WILDFLY_HOME/standalone/deployments). 
Then navigate to kie-wb.war/WEB-INF/classes/META-INF
Edit persistence.xml file and change following elements
jta-data-source to point to the newly created data source (JNDI name) for your data base
hibernate.dialect to hibernate supported dialect name for you data base
KIE Server on Wildfly
there is no need to do any changes to the application (the war file) as the persistence can be reconfigured via system properties. Set following system properties at the end of server startup command

-Dorg.kie.server.persistence.ds=java:jboss/datasources/jbpmDS
-Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect
Full command to start server will be:
./standalone.sh --server-config=standalone-full.xml -Dorg.kie.server.id=wildfly-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller -Dorg.kie.server.persistence.ds=java:jboss/datasources/jbpmDS 
-Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect

KIE Workbench on Tomcat
To modify data source configuration in Tomcat you need to alter resources.properties (inside TOMCAT_HOME/conf) file that defines data base connection. For MySQL it could look like this:

resource.ds1.className=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource
resource.ds1.uniqueName=jdbc/jbpmDS
resource.ds1.minPoolSize=0
resource.ds1.maxPoolSize=10
resource.ds1.driverProperties.user=guest
resource.ds1.driverProperties.password=guest
resource.ds1.driverProperties.URL=jdbc:mysql://localhost:3306/jbpm
resource.ds1.allowLocalTransactions=true

Make sure you're copy mysql JDBC driver into TOMCAT_HOME/lib otherwise it won't provide proper connection handling.
Next modify persistence.xml that resides inside workbench war file. Extract the kie-wb.war file into directory with same name and in same location (TOMCAT_HOME/webapps). 
Then navigate to kie-wb.war/WEB-INF/classes/META-INF
Edit persistence.xml file and change following elements
jta-data-source to point to the newly created data source (JNDI name) for your data base
hibernate.dialect to hibernate supported dialect name for you data base
KIE Server on Tomcat
there is no need to do any changes to the application (the war file) as the persistence can be reconfigured via system properties. Set or modify (as data source is already defined there) following system properties in setenv.sh script inside TOMCAT_HOME/bin

-Dorg.kie.server.persistence.ds=java:comp/env/jdbc//jbpmDS
-Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect
Complete content of the setenv.sh script is as follows:
CATALINA_OPTS="-Xmx512M -XX:MaxPermSize=512m -Dbtm.root=$CATALINA_HOME -Dorg.jbpm.cdi.bm=java:comp/env/BeanManager -Dbitronix.tm.configuration=$CATALINA_HOME/conf/btm-config.properties -Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry -Djava.security.auth.login.config=$CATALINA_HOME/webapps/kie-wb/WEB-INF/classes/login.config -Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpmDS -Dorg.kie.server.persistence.tm=org.hibernate.service.jta.platform.internal.BitronixJtaPlatform 
-Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect
-Dorg.kie.server.id=tomcat-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller"

Note that KIE Server persistence is required only for BPM capability so if you disable it you can skip any KIE server related persistence changes.

And that would be it. Hopefully this article will help with installation of KIE Workbench and Server on single application server. 
