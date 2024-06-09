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
    /// Represents the App1Helpers flow invoked function.
    /// </summary>
    public class SaveLastQueryTime
    {
        private readonly ILogger<SaveLastQueryTime> logger;
        private readonly IConfiguration _configuration;

        private readonly App1Helper _helpers;

        public SaveLastQueryTime(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _configuration = configuration;
            logger = loggerFactory.CreateLogger<SaveLastQueryTime>();
            _helpers = new App1Helper(loggerFactory, configuration);
        }

        /// <summary>
        /// Executes the logic app workflow.
        /// </summary>

        [FunctionName("SaveLastQueryTime")]
        public async Task<string> Run([WorkflowActionTrigger] string QuertyType, string QueryTime,string runId) 
        {
            this.logger.LogInformation($"Starting SaveLastQueryTime for runId {runId}");

            CloudBlockBlob blobToken = await _helpers.GetLastQueryTime(QuertyType);

            await blobToken.UploadTextAsync(QueryTime);

            return QueryTime;
        }
    }
}