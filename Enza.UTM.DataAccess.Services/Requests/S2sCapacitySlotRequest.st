<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://contract.enzazaden.com/seed2seed/v1">
  <soapenv:Header/>
  <soapenv:Body>
    <v1:getOpenCapacitySlotsFromMasterPlanningRequest>
      <v1:BreEzysAdministration>$Model.BreEzysAdministration$</v1:BreEzysAdministration>
      <v1:Year>$Model.Year$</v1:Year>
      <v1:Crop>$Model.Crop$</v1:Crop>
      <v1:Source>$Model.Source$</v1:Source>
      <v1:CapacitySlotID>$Model.CapacitySlotID$</v1:CapacitySlotID>
    </v1:getOpenCapacitySlotsFromMasterPlanningRequest>
  </soapenv:Body>
</soapenv:Envelope>