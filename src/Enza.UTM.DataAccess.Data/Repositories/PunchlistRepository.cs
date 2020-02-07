using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Results;
using ZXing;
using Enza.UTM.Common.Extensions;
using System.Text.RegularExpressions;
using System;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class PunchlistRepository : Repository<object>,IPunchlistRepository
    {
        public PunchlistRepository(IDatabase dbContext) : base(dbContext)
        {
        }

        public async Task<IEnumerable<Plate>> GetPunchlistAsync(int testID)
        {
            var p1 = DbContext.CreateOutputParameter("@PlatePlanID", DbType.Int32);
            var p2 = DbContext.CreateOutputParameter("@PlatePlanName", DbType.String,200);
            var p3 = DbContext.CreateOutputParameter("@SlotName", DbType.String, 200);
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_PUNCHLIST, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", testID);
                args.Add("@PlatePlanID", p1);
                args.Add("@PlatePlanName", p2);
                args.Add("@SlotName", p3);
            },
            reader=>new RawPlateData
            {
                PlateID = reader.Get<int>(0),
                PlateName = reader.Get<string>(1),
                MaterialKey = reader.Get<string>(2),
                //Position = reader.Get<string>(3),
                BgColor = reader.Get<string>(4),
                FgColor = reader.Get<string>(5),
                Row = reader.Get<string>(6),
                Column = reader.Get<int>(7),
                FileTitle = reader.Get<string>(8),
                Broken = false
            });
            var data1 = data.ToList();
            var count = data1.Count;
            int j = 0;
            for(int i=1; i<count; i++)
            {
                j = i - 1;
                if (data1[i].PlateID != data1[j].PlateID)
                    continue;
                if (string.IsNullOrWhiteSpace(data1[i].MaterialKey))
                    continue;
                if (data1[i].MaterialKey?.ToText().Trim().ToLower() == "qc")
                    continue;                
                while(data1[j].MaterialKey?.ToText().Trim().ToLower() == "qc")
                {
                    j--;
                    if (j == 0)
                        break;
                }
                var value1 = Regex.Replace(data1[i].MaterialKey == null ? "1" : data1[i].MaterialKey, "[^0-9]+", string.Empty);
                var value2 = Regex.Replace(data1[j].MaterialKey == null ? "0" : data1[j].MaterialKey, "[^0-9]+", string.Empty);

                Int64 diff = 0;
                if (!string.IsNullOrWhiteSpace(value1) && !string.IsNullOrWhiteSpace(value2))
                {
                    diff = Convert.ToInt64(value1) - Convert.ToInt64(value2);
                    if (diff == 0 || diff == 1)
                    {
                        //do nothing
                    }
                    else
                        data1[i].Broken = true;
                }
                else
                {
                    data1[i].Broken = true;
                }                
            }
            return data.GroupBy(g => new
            {
                g.PlateID, g.PlateName
            }).Select(x => new Plate
            {
                PlateID = x.Key.PlateID,
                PlateName = x.Key.PlateName,
                BarCode = GetBarCode(x.Key.PlateID.ToString()),
                TotalColumns = x.Max(c => c.Column),
                PlatePlanBarCode = GetBarCode(p1.Value.ToInt32().ToText()),
                PlatePlanName = p2.Value.ToText(),
                SlotName = p3.Value.ToText(),
                FileTitle = x.Select(a => a.FileTitle).FirstOrDefault(),
                Rows = x.GroupBy(g => g.Row)
                .Select(y => new Row
                {
                    RowID = y.Key,
                    Cells = y.Select(z => new Cell
                    {
                        BgColor = z.BgColor,
                        Column = z.Column,
                        MaterialKey = z.MaterialKey,
                        FgColor = z.FgColor,
                        Broken = z.Broken
                    }).OrderBy(a => a.Column).ToList()
                }).OrderBy(a => a.RowID).ToList()
            }).OrderBy(a=>a.PlateID);
        }

        private string GetBarCode(string plateName)
        {
            var writer = new BarcodeWriterSvg
            {
                Format = BarcodeFormat.CODE_128,
                Options = new ZXing.Common.EncodingOptions
                {
                    Width = 200,
                    Height = 100
                }
            };
            return writer.Write(plateName).Content;
        }
    }
}
