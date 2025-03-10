cls

# DECLARE THE VARIABLE VALUES

# Add all the asset public links, inside double quotes & separated by commas
$contentHub_AssetPublicLinks = @(
    "https://example.sitecorecontenthub.cloud/api/public/content/0fb562e57bd6442ea144d6131ecbdd87?v=44c12808"
    "https://example.sitecorecontenthub.cloud/api/public/content/450b447f4fc1444388d1c2013e3270e1?v=1a7a4e7e"
)

# Define the Content Hub API Endpoint variables
$contentHub_ApiHostname = "https://example.sitecorecontenthub.cloud"
$contentHub_AuthenticateApiEndpoint = "$contentHub_ApiHostname/api/authenticate"
$contentHub_Username = "my_username"
$contentHub_Password = "my_password"

# This is the URL of any asset details page. The asset Id will be appended to this URL, by the application.
$contentHub_AssetPageUrlBase = "$contentHub_ApiHostname/en-us/asset/"

# Accepts X-Auth-Token & array of Asset-To-Public-Relation-Links
# Returns an array of Asset Page URLs
function GetAssetPageUrls($x_auth_token, $relation_links){
    $assetPageLinks = @();
    $headers = @{
        "X-Auth-Token" = $x_auth_token
    }

    foreach($link in $relation_links){        
        $response = Invoke-RestMethod -Uri $link -Method Get -Headers $headers
        $url = $response.parents[0].href
                
        if(![string]::IsNullOrEmpty($url)){
            if ($url -match '/entities/([^?]+)') {
                $id = $matches[1]
                if (![string]::IsNullOrEmpty($id)) {                    
                    $assetPageLinks += $contentHub_AssetPageUrlBase + $id;
                }                
            }            
        }
    }
    return $assetPageLinks;
}

# Accepts X-Auth-Token & array of Asset_Link-IDs
# Returns array of Asset-To-Public-Relation-Links
function GetAssetToPublicLinkRelations($x_auth_token, $link_Ids){ 
    $relationLinks = @();    
    $apiUrl_template = "$contentHub_ApiHostname/api/entities/query?query=Definition.Name=='M.PublicLink' AND string('RelativeUrl')=='##LINK_ID##'"
    $headers = @{
        "X-Auth-Token" = $x_auth_token
    }
                  
    foreach($linkId in $link_Ids){
        $apiUrl = $apiUrl_template.Replace("##LINK_ID##",$linkId);        
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers        
        $relLink = $response.items[0].relations.AssetToPublicLink.href
                
        if(![string]::IsNullOrEmpty($relLink)){
            $relationLinks += $relLink;
        }
    }
    
    return $relationLinks
}

# Gets the X-Auth-Token for Content Hub
function GetXAuthToken(){
    # Prepare the headers and body for the POST request
    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        "user_name" = $contentHub_Username
        "password" = $contentHub_Password
    } | ConvertTo-Json

    # Send the POST request and get the response
    $response = Invoke-RestMethod -Uri $contentHub_AuthenticateApiEndpoint -Method Post -Headers $headers -Body $body

    # Parse the token from the response
    $response_token = $response.token
    return $response_token    
}

# Returns an array of link IDs from the user specified asset public links
function Get_LinkIdsFromAssetPublicLinks{ 
    $linkIds = @();
    foreach($link in $contentHub_AssetPublicLinks){
        if ($link -match '/content/([^?]+)') {
            $guid = $matches[1]
            $linkIds += $guid
        }            
    }
    return $linkIds
}

# Start method which executes all other functions
function GetAssetPageUrlsFromPublicLinks(){
    $assetPageUrls = @();  

    try{
        if($contentHub_AssetPublicLinks -gt 0){
            $assetPublicLinkIds = Get_LinkIdsFromAssetPublicLinks
            
            if($assetPublicLinkIds -gt 0){
                $token = GetXAuthToken
                $relation_links = GetAssetToPublicLinkRelations $token $assetPublicLinkIds
                
                if ($relation_links.Length -gt 0){
                    $assetPageUrls = GetAssetPageUrls $token $relation_links

                    if ($assetPageUrls.Length -gt 0){
                        Write-Host "NUMBER OF ASSET PUBLIC LINKS SPECIFIED: "$contentHub_AssetPublicLinks.Length -ForegroundColor Yellow
                        Write-Host "NUMBER OF ASSET PAGE URLs DERIVED: "$assetPageUrls.Length -ForegroundColor Yellow
                        Write-Host "`nASSET PAGE URLs: `n"

                        foreach($url in $assetPageUrls){
                            Write-Host $url -ForegroundColor Green
                        }
                    }
                    else{
                        Write-Host "NO ASSET PAGE URLS FOUND FOR THE LINKS SPECIFIED IN contentHub_AssetPublicLinks!" -ForegroundColor Red
                    }
                }
                else{
                    Write-Host "NO ASSET-TO-PUBLIC RELATION LINKS FOUND FOR THE LINKS SPECIFIED IN contentHub_AssetPublicLinks!" -ForegroundColor Red
                }
            }
            else{
                Write-Host "NO LINK IDs FOUND FOR THE LINKS SPECIFIED IN contentHub_AssetPublicLinks!" -ForegroundColor Red
            }
        }
        else{
            Write-Host "NO ASSET PUBLIC LINKS SPECIFIED IN contentHub_AssetPublicLinks!" -ForegroundColor Red
        }        
    }
    catch{
        Write-Host $_.Exception -ForegroundColor Red
    }  
}

GetAssetPageUrlsFromPublicLinks