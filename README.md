# About
This project seeks to harvest insight about Denver crimes by combining crime data with census data, weather data, and more to answer key questions, including the following:

### Temporal Trends
- How do crimes vary by neighborhood over time?
- Are certain types of crimes more prevalent during particular times of the year?
- What's the trend in reporting delay?

### Weather-Crime Correlations
- Are auto thefts more likely to occur on snowy days?
- Do aggravated assaults occur more frequently on days with extreme temperatures?

### Census-Adjusted Insights
- Which neighborhoods have the highest crime rates per capita?
- Is there a correlation between home ownership and violent crimes rate?
Do neighborhoods with different age profiles have different crime rates?

# How to Build

The project includes a Docker file, docker-compose file, and python script in the app/ directory that will migrate the CSV data into a local Postgres database for you to use. However, there is no requirement to build the project in this way if you wish to simply use the CSV files.

```bash
# Open a terminal (Command Prompt or PowerShell for Windows, Terminal for macOS or Linux)

# Ensure Git is installed
# Visit https://git-scm.com to download and install console Git if not already installed

# Clone the repository
git clone https://github.com/zrich1114/denver-crime.git

# Navigate to the project directory
cd denver-crime

# Build the project using docker-compose
docker-compose up --build

# Stop the containers and remove the volumes
docker-compose down -v
```
