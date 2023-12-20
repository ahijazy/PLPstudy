
execute_plp=function(cdmDatabaseSchema=cdmDatabaseSchema,
                    vocabularyDatabaseSchema = cdmDatabaseSchema,
                    cohortDatabaseSchema = cohortDatabaseSchema,
                    cohortTable =  cohortTable,
                    GenerateCohorts = TRUE,
                    tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
                    outputFolder=outputFolder,
                    incrementalFolder = file.path(outputFolder, "incrementalFolder"),
                    databaseId =   databaseId,
                    packageWithCohortDefinitions = "PLPstudy",
                    cohortIds = NULL,
                    databaseName = databaseId,
                    databaseDescription = databaseDescription,
                    extraLog = NULL) 
 {


if(GenerateCohorts==TRUE)
    { 
        cohort_generation(connectionDetails= connectionDetails ,
                    cdmDatabaseSchema = cdmDatabaseSchema,
                    vocabularyDatabaseSchema = cdmDatabaseSchema,
                    cohortDatabaseSchema = cohortDatabaseSchema,
                    cohortTable = cohortTable,
                    tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
                    outputFolder= outputFolder,
                    incrementalFolder = file.path(outputFolder, "incrementalFolder"),
                    databaseId = databaseId,
                    packageWithCohortDefinitions = "PLPstudy",
                    cohortIds = NULL,
                    minCellCount = 5,
                    databaseName = databaseName,
                    databaseDescription = databaseDescription,
                    extraLog = NULL) 

    }

# Create the PLP database details 
DatabaseDetails=PatientLevelPrediction::createDatabaseDetails (connectionDetails,
                            cdmDatabaseSchema=cdmDatabaseSchema, 
                            cdmDatabaseName=databaseName, 
                            cdmDatabaseId= databaseId,
                            tempEmulationSchema = cdmDatabaseSchema,
                            cohortDatabaseSchema = cohortDatabaseSchema, 
                            cohortTable = cohortTable,
                            outcomeDatabaseSchema = cohortDatabaseSchema, 
                            outcomeTable = cohortTable )

# The first step is to select the variables that will be used in the model:
# this is done by creating a covariate setting object using the createCovariateSettings
# function from the FeatureExtraction package.

#Covariate setting 1:
covSet1=FeatureExtraction::createCovariateSettings(
  useDemographicsAge = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useMeasurementMediumTerm = TRUE,
  useCharlsonIndex = TRUE)

#Covariate setting 2:
covSet2=FeatureExtraction::createCovariateSettings(
  useDemographicsAge = TRUE,
  useMeasurementMediumTerm = TRUE,
  useMeasurementLongTerm = TRUE,
  useMeasurementValueLongTerm = TRUE,
  useMeasurementValueMediumTerm = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useConditionGroupEraMediumTerm = TRUE,
  useConditionOccurrenceLongTerm = TRUE,
  useConditionOccurrenceMediumTerm = TRUE,
  useDrugEraLongTerm = TRUE,
  useDrugEraMediumTerm = TRUE,
  useDrugGroupEraLongTerm = TRUE,
  useDrugGroupEraMediumTerm = TRUE,
  useDrugGroupEraShortTerm = TRUE,
  useProcedureOccurrenceLongTerm = TRUE,
  useProcedureOccurrenceMediumTerm = TRUE,
  useCharlsonIndex = TRUE)

 
#population settings:
populationSettings <- PatientLevelPrediction::createStudyPopulationSettings(
  washoutPeriod = 0,
  firstExposureOnly = FALSE,
  removeSubjectsWithPriorOutcome = FALSE,
  priorOutcomeLookback = 1,
  riskWindowStart = -1,
  riskWindowEnd = 365,
  startAnchor =  'cohort start',
  endAnchor =  'cohort start',
  minTimeAtRisk = 30,
  requireTimeAtRisk = FALSE,
  includeAllOutcomes = TRUE
)

#split settings  
splitSettings <-  PatientLevelPrediction::createDefaultSplitSetting(
trainFraction = 0.75,
testFraction = 0.25,
type = 'stratified',
nfold = 3,
splitSeed = 1234
)

# preprocess settings
preprocessSettings <- PatientLevelPrediction::createPreprocessSettings(
  minFraction = 0.001,
  normalize = T,
  removeRedundancy = T
)

# first model design #using AdaBoost
model1=PatientLevelPrediction::createModelDesign(
    targetId  =1022,
    outcomeId = 777, 
    restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(),   
    populationSettings = populationSettings,
    covariateSettings =  covSet1, 
    featureEngineeringSettings = NULL,
    sampleSettings = NULL, 
    preprocessSettings = preprocessSettings,
    modelSettings = PatientLevelPrediction::setAdaBoost(), 
    splitSettings = splitSettings  )
# second model desi
model2=PatientLevelPrediction::createModelDesign(
    targetId  =1040,
    outcomeId = 777, 
    restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(), 
    populationSettings = populationSettings,
    covariateSettings =  covSet2, 
    featureEngineeringSettings = NULL,
    sampleSettings = NULL, 
    preprocessSettings = preprocessSettings,
    modelSettings = PatientLevelPrediction::setAdaBoost(), 
    splitSettings = splitSettings  )

#run the models
PatientLevelPrediction::runMultiplePlp (databaseDetails =DatabaseDetails  ,
 modelDesignList = list(model1,model2),
  saveDirectory =  outputFolder, 
    sqliteLocation = file.path(outputFolder, "sqlite"))  
 }
