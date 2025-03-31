public class TaxRateModel{
        public List<TaxRate> rates;
        public decimal totalRate;
         public class TaxRate{
            public string type;
            public string name;
            public double rate;
        }  
        public static TaxRateModel parse(String json) {
            system.debug('json'+json);
		    return (TaxRateModel) System.JSON.deserialize(json, TaxRateModel.class);
	    }
}