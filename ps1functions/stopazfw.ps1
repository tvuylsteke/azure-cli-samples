$accessParams = @{
Headers = @{
    'Content-Type' = 'application/json'
    }
Body = '{    
            "name" : "spongebob",               
}'    
Method = 'POST'
URI = "https://ps1func.azurewebsites.net/api/HttpTrigger?code=/jUzUZB2NJwgavSgNYr/UQFl5iEy58WMA8ByxrIg6xD6CjUXEgaFDA=="
}
   

$result = Invoke-RestMethod @accessParams
$result