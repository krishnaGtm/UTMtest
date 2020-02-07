using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;

namespace Enza.UTM.Web.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var services = new Dictionary<string, string>
            {
                {"API_BASE_URL", ConfigurationManager.AppSettings["BaseServiceUrl"]},
                {"API_BASE_PLANNING_URL", ConfigurationManager.AppSettings["BasePlanningServiceUrl"]},
                {"API_TOKEN_URL", ConfigurationManager.AppSettings["UserServiceURL"]},
                {"PHENOME_BASE_URL", ConfigurationManager.AppSettings["BasePhenomeServiceUrl"]}
            };
            ViewBag.Services = JsonConvert.SerializeObject(services);
            return View();
        }


        //sign in as different user in windows authentication
        [AllowAnonymous]
        public ActionResult Logout()
        {
            var cookie = Request.Cookies["TSWA-Last-User"];
            if (User.Identity.IsAuthenticated == false || cookie == null || StringComparer.OrdinalIgnoreCase.Equals(User.Identity.Name, cookie.Value))
            {
                var name = string.Empty;
                if (Request.IsAuthenticated)
                {
                    name = User.Identity.Name;
                }
                cookie = new HttpCookie("TSWA-Last-User", name);
                Response.Cookies.Set(cookie);

                Response.AppendHeader("Connection", "close");
                Response.StatusCode = 401; // Unauthorized;
                Response.Clear();
                //should probably do a redirect here to the unauthorized/failed login page
                //if you know how to do this, please tap it on the comments below
                Response.Write("Unauthorized. Reload the page to try again...");
                Response.End();
                return RedirectToAction("Index");
            }
            cookie = new HttpCookie("TSWA-Last-User", string.Empty)
            {
                Expires = DateTime.Now.AddYears(-5)
            };
            Response.Cookies.Set(cookie);
            return RedirectToAction("Index");
        }
    }
}
