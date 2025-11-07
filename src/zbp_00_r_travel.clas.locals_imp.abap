CLASS lsc_z00_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z00_r_travel IMPLEMENTATION.

  METHOD save_modified.
    DATA input TYPE TABLE FOR EVENT z00_r_Travel~travelCreated.
* Raise event for new travel.
    IF create-travel IS NOT INITIAL.
      RAISE ENTITY EVENT z00_r_Travel~travelCreated
      FROM VALUE #( FOR line IN create-travel (  %key = line-%key origin = 'Z00_R_TRAVEL' ) ).
    ENDIF.


    DELETE FROM Zjm_test WHERE description = 'Test'.
    FINAL(saver) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z00_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      saver->delete_item( <item_d>-Itemuuid ).
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
      saver->create_item( CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      saver->update_item(
          i_item    = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
                i_itemx   = CORRESPONDING #( <item_U> MAPPING FROM ENTITY USING CONTROL  )
      ).
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateItemDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateItemDate.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateItemDate.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Item
    FIELDS ( carrierId connectionId flightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)
    BY \_Travel
    FIELDS ( beginDate endDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel)
    LINK DATA(link).

* Travel must contain one entry for each distinct combination of
* AgencyId TravelId in items

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      APPEND VALUE #(  %tky = <item>-%tky %state_area = 'ITEMDATE' ) TO reported-item.
      READ TABLE link INTO DATA(linked_key)  WITH KEY source-ItemUuid = <item>-itemuuid source-%is_draft = <item>-%is_draft.

      READ TABLE travel ASSIGNING FIELD-SYMBOL(<travel>) WITH KEY AgencyId = linked_key-target-AgencyId
      TravelId = linked_key-target-TravelId %is_draft = linked_key-target-%is_draft.

      IF <item>-flightDate < <travel>-BeginDate OR <item>-FlightDate > <travel>-EndDate.
        APPEND VALUE #(  %tky = <item>-%tky  ) TO failed-item.
        APPEND VALUE #(  %state_area = 'ITEMDATE' %tky = <item>-%tky %path-travel = CORRESPONDING #( <travel>-%tky )
        %element-FlightDate = if_abap_behv=>mk-on
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>flight_outside_trip
        severity = if_abap_behv_message=>severity-error i_airline = <item>-CarrierId
        i_flight_number = <item>-connectionId ) ) TO reported-item.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS issueMessage FOR MODIFY
      IMPORTING keys FOR ACTION Travel~issueMessage.
    METHODS cancelTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancelTravel.
    METHODS approveTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~approveTravel.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateDateRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateRange.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS determineStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<line>).

      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
        EXPORTING
          i_agencyid = <line>-AgencyId
          i_actvt    = '02' ).

      APPEND VALUE #( %tky = <line>-%tky
                      %update = SWITCH #(  rc WHEN 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )  )
       TO  result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.

* Check authorization for create
    AUTHORITY-CHECK OBJECT '/LRN/AGCY'
    ID 'ACTVT' FIELD '01'.

    IF sy-subrc <> 0.
      result-%create = if_abap_behv=>auth-unauthorized.
    ELSE.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

  METHOD issueMessage.

    APPEND NEW zcm_00_messages( textid = zcm_00_messages=>general_message
    severity = if_abap_behv_message=>severity-information ) TO reported-%other.

  ENDMETHOD.

  METHOD cancelTravel.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BeginDate EndDate Status )
    WITH CORRESPONDING #( keys  )
    RESULT DATA(result).

    FINAL(today) = cl_abap_context_info=>get_system_date(  ).


    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).

      IF <line>-status = 'C'.
        "Trip  already cancelled
        APPEND VALUE #(  %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = <line>-%tky
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>already_cancelled
        severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.


      ELSEIF <line>-Enddate < today  OR <line>-beginDate < today.
        "trip already completed
        APPEND VALUE #(  %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = <line>-%tky
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>already_started
        severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.


      ELSE.
        <line>-status = 'C'.

      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( result )
    REPORTED DATA(reported_u)
    FAILED DATA(failed_u).



  ENDMETHOD.

  METHOD approveTravel.

    DATA oMessage TYPE REF TO zcm_00_messages.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate EndDate Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      IF <line>-status = 'C'.
        "can't approve a cancelled trip
        oMessage = NEW #( textid = zcm_00_messages=>already_cancelled severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #(  %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <line>-%tky %msg = oMessage ) TO reported-travel.
      ELSEIF <line>-Enddate < cl_abap_context_info=>get_system_date( ).
        " can't approve a completed trip
        oMessage = NEW #( textid = zcm_00_messages=>no_approval_finished severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #(  %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <line>-%tky %msg = oMessage ) TO reported-travel.
      ELSE.
        <line>-status = 'A'.
        oMessage = NEW #( textid = zcm_00_messages=>trip_approved severity = if_abap_Behv_message=>severity-success ).
        APPEND VALUE #( %tky = <line>-%tky %msg = oMessage ) TO reported-travel.
      ENDIF.
    ENDLOOP.
    MODIFY ENTITIES OF z00_r_Travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( result ).


  ENDMETHOD.

  METHOD validateBeginDate.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BeginDate )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'BEGIN' ) TO reported-travel.

      IF <line>-beginDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #( %state_area = 'BEGIN' %tky = <line>-%tky %element-BeginDate = if_abap_behv=>mk-on
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>begin_in_past
        severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateDateRange.

    READ ENTITIES OF z00_r_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result) .

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'RANGE' ) TO reported-travel.
      IF <line>-enddate < <line>-beginDate.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
*        Create entry in reported-travel
        APPEND VALUE #( %state_area = 'RANGE'
        %tky = <line>-%tky
        %element-BeginDate = if_abap_behv=>mk-on
        %element-EndDate = if_abap_behv=>mk-on
           %msg = NEW zcm_00_messages( textid = zcm_00_messages=>end_before_begin
           severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF z00_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS ( EndDate )
     WITH CORRESPONDING #(  keys )
     RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #( %tky = <line>-%tky %state_area = 'END' ) TO reported-travel.
      IF <line>-endDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #( %state_area = 'END' %tky = <line>-%tky %element-EndDate = if_abap_behv=>mk-on
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>end_in_past
        severity = if_abap_behv_message=>severity-error ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



  METHOD earlynumbering_create.

    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-agencyid = agencyid.
      <mapping>-travelid = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( customerID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #( %tky = <line>-%tky %state_area = 'CUST' ) TO reported-travel.

      SELECT SINGLE FROM /dmo/I_customer
      FIELDS 'X'
      WHERE customerId = @<line>-customerId
      INTO @DATA(check).

      IF check IS INITIAL.
        APPEND VALUE #(  %tky = <line>-%tky  ) TO failed-travel.
        APPEND VALUE #(  %state_area = 'CUST' %tky = <line>-%tky %element-customerId = if_abap_Behv=>mk-on
        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>no_customer severity = if_abap_behv_message=>severity-error ) )
        TO reported-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS (  status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      IF <line>-status IS INITIAL.
        <line>-status = 'B'. "Booked
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( result ).

  ENDMETHOD.

  METHOD get_instance_features.

    FINAL(today) = cl_abap_context_info=>get_system_date(  ).

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(trips).




    LOOP AT trips ASSIGNING FIELD-SYMBOL(<trip>).
* Is data active or draft?
      IF <trip>-%is_draft = if_abap_behv=>mk-on. "it's a draft.. get active version
        READ ENTITIES OF z00_r_travel IN LOCAL MODE
         ENTITY travel
          FIELDS (  beginDate endDate )
          WITH VALUE #(  ( %key = <trip>-%key %is_draft = if_abap_behv=>mk-off ) )
          RESULT DATA(trip_active).
        IF trip_active IS INITIAL. "There isn't an active version
          CLEAR: <trip>-beginDate, <trip>-endDate. "Use initial values
        ELSE.
          <trip>-beginDate = trip_active[ 1 ]-beginDate.
          <trip>-EndDate = trip_active[ 1 ]-enddate.
        ENDIF.

      ENDIF.

      APPEND CORRESPONDING #( <trip> ) TO result
      ASSIGNING FIELD-SYMBOL(<control>).

      IF <trip>-beginDate < today AND <trip>-beginDate IS NOT INITIAL.  " trip already started - don't change start date
        <control>-%field-BeginDate = if_abap_behv=>fc-f-read_only.


      ENDIF.
      IF <trip>-endDate < today AND <trip>-endDate IS NOT INITIAL. " trip already finished - don't change end date, No Edit, No Cancel, No Approve
        <control>-%field-EndDate = if_abap_behv=>fc-f-read_only.
        <control>-%features-%action-approveTravel = if_abap_behv=>fc-o-disabled.
        <control>-%features-%action-cancelTravel = if_abap_behv=>fc-o-disabled.
        <control>-%features-%update = if_abap_behv=>fc-o-disabled.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( beginDate Enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      <line>-duration = <line>-EndDate - <line>-beginDate + 1.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( Duration )
    WITH CORRESPONDING #( result ) .

  ENDMETHOD.

ENDCLASS.
