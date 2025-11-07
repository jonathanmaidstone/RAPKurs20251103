CLASS zcm_00_messages DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA airline TYPE /dmo/carrier_id.
    DATA flight_number TYPE /dmo/connection_id.

    CONSTANTS:
      BEGIN OF general_message,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF general_message.

    CONSTANTS:
      BEGIN OF already_cancelled,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF already_cancelled.

    CONSTANTS:
      BEGIN OF already_started,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF already_started.

    CONSTANTS:
      BEGIN OF trip_approved,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF trip_approved.
    CONSTANTS:
      BEGIN OF no_approval_finished,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF no_approval_finished.

    CONSTANTS:
      BEGIN OF begin_in_past,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF begin_in_past.

    CONSTANTS:
      BEGIN OF end_in_past,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF end_in_past.

    CONSTANTS:
      BEGIN OF end_before_begin,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF end_before_begin.

    CONSTANTS:
      BEGIN OF duration_updated,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF duration_updated.
    CONSTANTS:
      BEGIN OF no_customer,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF no_customer.
    CONSTANTS:
      BEGIN OF flight_outside_trip,
        msgid TYPE symsgid VALUE 'Z00',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'AIRLINE', "&1
        attr2 TYPE scx_attrname VALUE 'FLIGHT_NUMBER', "&2
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF flight_outside_trip.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    METHODS constructor
      IMPORTING
        !textid         LIKE if_t100_message=>t100key
        !previous       LIKE previous OPTIONAL
        severity        TYPE if_abap_behv_message=>t_severity
        i_airline       TYPE /dmo/carrier_id OPTIONAL
        i_flight_Number TYPE /dmo/connection_id OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_00_messages IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).

    if_t100_message~t100key = textid.
    if_abap_behv_message~m_severity = severity.
    airline = i_airline.
    flight_number = i_Flight_number.

  ENDMETHOD.



ENDCLASS.
