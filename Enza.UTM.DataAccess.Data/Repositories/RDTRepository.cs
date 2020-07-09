using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Services.Proxies;
using System.Net;
using System.Net.Http;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Common.Exceptions;
using System.Linq;
using Enza.UTM.Common;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class RDTRepository : Repository<object>, IRDTRepository
    {
        private readonly IUserContext userContext;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        public RDTRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

    }
    
}
