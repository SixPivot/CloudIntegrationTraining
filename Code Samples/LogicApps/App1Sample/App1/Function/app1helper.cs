//------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//------------------------------------------------------------

namespace demo.app1
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.Azure.Functions.Extensions.Workflows;
    using Microsoft.Azure.WebJobs;
    using Microsoft.Extensions.Logging;
    using Microsoft.WindowsAzure.Storage;
    using Microsoft.WindowsAzure.Storage.Blob;
    using Microsoft.Extensions.Configuration;
    using Newtonsoft.Json;

    /// <summary>
    /// Represents the App1Helper flow invoked function.
    /// </summary>
    public class App1Helper
    {
        private readonly ILogger<App1Helper> logger;
        private readonly IConfiguration _configuration;
        public App1Helper(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _configuration = configuration;
            logger = loggerFactory.CreateLogger<App1Helper>();
        }
        public async Task<App1Token> RetrieveTokenFromStorage(App1Token token)
        {
            this.logger.LogInformation("Starting RetrieveTokenFromStorage");

            CloudBlockBlob blobToken = await GetPreviousToken();

            if (await blobToken.ExistsAsync())
            {
                this.logger.LogDebug("Previous Token Found");
                var tokenText = await blobToken.DownloadTextAsync();
                token = JsonConvert.DeserializeObject<App1Token>(tokenText);
            }
            else
            {
                this.logger.LogDebug("Previous Token Not Found");
                token = new App1Token();
                token.TokenExpiry = DateTime.Now.AddSeconds(-60);
            }

            return token;
        }
        public async void SaveTokenToStorage(App1Token token)
        {
            this.logger.LogInformation("Starting SaveTokenToStorage");

            CloudBlockBlob blobToken = await GetPreviousToken();

            var tokenText = JsonConvert.SerializeObject(token);
            await blobToken.UploadTextAsync(tokenText);
        }

        public async Task<CloudBlockBlob> GetPreviousToken()
        {
            CloudBlockBlob blobToken = null;
            try
            {
                CloudStorageAccount cloudStorageAccount = CloudStorageAccount.Parse(_configuration["AzureWebJobsStorage"]);
                var cloudBlobClient = cloudStorageAccount.CreateCloudBlobClient();
                var container = cloudBlobClient.GetContainerReference("younity");
                await container.CreateIfNotExistsAsync();
                blobToken = container.GetBlockBlobReference("younityToken");
            }
            catch (Exception Ex1)
            {
                this.logger.LogError(Ex1, "GetPreviousToken: Error Getting Connection for Previous Token Blob");
            }

            return blobToken;
        }

         public async Task<CloudBlockBlob> GetLastQueryTime(string QuertyType)
        {
            CloudBlockBlob blobQueryTime = null;
            try
            {
                CloudStorageAccount cloudStorageAccount = CloudStorageAccount.Parse(_configuration["AzureWebJobsStorage"]);
                var cloudBlobClient = cloudStorageAccount.CreateCloudBlobClient();
                var container = cloudBlobClient.GetContainerReference("younity");
                await container.CreateIfNotExistsAsync();
                blobQueryTime = container.GetBlockBlobReference("younityQueryTime"+QuertyType.ToLower());
            }
            catch (Exception Ex1)
            {
                this.logger.LogError(Ex1, "GetPreviousToken: Error Getting Connection for Previous Token Blob");
            }

            return blobQueryTime;
        }
    }
}