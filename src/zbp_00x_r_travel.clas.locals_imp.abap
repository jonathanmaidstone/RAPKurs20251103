CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS zzvalidateClass FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~zzvalidateClass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD zzvalidateClass.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Item
    FIELDS ( AgencyId TravelID ZZClassZ00 )
    WITH CORRESPONDING #( keys )
     RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<class>).
      IF <class>-ZZClassZ00 <> 'Y' AND <class>-ZZClassZ00 <> 'C' AND <class>-ZZClassZ00 <> 'F'.
        APPEND VALUE #(  %tky = <class>-%tky  ) TO failed-item.
        APPEND VALUE #(  %tky = <class>-%tky %path-travel = CORRESPONDING #(  <class> ) %element-zzclassz00 = if_abap_behv=>mk-on
       %msg = NEW zcm_00_messages( textid = zcm_00_messages=>general_message severity = if_abap_behv_message=>severity-error ) ) TO reported-item.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z00_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z00_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<create>).
      IF <create>-%control-ZZClassZ00 = if_abap_behv=>mk-on.
        UPDATE z00_tritem  SET zzclassz00 = @<create>-ZZClassZ00
        WHERE item_uuid = @<create>-ItemUuid.
      ENDIF.
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<update>).
      IF <update>-%control-ZZClassZ00 = if_abap_behv=>mk-on.
        UPDATE z00_tritem  SET zzclassz00 = @<update>-ZZClassZ00
        WHERE item_uuid = @<update>-ItemUuid.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
