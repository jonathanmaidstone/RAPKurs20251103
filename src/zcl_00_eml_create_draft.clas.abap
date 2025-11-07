CLASS zcl_00_eml_create_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_00_eml_create_draft IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA travel TYPE TABLE FOR CREATE z00_r_travel.

    travel = VALUE #(  ( %cid = 'NEWINSTANCE' %is_draft = if_abap_behv=>mk-on "BeginDate = '20251201' EndDate = '20251110'
    CustomerId = '1'   Description = 'Create another draft object with EML'
*    %control-BeginDate = if_abap_Behv=>mk-on
*    %control-EndDate =  if_abap_Behv=>mk-on
*    %control-customerid = if_abap_Behv=>mk-on
    %control-description = if_abap_Behv=>mk-on
 ) ).

    MODIFY ENTITIES OF z00_r_travel
    ENTITY travel
    CREATE FROM travel
    FAILED DATA(failed)
    REPORTED DATA(reported).

    IF failed IS INITIAL.
      COMMIT ENTITIES RESPONSES FAILED DATA(commit_failed)
      REPORTED DATA(commit_Reported).

      out->write(  'Finished' ).
    ELSE.
      out->write( failed ).
      out->write(  reported ).
      ROLLBACK ENTITIES.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
