@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Task'
define view entity ZI_Task
  as select from ztask2
  association to parent ZI_Project as _Project 
    on $projection.ProjectUUID = _Project.ProjectUUID
  composition [0..*] of ZI_TimeEntry as _TimeEntries
{
  key task_uuid as TaskUUID,
  
  /* Here is the Value Help you asked for! 
     It links the field to the Root entity if used outside a composition */
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_Project', element: 'ProjectUUID' } }]
  project_uuid as ProjectUUID,
  
  task_name as TaskName,
  assigned_consultant as AssignedConsultant,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  planned_hours as PlannedHours,
  unit_of_measure as UnitOfMeasure,
  status as Status,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  /* Public Associations */
  _Project,
  _TimeEntries
}
