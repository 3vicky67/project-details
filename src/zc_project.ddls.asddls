@EndUserText.label: 'Projection View for Project'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_Project
  provider contract transactional_query
  as projection on ZI_Project
{
  key ProjectUUID,
  ProjectID,
  ProjectName,
  CustomerName,
  TotalBudget,
  
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
  CurrencyCode,
  
  Status,

  // --- MEDIA ANNOTATIONS (MANDATORY FOR DOWNLOAD) ---
  @Semantics.largeObject: {
    mimeType: 'InvoiceMimeType',
    fileName: 'InvoiceFileName',
    contentDispositionPreference: #ATTACHMENT
  }
  InvoiceContent,
  
  @Semantics.mimeType: true
  InvoiceMimeType,
  
  InvoiceFileName,
  // --------------------------------------------------

  /* Redirect Associations to Projection Layer */
  _Tasks : redirected to composition child ZC_Task
}
