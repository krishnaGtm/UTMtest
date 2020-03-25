using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Args
{
    public class DeleteSlotRequestArgs
    {
        public int SlotID { get; set; }
        public bool IsSuperUser { get; set; }
        /// <summary>
        /// comma separated crop
        /// </summary>
        public string Crops { get; set; }
    }
}
