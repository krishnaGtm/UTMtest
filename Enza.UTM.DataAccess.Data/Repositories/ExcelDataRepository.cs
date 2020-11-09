using System;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using NPOI.SS.UserModel;
using NPOI.XSSF.Model;
using NPOI.XSSF.UserModel;
using System.Configuration;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class ExcelDataRepository : Repository<object>, IExcelDataRepository
    {
        private readonly IUserContext userContext;

        public ExcelDataRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<ExcelDataResult> ExportExcelDataToDBAsync(ImportDataRequestArgs requestArgs)
        {
            var tcs = new TaskCompletionSource<ExcelDataResult>();
            try
            {
                var result = new ExcelDataResult();
                var xssfwb = new XSSFWorkbook(requestArgs.DataStream);
                var sheet = xssfwb.GetSheetAt(0);
                var screeningNr = sheet.GetRow(0);
                var headerText = sheet.GetRow(1);

                var stylesTable = xssfwb.GetStylesSource();
                /*var cell = sheet.GetRow(1).GetCell(4);
                var stylesTable = xssfwb.GetStylesSource();
                var name = stylesTable.GetCellStyleName(cell);
                */

                if (screeningNr == null || headerText == null)
                {
                    result.Errors.Add("Invalid Excel format.");
                    result.Success = false;
                    return result;
                }
                var cropRow = sheet.GetRow(3);
                var crop = string.Empty;
                var syncCode = string.Empty;
                var breedingStation = string.Empty;
                if (cropRow == null)
                {
                    result.Success = false;
                    result.Errors.Add("No Crop Record Found.");
                    return result;
                }

                for (int i = 0; i < headerText.Cells.Count; i++)
                {
                    if (headerText.GetCell(i).ToText().ToLower() == "crop" ||
                        headerText.GetCell(i).ToText().ToLower() == "cropcode")
                    {
                        crop = cropRow.GetCell(i)?.ToString();
                    }
                    if (headerText.GetCell(i).ToText().ToLower().Trim() == "brstation")
                    {
                        breedingStation = cropRow.GetCell(i)?.ToString();                       
                    }
                    if(!string.IsNullOrWhiteSpace(crop) && !string.IsNullOrWhiteSpace(breedingStation))
                    {
                        break;
                    }
                }
                if (string.IsNullOrWhiteSpace(crop))
                {
                    result.Success = false;
                    result.Errors.Add("No Crop Record Found.");
                    return result;
                }
                if (string.IsNullOrWhiteSpace(breedingStation))
                {
                    result.Success = false;
                    result.Errors.Add("No breeding station found.");
                    return result;
                }

                var dtRowTVP = new DataTable("TVP_Row");
                var dtColumnsTVP = new DataTable("TVP_Column");
                var dtCellTVP = new DataTable("TVP_Cell");
                var dtListTVP = new DataTable("TVP_List");

                //prepare list tvp which is only needed for importing data from phenome
                dtListTVP.Columns.Add("RowID");
                dtListTVP.Columns.Add("GID");
                dtListTVP.Columns.Add("EntryCode");

                //prepare columns
                PrepareColumnTableTVP(dtColumnsTVP, headerText, stylesTable, screeningNr);
                var coldata = dtColumnsTVP.AsEnumerable().Select(x => new
                {
                    ColName = x.IsNull("TraitID") ? x["ColumnLabel"] : x["TraitID"]
                }).AsEnumerable().Select(x => x.ColName).GroupBy(g => g).Select(x => new
                {
                    ColVal = x.Key,
                    Count = x.Count()
                }).Where(x => x.Count > 1);

                if (coldata.Any())
                {
                    var keylist = coldata.Select(x => x.ColVal.ToText()).ToList();
                    var key = keylist.Truncate();                   
                    result.Errors.Add($"Duplicate Column {key}");
                }
                result.Success = !result.Errors.Any();
                if (!result.Success)
                    return result;

                //this validation is removed as per client request, and query is adjusted on returning multiple traitname for same determination ID.
                //var columnvalidations = await ValidateColumnsForUniqueDeterminations(dtColumnsTVP, crop, requestArgs.Source);
                //if (columnvalidations.Tables[0].Rows.Count > 0)
                //{
                //    result.Success = false;
                //    foreach (DataRow _value in columnvalidations.Tables[0].Rows)
                //    {
                //        result.Errors.Add("Multiple determination applied for Trait " + _value["Traits"]);
                //    }
                //    return result;
                //}
                
                var lastRow = sheet.LastRowNum + 1; //this is because RowNum starts from 0 not from 1.
                if (lastRow - 2 > ConfigurationManager.AppSettings["App:MaxNoOfRecords"].ToInt64()) //first two rows data are meta data and should be ignored while importing it so value 2 is subtracted.
                {
                    result.Errors.Add("Cannot import excel file having rows greater than "+ ConfigurationManager.AppSettings["App:MaxNoOfRecords"]);
                    result.Success = false;
                    return result;
                }
                //Prepare rows and cell values
                PrepareRowAndCellTVP(dtRowTVP, dtCellTVP, headerText, stylesTable, sheet, result);
                var data = dtRowTVP.AsEnumerable().Select(x => x.Field<string>("MaterialKey"))
                    .GroupBy(g => g)
                    .Select(
                        x => new
                        {
                            MaterialKey = x.Key,
                            Count = x.Count()
                        });

                if (data.Any(x => x.MaterialKey.ToText() == string.Empty))
                {
                    result.Errors.Add("Material Key cannot be null or empty");
                }
                var material = data.FirstOrDefault();
                if(material != null)
                {
                    syncCode = material.MaterialKey?.Substring(0, 2);
                }
                if(string.IsNullOrWhiteSpace(syncCode))
                {
                    result.Errors.Add("SyncCode cannot be null or empty");
                }
                var keys = data.Where(x => x.Count > 1);
                if (keys.Any())
                {                    
                    var keylist = keys.Select(x => x.MaterialKey).ToList();
                    var key = keylist.Truncate();
                    result.Errors.Add($"Duplicate Material key {key}");
                }
                result.Success = !result.Errors.Any();
                if (result.Success)
                {
                    await ImportDataAsync(crop, breedingStation, syncCode, string.Empty, requestArgs, dtColumnsTVP, dtRowTVP, dtCellTVP,dtListTVP);                   

                    tcs.SetResult(await GetDataAsync(requestArgs));
                }
                else
                    tcs.SetResult(result);
            }
            catch (Exception ex)
            {
                tcs.SetException(ex);
            }
            return await tcs.Task;
        }

        public async Task ImportDataAsync(string crop, string breedingStation,string syncCode, string countryCode, ImportDataRequestArgs requestArgs, 
            DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP, DataTable dtListTVP)
        {
            var p1 = DbContext.CreateOutputParameter("@TestID", DbType.Int32);
            DbContext.CommandTimeout = 5 * 60; //5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_INSERT_EXCEL_DATA,
                CommandType.StoredProcedure, args1 =>
                {
                    args1.Add("@CropCode", crop);
                    args1.Add("@BreedingStationCode", breedingStation);
                    args1.Add("@SyncCode", syncCode);
                    args1.Add("@CountryCode", countryCode);
                    args1.Add("@TestTypeID", requestArgs.TestTypeID);
                    args1.Add("@UserID", userContext.GetContext().FullName);
                    args1.Add("@FileTitle", requestArgs.FilePath);
                    args1.Add("@TVPColumns", dtColumnsTVP);
                    args1.Add("@TVPRow", dtRowTVP);
                    args1.Add("@TVPCell", dtCellTVP);
                    args1.Add("@TestID", p1);
                    args1.Add("@PlannedDate", requestArgs.PlannedDate);
                    args1.Add("@MaterialStateID", requestArgs.MaterialStateID);
                    args1.Add("@MaterialTypeID", requestArgs.MaterialTypeID);
                    args1.Add("@ContainerTypeID", requestArgs.ContainerTypeID);
                    args1.Add("@Isolated", requestArgs.Isolated);
                    args1.Add("@Source", requestArgs.Source);
                    args1.Add("@TestName", requestArgs.TestName);
                    args1.Add("@ObjectID", requestArgs.ObjectID);
                    args1.Add("@ExpectedDate", requestArgs.ExpectedDate);
                    args1.Add("@Cumulate", requestArgs.Cumulate);
                    args1.Add("@ImportLevel", requestArgs.ImportLevel);
                    args1.Add("@TVPList", dtListTVP);
                    args1.Add("@ExcludeControlPosition", requestArgs.ExcludeControlPosition);
                    args1.Add("@SiteID", requestArgs.SiteID);
                    args1.Add("@FileID", requestArgs.FileID);
                });
            requestArgs.TestID = p1.Value.ToInt32();
        }

        public async Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs)
        {
            var result = new ExcelDataResult();
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_DATA, CommandType.StoredProcedure,
                args1 =>
                {
                    args1.Add("@TestID", requestArgs.TestID);
                    //args1.Add("@User", userContext.GetContext().FullName);
                    args1.Add("@Page", requestArgs.PageNumber);
                    args1.Add("@PageSize", requestArgs.PageSize);
                    args1.Add("@FilterQuery", requestArgs.ToFilterString());
                });
            if (data.Tables.Count == 2)
            {
                result.Success = true;
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                if (table0.Columns.Contains("Total"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.TotalCount = table0.Rows[0]["Total"].ToInt32();
                    }
                    table0.Columns.Remove("Total");
                }
                result.DataResult = new ExcelData
                {
                    Columns = data.Tables[1],
                    Data = table0
                };
            }
            else
            {
                result.Success = false;
                result.Errors.Add("Problem while fetching data.");
            }
            return result;
        }

        private void PrepareRowAndCellTVP(DataTable dtRowTVP, DataTable dtCellTVP, IRow headerText,
            StylesTable stylesTable, ISheet sheet, ExcelDataResult result)
        {
            int rowindex = 2;
            var lastRow = sheet.LastRowNum;
            dtRowTVP.Columns.Add("RowNr");
            dtRowTVP.Columns.Add("MaterialKey");
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("EntryCode");

            dtCellTVP.Columns.Add("RowID");
            dtCellTVP.Columns.Add("ColumnID");
            dtCellTVP.Columns.Add("Value");
            while (rowindex <= lastRow)
            {
                var row = sheet.GetRow(rowindex);
                if (row != null)
                {
                    var drRow = dtRowTVP.NewRow();
                    drRow["RowNr"] = rowindex - 1;

                    for (int i = 0; i < headerText.LastCellNum; i++)
                    {
                        var headerVal = headerText.GetCell(i).ToText().Trim();
                        if (!string.IsNullOrWhiteSpace(headerVal))
                        {
                            if ((headerVal.ToLower() == "gid" || headerVal.ToLower() == "crop" ||
                                 headerVal.ToLower() == "cropcode") &&
                                string.IsNullOrWhiteSpace(row.GetCell(i).ToText().Trim()))
                                return;
                            if (headerVal.ToLower() == "gid")
                            {
                                var materialKey = row.GetCell(i).ToText().Trim();
                                drRow["MaterialKey"] = materialKey;
                            }
                            var cellValue = row.GetCell(i).ToText().Trim();
                            if (string.IsNullOrWhiteSpace(cellValue))
                                continue;
                            var drCell = dtCellTVP.NewRow();
                            drCell["RowID"] = rowindex - 1;
                            drCell["ColumnID"] = i;
                            var dataType = stylesTable.GetCellStyleName(headerText.GetCell(i)).ToLower();
                            switch (dataType)
                            {
                                case "character":
                                    drCell["Value"] = cellValue;
                                    break;
                                case "decimal":
                                    if (string.IsNullOrWhiteSpace(cellValue))
                                    {
                                        drCell["Value"] = null;
                                    }
                                    else if (decimal.TryParse(cellValue, out decimal decVal))
                                    {
                                        drCell["Value"] = decVal;
                                    }
                                    else
                                    {
                                        result.Success = false;
                                        AddError(result, "Value is not in correct decimal format.", rowindex, i);
                                    }
                                    break;
                                case "date":
                                case "datetime":
                                    if (string.IsNullOrWhiteSpace(cellValue))
                                    {
                                        drCell["Value"] = null;
                                    }
                                    else if (DateTime.TryParse(row.GetCell(i).ToText().Trim(), out DateTime dtVal))
                                    {
                                        drCell["Value"] = dtVal;
                                    }
                                    else
                                    {
                                        result.Success = false;
                                        AddError(result, "Value is not in correct date format.", rowindex, i);
                                    }
                                    break;
                                case "integer":
                                    if (string.IsNullOrWhiteSpace(cellValue))
                                    {
                                        drCell["Value"] = null;
                                    }
                                    else if (int.TryParse(cellValue, out int intVal))
                                    {
                                        drCell["Value"] = intVal;
                                    }
                                    else
                                    {
                                        result.Success = false;
                                        AddError(result, "Value is not in correct integer format.", rowindex, i);
                                    }
                                    break;
                                case "logical":
                                    var validValues = new [] {"yes", "no", "true", "false", "0", "1"};
                                    if (string.IsNullOrWhiteSpace(cellValue))
                                    {
                                        AddError(result,"Value can't be empty for logical column. Valid values can be yes/no, true/false, 0/1.",
                                            rowindex, i);
                                    }
                                    else if (!validValues.Contains(cellValue.ToLower()))
                                    {
                                        AddError(result,
                                            "Value is not in correct logical format. Valid values can be yes/no, true/false, 0/1.",
                                            rowindex, i);
                                    }
                                    else
                                    {
                                        drCell["Value"] = cellValue;
                                    }
                                    break;
                                default:
                                    drCell["Value"] = cellValue;
                                    break;
                            }

                            dtCellTVP.Rows.Add(drCell);
                        }
                        else
                            break;
                    }
                    dtRowTVP.Rows.Add(drRow);
                }
                rowindex++;
            }
        }

        private void PrepareColumnTableTVP(DataTable dtColumnsTVP, IRow header, StylesTable stylesTable,
            IRow screeningNr)
        {
            dtColumnsTVP.Columns.Add("ColumnNr");
            dtColumnsTVP.Columns.Add("TraitID");
            dtColumnsTVP.Columns.Add("ColumnLabel");
            dtColumnsTVP.Columns.Add("DataType");

            for (int i = 0; i < header.Cells.Count; i++)
            {
                var cell = header.GetCell(i);
                if (cell == null)
                    break;

                var dataType = stylesTable.GetCellStyleName(cell);
                if (string.IsNullOrWhiteSpace(dataType))
                    dataType = "character";

                var headerText = header.GetCell(i).ToText();
                if (!string.IsNullOrWhiteSpace(headerText))
                {
                    var dr = dtColumnsTVP.NewRow();
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = int.TryParse(screeningNr.GetCell(i).ToText(), out int screennr)
                        ? screennr
                        : (int?) null;
                    dr["ColumnLabel"] = header.GetCell(i).ToText().Trim();
                    dr["DataType"] = GetExcelDataType(dataType);
                    dtColumnsTVP.Rows.Add(dr);
                }
            }
        }

        string GetExcelDataType(string excelDataType)
        {
            var datatype = "";
            switch (excelDataType?.ToLower())
            {
                case "character":
                    datatype = "NVARCHAR(255)";
                    break;
                case "decimal":
                    datatype = "DECIMAL(18, 2)";
                    break;
                case "datetime":
                case "date":
                    datatype = "DATETIME";
                    break;
                case "integer":
                    datatype = "INT";
                    break;
                case "logical":
                    datatype = "NVARCHAR(255)";
                    break;
                default:
                    datatype = "NVARCHAR(255)";
                    break;
            }
            return datatype;
        }

        void AddError(ExcelDataResult result, string error, int row, int col)
        {
            result.Errors.Add($"Row: {(row + 1)}, Column: {(col + 1)} => {error}");
        }
    }
}
