namespace demo.app1
{
    using System;
    public class App1Token
    {
        /// <summary>
        /// Gets or sets the zip code.
        /// </summary>
        public string Token { get; set; }

        /// <summary>
        /// Gets or sets the current weather.
        /// </summary>
        public string Token_Type { get; set; }

        /// <summary>
        /// Gets or sets the low temperature for the day.
        /// </summary>
        public DateTime TokenExpiry { get; set; }
    }
}