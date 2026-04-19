@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Time Entry'
define view entity ZI_TimeEntry
  as select from ztime_entry
  association to parent ZI_Task as _Task 
    on $projection.TaskUUID = _Task.TaskUUID
  association [1..1] to ZI_Project as _Project
    on $projection.ProjectUUID = _Project.ProjectUUID
{
  key time_entry_uuid as TimeEntryUUID,
  task_uuid as TaskUUID,
  
  /* Read-only mapping to jump straight to Root if needed */
  _Task.ProjectUUID as ProjectUUID, 
  
  entry_date as EntryDate,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  hours_worked as HoursWorked,
  unit_of_measure as UnitOfMeasure,
  work_description as WorkDescription,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  /* Public Associations */
  _Task,
  _Project
}
