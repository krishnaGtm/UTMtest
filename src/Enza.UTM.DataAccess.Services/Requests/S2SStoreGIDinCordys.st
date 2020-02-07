<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://contract.enzazaden.com/UTM/v1">
  <soapenv:Header/>
  <soapenv:Body>
    <v1:StoreGIDinCordys>
      <v1:records>
        $Model:{x|
        <v1:tuple>
          <v1:plantNumber>$x.PlantNr;format="xml"$</v1:plantNumber>
          <v1:gid>$x.GID$</v1:gid>
          <v1:masterNumber>$x.MasterNr;format="xml"$</v1:masterNumber>
          <v1:researchGroupId>$x.ResearchGroupID$</v1:researchGroupId>
        </v1:tuple>
        }$
      </v1:records>      
    </v1:StoreGIDinCordys>
  </soapenv:Body>
</soapenv:Envelope>