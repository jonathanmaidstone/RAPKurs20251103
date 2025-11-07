CLASS zcl_00_eml_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_00_eml_demo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA input_keys TYPE TABLE FOR READ IMPORT  z00_r_travel.
*    DATA trips TYPE TABLE FOR READ RESULT z00_r_travel.
    DATA changes TYPE TABLE FOR UPDATE z00_r_travel.

    input_keys = VALUE #( ( Agencyid = '70000' travelId = '12345' ) ).

    READ ENTITIES OF z00_r_travel
    ENTITY travel
    ALL FIELDS
    WITH input_keys
    RESULT DATA(trips).

    out->write( trips ).



    LOOP AT trips ASSIGNING FIELD-SYMBOL(<trip>).
      <trip>-status = 'Z'.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel
    ENTITY Travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( trips )
    REPORTED DATA(Reported)
    FAILED DATA(failed).

    COMMIT ENTITIES.


  ENDMETHOD.
ENDCLASS.
