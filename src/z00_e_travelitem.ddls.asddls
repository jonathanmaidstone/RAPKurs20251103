@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension view for travel item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@AbapCatalog.extensibility: {
    extensible: true,
    elementSuffix: 'Z00',
    dataSources: [ 'Item' ],
    allowNewDatasources: false
    
}
define view entity Z00_E_TRAVELITEM as select from z00_tritem as Item
{
    key item_uuid as itemUUID
   
}
