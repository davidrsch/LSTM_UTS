
###############################################################################
##                                                                           ##
##                       Shiny App - Global code                             ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#Possible file extensions:
#For text files
readdelim <- c("text","csv","tsv","fwf")
#For excel files
readexcel <- c("xlsx","xls")
#All together
readall <- c(readdelim,readexcel)

#Date time classes
Date_time_classes <- c("POSIXct","POSIXt")

#Warning classes
warningclasses <- c("simpleWarning", "warning", "condition")

#Error classes
errorclasses <- c("simpleError", "error", "condition")

#To find NA values in forecast variable
whichareNA <- function(x){
  
  index_of_nas <- c()
  
  for (i in 1:length(x)) {
    if(is.na(x[i])){
      index_of_nas[(length(index_of_nas)+1)] <- i
    }
  }
  
  return(index_of_nas)
}

#Function to create time series
createseriesvalues <- function( TS, transformations ){
  #To store all the time series in a list
  listofts <- list()
  
  for (serie in transformations) {
    
    #To store the original time serie data, even if Original is not selected,
    #because th training vectors of the original serie are needed for the
    #tests
    
    #To apply if time series Original is selected
      #Add original TS to listofts
      timeserie <- "original"
      listofts[[timeserie]] <- TS
    
    #To apply if time series First transformation is selected
    if(serie == "First transformation"){
      
      #To differenciate the time series until meets stationariti
      for(i in 1:length(TS)){
        valuedif <- diff(TS, differences = i)
        ADF <- adf.test(valuedif, alternative = "stationary")
        PP <- pp.test(valuedif, alternative = "stationary")
        
        #To stop when TS is stationary
        if(ADF$p.value <= 0.05 && PP$p.value <= 0.05){
          
          #Add firstrf TS to listofts
          timeserie <- "firstrf"
          listofts[[timeserie]] <- valuedif
          
          #Store in global env the different order applied in firstrf
          FirstTrfdfv <<- i
          break
        }else{}
        
      }
      
    }
    
    #To apply if time series Second transformation is selected
    if(serie == "Second transformation"){
      
      #Apply log transformation to the selected forecast value
      valuelog <- log(TS)
      
      #To differenciate the time series until meets stationariti
      for (i in 1:length(TS)) {
        valuedif <- diff(valuelog, differences = i)
        ADF <- adf.test(valuedif, alternative = "stationary")
        PP <- pp.test(valuedif, alternative = "stationary")
        
        #To stop when TS is stationary
        if(ADF$p.value <= 0.05 && PP$p.value <= 0.05){
          
          #Add secondtrf TS to listofts
          timeserie <- "secondtrf"
          listofts[[timeserie]] <- valuedif
          
          #Store in global env the different order applied in firstrf
          SecondTrfdfv <<- i
          break
        }else{}
        
      }
      
    }
    
  }
  
  return(listofts)
  
}

#Create scaled time series
createscaledseries <- function(TimeSeries, scales){
  #To store all the scaled time series in a list
  listofscaledts <- list()
  
  for (tsvalues in 1:length(TimeSeries)){
    
    for (scaledoptions in scales) {
      
      #Add exact value scale to listofscaledts
      scaledvalue <- paste0(names(TimeSeries)[tsvalues],"_exact")
      listofscaledts[[scaledvalue]] <- TimeSeries[[names(TimeSeries)[tsvalues]]]
      
      if(scaledoptions == "From 0 to 1"){
        #Apply from 0 to 1 scale to TS
        scaledts <- rescale(TimeSeries[[names(TimeSeries)[tsvalues]]],
                            to = c(0,1), from = c(min(TimeSeries[[names(TimeSeries)[tsvalues]]]),
                                                  max(TimeSeries[[names(TimeSeries)[tsvalues]]])))
        #Add from 0 to 1 value scale to listofscaledts
        scaledvalue <- paste0(names(TimeSeries)[tsvalues],"_0-1")
        listofscaledts[[scaledvalue]] <- scaledts
      }
      
      if(scaledoptions == "From -1 to 1"){
        #Apply from-1 to 1 scale to TS
        scaledts <- rescale(TimeSeries[[names(TimeSeries)[tsvalues]]],
                            to = c(-1,1),
                            from = c(min(TimeSeries[[names(TimeSeries)[tsvalues]]]),
                                     max(TimeSeries[[names(TimeSeries)[tsvalues]]])))
        #Add from 0 to 1 value scale to listofscaledts
        scaledvalue <- paste0(names(TimeSeries)[tsvalues],"_-1-1")
        listofscaledts[[scaledvalue]] <- scaledts
      }
      
    }
    
  }
  
  return(listofscaledts)
  
}

#Generate inputs
generate_inputs <- function(input_values, temporal_horizon){
  inputs <- input_values
  inputs <- replace(inputs,which(grepl("Same as TH",inputs)),temporal_horizon)
  inputs <- replace(inputs,which(grepl("Double of TH",inputs)),(2*temporal_horizon))
  inputs <- replace(inputs,which(grepl("Triple of TH",inputs)),(3*temporal_horizon))
  inputs <- unique(inputs)
  inputs <- as.numeric(inputs)
  return(inputs)
}

#Creating Training vectors
creatingrollingwindows <- function(trysclts, lookback, th, traiobsamount){
  #To store all rolling windows vectors(trainputs,trainoutputs,testinputs,testoutputs)
  #in a list
  listofRW <-list()
  
  for (serie in 1:length(trysclts)) {
    
    for (input in 1:length(lookback)) {
      
      #To create rolling windows vectors
      rolliwindows <- paste0(names(trysclts)[serie],"_",lookback[input],"inputs")
      listofRW[[rolliwindows]] <- list()
      
      #To decrease the size of the training sample in dependencie of the difference
      #order used in the transformations. This is donde because in order to compare
      #models effectiveness will be need equal amount of predictions.
      if(grepl("original",rolliwindows)){
        trainlength <- traiobsamount
      }
      if(grepl("firstrf",rolliwindows)){
        trainlength <- traiobsamount - FirstTrfdfv
      }
      if(grepl("secondtrf",rolliwindows)){
        trainlength <- traiobsamount - SecondTrfdfv
      }
      
      #Create and add the trainig inputs vector to the rolling windows vector
      traininputs <- "traininputs"
      traininputsrw <- t(
        sapply(1:(trainlength-(th+lookback[input]-1)),
               function(x) trysclts[[names(trysclts)[serie]]]
               [x:(x+lookback[input]-1)]))
      if(lookback[input] == 1){
        traininputsrw <- t(traininputsrw)
      }
      dim(traininputsrw) = c(dim(traininputsrw),1)
      listofRW[[rolliwindows]][[traininputs]] <- traininputsrw
      
      #Create and add the trainig outputs vector to the rolling windows vector
      traininoutputs <- "traininoutputs"
      traininoutputsrw <- t(
        sapply((lookback[input]+1):(trainlength-th+1),
               function(x) trysclts[[names(trysclts)[serie]]][x:(x+th-1)]))
      if(th == 1){
        traininoutputsrw <- t(traininoutputsrw)
      }
      listofRW[[rolliwindows]][[traininoutputs]] <- traininoutputsrw
      
      #Create and add the test inputs vector to the rolling windows vector
      testinput <- "testinput"
      testinputrw <- t(
        sapply((trainlength-(lookback[input]+th-2)):
                 (length(trysclts[[names(trysclts)[serie]]])-(th+lookback[input]-1)),
               function(x) trysclts[[names(trysclts)[serie]]]
               [x:(x+lookback[input]-1)]))
      if(lookback[input] == 1){
        testinputrw <- t(testinputrw)
      }
      dim(testinputrw) = c(dim(testinputrw),1)
      listofRW[[rolliwindows]][[testinput]] <- testinputrw
      
      #Create and add the test outputs vector to the rolling windows vector
      testoutput <- "testoutput"
      testoutputrw <- t(
        sapply((trainlength-th+2):
                 (length(trysclts[[names(trysclts)[serie]]])-th+1),
               function(x) trysclts[[names(trysclts)[serie]]]
               [x:(x+th-1)]))
      if(th == 1){
        testoutputrw <- t(testoutputrw)
      }
      listofRW[[rolliwindows]][[testoutput]] <- testoutputrw
      
    }
    
  }
  
  #Return the list with all the rolling windows vectors
  return(listofRW)
}

#Calculate the amount of model to build
amount_of_models_to_build <- function(transformofseries, scales,
                                      inputs, neurons, ScaledTS){
  amtb <- 0
  
  #If the user select the Original transformation the training vectors builded will
  #be use to buil, compile and fit models
  if(is.element("Original", transformofseries)){
    true_tv <- ScaledTS
    
    #If the user does not select the Original transformation skip the training
    #vectors that has this TS as base
  }else{
    contain_original <- which(grepl("original",names(ScaledTS)))
    true_tv <- ScaledTS[-(1:contain_original[length(contain_original)])]
    
  }
  
  if(is.element("Exact values", scales)){
    true_tv <- true_tv
  }else{
    contain_exact <- which(grepl("exact",names(true_tv)))
    true_tv <- true_tv[-(1:contain_exact[length(contain_exact)])]
    
  }
  
  for (option in inputs) {
    if(is.element("same as input", neurons)){
      models_per_option <- c(option,neurons[2:length(neurons)])
    }else{
      models_per_option <- neurons
    }
    models_per_option <- unique(models_per_option)
    amtb <- amtb + length(models_per_option)
  }
  amtb <- amtb * length(true_tv) 
  return(amtb)
}

#Build, compile and saving the models
build_and_compile_models <- function(tv, transformofseries, scales, neurons_amounts,
                                     th, epochs, path_of_directorio,
                                     amount_to_uppb_per_model,
                                     models_to_build){
  
  #To store the path of the models
  models <- list()
  #Set neurona as NULL
  neurona <- NULL
  #Store progress bar value
  progress_bar_value <- 15
  #Store models builded
  models_builded <- 0
  
  #If the user select the Original transformation the training vectors builded will
  #be use to buil, compile and fit models
  if(is.element("Original", transformofseries)){
    true_tv <- tv
    
    #If the user does not select the Original transformation skip the training
    #vectors that has this TS as base
  }else{
    contain_original <- which(grepl("original",names(tv)))
    true_tv <- tv[-(1:contain_original[length(contain_original)])]
    
  }
  
  if(is.element("Exact values", scales)){
    true_tv <- true_tv
  }else{
    contain_exact <- which(grepl("exact",names(true_tv)))
    true_tv <- true_tv[-(1:contain_exact[length(contain_exact)])]
    
  }
  
  for (training_vector in 1:length(true_tv)) {
    
    for (neurons in neurons_amounts) {
      #If the user select "sames as input" option in neurons amount options
      if(neurons == "same as inputs"){
        #Store the value of the inputs amount
        neurona <- dim(true_tv[[training_vector]][[1]])[2]
        neurona <- as.character(neurona)
        
        #If the input amount was also added for the user skip it to use it just
        #one time
        if(is.element(neurona,neurons_amounts)){
          
          #If is not already an option
        }else{
          neurona <- as.numeric(neurona)
          
        }
        #If the user does not select the option "same as input"
      }else{
        neurona <- as.numeric(neurons)
        
      }
      
      #If the neuron amount will be use
      if(is.numeric(neurona)){
        #Update progress bar value
        models_builded <- models_builded + 1
        update_modal_progress(
          text = paste0("Building models ", "[",models_builded, "/",
                        models_to_build, "] ",sprintf("(%02d%%)", round(progress_bar_value))),
          value = round(progress_bar_value) /100)
        
        #To name the models
        modelname <- paste0("model_",neurona,"nLSTM_",names(true_tv)[[training_vector]])
       
        #To build the models
        model <- keras_model_sequential()%>%
          layer_lstm(units = neurona, input_shape=c(dim(true_tv[[training_vector]][[1]])[2], 1))%>%
          layer_dense(th)
        #To compile the model
        model%>%
          compile( loss = "mse", optimizer='adam')
        #To fit the model
        model%>%
          fit(true_tv[[training_vector]][[1]],
              true_tv[[training_vector]][[2]],
              epochs = epochs,
              batch_size = 1,
              shuffle = F,
              verbose = 0)
        #Store the model directory
        model_directorio <- paste0(path_of_directorio,"/Models/",modelname,".hdf5")
        #Save model
        model%>%save_model_hdf5(model_directorio)
        #Store the model path 
        models[[modelname]] <- model_directorio
        
        k_clear_session()
        
        #Update progress bar value
        progress_bar_value <- progress_bar_value + amount_to_uppb_per_model
        update_modal_progress(
          text = paste0("Building models ", "[",models_builded, "/",
                        models_to_build, "] ",sprintf("(%02d%%)", round(progress_bar_value))),
          value = round(progress_bar_value) /100)
      }
      
    }
    
  }
  
  return(models)
}

#To find the min value of each row of a dataframe
rowMin <- function(df){
  if(!is.data.frame(df)){
    stop("'df' must be a data frame")
  }
  if(length(dim(df)) != 2){
    stop("'df' must be a two dimensions data frame")
  }else{
    Min <- c()
    for (row in 1:dim(df)[1]) {
      
      Min[row] <- min(as.numeric(df[row,]), na.rm = T)
      
    }
    return(Min)
  }
}

#To calculate the mean value of each row of a dataframe
rowMEAN <- function(df){
  if(!is.data.frame(df)){
    stop("'df' must be a data frame")
  }
  if(length(dim(df)) != 2){
    stop("'df' must be a two dimensions data frame")
  }else{
    Mean <- c()
    for (row in 1:dim(df)[1]) {
      
      Mean[row] <- mean(as.numeric(df[row,]), na.rm = T)
      
    }
    return(Mean)
  }
}

#To find the max value of each row of a dataframe
rowMax <- function(df){
  if(!is.data.frame(df)){
    stop("'df' must be a data frame")
  }
  if(length(dim(df)) != 2){
    stop("'df' must be a two dimensions data frame")
  }else{
    Max <- c()
    for (row in 1:dim(df)[1]) {
      
      Max[row] <- max(as.numeric(df[row,]), na.rm = T)
      
    }
    return(Max)
  }
}

#Testing models
evaluate_models <- function(trainingvectors, models, amountoftest,
                            series, test_set, lookback, th,
                            amount_to_uppb_per_test, path_of_directorio,
                            models_to_build){
  
  #Store progress bar value
  progress_bar_value <- 75
  #Number of model been use from total of models
  model_been_use <- 0
  
  #To store the estimate RMSE to obtain of using the evaluated model 
  Models <- rep(NA, models_to_build)
  RMSE <- rep(NA, models_to_build)
  resultofmodelevaluation <- data.frame(Models,RMSE)
  
  for (tv in 1:length(trainingvectors)) {
    
    #Store the numbers of the model build using the selected
    #training vector
    
    modelstotest <- which(grepl(names(trainingvectors)[tv],names(models)))
    
    #If there is not any model build with the selected training vector
    #(in case the Original time serie is no selected, because is necessary
    #to build it for the test) return nothing
    if(length(modelstotest) == 0){
      
    }
    if(length(modelstotest) > 0){
      #To store Min, Mean, Max value of predictions per model
      MMMmodel <- NULL
      MMMmodel <- data.frame(matrix(NA,
                                    nrow = th + test_set - 1,
                                    ncol = 3))
      
      #To do with the several models build with the selected training vector
      for (testmodel in 1: length(modelstotest)){
        
        #Update the number of model been use from total of models
        model_been_use <- model_been_use + 1
        
        #To store the mean RMSE of all test
        erroresoftest <- NULL
        erroresoftest <- c()
        
        #To store the min value of the predictions of all tests
        Minofpredictions <- NULL
        Minofpredictions <- data.frame(matrix(NA,
                                               nrow = th + test_set - 1,
                                               ncol = amountoftest))
        
        #To store the mean value of the predictions of all tests
        Meanofpredictions <- NULL
        Meanofpredictions <- data.frame(matrix(NA,
                                               nrow = th + test_set - 1,
                                               ncol = amountoftest))
        
        #To store the max value of the predictions of all tests
        Maxofpredictions <- NULL
        Maxofpredictions <- data.frame(matrix(NA,
                                              nrow = th + test_set - 1,
                                              ncol = amountoftest))
        
        #Load the model
        tousemodel <- load_model_hdf5(models[modelstotest][[testmodel]])
        
        for (test in 1:amountoftest) {
          
          #To store the predictions obtained
          predicciones <- NULL
          predicciones <- data.frame(matrix(NA,
                                            nrow = th + test_set - 1,
                                            ncol = test_set))
          
          #To store the mean RMSE of each test
          errores <- NULL
          errores <- c()
          
          #To store the model to use
          modeltouse <- NULL
          modeltouse <- tousemodel
          
          #Update progress bar value
          update_modal_progress(
            text = paste0("Test ","[", test, "/", amountoftest, "]",
                          " of ", "[", model_been_use, "/", models_to_build, "]",
                          " models ", sprintf("(%02d%%)", round(progress_bar_value))),
            value = round(progress_bar_value) /100)
          
          for (i in 1:test_set){
            
            #Store the vector to use as input to the predictions and
            #training
            inputtopasstomodel <- trainingvectors[[tv]][[3]][i,,]
            #Give the proper 3d
            dim(inputtopasstomodel) <- c(1, length(inputtopasstomodel), 1)
            
            #Real value of the predicted observations (To evaluate predictions)
            true_output <- trainingvectors[[paste0("original_",
                                                   "exact_",
                                                   lookback[1],
                                                   "inputs")]][[4]][i,]
            
            #Last know real value (To invert differences)
            true_input <- trainingvectors[[paste0("original_",
                                                  "exact_",
                                                  dim(trainingvectors[[tv]][[3]])[2],
                                                  "inputs")]][[3]][i,,]
            
            #Store the vector to use as output to traing the models
            outputtopasstomodel <- trainingvectors[[tv]][[4]][i,]
            #Give the proper 2d
            dim(outputtopasstomodel) <- c(1, length(outputtopasstomodel))
            
            #To obtain the predictions if the training vector selected
            #is build with the Original TS
            if(grepl("original", names(trainingvectors[tv]))){
              
              #Make the forecast
              if (grepl("exact",names(trainingvectors[tv]))){
                prediccion <- modeltouse%>%predict(inputtopasstomodel,
                                                   batch_size = 1)
              }
              if (grepl("0-1",names(trainingvectors[tv]))){
                prediccionscala <- modeltouse%>%predict(inputtopasstomodel,
                                                        batch_size = 1)
                prediccion <- rescale(prediccionscala, to = c(min(series[["original"]]),
                                                              max(series[["original"]])),
                                      from = c(0,1))
              }
              if (grepl("-1-1",names(trainingvectors[tv]))){
                prediccionscala <- modeltouse%>%predict(inputtopasstomodel,
                                                        batch_size = 1)
                prediccion <- rescale(prediccionscala, to = c(min(series[["original"]]),
                                                              max(series[["original"]])),
                                      from = c(-1,1))
              }
              
            }
            #To obtain the predictions if the training vector selected
            #is build with the First Transformation TS
            if(grepl("firstrf",names(trainingvectors[tv]))){
              
              #Make the forecast
              if (grepl("exact",names(trainingvectors[tv]))){
                predicciondif <- modeltouse%>%predict(inputtopasstomodel,
                                                      batch_size = 1)
                prediccion <- diffinv(predicciondif[1:th],
                                      differences = FirstTrfdfv,
                                      xi = true_input[
                                        (length(true_input)-FirstTrfdfv + 1):
                                          length(true_input)])
                prediccion <- prediccion[-(1:FirstTrfdfv)]
              }
              if (grepl("0-1",names(trainingvectors[tv]))||
                  grepl("-1-1",names(trainingvectors[tv]))){
                
                prediccionscala <- modeltouse%>%predict(inputtopasstomodel,
                                                        batch_size = 1)
                
                if(grepl("0-1",names(trainingvectors[tv]))){
                  
                  predicciondif <- rescale(prediccionscala, to = c(min(series[["firstrf"]]),
                                                                   max(series[["firstrf"]])),
                                           from = c(0,1))
                  
                }
                if(grepl("-1-1",names(trainingvectors[tv]))){
                  
                  predicciondif <- rescale(prediccionscala, to = c(min(series[["firstrf"]]),
                                                                   max(series[["firstrf"]])),
                                           from = c(-1,1))
                  
                }
                prediccion <- diffinv(predicciondif[1:th],
                                      differences = FirstTrfdfv,
                                      xi = true_input[
                                        (length(true_input)-FirstTrfdfv + 1):
                                          length(true_input)])
                prediccion <- prediccion[-(1:FirstTrfdfv)]
              }
              
            }
            #To obtain the predictions if the training vector selected
            #is build with the Second Transformation TS
            if(grepl("secondtrf",names(trainingvectors[tv]))){
              
              #Make the forecast
              if (grepl("exact",names(trainingvectors[tv]))){
                
                predicciondif <- modeltouse%>%predict(inputtopasstomodel, batch_size=1)
                prediccionlog <- diffinv(predicciondif[1:th],
                                         differences = SecondTrfdfv,
                                         xi = log(true_input)[
                                           (length(true_input)-SecondTrfdfv + 1):
                                             length(true_input)])
                prediccionlog <- prediccionlog[-(1:SecondTrfdfv)]
                prediccion <- exp(prediccionlog)
                
              }
              if (grepl("0-1",names(trainingvectors[tv]))||
                  grepl("-1-1",names(trainingvectors[tv]))){
                
                prediccionscala <- modeltouse%>%predict(inputtopasstomodel,
                                                        batch_size=1)
                
                if(grepl("0-1",names(trainingvectors[tv]))){
                  
                  predicciondif <- rescale(prediccionscala,
                                           to = c(min(series[["secondtrf"]]),
                                                  max(series[["secondtrf"]])),
                                           from = c(0,1))
                  
                }
                if(grepl("-1-1",names(trainingvectors[tv]))){
                  
                  predicciondif <- rescale(prediccionscala,
                                           to = c(min(series[["secondtrf"]]),
                                                  max(series[["secondtrf"]])),
                                           from = c(-1,1))
                  
                }
                prediccionlog <- diffinv(predicciondif[1:th],
                                         differences = SecondTrfdfv,
                                         xi = log(true_input)[
                                           (length(true_input)-SecondTrfdfv + 1):
                                             length(true_input)])
                prediccionlog <- prediccionlog[-(1:SecondTrfdfv)]
                prediccion <- exp(prediccionlog)
              }
              
            }
            #Evaluate and store the result in the error vector
            errores[i] <- rmse(actual = true_output,
                               predicted = prediccion[1:th])
            
            #Store the prediction on the predictions dataframe
            predicciones[i] <- c(rep(NaN,(i - 1)),
                                 prediccion[1:th],
                                 rep(NaN,(test_set - i)))
            
            #fit the with the new available inputs and outputs
            modeltouse %>%fit(
              inputtopasstomodel,
              outputtopasstomodel,
              batch_size = 1,
              epoch = 1,
              shuffle = F,
              verbose = 0)
            
          }
          
          k_clear_session()
          
          #Ad the result of one test to the list of each test
          erroresoftest[test] <- mean(errores)
          
          #Ad the min of one test to the list of each test
          Minofpredictions[test] <-  rowMin(predicciones)
          
          #Ad the mean of one test to the list of each test
          Meanofpredictions[test] <-  rowMEAN(predicciones)
          
          #Ad the max of one test to the list of each test
          Maxofpredictions[test] <-  rowMax(predicciones)
          
          #Update progress bar value
          progress_bar_value <- progress_bar_value + amount_to_uppb_per_test
          update_modal_progress(
            text = paste0("Test ","[", test, "/", amountoftest, "]",
                          " of ", "[", model_been_use, "/", models_to_build, "]",
                          " models ", sprintf("(%02d%%)", round(progress_bar_value))),
            value = round(progress_bar_value) /100)
          
        }
        
        MIN <- rowMin(Minofpredictions)
        MEAN <- rowMEAN(Meanofpredictions)
        MAX <- rowMax(Maxofpredictions)
        
        MMMmodel[1] <- MIN
        MMMmodel[2] <- MEAN
        MMMmodel[3] <- MAX
        colnames(MMMmodel) <- c("MIN","MEAN","MAX")
        
        #Save predictions min, mean and max values
        write.xlsx(MMMmodel,
                   file = paste0(path_of_directorio, "/www/db/predicciones/",
                                 names(models)[modelstotest][testmodel],".xlsx"))
        
        #Ad the normalized RMSE obtained in all test to the list of models results
        modelname <- names(models)[modelstotest][testmodel]
        
        resultofmodelevaluation$Models[modelstotest[[testmodel]]] <- modelname
        resultofmodelevaluation$RMSE[modelstotest[[testmodel]]] <- mean(erroresoftest)
        
      }
      
    }
    
  }
  
  return(resultofmodelevaluation)
  
}