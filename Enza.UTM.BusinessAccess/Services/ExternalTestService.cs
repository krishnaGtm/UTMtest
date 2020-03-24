using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using NPOI.XSSF.UserModel;

namespace Enza.UTM.BusinessAccess.Services
{
    public class ExternalTestService : IExternalTestService
    {
        readonly IExternalTestRepository _externalTestRepository;
        readonly ITestService _testService;
        public ExternalTestService(IExternalTestRepository externalTestRepository,ITestService testService)
        {
            _externalTestRepository = externalTestRepository;
            _testService = testService;
        }
        public async Task<ImportDataResult> ImportDataAsync(ExternalTestImportRequestArgs requestArgs)
        {
            var result = new ImportDataResult();
            var xssfwb = new XSSFWorkbook(requestArgs.DataStream);
            var sheet = xssfwb.GetSheetAt(0);
            var headerRow = sheet.GetRow(0);

            var countryRequiredTestTypeIDs = new[] { TestTypes.MARKER_2GB_TEST, TestTypes.DNA_ISOLATION };
            var countryRequired = (countryRequiredTestTypeIDs.Contains(requestArgs.TestTypeID));

            var validColumns = new List<string> { "Numerical ID", "Sample Name" };
            if (countryRequired)
            {
                validColumns.Add("Country");
            }
            var headers = new Dictionary<int, string>();
            //read headers from excel's first row
            if (headerRow == null)
            {
                result.Errors.Add("Invalid file format. Header information is missing.");
                return result;
            }
            for (int i = 0; i < headerRow.LastCellNum; i++)
            {
                var headerText = headerRow.GetCell(i)?.ToText().Trim();
                if (!string.IsNullOrWhiteSpace(headerText))
                    headers.Add(i, headerText);
            }
            //validate headers 
            if (validColumns.Any(validColumn => !headers.Any(o => o.Value.EqualsIgnoreCase(validColumn))))
            {
                var missingFields = validColumns.Where(x => !headers.Select(y => y.Value).Contains(x, StringComparer.OrdinalIgnoreCase));
                result.Errors.Add($"Missing mandatory fields: {string.Join(", ", missingFields) }");
                return result;
            }

            #region Preapare TVP

            var dtRowTVP = new DataTable("TVP_Row");
            dtRowTVP.Columns.Add("RowNr", typeof(int));
            dtRowTVP.Columns.Add("MaterialKey", typeof(string));
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("EntryCode");

            var dtColumnsTVP = new DataTable("TVP_Column");
            dtColumnsTVP.Columns.Add("ColumnNr", typeof(int));
            dtColumnsTVP.Columns.Add("TraitID", typeof(int));
            dtColumnsTVP.Columns.Add("ColumnLabel", typeof(string));
            dtColumnsTVP.Columns.Add("DataType", typeof(string));

            var dtCellTVP = new DataTable("TVP_Cell");
            dtCellTVP.Columns.Add("RowID", typeof(int));
            dtCellTVP.Columns.Add("ColumnID", typeof(int));
            dtCellTVP.Columns.Add("Value", typeof(string));

            #endregion

            foreach (var header in headers.OrderBy(x => x.Key))
            {
                //ignore country column since it is stored in test table. so we are not storing it in column and cell table.
                var columnName = "";
                switch (header.Value.ToLower())
                {
                    case "numerical id":
                        columnName = "GID";
                        break;
                    case "sample name":
                        columnName = "Plant Name";
                        break;
                    default:
                        columnName = header.Value;
                        break;
                }
                if (header.Value.EqualsIgnoreCase("Country"))
                    continue;
                dtColumnsTVP.Rows.Add(header.Key, null, columnName, "NVARCHAR(255)");
            }
            var columns = headers.ToList();
            var totalCols = headerRow.LastCellNum;
            bool breakLoop = false;
            for (var i = 1; i <= sheet.LastRowNum; i++)
            {
                if (breakLoop)
                    break;
                var row = sheet.GetRow(i);
                if (row != null)
                {
                    var rowNr = i - 1;

                    var drRow = dtRowTVP.NewRow();
                    drRow["RowNr"] = rowNr;
                    for (var j = 0; j < columns.Count; j++)
                    {
                        var column = columns[j];
                        var cellValue = row.GetCell(column.Key).ToText().Trim();
                        if (column.Value.EqualsIgnoreCase("Numerical ID"))
                        {
                            //validate if material key is empty
                            if (string.IsNullOrWhiteSpace(cellValue))
                            {
                                breakLoop = true;
                                break;
                            }
                            else
                                drRow["MaterialKey"] = cellValue;                            
                        }
                        else if (column.Value.EqualsIgnoreCase("Sample name"))
                        {
                            //validate if plant name is empty
                            if (string.IsNullOrWhiteSpace(cellValue))
                            {
                                breakLoop = true;
                                break;
                            }
                        }
                        else if (column.Value.EqualsIgnoreCase("Country"))
                        {
                            if (countryRequired)
                            {
                                //validate if country is empty
                                if (string.IsNullOrWhiteSpace(cellValue))
                                {
                                    breakLoop = true;
                                    break;
                                }
                            }
                            //only one country code is enough since it will be passed as single data in sp
                            if (string.IsNullOrWhiteSpace(requestArgs.CountryCode))
                            {
                                requestArgs.CountryCode = cellValue;
                            }
                        }
                        //we don't need to send country information in cell. We already send it for test.
                        if (!column.Value.EqualsIgnoreCase("Country") && !string.IsNullOrWhiteSpace(cellValue))
                        {
                            //get value for celltvp
                            var drCell = dtCellTVP.NewRow();
                            drCell["RowID"] = rowNr;
                            drCell["ColumnID"] = j;
                            drCell["Value"] = cellValue;
                            dtCellTVP.Rows.Add(drCell);
                        }
                    }
                    dtRowTVP.Rows.Add(drRow);
                }
            }
            await _externalTestRepository.ImportDataAsync(requestArgs, dtColumnsTVP, dtRowTVP, dtCellTVP);

            return result;
        }

        public async Task<byte[]> GetExcelFileForExternalTestAsync(int testID, bool markAsExported = false)
        {
            //get det
            var initialTestDetail = await _testService.GetTestDetailAsync(new GetTestDetailRequestArgs
            {
                TestID = testID
            });

            var rs = await _externalTestRepository.GetExternalTestDataForExportAsync(testID, markAsExported);
            
            //get test detail including status and other required information
            var testDetail = await _externalTestRepository.GetExternalTestDetail(testID);
            if (testDetail != null && testDetail.StatusCode != initialTestDetail.StatusCode)
            {
                await _testService.SendTestCompletionEmailAsync(testDetail.CropCode, testDetail.BreedingStationCode, testDetail.LabPlatePlanName);
            }
            
            using (var ms = new MemoryStream())
            {
                var book = new XSSFWorkbook();
                var sheet = book.CreateSheet("Sheet1");
                //add header row
                var header = sheet.CreateRow(0);
                for (var i = 0; i < rs.Columns.Count; i++)
                {
                    var column = rs.Columns[i];
                    var cell = header.CreateCell(i);
                    cell.SetCellValue(column.ColumnLabel);
                }
                //add data rows
                var rowNr = 1;
                foreach (DataRow dr in rs.Data.Rows)
                {
                    var row = sheet.CreateRow(rowNr++);
                    for (var i = 0; i < rs.Columns.Count; i++)
                    {
                        var column = rs.Columns[i];
                        var cell = row.CreateCell(i);
                        cell.SetCellValue(dr[column.ColumnID].ToText());
                    }
                }
                book.Write(ms);

                return ms.ToArray();
            }
        }

        public Task<DataTable> GetExternalTestsLookupAsync(string cropCode, string brStationCode, bool showAll)
        {
            return _externalTestRepository.GetExternalTestsLookupAsync(cropCode, brStationCode, showAll);
        }
    }
}
