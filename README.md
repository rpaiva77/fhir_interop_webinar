# Webinar Interoperabilidad y FHIR
En este webinar, hablamos de Interoperabilidad desde la perspectiva del estándar y de su convivencia con los demás estándares sanitarios en InterSystems IRIS for Health. Empezamos con un *endpoint* FHIR en InterSystems IRIS for Health y veremos manejarlos mediante una producción. Veremos como editar los recursos FHIR y manipularlos. En seguida, abordaremos el *Capability Statement* y veremos como modificar las capacidades de un servidor FHIR. Finalmente, veremos como consumir datos clínicos en distintos formatos (HL7, CDA y formatos propietarios) y persistirlos en un servidor/repositorio FHIR. 
## Herramientas utilizadas
* [Docker](https://www.docker.com/products/docker-desktop) - para ejecutar [IRIS for Health Community](https://www.intersystems.com/products/intersystems-iris-for-health/).
* [GoogleARC](https://install.advancedrestclient.com/install) - para lanzar peticiones REST.
* [Synthea](https://github.com/synthetichealth/synthea) - para generar bundles de recursos fhir con datos para prueba. No lo vamos a usar de manera explicita en este webinar. Lo hemos usado para generar los datos de prueba subidos al repositorio en el script de configuración inicial.

## Contenido

### Ficheros de configuración
1. `DockerFile` — script para la creación del Docker container
2. `docker-compose.yml` - configuración para la ejecución del container
3. `Installer.xml` — manifiesto del instalador para la configuración de la instancia de InterSystems IRIS for Health
4. `FHIRStarter_Export.xml` — export de las clases necesarias para la producción a cargar en el namespace FHIRDEMO
5. `ISCPATIENTtoFHIR.xml` — esquema XML para simular un formato propietario de datos clínicos
6. `iris.script` -  creación y configuración del namespace FHIRSERVER
7. `Webinar_ChangeBPL.xml` - proceso BPL a cargar en el namespace FHIRSERVER
8. `Webinar.Change.cls` - proceso con igual funcionalidad que el anterior pero en código COS 
9. `NewInterOpWebCapabilityStatement.json` - fichero que contiene un CapabilityStatement con solamente 3 recursos 

### Ficheros de prueba
1. `ISC/ISCPATIENTtoFHIR.xml` — ejemplo de un fichero XML - simula un formato propietario
2. `ISC/EpicCCDA21toFHIR.xml` — ejemplo de un fichero CDA
3. `ISC/HL7toFHIR.HL7` — ejemplo de un fichero HL7
4. `ISC/PatientsCSVtoFHIR.csv` — ejemplo de un fichero CSV - simula un dump/export de datos en el formato: registro por línea con los campos separados por coma (',')
5. `ISC/HL7v2_ORU_R01.hl7` - ejemplo de un fichero HL7
6. `ISC/MRNFlatFile.txt` - ejemplo de un fichero con solamente el NHC (Numero de Historia Clínica)
7. `ISC/In` — carpeta donde poner el ficheros de prueba
8. `arc-data-export.json` - colección de peticiones rest
9. `README.md` — fichero de instrucciones


## Instalación
La instalación crea 2 namespaces FHIRSERVER y FHIRDEMO. En el namespace FHIRSERVER se crea un *endpoint* FHIR /fhir/r4. En el namespace FHIRDEMO se crean 2 *endpoints* el /fhirstarter/r4, el /fhirplace/r4 y se crea la producción FHIRStarter. 
La configuración de un repositorio de recursos [FHIR R4](https://www.hl7.org/fhir/) utilizando las funcionalidades de [FHIR Server](https://docs.intersystems.com/irisforhealth20204/csp/docbook/DocBook.UI.Page.cls?KEY=HXFHIR) de IRIS for Health. En este webinar configuramos el Servidor/Repositorio FHIR mediante scripting. Sin embargo, lo podríamos hacer mediante el uso de la UI proporcionada por la Plataforma.

1. Descargar el repositorio
```shell
git clone https://github.com/rpaiva77/fhir_interop_webinar
cd webinar_fhir_profiling
```

2. Iniciar la instancia [IRIS for Health](https://www.intersystems.com/products/intersystems-iris-for-health/)
```shell
docker-compose up
```

3. Con la instancia en marcha, acceder al [Mng. Portal](http://localhost:8091/csp/sys/UtilHome.csp)
* Usuario: `superuser`
* Password: `SYS`

4. Revisar la configuraración del Servidor FHIR en [Mng. Portal > Health > FHIR Configuration > Server Configuration](http://localhost:8091/csp/healthshare/FHIRSERVER/fhirconfig/index.html#/server-config), hacer click en el *endpoint* y comprobar el paquete core - standard R4.  

## Primeras interacciones con el Repositorio FHIR
En el namespace FHIRSERVER ejecutemos algunas unas pruebas sencillas contra el *endpoint* /fhir/r4. En el archivo arc-requests.json tenemos algunas peticiones preparadas. 
* CapabilityStatement: Ver el *Capability Statement* del *FHIR Server*.
* AllPatients: Obtener los pacientes disponibles.
* Patient Everything: Obtener toda la info del paciente 1
* Patient Observation: Obtener la primera observación del paciente 1 (Observation/5)
* Patient One: Obtener el paciente 1

## Cambio en FoundationProduction para InterOpProdoction:
* Cambiar el endpoint /fhir/r4 en Interoperability - Service Config Name añadir HS.FHIRServer.Interop.Service
* En la producción añadir el HS.FHIRServer.Interop.Service y el HS.FHIRServer.Interop.Operation
* Configurar/Revisar el destino en el *business service* HS.FHIRServer.Interop.Service
* GET al Patient 1 y mirar la traza de mensajería

## Añadir el componente Webinar.ChangeBPL a la producción. 
* Desde Interoperability > Lista de procesos de negocio > Importar, buscar el fichero Webinar.ChangeBPL.xml. Compilar.
* En la producción habrá que cambiar el target del *business service* HS.FHIRServer.Interop.Service. Enviar al nuevo *business process*
* Mirar el contenido del BPL y activar la actividad Codigo

## Crear un endpoint proxy para el repositorio fhir/r4
* Quitar el HS.FHIRServer.Interop.Service de la configuración del *endpoint* /fhir/r4
* Añadir nuevo endpoint proxyfhir/r4
* Añadir el HS.FHIRServer.Interop.Service al /proxyfhir/r4
* En la producción quitar el HS.FHIRServer.Interop.Operation y añadir el HS.FHIRServer.Interop.HTTPOperation
* Cambiar el target de HS.FHIRServer.Interop.Service para el HS.FHIRServer.Interop.HTTPOperation. 
* Añadir en Health > Service Registry un nuevo servicio: 
    - Service Type: HTTP 
    - Name: FHIRv4 
    - Host: localhost
    - URL: http://localhost:52773/fhir/r4/

## Cambiar el CapabilityStatement 
* Desde una consola de terminal acceder a la instancia de InterSystems IRIS for Health, acceder al namespace "FHIRSERVER" y exportar el Capability Statement. Lo mismo se podría hacer usando el ARC mediante un GET a los metadatos (http://localhost:8091/fhir/r4/metadata) 

```shell
docker exec -it fhir_interop_webinar_iris_1 bash
iris session IRIS
zn "FHIRSERVER"
set strategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint("/fhir/r4")
set interactions = strategy.NewInteractionsInstance()
set capabilityStatement = interactions.LoadMetadata()
do capabilityStatement.%ToJSON("/irisdev/MyCapabilityStatement.json")
```
* Tras manipular en Capability Statement habrá que subirlo al *endpoint*. Hemos dejado en esta carpeta al fichero NewInterOpWebCapabilityStatement.json. Este fichero contiene el Capability Statement para solamente 3 recursos - Encounter, Immunization y Patient.

 ```shell  
docker exec -it fhir_interop_webinar_iris_1 bash
iris session IRIS
zn "FHIRSERVER"
set strategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint("/fhir/r4")
set interactions = strategy.NewInteractionsInstance()
set newCapabilityStatement = {}.%FromJSON("/irisdev/NewInterOpWebCapabilityStatement.json")
do interactions.SetMetadata(newCapabilityStatement)
```
## Probar los componentes de FHIRStarter
* Para porbarlo hay que cambiar al namespace FHIRDEMO
* Antes de probarlo, echar una mirada a los ficheros de prueba:
    `ISC/ISCPATIENTtoFHIR.xml` — ejemplo com un fichero XML - simula un formato propietario
    `ISC/EpicCCDA21toFHIR.xml` — ejemplo com un fichero CDA
    `ISC/HL7toFHIR.HL7` — ejemplo com un fichero HL7
    `ISC/PatientsCSVtoFHIR.csv` — ejemplo com un fichero CSV - simula un dump/export de datos en el formato: un registro por línea con los campos separados por coma (',')
* Colocar cada un de los archivos de prueba en la carpeta asignada. Habrá que confirmar que la carpeta es correcta
* Verifique que se recoge y procesa el archivo 
* En Interoperabilidad > Ver > Mensajes es posible ver toda la traza del mensaje 
* Comprobar el contenido de los 2 *business process*. Comprobar el uso de transformaciones ya disponibles en la plataforma para los archivos CDA y HL7. Para los formatos propietarios (XML y CSV) se usan las herramientas ya conocidas de la plataforma - DTL y RecordMap.
* Debe tenerse en cuenta que el archivo PatientCSVtoFHIR tiene 200 pacientes para convertir en recursos FHIR. Esto puede tardar un poco dependiendo de los recursos del sistema.

## Probar los componentes de FHIRPlace
* Para porbarlo hay que cambiar al namespace FHIRDEMO
* Antes de probarlo, echar una mirada a los ficheros de prueba:
    `ISC/HL7v2_ORU_R01.hl7` - ejemplo de un fichero HL7
    `ISC/HL7toFHIR.HL7` — ejemplo con un fichero HL7
    `ISC/MRNFlatFile.txt` - ejemplo de un fichero con solamente el NHC (Numero de Historia Clinica)
* Colocar el fichero HL7toFHIR.HL7 en la carpeta de entrada para agregar un recurso FHIR al *endpoint* EMREmulatorFHIRR4 FHIR 
* La entrada en el Registry de servicios (Health > Service Registry) EMREmulatorFHIRR4 apunta al *endpoint* FHIR /fhirstarter/r4
* Colocar el fichero HL7v2_ORU_R01.hl7 o MRNFlatFile.txt en la carpeta de entrada para activar la recopilación de datos FHIR externa basada en un NHC del paciente
* El mensaje .hl7 incluye un valor de NHC en la lista de identificadores de paciente que obtiene el HL7v2.MRNExtractor. El archivo .txt se recoge mediante una simple definición de mapa de registros en la demostración. Ambos valores de entrada de MRN se transfieren al PatientRecordCollector BPL
* PatientRecordCollector BPL permite la orquestación de varios pasos. Su funcionamiento se basa en los siguientes pasos:
    1. Eliminar cualquier recurso existente en el *endpoint* local /fhirplace/r4 para el NHC del archivo de entrada. Esto asegura que no haya una duplicación accidental de datos dentro del repositorio FHIR
    2. Llamar al *endpoint* FHIR externo etiquetado EMREmulatorFHIRR4. El Service Registry apunta al extremo FHIRStarter /fhirstarter/r4. Hay dos llamadas a este *endpoint*:
        2. 1. Primero, una validación: "¿Tiene un paciente que coincida con el NHC de entrada?"
        2. 2. Si se encuentra un paciente, la segunda llamada es GET $everything contra el recurso Paciente. Esto devuelve un *searchset bundle* que debe cambiarse para guardarse en el repositorio de InterSystems IRIS for Health ™ FHIR
    3. Enviar el bubndle 'searchset' a BundleFlip BPL. Este componente realiza dos cambios importantes en el bundle
        3. 1. Cambiar el tipo de bundle de searchset a transaction y actualizar los subcampos necesarios para reflejar este cambio.
        3. 2. Cambiar todas las referencias de URL a recursos de /<RESOURCE>/<ID> a valores UUID. Hay que tener en cuenta que los valores /<RESOURCE>/<ID> en el bundle reflejarán los ID de recursos de *endpoints* externos y deben reemplazarse en InterSystems IRIS for Health 2020.4 y versiones anteriores. Cambiar estas referencias a UUID garantiza que el código FHIR de InterSystems IRIS for Health mantenga la integridad del paquete cuando se envía al punto final FHIR local.
    4. Envía el bundle al *endpoint* FHIR local, /fhirplace/r4

## Para la Demo
Una vez que se haya terminado la demo, los siguientes comandos van a detener cualquier contenedor que aún se esté ejecutando y eliminarlo. En el caso de que el arranque de la demo no se hay echo en modo Detached (--detach o -d), debemos debese para el container mediante CTRL+C en la consola donde se ejecuta. Tras hacerlo es necesario el siguiente comando:

```shell
docker exec -it fhir_interop_webinar_iris_1 bash
docker-compose down
```
Esto es particularmente útil si tiene otras demostraciones ejecutándose en la misma máquina.

