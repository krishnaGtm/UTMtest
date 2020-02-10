using System;
using System.Linq;
using System.Reflection;
using Swashbuckle.Swagger;

namespace Enza.UTM.Common.Attributes
{
    [AttributeUsage(AttributeTargets.Property)]
    public class SwaggerExcludeAttribute : Attribute
    {
    }


    public class SwaggerExcludeFilter : ISchemaFilter
    {
        #region ISchemaFilter Members

        public void Apply(Schema schema, SchemaRegistry schemaRegistry, Type type)
        {
            if (schema?.properties == null || type == null)
                return;

            var properties = schema.properties.Select(o => o.Key).ToList();
            var excludedProperties = type.GetProperties().Where(t => t.GetCustomAttribute<SwaggerExcludeAttribute>() != null);
            foreach (var excludedProperty in excludedProperties)
            {
                var propertyName = properties.FirstOrDefault(o => string.Compare(o, excludedProperty.Name, StringComparison.OrdinalIgnoreCase) == 0);
                if (propertyName == null)
                    continue;

                schema.properties.Remove(propertyName);
            }
        }

        #endregion
    }
}