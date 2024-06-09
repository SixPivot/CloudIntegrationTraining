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
    using System.Net;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;
    using Microsoft.Extensions.Configuration;
    using Microsoft.WindowsAzure.Storage;
    using Microsoft.WindowsAzure.Storage.Blob;
    using System.Text.RegularExpressions;

    /// <summary>
    /// Represents the App1Helper flow invoked function.
    /// </summary>
    public class FormatDateTime
    {
        private readonly ILogger<RetrieveLastQueryTime> logger;
        private readonly IConfiguration _configuration;

        private readonly App1Helper _helpers;

        public FormatDateTime(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _configuration = configuration;
            logger = loggerFactory.CreateLogger<RetrieveLastQueryTime>();
            _helpers = new App1Helper(loggerFactory, configuration);
        }

        /// <summary>
        /// Executes the logic app workflow.
        /// </summary>

        [FunctionName("FormatDateTime")]
        public async Task<string> Run([WorkflowActionTrigger] string unixDatetime, string formatString) 
        {
            this.logger.LogInformation($"Starting FormatDateTime");

            string result = "";

            if (string.IsNullOrEmpty(unixDatetime))
            {
                return result;
            }

            long templ = long.Parse(Regex.Match(unixDatetime, @"-?\d+").Value);

            result = DateTimeOffset.FromUnixTimeMilliseconds(templ).ToString(formatString);

            if (result == "9999-12-31")
            {
                return "";
            }

            return result;
        }
    }
}