/**
 * @name: Chris Salgado
 * @date: 6/2/2025
 * @description: Gateway class for working with TradeGov Responses
 */
public class TradeGovResponseGateway {
    
    public static List<Trade_Gov_Response__c> createTGResponseFromJSON(Id relatedRecordId, String responseBody){
        List<Trade_Gov_Response__c> tgResponseList = new List<Trade_Gov_Response__c>();        
        
        //Iterate over the parsed Results of the Response Body
        for(String resultString : getTGResultStrings(responseBody)){                
            Trade_Gov_Response__c tgResponse = new Trade_Gov_Response__c();
            
            //Set Response Relationship
            setTGResponseRelationship(relatedRecordId, tgResponse);

            //JSON Deserialize the Trade Gov API Response using the TG Wrapper Class
            TradeGovResponseWrapper tgrwObj = (TradeGovResponseWrapper) JSON.deserialize(resultString, TradeGovResponseWrapper.class);

            //Concatenate Names as CSV
            String concatNames = '';
            if(!String.isBlank(tgrwObj.name)){
                concatNames = tgrwObj.name;
                if(!tgrwObj.alt_names.isEmpty()){
                    concatNames = concatNames + ', ' + String.join(tgrwObj.alt_names, ', ');
                }
            }
            else{
                if(!tgrwObj.alt_names.isEmpty()){
                    concatNames = String.join(tgrwObj.alt_names, ', ');
                }
            }
            
            //Parse & Concatenate Id Number Values as Text
            String richTextValue;
            if(tgrwObj.ids != null && !tgrwObj.ids.isEmpty()){
                for(TradeGovResponseWrapper.Ids tempIds : tgrwObj.ids){            
                    System.debug('check numberValue ' + tempIds.numberValue);

                    if(String.isBlank(richTextValue)){
                        richTextValue = 'Type - ' + tempIds.type + '<br>Value - ' + tempIds.numberValue + '<br><br>';
                    }
                    else {
                        richTextValue += 'Type - ' + tempIds.type + '<br>Value - ' + tempIds.numberValue + '<br><br>';
                    }
                }
            }

            tgResponse.Entity_Names__c = concatNames;
            tgResponse.Match_Score__c = tgrwObj.score;
            tgResponse.Source__c = tgrwObj.source;
            tgResponse.Remarks__c = tgrwObj.remarks;
            tgResponse.Source_List_URLs__c = tgrwObj.source_list_url;        
            tgResponse.Information__c = tgrwObj.source_information_url;
            tgResponse.Ids__c = richTextValue;

            tgResponseList.add(tgResponse);
        }

        return tgResponseList;
    }

    private static List<String> getTGResultStrings(String responseBody){
        List<String> resultStringList = new List<String>();

        //Replace Number
        String originalStr = '"number":';
        String newStr = '"numberValue":';
        String fullJsonString = responseBody.replace(originalStr, newStr);

        //Deserialize String
        Map<String, Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(fullJsonString);

        //Get Results from Object Map
        List<Object> resultsObjList = (List<Object>) objMap.get('results');

        //Iterate over list of Result Objects
        for(Object tempObj : resultsObjList){
            //Serializing the Results
            String resultString = JSON.serialize(tempObj);            
            resultStringList.add(resultString);
        }

        return resultStringList;
    }
    
    private static void setTGResponseRelationship(Id relatedRecordId, Trade_Gov_Response__c tgResponse){
        //Set Relationship based on sObject type of Record Id
        switch on String.valueOf(relatedRecordId.getSobjectType()){
            when 'Account'{
                tgResponse.Account__c = relatedRecordId;
            }
            when 'Contact'{
                tgResponse.Contact__c = relatedRecordId;
            }
        }
    }
}