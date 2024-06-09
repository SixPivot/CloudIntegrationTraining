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

    /// <summary>
    /// Represents the App1Helpers flow invoked function.
    /// </summary>
    public class GetApp1Token
    {
        private readonly ILogger<GetApp1Token> logger;
        private readonly IConfiguration _configuration;

        private readonly App1Helper _helpers;

        public GetApp1Token(ILoggerFactory loggerFactory, IConfiguration configuration)
        {
            _configuration = configuration;
            logger = loggerFactory.CreateLogger<GetApp1Token>();
            _helpers = new App1Helper(loggerFactory, configuration);
        }

        /// <summary>
        /// Executes the logic app workflow.
        /// </summary>

        [FunctionName("GetApp1Token")]
        public async Task<App1Token> Run([WorkflowActionTrigger] string runId) 
        {
            this.logger.LogInformation($"Starting GetApp1Token  for runId {runId}");

            var App1Token = new App1Token();
            App1Token.TokenExpiry = DateTime.Now.AddSeconds(-60);

            string clientid = "";
            string userid = ""; 
            string companyid = ""; 
            string tokenurl = ""; 
            string idpurl = ""; 
            string privatekey = ""; 
            string granttype = "";

            // Read configuration data
            // string keyName = "AzureWebJobsStorage";
            // string message = _configuration[keyName];
            // this.logger.LogInformation($"config value - AzureWebJobsStorage {message}");
            clientid = _configuration["App1:ClientId"];
            userid = _configuration["App1:UserId"]; 
            companyid = _configuration["App1:CompanyId"];
            tokenurl = _configuration["App1:TokenURL"];
            idpurl = _configuration["App1:IdpURL"];
            privatekey = _configuration["App1:PrivateKey"];
            granttype = _configuration["App1:GrantType"];

            this.logger.LogInformation("GetApp1Token After Get Config");

            // check if existing token is in storage
            App1Token = await _helpers.RetrieveTokenFromStorage(App1Token);

            // check if existing token is expired and is good for 5 more minutes
            if (App1Token.TokenExpiry > DateTime.Now.AddMinutes(5))
            {
                this.logger.LogInformation("GetApp1Token Valid Token Found");
                return App1Token;
            }

            this.logger.LogInformation("GetApp1Token Valid Token Not Found");

            // var rootUrl = "https://" + dataCentreUrl;
            // RestClient client = new RestClient(rootUrl);

            string IDPUrl = idpurl;
            string TokenUrl = tokenurl;
            if (!IDPUrl.StartsWith("http"))
            {
                IDPUrl = "https://" + IDPUrl;
            }
            RestClient idpClient = new RestClient(IDPUrl);
            var idpRequest = new RestRequest(Method.POST);
            idpRequest.AddHeader("Accept", "*/*");
            idpRequest.AddHeader("content-type", "application/x-www-form-urlencoded");
            idpRequest.AddParameter("application/x-www-form-urlencoded", $"client_id={clientid}&user_id={userid}&token_url={tokenurl}&private_key={privatekey}", ParameterType.RequestBody);

            var idpResponse = idpClient.Execute(idpRequest);

            if (idpResponse.StatusCode == HttpStatusCode.OK)
            {
                if (!TokenUrl.StartsWith("http"))
                {
                    TokenUrl = "https://" + TokenUrl;
                }
                RestClient tokenClient = new RestClient(TokenUrl);
                var tokenRequest = new RestRequest(Method.POST);
                tokenRequest.AddHeader("Accept", "*/*");
                tokenRequest.AddHeader("content-type", "application/x-www-form-urlencoded");
                tokenRequest.AddParameter("application/x-www-form-urlencoded", $"client_id={clientid}&company_id={companyid}&grant_type={granttype}&assertion={idpResponse.Content}", ParameterType.RequestBody);
                var tokenResponse = tokenClient.Execute(tokenRequest);

                if (tokenResponse.StatusCode == HttpStatusCode.OK)
                {
                    var data = JsonConvert.DeserializeObject<JObject>(tokenResponse.Content);
                    var access_token = data["access_token"].ToString();
                    var token_type = data["token_type"].ToString();
                    var expires_in = data["expires_in"].ToString();
                    App1Token.TokenExpiry = DateTime.Now.AddSeconds(Convert.ToDouble(expires_in));
                    App1Token.Token_Type = token_type;
                    App1Token.Token = access_token;
                    this.logger.LogInformation($"Token values - TokenExpiry {App1Token.TokenExpiry}");
                    this.logger.LogInformation($"Token values - Token_Type {App1Token.Token_Type}");
                    // store token in storage
                    _helpers.SaveTokenToStorage(App1Token);
                }
                else
                {
                    this.logger.LogError($"Failed to get SF Token - statuscode {tokenResponse.StatusCode} content {tokenResponse.Content}");
                    throw new Exception($"Failed to get SF Token - statuscode {tokenResponse.StatusCode} content {tokenResponse.Content}");
                }
            }
            else
            {
                this.logger.LogError($"Failed to get SF IDP - statuscode {idpResponse.StatusCode} content {idpResponse.Content}");
                throw new Exception($"Failed to get SF IDP - statuscode {idpResponse.StatusCode} content {idpResponse.Content}");
            }
            
            return App1Token;
        }
    }
}