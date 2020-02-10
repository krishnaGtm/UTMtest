using System;
using System.Globalization;
using System.Security;

namespace Enza.UTM.Common
{
    public class Template
    { 
        public static string Render(string template, object model)
        {
            //var tpl = new Antlr4.StringTemplate.Template(template, '$', '$');
            //tpl.Add("Model", model);
            //return tpl.Render();
            var group = new Antlr4.StringTemplate.TemplateGroup('$', '$');
            var tpl = new Antlr4.StringTemplate.Template(group, template);
            //register renderer for additional formatting from st file.
            group.RegisterRenderer(typeof(string), new StringAttributeRenderer());

            tpl.Add("Model", model);
            return tpl.Render();
        }
    }

    public class StringAttributeRenderer : Antlr4.StringTemplate.IAttributeRenderer
    {
        public string ToString(object obj, string formatString, CultureInfo culture)
        {
            if (obj == null || obj == DBNull.Value)
                return string.Empty;

            var value = obj.ToString();
            if (!string.IsNullOrWhiteSpace(formatString))
            {
                if(string.Compare(formatString, "xml", true) == 0)
                {
                    return SecurityElement.Escape(value);
                }
            }
            return value;
        }
    }
}
