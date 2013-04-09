//Retrieve currencyCode from list in database

​ <cfquery name="qCurrency" datasource="yourDB">
            select currencyCode
            from tbl_currencies
  </cfquery>
​//Use valueList() to insert a " , "  between each value of the query

      <cfset currencyList = ValueList(qCurrency.currencyCode, ' , ' ) />
​//Create a temporary list that is empty

      <cfset tempList = "" />
//Loop through currencyList

<cfloop list="#currencyList#" index="li">
//Send http request to remote currency converter sending your list element as a variable

       
        <cftry>
            <cfhttp result="getCurrency" url="http://rate-exchange.appspot.com/currency?from=EUR&to=#li#" ></cfhttp>
          //Save the contents of the request

            <cfset getCurrencyBody = getCurrency.fileContent>
        //Use deserializeJson() to convert the return data into CFML data

            <cfset cfData = deserializeJson(getCurrencyBody) >
       //Output name of currency

           <cfoutput>#li#:   </cfoutput>
          //Use try-catch statement to update currencies in the database        

            <cftry>  
             //Output updated rate         

                <cfoutput>#cfData.rate#<br/></cfoutput>
           //Update rate in the database         

                <cfquery name="qUpdateCurrency" datasource="yourDB">
                    update tbl_currencies
                    set rate = '#cfData.rate#', lastUpdate = #createODBCDateTime(now())#
                    where currencyCode = '#li#'
                </cfquery>
          //Catch any currencies that could not be converted and skip over them          

                <cfcatch>
                    Skipping<br/>
                    <cfset error = error & "Error Occurred updating the currency for " & li & " in the database <br />" & cfcatch.Message & cfcatch.Detail & "<br /><br/>" />
                </cfcatch>
            </cftry>
           
            <cfcatch>
                <cfoutput>#li#: Skipping<br/></cfoutput>
                <cfset error = error & "Error Occurred executing cfHttpRequest for " & li & " to http://rate-exchange.appspot.com/currency?from=EUR&to=#li#<br />" & cfcatch.Message & "-" & cfcatch.Detail & "<br /><br/>" />
            </cfcatch>
        </cftry>
    </cfloop>​
