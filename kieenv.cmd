set JAVA_OPTS=-Xmx2048m -XX:MaxPermSize=256m
REM -Dorg.kie.server.user=ks-user -Dorg.kie.server.pwd=Password1!
REM org.uberfire.nio.git.dir
SET GIT_DIR=%USERPROFILE%\dev\rules
SET KIE_CONNECTION_URL=jdbc:h2:file:~/jbpm
SET KIE_CONNECTION_DRIVER=h2
SET KIE_CONNECTION_USER=sa
# Empty password by default
# ENV KIE_CONNECTION_PASSWORD 
SET KIE_CONNECTION_DATABASE=kie
SET KIE_USER=kie
SET KIE_PWD=kie
SET BTM_CONF=-Dbitronix.tm.configuration=%CD%\conf\btm-config.properties
SET XA=-Dcom.arjuna.ats.jta.recovery.XAResourceRecovery1=com.arjuna.ats.internal.jdbc.recovery.BasicXARecovery;abs://%CD%\conf\xa-recovery-properties.xml
SET CATALINA_OPTS=-Dorg.uberfire.nio.git.dir=%GIT_DIR% -Dorg.kie.server.user=%KIE_USER% -Dorg.kie.server.pwd=%KIE_PWD% -Djava.security.auth.login.config=$CATALINA_HOME/conf/login.config -Dorg.jboss.logging.provider=jdk  -Djbpm.tsr.jndi.lookup=java:comp/env/TransactionSynchronizationRegistry -Dorg.kie.server.persistence.ds=java:comp/env/jdbc/jbpm -Djbpm.tm.jndi.lookup=java:comp/env/TransactionManager -Dorg.kie.server.persistence.tm=JBossTS -Dhibernate.connection.release_mode=after_transaction -Dorg.kie.server.id=tomcat-kieserver -Dorg.kie.server.location=http://localhost:8080/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-drools-wb/rest/controller %XA%