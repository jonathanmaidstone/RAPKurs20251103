*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_event_handler DEFINITION
INHERITING FROM cl_abap_behavior_event_handler.

  PRIVATE SECTION.
    METHODS on_travel_created FOR ENTITY EVENT
      IMPORTING new_trips
                  FOR travel~travelCreated.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_travel_created.
* write a log entry
    DATA log TYPE TABLE FOR CREATE /lrn/437_i_travellog.

*    LOOP AT new_trips ASSIGNING FIELD-SYMBOL(<trip>).
*      APPEND VALUE #( agencyId = <trip>-agencyId travelId = <trip>-travelid
*      origin = 'Z00_R_TRAVEL' ) TO log.
*    ENDLOOP.
    log = CORRESPONDING #( new_trips ).

    MODIFY ENTITIES OF /lrn/437_i_travellog
    ENTITY TravelLog
    CREATE AUTO FILL CID
    FIELDS ( AgencyId TravelId Origin )
    WITH log.

  ENDMETHOD.

ENDCLASS.
