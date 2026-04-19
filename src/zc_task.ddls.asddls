@EndUserText.label: 'Projection View for Task'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI.headerInfo: { typeName: 'Task', typeNamePlural: 'Tasks', title: { type: #STANDARD, value: 'TaskName' } }
@Metadata.allowExtensions: true
define view entity ZC_Task
  as projection on ZI_Task
{
  @UI.facet: [
    { id: 'Task', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Task Details' },
    { id: 'TimeEntries', purpose: #STANDARD, type: #LINEITEM_REFERENCE, targetElement: '_TimeEntries', label: 'Time Entries' }
  ]

  key TaskUUID,
  ProjectUUID,
  
  @UI: { lineItem: [{ position: 10 }], identification: [{ position: 10 }] }
  TaskName,
  
  @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }] }
  AssignedConsultant,
  
  @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }] }
  PlannedHours,
  
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
  UnitOfMeasure,
  
  @UI: { 
    lineItem: [
      { position: 40 },
      // This exposes the Action button on the Fiori UI table!
      { type: #FOR_ACTION, dataAction: 'generateInvoice', label: 'Generate Invoice' }
    ], 
    identification: [{ position: 40 }] 
  }
  Status,

  /* Redirect Associations to Projection Layer */
  _Project : redirected to parent ZC_Project,
  _TimeEntries : redirected to composition child ZC_TimeEntry
}
