/**
 * @name: Chris Salgado
 * @date: 6/2/2025
 * @description: Wrapper class for TradeGov Object
 */
public class TradeGovWrapper {
    public String objectName {get; set;}
    public String accName {get; set;}
    public String address {get; set;}
    public String city {get; set;}
    public String country {get; set;}
    public String state {get; set;}
    public String postal {get; set;}    
    public Boolean fuzzyMatch {get; set;}
    public String endpoint {get; set;}
    public Id id {get; set;}

    // Constructor to initialize TradeGovResponseWrapper
    public TradeGovWrapper(SObject sObj, Id id) {
        this.objectName = sobj.getSObjectType().getDescribe().getName();
        this.fuzzyMatch = true;
        this.id = id;

        switch on this.objectName {
            // Case for Account
            when 'Account' {
                Account acc = (Account) sobj;
                this.accName = acc?.Name != null ? acc.Name : '';
                this.address = acc?.BillingStreet != null ? acc.BillingStreet : '';
                this.city = acc?.BillingCity != null ? acc.BillingCity : '';
                this.country = acc?.BillingCountry != null ? acc.BillingCountry : '';
                this.state = acc?.BillingState != null ? acc.BillingState : '';
                this.postal = acc?.BillingPostalCode != null ? acc.BillingPostalCode : '';
            }

            // Case for Contact
            when 'Contact' {
                Contact cont = (Contact) sobj;
                this.accName = cont?.FirstName != null || cont.LastName != null ? cont.FirstName + ' ' + cont.LastName : '';
                this.address = cont?.MailingStreet != null ? cont.MailingStreet : '';
                this.city = cont?.MailingCity != null ? cont.MailingCity : '';
                this.country = cont?.MailingCountry != null ? cont.MailingCountry : '';
                this.state = cont?.MailingState != null ? cont.MailingState : '';
                this.postal = cont?.MailingPostalCode != null ? cont.MailingPostalCode : '';
            }

            // Default case if none of the above cases match
            when else {
                // Handle case when objectType is not one of the expected types
                System.debug('Unsupported object type: ' + this.objectName);
            }
        }

        //Set URL endpoint
        this.endpoint = 'callout:Trade_Gov_Credential/consolidated_screening_list/v1/search?name=' +
                formatURLParam(this.accName) +
                '&fuzzy_name=' + this.fuzzyMatch +
                '&countries=' + formatURLParam(this.country) +
                '&address=' + formatURLParam(this.address) +
                '&city=' + formatURLParam(this.city) +
                '&state=' + formatURLParam(this.state) +
                '&postal_code=' + formatURLParam(this.postal);
    }

    private static String formatURLParam(String inputString){
        String outputString = EncodingUtil.urlEncode(inputString, 'UTF-8');
        outputString = outputString.replace('+', '%20');
        return outputString;
    }
}