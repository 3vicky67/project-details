CLASS lhc_Project DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Project RESULT result.

    METHODS setProjectID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Project~setProjectID.

    METHODS generateInvoice FOR MODIFY
      IMPORTING keys FOR ACTION Project~generateInvoice RESULT result.
ENDCLASS.

CLASS lhc_Project IMPLEMENTATION.
  METHOD get_instance_authorizations.
    " Authorization logic for the entire composition tree goes here
  ENDMETHOD.

  METHOD setProjectID.
    " 1. Read the newly created Projects
    READ ENTITIES OF ZI_Project IN LOCAL MODE
      ENTITY Project FIELDS ( ProjectID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_projects).

    " 2. Find the current highest Project ID in the database table
    SELECT MAX( project_id ) FROM zproject INTO @DATA(lv_max_project_id).

    " 3. Calculate the next available number
    DATA lv_next_number TYPE i VALUE 1000.

    IF lv_max_project_id IS NOT INITIAL.
      DATA(lv_current_number) = CONV i( substring_after( val = lv_max_project_id sub = 'PRJ-' ) ).
      lv_next_number = lv_current_number + 1.
    ENDIF.

    " 4. Update the Project ID field
    MODIFY ENTITIES OF ZI_Project IN LOCAL MODE
      ENTITY Project UPDATE FIELDS ( ProjectID )
          WITH VALUE #( FOR project IN lt_projects WHERE ( ProjectID IS INITIAL )
                        ( %tky = project-%tky ProjectID = |PRJ-{ lv_next_number }| ) )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

METHOD generateInvoice.
    " 1. Read Project Header Data
    READ ENTITIES OF ZI_Project IN LOCAL MODE
      ENTITY Project ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_projects).

    " 2. Read Associated Tasks
    READ ENTITIES OF ZI_Project IN LOCAL MODE
      ENTITY Project BY \_Tasks
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_all_tasks).

    " 3. Read Associated Time Entries via Tasks
    " Note: Verify that your association in the BDEF is named \_TimeEntries.
    " If Time Entries are a direct child of Project instead, change ENTITY Task to ENTITY Project.
    IF lt_all_tasks IS NOT INITIAL.
      READ ENTITIES OF ZI_Project IN LOCAL MODE
        ENTITY Task BY \_TimeEntries
        ALL FIELDS WITH CORRESPONDING #( lt_all_tasks )
        RESULT DATA(lt_all_time_entries).
    ENDIF.

    LOOP AT lt_projects INTO DATA(ls_project).

      DATA lt_invoice TYPE TABLE OF string.
      APPEND |========================================| TO lt_invoice.
      APPEND |           OFFICIAL INVOICE             | TO lt_invoice.
      APPEND |========================================| TO lt_invoice.
      APPEND |Project ID:   { ls_project-ProjectID }| TO lt_invoice.
      APPEND |Project Name: { ls_project-ProjectName }| TO lt_invoice.
      APPEND |Customer:     { ls_project-CustomerName }| TO lt_invoice.
      APPEND |----------------------------------------| TO lt_invoice.
      APPEND |ITEMIZED TASK & TIME LIST:              | TO lt_invoice.
      APPEND |----------------------------------------| TO lt_invoice.

      DATA(lv_has_tasks) = abap_false.

      " 4. Loop through Tasks
      LOOP AT lt_all_tasks INTO DATA(ls_task_link)
        WHERE ProjectUUID = ls_project-ProjectUUID.

        lv_has_tasks = abap_true.

        " Print the Task Header
        DATA(lv_task_line) = |[TASK] { ls_task_link-TaskName WIDTH = 18 } | &&
                             |{ ls_task_link-AssignedConsultant WIDTH = 12 } | &&
                             |{ ls_task_link-PlannedHours } hrs|.
        APPEND lv_task_line TO lt_invoice.

        " 5. Loop through Time Entries belonging to this specific Task
        DATA(lv_has_time) = abap_false.
        LOOP AT lt_all_time_entries INTO DATA(ls_time_entry)
          WHERE TaskUUID = ls_task_link-TaskUUID.

          lv_has_time = abap_true.

          " Format date to YYYY-MM-DD
          DATA(lv_date) = |{ ls_time_entry-EntryDate DATE = ISO }|.

         DATA(lv_time_line) = |  -> { lv_date } \\ { ls_time_entry-HoursWorked } { ls_time_entry-UnitOfMeasure } \\ { ls_time_entry-WorkDescription }|.
          APPEND lv_time_line TO lt_invoice.
        ENDLOOP.

        IF lv_has_time = abap_false.
           APPEND |  -> (No time entries recorded yet)| TO lt_invoice.
        ENDIF.

        APPEND | | TO lt_invoice. " Add a blank line for readability between tasks
      ENDLOOP.

      IF lv_has_tasks = abap_false.
        APPEND | (No tasks found for this project)      | TO lt_invoice.
      ENDIF.

      APPEND |----------------------------------------| TO lt_invoice.
      APPEND |TOTAL DUE:    { ls_project-TotalBudget } { ls_project-CurrencyCode }| TO lt_invoice.
      APPEND |========================================| TO lt_invoice.

      " 6. Convert and Update
      DATA lv_full_text TYPE string.
      LOOP AT lt_invoice INTO DATA(ls_line).
        lv_full_text = lv_full_text && ls_line && cl_abap_char_utilities=>cr_lf.
      ENDLOOP.

      DATA(lv_xstring) = cl_abap_conv_codepage=>create_out( )->convert( source = lv_full_text ).

      MODIFY ENTITIES OF ZI_Project IN LOCAL MODE
        ENTITY Project
        UPDATE FIELDS ( Status InvoiceContent InvoiceMimeType InvoiceFileName )
        WITH VALUE #( ( %tky            = ls_project-%tky
                        Status          = 'INVOICED'
                        InvoiceContent  = lv_xstring
                        InvoiceMimeType = 'text/plain'
                        InvoiceFileName = |Invoice_{ ls_project-ProjectID }.txt| ) )
        FAILED failed.

      APPEND VALUE #( %tky = ls_project-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = 'Invoice Generated with Tasks & Time!' )
                    ) TO reported-project.
    ENDLOOP.

    " 7. Refresh UI
    READ ENTITIES OF ZI_Project IN LOCAL MODE ENTITY Project ALL FIELDS WITH CORRESPONDING #( keys ) RESULT lt_projects.
    result = VALUE #( FOR ls_res IN lt_projects ( %tky = ls_res-%tky %param = CORRESPONDING #( ls_res ) ) ).
  ENDMETHOD.
ENDCLASS.
