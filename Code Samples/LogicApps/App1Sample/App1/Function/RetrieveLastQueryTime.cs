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
    using RestSharp;
    using RestSharp.Authenticators;
    using System.Net;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;
    using Microsoft.Extensions.Configuration;
    using Microsoft.WindowsAzure.Storage;
    using Microsoft.WindowsAzure.Storage.Blob;

    /// <summary>
    /// Represents the App1Helper flow invoked function.
    /// </summary>
    public class RetrieveLastQueryTime
    {
        private readonly ILogger<RetrieveLastQueryTime> logger;
        private readonly IConfiguration _configuration;

        private readonly App1Helper _helpers;

        public RetrieveLastQueryTime(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _configuration = configuration;
            logger = loggerFactory.CreateLogger<RetrieveLastQueryTime>();
            _helpers = new App1Helper(loggerFactory, configuration);
        }

        /// <summary>
        /// Executes the logic app workflow.
        /// </summary>

        [FunctionName("RetrieveLastQueryTime")]
        public async Task<string> Run([WorkflowActionTrigger] string QuertyType,string runId) 
        {
            this.logger.LogInformation($"Starting RetrieveLastQueryTime  for runId {runId}");

            string QueryTime = "";

            CloudBlockBlob blobLastQueryTime = await _helpers.GetLastQueryTime(QuertyType);

            if (await blobLastQueryTime.ExistsAsync())
            {
                QueryTime = await blobLastQueryTime.DownloadTextAsync();
                this.logger.LogInformation($"Previous QueryTime Found {QueryTime}");
            }
            else
            {
                DateTime temp = DateTime.UtcNow;
                QueryTime = temp.ToString("yyyy-MM-ddTHH:mm:ssZ");
                this.logger.LogInformation($"Previous QueryTime Not Found - Current UTC {QueryTime}");
                temp = temp.AddHours(-1);
                temp = temp.AddMinutes(-5);
                QueryTime = temp.ToString("yyyy-MM-ddTHH:mm:ssZ");
                this.logger.LogInformation($"Previous QueryTime Not Found - Created New {QueryTime}");
            }

            this.logger.LogInformation($"RetrieveLastQueryTime QueryTime = {QueryTime}");

            return QueryTime;
        }
    }
}