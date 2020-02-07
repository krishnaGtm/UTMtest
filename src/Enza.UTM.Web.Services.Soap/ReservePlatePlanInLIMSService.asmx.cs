using System;
using System.Web.Services;
using System.CodeDom.Compiler;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using Autofac;
using Autofac.Integration.Web;
using Enza.UTM.BusinessAccess.Interfaces;
using System.Web;
using System.Web.Services.Description;
using System.Web.Services.Protocols;
using System.Xml.Schema;
using System.Xml.Serialization;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.Web.Services.Soap
{
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [WebServiceBinding(Name = "V01Obj", Namespace = "http://contract.enzazaden.com/UTM", ConformsTo = WsiProfiles.BasicProfile1_1)]
    public interface IV01Obj
    {
        [WebMethod]
        [SoapRpcMethod("", RequestNamespace = "http://contract.enzazaden.com/UTM/V01",
            ResponseNamespace = "http://contract.enzazaden.com/UTM/V01", Use = SoapBindingUse.Literal)]
        void ReservePlateplansInLIMSCallback(string SynchronisationCode, string RequestingUserID, int LIMSPlateplanID,
            string LIMSPlateplanName, string RequestingSystem, int RequestID,

            [XmlArrayItem("Plate", Form = XmlSchemaForm.Unqualified, IsNullable = false)]
            PlatesParamPlate[] Plates, out string Results);
    }

    /// <remarks/>
    [GeneratedCode("wsdl", "4.7.2558.0")]
    [Serializable]
    [DebuggerStepThrough]
    [DesignerCategory("code")]
    [XmlType(AnonymousType = true, Namespace = "http://contract.enzazaden.com/UTM/V01")]
    public class PlatesParamPlate
    {

        private int lIMSPlateIDField;

        private string lIMSPlateNameField;

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = false)]
        public int LIMSPlateID
        {
            get { return lIMSPlateIDField; }
            set { lIMSPlateIDField = value; }
        }

        /// <remarks/>
        [XmlElement(Form = XmlSchemaForm.Unqualified, IsNullable = true)]
        public string LIMSPlateName
        {
            get {return lIMSPlateNameField; }
            set { lIMSPlateNameField = value; }
        }
    }


    [WebService(Namespace = "http://contract.enzazaden.com/UTM")]
    public class V01Obj : WebService, IV01Obj
    {
        public ITestService TestService { get; set; }
        public V01Obj()
        {
            var cpa = (IContainerProviderAccessor)HttpContext.Current.ApplicationInstance;
            var cp = cpa.ContainerProvider;
            cp.RequestLifetime.InjectProperties(this);
        }
        public void ReservePlateplansInLIMSCallback(string SynchronisationCode, string RequestingUserID, int LIMSPlateplanID,
            string LIMSPlateplanName, string RequestingSystem, int RequestID, PlatesParamPlate[] Plates, out string Results)
        {
            Results = "Success";
            try
            {
                AsyncHelper.RunSync(() => TestService.ReservePlateplansInLIMSCallbackAsync(
                    new ReservePlateplansInLIMSCallbackRequestArgs
                    {
                        LIMSPlatePlanID = LIMSPlateplanID,
                        LIMSPlatePlanName = LIMSPlateplanName,
                        SyncCode = SynchronisationCode,
                        TestID = RequestID,
                        UserID = RequestingUserID,
                        Plates = Plates.Select(o => new Plate
                        {
                            LIMSPlateID = o.LIMSPlateID,
                            LIMSPlateName = o.LIMSPlateName
                        }).ToList()
                    }));
            }
            catch (Exception ex)
            {
                this.LogError(ex);
                Results = string.Concat("Failure: ", ex.Message);
            }
        }
    }
}

