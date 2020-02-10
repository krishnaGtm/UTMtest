<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:seed="http://schemas.enzazaden.com/domain/seed2seed">
  <soapenv:Header/>
  <soapenv:Body>
    <seed:GetProgramCodesByCrop preserveSpace="no" qAccess="0" qValues="">
      <seed:Crop>$Model.crop$</seed:Crop>
    </seed:GetProgramCodesByCrop>
  </soapenv:Body>
</soapenv:Envelope>