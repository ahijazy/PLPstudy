library(ROhdsiWebApi)

baseUrl <-"https://pioneer.hzdr.de/WebAPI"

token <- 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhaGlqYXp5QGVpc2JtLm9yZyIsIlNlc3Npb24tSUQiOm51bGwsImV4cCI6MTY5ODE5MzcxOH0.G1vZqSYQCvMyRXFQM-UhmAkvLY7huOff1NH6D78eN86yV6_rjl7rHJH9_u3nwCa_0OteFjbm7jxSwD_oDgjvUQ'
setAuthHeader(baseUrl = baseUrl, token)

# after inserting the cohorts
 
# Insert cohort definitions from ATLAS into package -----------------------
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreate.csv",
baseUrl = baseUrl ,
insertTableSql = TRUE,
insertCohortCreationR = TRUE,
generateStats = FALSE,
packageName = "PioneerMetastaticAE")