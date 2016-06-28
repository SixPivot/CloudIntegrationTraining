Add-AzureAccount
get-azuresubscription
select-azuresubscription '<Enter the name of your Azure Subscription>'
$StorageAccountName = "cloudintegrationtrainXX" 
$StorageAccountKey = "<enter your storage key>"
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "swagger"
New-AzureStorageContainer -Name $ContainerName -Context $ctx -Permission Blob
$localFileDirectory = "C:\Users\bchesnut.CHESNUT\Downloads\"
$BlobName = "ConferenceApiApp_swagger.json" 
$localFile = $localFileDirectory + $BlobName 
#Set-AzureStorageBlobContent -File $localFile -Container $ContainerName -Blob $BlobName -Context $ctx
Get-AzureStorageBlob -Container $ContainerName -Context $ctx
#
# Setup CORS so Logic App can access
#
$CorsRules = (@{AllowedHeaders=@("*");AllowedOrigins=@("*");ExposedHeaders=@("content-length");MaxAgeInSeconds=200;AllowedMethods=@("Get","Connect", "Head")})
Set-AzureStorageCORSRule -ServiceType Blob -CorsRules $CorsRules -Context $ctx
$CorsRulesOut = Get-AzureStorageCORSRule -ServiceType Blob -Context $ctx
echo $CorsRulesOut
