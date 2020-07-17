﻿using System;
using System.Collections.Generic;

namespace Enza.UTM.Entities.Results
{
    public class RequestSampleTest
    {
        public string Crop { get; set; }
        public string BrStation { get; set; }
        public string Country { get; set; }
        public string Level { get; set; }
        public string TestType { get; set; }
        public int RequestID { get; set; }
        public string RequestingSystem { get; set; }
        public int DeterminationID { get; set; }
        public int MaterialID { get; set; }
        public string Name { get; set; }
        public DateTime ExpectedResultDate { get; set; }
        public string MaterialStatus { get; set; }
    }

    public class Material
    {
        public int MaterialID { get; set; }
        public string Name { get; set; }
        public DateTime ExpectedResultDate { get; set; }
        public string MaterialStatus { get; set; }
        public int NrPlants { get; set; }
        public int InterfaceRefID { get; set; }
    }

    public class Determination
    {
        public int DeterminationID { get; set; }
        public List<Material> Materials { get; set; }
    }

    public class RequestSampleTestRequest
    {
        public string Crop { get; set; }
        public string BrStation { get; set; }
        public string Country { get; set; }
        public string Level { get; set; }
        public string TestType { get; set; }
        public int RequestID { get; set; }
        public string RequestingUser { get; set; }
        public string RequestingName { get; set; }
        public string RequestingSystem { get; set; }
        public List<Determination> Determinations { get; set; }
    }

    public class RequestSampleTestResult
    {
        public string Success { get; set; }
        public string ErrorMsg { get; set; }
    }
}
