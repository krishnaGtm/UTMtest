<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bpm="http://schemas.enzazaden.com/domain/3gb/bpm">
  <soapenv:Header/>
  <soapenv:Body>
    <bpm:GetAvailable3GBProjects>
      <bpm:Crop>$Model.CropCode$</bpm:Crop>
      <bpm:BreedingProject>$Model.BrStationCode$</bpm:BreedingProject>
      <bpm:ThreeGBType>$Model.ThreeGBType$</bpm:ThreeGBType>
    </bpm:GetAvailable3GBProjects>
  </soapenv:Body>
</soapenv:Envelope>