CLASS zcl__eml_create_a DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl__eml_create_a IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA travel TYPE TABLE FOR CREATE z00_R_travel.
    DATA items TYPE TABLE FOR CREATE z00_R_travel\_item.


    travel = VALUE #(  ( %cid = 'PARENT' description = 'Create By Association' BeginDate = '20251201' EndDate = '20251220'
    customerId = '1'
    %control-description = if_abap_behv=>mk-on %control-BeginDate = if_abap_behv=>mk-on %control-EndDate = if_abap_behv=>mk-on
    %control-CustomerId = if_abap_behv=>mk-on ) ).

    items = VALUE #(  ( %cid_ref = 'PARENT'
    %target = VALUE #( ( %cid = 'ITEM1'  carrierId = 'LH' connectionid = '0400' flightDate = '20251201' BookingId = '1'
    %control-Carrierid = if_abap_behv=>mk-on %control-connectionid = if_abap_behv=>mk-on
     %control-flightdate = if_abap_behv=>mk-on %control-bookingid = if_abap_behv=>mk-on )
    ( %cid = 'ITEM2' carrierId = 'LH' connectionid = '0401' flightDate = '20251219' BookingId = '2'
    %control-Carrierid = if_abap_behv=>mk-on %control-connectionid = if_abap_behv=>mk-on
     %control-flightdate = if_abap_behv=>mk-on %control-bookingid = if_abap_behv=>mk-on ) ) ) ).

    MODIFY ENTITIES OF z00_r_travel
    ENTITY Travel
    CREATE FROM travel
    CREATE BY \_Item
    FROM items.

commit entities RESPONSES failed data(failed) reported data(reported).
if failed is initial.
out->write( 'Worked' ).
else.
out->write( 'Failed' ).
endif.
  ENDMETHOD.
ENDCLASS.
