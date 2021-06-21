Class Webinar.Change Extends Ens.BusinessProcess
{

/// Description
Property TargetConfigName As Ens.DataType.ConfigName;

Parameter SETTINGS = "TargetConfigName";

Method OnRequest(pInput As HS.FHIRServer.Interop.Request, Output pOutput As HS.FHIRServer.Interop.Response) As %Status
{
    set tSC=$$$OK
    #Dim tResponse As HS.FHIRServer.Interop.Response
    Set tStatus = ..SendRequestSync(..TargetConfigName, pInput, .pOutput, 5)
    If ($$$ISERR(tStatus)) Return tStatus

    
    //Identify payload as a Patient resource and convert to dynamic object
    if ((pInput.Request.RequestMethod="GET") & (pInput.Request.RequestPath["Patient")){
        set stream = ##class(HS.SDA3.QuickStream).%OpenId(pOutput.QuickStreamId)
        $$$TRACE("QuickStream Size: "_stream.SizeGet())
        set tPatient = ##class(%DynamicObject).%FromJSON(stream)

        // Modify Patient resource
        do tPatient.%Set("gender","unknown")
        do tPatient.%Remove("name")
        //if $isobject(tPatient.name) && (tPatient.name.%Size() > 0) {
        //    set tFamilyname = tPatient.name.%Get(0).family
        //    $$$TRACE("Family Name: "_tFamilyname)
        //    do tPatient.name.%Set("family","XXX")
        //}   
        //do tPatient.%Set("active", 0, "boolean")
        
        //set outFile=##class(%File).%New("/irisdev/app/patient.json")
        //set sc=outFile.Open("WSN")
        //do tPatient.%ToJSON(outFile)
        //do outFile.Close()


        //Update payload with modified Patient resource
        set newstream=##class(HS.SDA3.QuickStream).%New()
        do tPatient.%ToJSON(newstream)
        set tSC=newstream.%Save() 
        set pOutput.QuickStreamId=newstream.%Id()
    }
        quit tSC
}

Storage Default
{
<Data name="ChangeDefaultData">
<Subscript>"Change"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
</Data>
<DefaultData>ChangeDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
