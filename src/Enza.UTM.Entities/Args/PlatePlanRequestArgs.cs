﻿using System.Collections.Generic;
using System.Data;
using System.Linq;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class PlatePlanRequestArgs : PagedRequestArgs
    {
        public string Crops { get; set; }

    }
}
