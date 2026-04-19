@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Project'
define root view entity ZI_Project
  as select from zproject
  composition [0..*] of ZI_Task as _Tasks
{
  key project_uuid as ProjectUUID,
  project_id as ProjectID,
  project_name as ProjectName,
  customer_name as CustomerName,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  total_budget as TotalBudget,
  currency_code as CurrencyCode,
  status as Status,
  invoice_content as InvoiceContent,
  invoice_mime_type as InvoiceMimeType,
  invoice_file_name as InvoiceFileName,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  /* Public Associations */
  _Tasks
}
