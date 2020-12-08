using Autofac;
using Autofac.Integration.Web;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;
using System;
using System.CodeDom.Compiler;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Services.Description;
using System.Web.Services.Protocols;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace Enza.UTM.Web.Services.Soap
{
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [WebServiceBinding(Name = "V01Obj", Namespace = "http://contract.enzazaden.com/UTM", ConformsTo = WsiProfiles.BasicProfile1_1)]
    public interface IReceiveResultsinKscoreService
    {
        [WebMethod]
        [SoapRpcMethod("",
            RequestNamespace = "http://contract.enzazaden.com/UTM/V01",
            ResponseNamespace = "http://contract.enzazaden.com/UTM/V01",
            Use = SoapBindingUse.Literal)]
        void ReceiveResultsinKscore(string RequestingUserID, string RequestingUserName, string RequestingSystem,
            int RequestID, int LimsPlateplanID, string LimsPlateplanStatus,
            [XmlArrayItem("Plate", Form = XmlSchemaForm.Unqualified,
                IsNullable = false)] KscorePlate[] Plates, out string Results);
    }

    [WebService(Namespace = "http://contract.enzazaden.com/UTM")]
    public class ReceiveResultsinKscoreService : WebService, IReceiveResultsinKscoreService
    {
        public ITestService TestService { get; set; }
        public ReceiveResultsinKscoreService()
        {
            var cpa = (IContainerProviderAccessor)HttpContext.Current.ApplicationInstance;
            var cp = cpa.ContainerProvider;
            cp.RequestLifetime.InjectProperties(this);
        }
        public void ReceiveResultsinKscore(string RequestingUserID, string RequestingUserName, string RequestingSystem,
            int RequestID, int LimsPlateplanID, string LimsPlateplanStatus, KscorePlate[] Plates,
            out string Results)
        {
            Results = "Success";
            try
            {                
                AsyncHelper.RunSync(() => TestService.ReserveScoreResult(
                    new ReceiveScoreArgs
                    {
                        RequestID = RequestID,
                        ScoreResults = Plates.SelectMany(x => x.Wells.SelectMany(y => y.Markers.Select(z => new ScoreResultData
                        {
                            LimsPlateID = x.LimsPlateID,
                            Position = y.PlateRow + $"{y.PlateColumn:00}",
                            Determination = z.MarkerNr,
                            ScoreVal = z.Scores.FirstOrDefault()?.AlleleScore
                        }))).ToList()

            }));
            }
            catch(Exception e)
            {
                this.LogError(e);
                Results = string.Concat("Failure: ", e.Message);
            }
            

        }
    }


    /// <remarks/>
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [Serializable]
    [DebuggerStepThrough]
    [DesignerCategory("code")]
    [XmlType(AnonymousType = true, Namespace = "http://contract.enzazaden.com/UTM/V01")]
    public class KscorePlate
    {

        private int? limsPlateIDField;

        private string limsPlateNameField;

        private int? plateNrField;

        private KscoreWell[] wellsField;

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public int? LimsPlateID
        {
            get
            {
                return limsPlateIDField;
            }
            set
            {
                limsPlateIDField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string LimsPlateName
        {
            get
            {
                return limsPlateNameField;
            }
            set
            {
                limsPlateNameField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public int? PlateNr
        {
            get
            {
                return plateNrField;
            }
            set
            {
                plateNrField = value;
            }
        }

        /// <remarks/>
        [XmlArray(Form = XmlSchemaForm.Unqualified)]
        [XmlArrayItem("Well", typeof(KscoreWell), Form = XmlSchemaForm.Unqualified, IsNullable = false)]
        public KscoreWell[] Wells
        {
            get
            {
                return wellsField;
            }
            set
            {
                wellsField = value;
            }
        }
    }

    /// <remarks/>
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [Serializable]
    [DebuggerStepThrough]
    [DesignerCategory("code")]
    [XmlType(AnonymousType = true, Namespace = "http://contract.enzazaden.com/UTM/V01")]
    public class KscoreWell
    {

        private string plateRowField;

        private int? plateColumnField;

        private int? plantNrField;

        private string breedingStationCodeField;

        private KscoreMarker[] markersField;

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string PlateRow
        {
            get
            {
                return plateRowField;
            }
            set
            {
                plateRowField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public int? PlateColumn
        {
            get
            {
                return plateColumnField;
            }
            set
            {
                plateColumnField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public int? PlantNr
        {
            get
            {
                return plantNrField;
            }
            set
            {
                plantNrField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string BreedingStationCode
        {
            get
            {
                return breedingStationCodeField;
            }
            set
            {
                breedingStationCodeField = value;
            }
        }

        /// <remarks/>
        [XmlArray(Form = XmlSchemaForm.Unqualified)]
        [XmlArrayItem("Marker", typeof(KscoreMarker), Form = XmlSchemaForm.Unqualified, IsNullable = false)]
        public KscoreMarker[] Markers
        {
            get
            {
                return markersField;
            }
            set
            {
                markersField = value;
            }
        }
    }

    /// <remarks/>
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [Serializable]
    [DebuggerStepThrough]
    [DesignerCategory("code")]
    [XmlType(AnonymousType = true, Namespace = "http://contract.enzazaden.com/UTM/V01")]
    public class KscoreMarker
    {

        private int? markerNrField;

        private KscoreScore[] scoresField;

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public int? MarkerNr
        {
            get
            {
                return markerNrField;
            }
            set
            {
                markerNrField = value;
            }
        }

        /// <remarks/>
        [XmlArray(Form = XmlSchemaForm.Unqualified)]
        [XmlArrayItem("Score", typeof(KscoreScore), Form = XmlSchemaForm.Unqualified, IsNullable = false)]
        public KscoreScore[] Scores
        {
            get
            {
                return scoresField;
            }
            set
            {
                scoresField = value;
            }
        }
    }

    /// <remarks/>
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [Serializable]
    [DebuggerStepThrough]
    [DesignerCategory("code")]
    [XmlType(AnonymousType = true, Namespace = "http://contract.enzazaden.com/UTM/V01")]
    public class KscoreScore
    {

        private string creationDateField;

        private string alleleScoreField;

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string CreationDate
        {
            get
            {
                return creationDateField;
            }
            set
            {
                creationDateField = value;
            }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string AlleleScore
        {
            get
            {
                return alleleScoreField;
            }
            set
            {
                alleleScoreField = value;
            }
        }
    }
}