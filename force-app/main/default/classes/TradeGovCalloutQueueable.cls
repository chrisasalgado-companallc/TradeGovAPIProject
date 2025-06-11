/**
 * @name: Chris Salgado
 * @date: 6/2/2025
 * @description: Queueable class for making callouts to TradeGov API
 */
public class TradeGovCalloutQueueable implements Queueable, Database.AllowsCallouts{
    private TradeGovWrapper tgWrapper;

    // Constructor to accept the wrapper object
    public TradeGovCalloutQueueable(TradeGovWrapper wrapper) {
        this.tgWrapper = wrapper;        
    }

    /**
     * Makes a GET call to the Trade.gov Consolidated Screening List API.
     * @param wrapper TradeGovWrapper to pass into the utility method.
     */
    public void execute(QueueableContext context) {
        
        // Access the wrapper object here
        System.debug('Processing API Wrapper: ' + tgWrapper.objectName + '/Id = ' + tgWrapper.id);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('Check endpoint ' + tgWrapper.endpoint);
        request.setEndpoint(tgWrapper.endpoint);
        request.setMethod('GET');

        try {
            // Make the callout
            HttpResponse response = http.send(request);

            // Check the response status
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
                //Create Response Records
                List<Trade_Gov_Response__c> tgResponseList = TradeGovResponseGateway.createTGResponseFromJSON(tgWrapper.Id, response.getBody());
                if(!tgResponseList.isEmpty()){
                    insert tgResponseList;
                }
            } else {
                System.debug('Error: Status Code = ' + response.getStatusCode() + ' - Error Message: ' + response.getStatus() );                     
            }
        }
        catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());            
        }
    }
}