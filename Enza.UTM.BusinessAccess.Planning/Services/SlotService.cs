using System.Configuration;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Planning.Services
{
    public class SlotService : ISlotService
    {
        private readonly IUserContext _userContext;
        private readonly ISlotRepository _repository;
        private readonly IEmailService _emailService;
        public SlotService(IUserContext userContext, ISlotRepository repository, IEmailService emailService)
        {
            _userContext = userContext;
            _repository = repository;
            _emailService = emailService;
        }

        public async Task<GetAvailPlatesTestsResult> GetAvailPlatesTestsAsync(GetAvailPlatesTestsRequestArgs args)
        {
            return await _repository.GetAvailPlatesTestsAsync(args);
        }

        public async Task<SlotLookUp> GetSlotDataAsync(int id)
        {
            return await _repository.GetSlotDataAsync(id);
        }

        public async Task<SlotApprovalResult> UpdateSlotPeriodAsync(UpdateSlotPeriodRequestArgs request)
        {
            //var res = new SlotApprovalResult
            //{
            //    Message = "Slot updated successfully.",
            //    Success = true
            //};
            //EmailDataArgs item = null;
            //if(request.PlannedDate != null && request.ExpectedDate != null)
            //    item = await _repository.UpdateSlotPeriodAsync(request);
            //if(item !=null)
            //    return await SendEmailAsync(item);
            //return res;




            var res = new SlotApprovalResult
            {
                Message = "Slot updated successfully.",
                Success = true
            };
            EmailDataArgs item = null;
            SlotApprovalResult resp1 = new SlotApprovalResult();
            var slotData = await _repository.GetSlotDataAsync(request.SlotID);
            if(slotData !=null)
            {
                if (request.PlannedDate != null && request.ExpectedDate != null)
                {
                    if(request.PlannedDate.Value.ToShortDateString() != slotData.PlannedDate.ToShortDateString() || request.ExpectedDate.Value.ToShortDateString() != slotData.ExpectedDate.ToShortDateString())
                    {
                        item = await _repository.UpdateSlotPeriodAsync(request);
                    }
                }
                if((request.NrOfPlates > 0) && (request.NrOfTests != slotData.NrOfTests || request.NrOfPlates != slotData.NrOfPlates))
                {
                    resp1 = await EditSlotAsync(new EditSlotRequestArgs
                    {
                        Forced = request.Forced,
                        NrOfPlates = request.NrOfPlates,
                        NrOfTests = request.NrOfTests,
                        SlotID = request.SlotID
                    });
                }

            }

            if (item != null)
                return await SendEmailAsync(item);

            if (!resp1.Success)
            {
                res.Message = resp1.Message;
                res.Success = false;

            };            
            return res;
        }
        public async Task<SlotApprovalResult> ApproveSlotAsync(int SlotID)
        {
            var item = await _repository.ApproveSlotAsync(SlotID);
            return await SendEmailAsync(item);
        }
        public async Task<SlotApprovalResult> DenySlotAsync(int SlotID)
        {
            var item = await _repository.DenySlotAsync(SlotID);
            return await SendEmailAsync(item);
        }

        public Task<DataTable> GetPlannedOverviewAsync(int year, int? periodID)
        {
            return _repository.GetPlannedOverviewAsync(year, periodID);
        }

        public Task<BreedingOverviewResult> GetBreedingOverviewAsync(BreedingOverviewRequestArgs requestArgs)
        {
            return _repository.GetBreedingOverviewAsync(requestArgs);
        }

        public async Task<SlotApprovalResult> SendEmailAsync(EmailDataArgs args)
        {
            var res = new SlotApprovalResult
            {
                Message = "Error on sending mail",
                Success = false
            };
            var from = ConfigurationManager.AppSettings["LAB:EmailSender"];
            //var userName = LDAP.GetUserName(_userContext.GetContext().FullName);
            var recipient = LDAP.GetEmail(args.RequestUser);
            var body = string.Empty;
            switch (args.Action)
            {
                case "Approved":
                    body = "Your reservation request (" + args.SlotName + ") for planned " + args.PeriodName + " year " +
                        args.PlannedDate.Year + " is approved.";
                    //body = $"The slot {args.SlotName} for { args.PeriodName}/{args.PlannedDate.Year} has been approved by the lab.";
                    break;
                case "Rejected":
                    body = "Your reservation request (" + args.SlotName + ") for planned " + args.PeriodName + " year " +
                        args.PlannedDate.Year + " is rejected. Please contact the lab.";
                    //body = $"The slot {args.SlotName} for { args.PeriodName}/{args.PlannedDate.Year} has not been approved by the lab.";
                    break;
                case "Changed":
                    body = $"Your reservation request ({args.SlotName}) for Planned {args.PeriodName} year {args.PlannedDate.Year} and Expected {args.ExpectedPeriodName} year {args.ExpectedDate.Year} has been updated and approved: <br>" +
                        $"New Planned date: {string.Format("{0:yyyy-MM-dd}", args.ChangedPlannedDate)} ({args.ChangedPeriodName}  {args.ChangedPlannedDate.Year}) <br>" +
                        $"New Expected date:{string.Format("{0:yyyy-MM-dd}", args.ChangedExpectedDate)} ({args.ChangedExpectedPeriodName}  {args.ChangedPlannedDate.Year})";

                    //body = $"The slot modification {args.SlotName} for { args.PeriodName}/{args.PlannedDate.Year} has been approved by the lab.";
                    break;
            }

            await _emailService.SendEmailAsync(from, new[] { recipient }, "Slot Reservation".AddEnv(), body);

            res.Success = true;
            res.Message = "Email notification sent to " + recipient;
            return res;
        }

        public async Task<SlotApprovalResult> EditSlotAsync(EditSlotRequestArgs args)
        {
            var res = new SlotApprovalResult
            {
                Message = "Slot Updated Successfully.",
                Success = true
            };
            var resp = await _repository.EditSlotAsync(args);
            if(!resp.Success)
            {
                res.Message = resp.Message;
                res.Success = false;                
            };
            ////send email if some test is already linked to edited slot
            //if(resp.Data?.Tables[0].Rows.Count > 0)
            //{

            //}

            //return message
            return res;
        }

        public Task<DataTable> GetApprovedSlotsAsync(string slotName)
        {
            return _repository.GetApprovedSlotsAsync(slotName);
        }
    }
}
