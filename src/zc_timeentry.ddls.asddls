@EndUserText.label: 'Projection View for Time Entry'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI.headerInfo: { typeName: 'Time Entry', typeNamePlural: 'Time Entries' }
@Metadata.allowExtensions: true
define view entity ZC_TimeEntry
  as projection on ZI_TimeEntry
{
  @UI.facet: [
    { id: 'TimeEntry', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Time Entry Details' }
  ]

  key TimeEntryUUID,
  TaskUUID,
  
  // ADD THIS LINE BELOW TO FIX THE ERROR
  ProjectUUID, 
  
  @UI: { lineItem: [{ position: 10 }], identification: [{ position: 10 }] }
  EntryDate,
  
  @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }] }
  HoursWorked,
  
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
  UnitOfMeasure,
  
  @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }] }
  WorkDescription,

  /* Redirect Associations to Projection Layer */
  _Task : redirected to parent ZC_Task,
  _Project : redirected to ZC_Project
}
