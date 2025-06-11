/**
 * @name: Chris Salgado
 * @date: 6/2/2025
 * @description: Wrapper class for deserializing the JSON response from the TradeGov API
 */
public class TradeGovResponseWrapper {    
    public String name {get; set;}
    public List<String> alt_names {get; set;}
    public String remarks {get; set;}
    public String source {get; set;}
    public String source_information_url {get; set;}
    public String source_list_url {get; set;}
    public Decimal score {get; set;} 
    public List<Ids> ids { get; set; }

    public class Ids {
        public String type { get; set; }
        public String numberValue { get; set; }
    }
}