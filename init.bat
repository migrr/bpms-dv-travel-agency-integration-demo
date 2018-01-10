@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=JBoss BPM Suite & JDV Travel Agency Integration Demo
set AUTHORS=Nirja Patel, Shepherd Chengeta, Van Halbert,
set AUTHORS2=Andrew Block, Eric D. Schabell
set PROJECT=git@github.com:jbossdemocentral/bpms-dv-travel-agency-integration-demo.git
set PRODUCT=JBoss BPM Suite
set JBOSS_HOME=%PROJECT_HOME%target\jboss-eap-6.4
set SERVER_DIR=%JBOSS_HOME%\standalone\deployments\
set SERVER_CONF=%JBOSS_HOME%\standalone\configuration\
set SERVER_BIN=%JBOSS_HOME%\bin
set SRC_DIR=%PROJECT_HOME%installs

set DV_PRODUCT=JBoss DV
set DV_JBOSS_HOME=%PROJECT_HOME%target\jboss-dv-6.2
set DV_SERVER_DIR=%DV_JBOSS_HOME%\standalone\deployments\
set DV_SERVER_CONF=%DV_JBOSS_HOME%\standalone\configuration\
set DV_SERVER_BIN=%DV_JBOSS_HOME%\bin
set DV_SRC_DIR=%PROJECT_HOME%installs

set SUPPORT_DIR=%PROJECT_HOME%support
set PRJ_DIR=%PROJECT_HOME%projects
set BPMS=jboss-bpmsuite-installer-6.2.0.BZ-1299002.jar
set EAP=jboss-eap-6.4.0-installer.jar
set EAP_PATCH=jboss-eap-6.4.4-patch.zip
set VERSION=6.2

set DV=jboss-dv-installer-6.2.0.redhat-3.jar
set DV_VERSION=6.2


REM wipe screen.
cls
GOTO :README
echo.
echo ###############################################################################
echo ##                                                                           ##
echo ##  Setting up the                                                           ##
echo ##                                                                           ##
echo ##     %DEMO%                                                      ##
echo ##                                                                           ##
echo ##                                                                           ##
echo ##   ####  ####   #   #      ### #   # ##### ##### #####       ####  #    #  ##
echo ##   #   # #   # # # # #    #    #   #   #     #   #       #   #   # #    #  ##
echo ##   ####  ####  #  #  #     ##  #   #   #     #   ###    ###  #   # #    #  ##
echo ##   #   # #     #     #       # #   #   #     #   #       #   #   #  #  #   ##
echo ##   ####  #     #     #    ###  ##### #####   #   #####       ####    ##    ##
echo ##                                                                           ##
echo ##                                                                           ##
echo ##  brought to you by,                                                       ##
echo ##                                                                           ##
echo ##         %AUTHORS%                      ##
echo ##         %AUTHORS2%                                    ##
echo ##                                                                           ##
echo ##  %PROJECT% 
echo ##                                                                           ##
echo #################################################################################
echo.

REM make some checks first before proceeding.	
if exist "%SRC_DIR%\%EAP%" (
        echo Product sources are present...
        echo.
) else (
        echo Need to download %EAP% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist %SRC_DIR%\%EAP_PATCH% (
        echo Product patches are present...
        echo.
) else (
        echo Need to download %EAP_PATCH% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist "%SRC_DIR%\%BPMS%" (
        echo BPMS Product sources are present...
        echo.
) else (
        echo Need to download %BPMS% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist "%SRC_DIR%\%DV%" (
        echo DV Product sources are present...
        echo.
) else (
        echo Need to download %DV% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

REM Remove the old JBoss instance, if it exists.
if exist "%JBOSS_HOME%" (
         echo - existing JBoss product install removed...
         echo.
         rmdir /s /q target"
 )

REM Run installers.
echo EAP installer running now...
echo.
call java -jar "%SRC_DIR%/%EAP%" "%SUPPORT_DIR%\installation-eap" -variablefile "%SUPPORT_DIR%\installation-eap.variables"


if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error Occurred During JBoss EAP Installation!
	echo.
	GOTO :EOF
)

call set NOPAUSE=true

echo.
echo Applying JBoss EAP patch now...
echo.
call %JBOSS_HOME%/bin/jboss-cli.bat --command="patch apply %SRC_DIR%/%EAP_PATCH% --override-all"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error Occurred During JBoss EAP Patch Installation!
	echo.
	GOTO :EOF
)

echo.
echo JBoss BPM Suite installer running now...
echo.
call java -jar "%SRC_DIR%/%BPMS%" "%SUPPORT_DIR%\installation-bpms" -variablefile "%SUPPORT_DIR%\installation-bpms.variables"

if not "%ERRORLEVEL%" == "0" (
	echo Error Occurred During %PRODUCT% Installation!
	echo.
	GOTO :EOF
)

echo.
echo JBoss EAP for DataVirt installer running now...
echo.
call java -jar "%SRC_DIR%/%EAP%" "%SUPPORT_DIR%\installation-dv-eap" -variablefile "%SUPPORT_DIR%\installation-dv-eap.variables"

if not "%ERRORLEVEL%" == "0" (
  echo.
  echo Error Occurred During JBoss EAP for DataVirt Installation!
  echo.
  GOTO :EOF
)

call set NOPAUSE=true

echo.
echo Applying JBoss EAP for DataVirt patch now...
echo.
call %DV_JBOSS_HOME%/bin/jboss-cli.bat --command="patch apply %SRC_DIR%/%EAP_PATCH% --override-all"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error Occurred During JBoss EAP for DataVirt Patch Installation!
	echo.
	GOTO :EOF
)

echo.
echo JBoss DV installer running now...
echo.
call java -jar "%SRC_DIR%/%DV%" "%SUPPORT_DIR%\installation-dv" -variablefile "%SUPPORT_DIR%\installation-dv.variables"

if not "%ERRORLEVEL%" == "0" (
	echo Error Occurred During JBoss DV Installation!
	echo.
	GOTO :EOF
)

echo - setting up demo projects...
echo.

echo - enabling demo accounts role setup in application-roles.properties file...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\application-roles.properties" "%SERVER_CONF%"
echo. 

mkdir "%SERVER_BIN%\.niogit\"
xcopy /Y /Q /S "%SUPPORT_DIR%\bpm-suite-demo-niogit\*" "%SERVER_BIN%\.niogit\"
echo. 

echo.
echo - setting up web services...
echo.
call mvn clean install -f "%PRJ_DIR%/pom.xml"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error Building Maven Project!
	echo.
	GOTO :EOF
)


xcopy /Y /Q "%PRJ_DIR%\acme-demo-flight-service\target\acme-flight-service-1.0.war" "%SERVER_DIR%"
xcopy /Y /Q "%PRJ_DIR%\acme-demo-hotel-service\target\acme-hotel-service-1.0.war" "%SERVER_DIR%"

echo.
echo - adding acmeDataModel-1.0.jar to business-central.war/WEB-INF/lib
xcopy /Y /Q "%PRJ_DIR%\acme-data-model\target\acmeDataModel-1.0.jar" "%SERVER_DIR%\business-central.war\WEB-INF\lib"

echo.
echo - deploying external-client-ui-form-1.0.war to EAP deployments directory
xcopy /Y /Q "%PRJ_DIR%\external-client-ui-form\target\external-client-ui-form-1.0.war" "%SERVER_DIR%"

echo.
echo - setting up standalone.xml configuration adjustments...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\standalone.xml" "%SERVER_CONF%"
echo.

echo - setup email task notification users...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\userinfo.properties" "%SERVER_DIR%\business-central.war\WEB-INF\classes\"

REM Optional: uncomment this to install mock data for BPM Suite
REM
REM echo - setting up mock bpm dashboard data...
REM echo.
REM xcopy /Y /Q "%SUPPORT_DIR%\1000_jbpm_demo_h2.sql" "%SERVER_DIR%\dashbuilder.war\WEB-INF\etc\sql"
REM echo.

echo.
echo - setting up standalone.xml configuration adjustments for DV server...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\standalone.xml" "%DV_SERVER_CONF%"
echo.

echo.
echo - setting up travel VDB for DV server...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\vdb\travel-vdb.xml" "%DV_SERVER_DIR%"
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\vdb\travel-vdb.xml.dodeploy" "%DV_SERVER_DIR%"
echo.

echo.
echo - setting up travel data for DV server...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\data\flights-source-schema.sql" "%DV_SERVER_CONF%"
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\data\hotels-source-schema.sql" "%DV_SERVER_CONF%"
echo.

echo - copy Teiid JDBC Driver ...
echo.
xcopy /Y /Q "%DV_JBOSS_HOME%\dataVirtualization\jdbc\teiid-8.*.jar" "%SERVER_DIR%\dashbuilder.war\WEB-INF\lib\"

echo - copy flight and hotel dashboard files ...
echo.
xcopy /Y /Q "%SUPPORT_DIR%\teiidfiles\dashboard\*.*" "%SERVER_DIR%\dashbuilder.war\WEB-INF\deployments\"

echo.
echo ===============================================================================
echo =                                                                             =
echo =  You can now start the DV server with:                                      =
echo =                                                                             =
echo =   %DV_SERVER_BIN%\standalone.sh -Djboss.socket.binding.port-offset=100
echo =                                                                             =
echo =  You can now start the %PRODUCT% with:                                =
echo =                                                                             =
echo =   %SERVER_BIN%\standalone.bat                                 =
echo =                                                                             =
echo =  Login into business central at:                                            =
echo =                                                                             =
echo =    http://localhost:8080/business-central  [u:erics / p:bpmsuite1!]         =
echo =                                                                             =
echo =  See README.md for general details to run the various demo cases.           =
echo =                                                                             =
echo =  %DEMO% Setup Complete.                                           =
echo =                                                                             =
echo ===============================================================================
echo.
