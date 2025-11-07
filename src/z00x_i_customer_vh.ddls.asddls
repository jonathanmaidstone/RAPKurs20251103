@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer layer value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z00X_I_CUSTOMER_VH as select from /DMO/I_Customer
{
    key CustomerID,
    
    LastName,
    FirstName,
    Street,
    PostalCode,
    City,
    CountryCode
   
}
