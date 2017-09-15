@echo off
if "%1" == "" echo Missing TOMCAT parameter && goto :eof
if not exist kie-drools-wb.war echo Unable to find kie-drools-wb.war in current dir && goto :eof
if not exist %1\webapps echo Unable to find tomcat webapps directory && goto :eof

@echo on
xcopy /d login.config %1\conf
xcopy /d tomcat-users.xml %1\conf
xcopy /d server.xml %1\conf
xcopy /d context.xml %1\conf
xcopy /d resources.properties %1\conf
xcopy /d btm-config.properties %1\conf
xcopy /d xa-recovery-properties.xml %1\conf
xcopy /d kieenv.cmd %1
xcopy /d *.jar %1\lib
xcopy /d *.war %1\webapps

:eof