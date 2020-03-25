const serverUrl = `${window.services.API_BASE_URL}/api/v1/`;
const planningUrl = `${window.services.API_BASE_PLANNING_URL}/api/v1/`;
const tokenUrl = `${window.services.API_TOKEN_URL}/v1/users/token`;

const urlConfig = {
  // source
  getImportSource: `${serverUrl}Master/getImportSources`,

  // Planning
  planingCapacity: `${planningUrl}Capacity`,
  postPlaningCapacity: `${planningUrl}Capacity/saveCapacity`,
  getApprovalListForLab: `${planningUrl}Capacity/getApprovalListForLab`,
  getPlanPeriods: `${planningUrl}Planning/Master/PlanPeriods`,
  approveSlot: `${planningUrl}Slot/approveSlot`,
  denySlot: `${planningUrl}Slot/denySlot`,
  updateSlotPeriod: `${planningUrl}Slot/UpdateSlotPeriod`,

  // new call 2018/08/15
  getBreedingNew: `${serverUrl}Master/getbreedingstation`,

  // Breed
  getBreeder: `${planningUrl}Planning/Master/ReserveCapacityLookup`,
  postBreeder: `${planningUrl}Capacity/reserveCapacity`,
  getPeriod: `${planningUrl}Planning/Master/DisplayPeriod`,
  getPlatestTest: `${planningUrl}Slot/AvailablePlatesTests`,
  getMaterialType: `${planningUrl}Planning/Master/MaterialTypePerCropLookup`,

  // OVERVIEW
  getLabOverview: `${planningUrl}Slot/plannedOverview`,

  // slot
  getSlotBreedingOverview: `${planningUrl}Slot/breedingOverview`,
  deleteSlotBreedingOverview: `${planningUrl}Slot/breedingOverview`,
  updateSlotBreedingOverview: `${planningUrl}Slot/breedingOverview`,

  // determination :: Marker
  postMarkers: `${serverUrl}determination/assignDeterminations`,
  getDetermination: `${serverUrl}determination/getDataWithDeterminations`, // plateFilling GRID call
  getMaterials: `${serverUrl}determination/getMaterialsWithDeterminations`, // plateFilling GRID call
  getMarkers: `${serverUrl}Determination`,
  getExternalDeterminations: `${serverUrl}determination/getExternalDeterminations`,

  getMaterialsWithDeterminationsForExternalTest: `${serverUrl}determination/getMaterialsWithDeterminationsForExternalTest`,

  // ExcelData
  postExternalFile: `${serverUrl}externaltests/import`,
  postFile: `${serverUrl}exceldata/import`,
  getFileData: `${serverUrl}exceldata/getdata`,
  getExternalTests: `${serverUrl}externaltests/getExternalTests`,
  getExport: `${serverUrl}externaltests/export`,

  // getFileList
  getFileList: `${serverUrl}File`,

  // slot
  getSlot: `${serverUrl}test/getslotpertest`,
  getLinkSlotTest: `${serverUrl}test/linkslotntest`,

  deleteSlot: `${planningUrl}Capacity/deleteSlot`,
  moveSlot: `${planningUrl}Capacity/MoveSlot`,

  // Materials
  getPlant: `${serverUrl}Materials`,
  // delMaterials: `${serverUrl}materials/Delete`, changed
  delMaterials: `${serverUrl}materials/markdead`,
  deleteDeadMaterials: `${serverUrl}materials/DeleteDeadMaterial`,
  saveDeterminations: `${serverUrl}determination/assigndeterminations`,

  delMaterialsUndo: `${serverUrl}materials/UndoDead`,
  delDeleteReplicate: `${serverUrl}materials/DeleteReplicate`,

  getmaterialState: `${serverUrl}materials/getMaterialstate`,
  getmaterialType: `${serverUrl}materials/getMaterialtype`,
  replicateMaterials: `${serverUrl}materials/replicate`,
  getContainerTypes: `${serverUrl}test/getContainerTypes`,

  getWellType: `${serverUrl}well/getwelltypes`,

  // Test
  getTestsLookup: `${serverUrl}test/gettestslookup`,
  updateTestAttributes: `${serverUrl}test/updateTest`,
  postSaveNrOfSamples: `${serverUrl}test/saveNrOfSamples`,
  postDeleteTest: `${serverUrl}test/deleteTest`,

  // TestType
  getTestType: `${serverUrl}TestType`,

  // Well
  getWellPosition: `${serverUrl}well/getwellpositions`,
  postAssignFixedPosition: `${serverUrl}well/assignfixedposition`,
  postUndoFixedPosition: `${serverUrl}well/undofixedposition`,

  // Reorder Save to DB
  postWellSaveDB: `${serverUrl}well/save`,

  // PunchList
  getPunchList: `${serverUrl}punchlist/getPunchlist`,

  // PlateLabel
  postPlateLabel: `${serverUrl}test/printPlateLabels`,

  // Reserve Plate
  postReservePlate: `${serverUrl}test/reserveplatesinlims`,

  // Plate in LIMS
  postPlateInLims: `${serverUrl}test/fillPlatesInLims`,

  // Get test detail
  getTestDetail: `${serverUrl}test/gettestdetail`,

  // Remarks
  putTestSaveRemark: `${serverUrl}test/saveremark`,

  // complete request
  putTestUpdateStatus: `${serverUrl}test/updateteststatus`,
  // mixed with above call ( Binod above and krishna below )
  putCompleteTestRequest: `${serverUrl}test/completeTestRequest`,

  // getStatus
  getStatusList: `${serverUrl}/status/getstatuslist/test`,

  token: tokenUrl,
  // Phenome url
  // https://onprem.unity.phenome-networks.com/login_do
  phenomeLogin: `${serverUrl}phenome/login`,
  phenomeSSOLogin: `${serverUrl}phenome/ssologin`,
  getResearchGroups: `${serverUrl}phenome/getResearchGroups`,
  getFolders: `${serverUrl}phenome/getFolders`,
  importPhenome: `${serverUrl}phenome/import`,

  // Traits
  getRelationTrait: `${serverUrl}traitDetermination/getTraitsAndDetermination`,
  getRelationDetermination: `${serverUrl}traitDetermination/getDeterminations`,
  getRelation: `${serverUrl}traitDetermination/getRelationTraitDetermination`,
  postRelation: `${serverUrl}traitdetermination/saveRelationTraitDetermination`,
  // getCrop: `${serverUrl}Master/getCrops`,
  getCrop: `${serverUrl}traitdetermination/getCrops`,

  // Traits Results
  getTraitResults: `${serverUrl}traitdetermination/getTraitDeterminationResult`,
  postTraitResults: `${serverUrl}traitdetermination/saveTraitDeterminationResult`,
  // getTraitValues: `${serverUrl}Master/getTraitValues`, // ?cropCode=TO&traitID=230
  getTraitValues: `${serverUrl}traitdetermination/getTraitLOV`, // ?cropCode=TO&traitID=230
  checkValidation: `${serverUrl}validateData/ValidateTraitDeterminationResult`,

  // 3gb
  getThreeGBavailableProjects: `${serverUrl}threeGB/getAvailableProjects`,
  postThreeGBimport: `${serverUrl}threeGB/import`,
  postSendToThreeGBCockpit: `${serverUrl}threeGB/sendTo3GBCockpit`,

  postGetThreeGBmaterial: `${serverUrl}materials/get3GBMaterial`, // get3GBMaterial`, // getSelectedMaterial
  postAddToThreeGB: `${serverUrl}materials/AddTo3GB`, // AddTo3GB // AddMaterial

  // EMAIL CONFIG
  getEmailConfig: `${serverUrl}EmailConfig`,
  postEmailConfig: `${serverUrl}EmailConfig`,
  deletEmailConfig: `${serverUrl}EmailConfig`,

  getPlatPlan: `${serverUrl}test/getPlatePlanOverview`,
  // PLAT PLAN
};
export default urlConfig;
