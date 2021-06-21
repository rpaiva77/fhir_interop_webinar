ARG IMAGE=store/intersystems/iris-community:2020.1.0.204.0
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.204.0-zpm
ARG IMAGE=intersystemsdc/irishealth-community:2020.2.0.204.0-zpm
ARG IMAGE=intersystemsdc/irishealth-community:2020.3.0.200.0-zpm
ARG IMAGE=store/intersystems/irishealth-community:2020.4.0.524.0
ARG IMAGE=store/intersystems/irishealth-community:2020.4.0.547.0
FROM $IMAGE

USER root

COPY data/fhir /tmp/fhirdata
COPY iris.script /tmp/iris.script
COPY ./Installer.xml ./FHIRStarter_Export.xml ./ISCPATIENTtoFHIR.xsd $ISC_PACKAGE_INSTALLDIR/mgr/

USER ${ISC_PACKAGE_MGRUSER}

# run iris and initial 
RUN iris start IRIS \
    && iris session IRIS -U %SYS "##class(%SYSTEM.OBJ).Load(\"$ISC_PACKAGE_INSTALLDIR/mgr/Installer.xml\",\"cdk\")" \
    && iris session IRIS -U %SYS "##class(Demo.Installer).Install()" \
    && iris session IRIS < /tmp/iris.script 