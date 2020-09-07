public class ParkingCloudApexController {
    
    @AuraEnabled
    public static List<String> isCorrectAndNotDuplicate(List<String> dataFromFile){
        List<String> preCorrectList = new List<String>();
        List<String> correctList = new List<String>();
        List<String> forInsert = new List<String>();
        List<String> forUpdate = new List<String>();
        List<String> idOfUpdate = new List<String>();
        List<Sensor__c> updateSensor = new List<Sensor__c>();
        
        //Checking the input data for correctness
        for(Integer i=1; i<dataFromFile.size(); i++){
            List<String> tokens = dataFromFile[i].split(',');
            
            if( tokens[0] == '' || tokens[1] == '' || tokens[2] == '' || (tokens.size()!=4) || 
               (tokens[2]!='Works' && tokens[2]!='Broken' && tokens[2]!='Renovated') ){
                   System.debug('Invalid string! This sensor is skipped!');
               }
            else{
                preCorrectList.add(dataFromFile[i]);
            }   
        }
        
        //Checking input data for duplicates
        Set<String> currId = new Set<String>();
        for(Integer h=0; h<preCorrectList.size(); h++){
            List<String> tk = preCorrectList[h].split(',');
            if(currId.contains(tk[1]) == true){
                System.debug('Duplicated ID! This sensor is skipped!');
            }
            else{
                currId.add(tk[1]);
                correctList.add(preCorrectList[h]);
            }
        }
        
        List<Sensor__c> sensorBD = [SELECT Id, Name, Base_Station__c FROM Sensor__c];
        
        //Dividing input data into data for loading and for updating
        for(Integer j=0; j<correctList.size(); j++){
            List<String> subStr = correctList[j].split(',');
            Boolean dubl = false;
            for(Integer k=0; k<sensorBD.size(); k++){
                if(subStr[1] == sensorBD[k].Name){
                    forUpdate.add(correctList[j]);
                    idOfUpdate.add(sensorBD[k].Id);
                    dubl = true;
                }
            }
            if(dubl == false){
                forInsert.add(correctList[j]);
            }
        }
        
        //Updating existing sensor data
        if(forUpdate.size() > 0){
            Set<String> newBaseStationNames = new Set<String>();
            List<String> deferredInfo = new List<String>();
            List<String> idForNewUpdate = new List<String>();
            
            for(Integer l=0; l<forUpdate.size(); l++){
                List<String> subStr1 = forUpdate[l].split(',');
                
                Sensor__c item = new Sensor__c();
                item.Id = idOfUpdate[l];
                item.Name = subStr1[1];
                item.Status__c = subStr1[2];
                item.Model__c = subStr1[3];
                
                List<Base_Station__c> currBase = [SELECT Id, Name FROM Base_Station__c WHERE Name =: subStr1[0]];
                //Updating sensors with existing Base_Station__c
                if(currBase.size() > 0){
                    item.Base_Station__c = currBase[0].Id;
                    updateSensor.add(item);
                }
                else{
                    deferredInfo.add(forUpdate[l]);
                    newBaseStationNames.add(subStr1[0]);
                    idForNewUpdate.add(idOfUpdate[l]);
                }              
            }
            
            //Updating sensors with new Base_Station__c
            if(newBaseStationNames.size() > 0){
                List<Base_Station__c> toInsertBaseStation = new List<Base_Station__c>();
                
                String newBaseNames = newBaseStationNames.toString();
                String subStr2 = newBaseNames.substring(1, newBaseNames.length()-1);
                List<String> arrOfNewBaseNames = subStr2.split(',');
                for(Integer j=0; j<arrOfNewBaseNames.size(); j++){
                    Base_Station__c newBase = new Base_Station__c();
                    newBase.Name = arrOfNewBaseNames[j];
                    toInsertBaseStation.add(newBase);
                }
                
                if(toInsertBaseStation.size() > 0){
                    insert toInsertBaseStation;
                }
                
                for(Integer k=0; k<deferredInfo.size(); k++){
                    List<String> newInfoDeferred = deferredInfo[k].split(',');
                    String baseNameDeferred = newInfoDeferred[0];
                    List<Base_Station__c> currBaseDeferred = [SELECT Id, Name FROM Base_Station__c WHERE Name =: baseNameDeferred];
                    
                    Sensor__c newItemD = new Sensor__c();
                    newItemD.Id = idForNewUpdate[k];
                    newItemD.Name = newInfoDeferred[1];
                    newItemD.Status__c = newInfoDeferred[2];
                    newItemD.Model__c = newInfoDeferred[3];
                    newItemD.Base_Station__c = currBaseDeferred[0].Id;
                    
                    updateSensor.add(newItemD);
                }
            }   
        }
        
        if(updateSensor.size() > 0){
            update updateSensor;          
        }
        
        return forInsert;
    }
    
    @AuraEnabled
    public static void getFileInfo(String fileId){
        
        //Processing information from a file
        ContentVersion fileContent = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: fileId
                                      AND IsLatest = true];
        Blob data = fileContent.VersionData;
        String allInfo = data.toString();
        List<String> arrOfSensor = allInfo.split('\n');
        List<String> correctData = isCorrectAndNotDuplicate(arrOfSensor);
        
        List<Sensor__c> toInsertSensor = new List<Sensor__c>();
        Set<String> newBaseStationNames = new Set<String>();
        List<Base_Station__c> toInsertBaseStation = new List<Base_Station__c>();
        List<String> deferredInfo = new List<String>();
        
        for(Integer i=0; i<correctData.size(); i++){
            List<String> newInfo = correctData[i].split(',');
            
            String baseName = newInfo[0];
            List<Base_Station__c> currBase = [SELECT Id, Name FROM Base_Station__c WHERE Name =: baseName];
            String baseLookup;
            
            //Inserting sensors with existing Base_Station__c
            if(currBase.size() > 0){
                baseLookup = currBase[0].Id;
                
                Sensor__c newItem = new Sensor__c();
                newItem.Name = newInfo[1];
                newItem.Status__c = newInfo[2];
                newItem.Model__c = newInfo[3];
                newItem.Base_Station__c = baseLookup;
                
                toInsertSensor.add(newItem);
            }
            else{
                deferredInfo.add(correctData[i]);
                newBaseStationNames.add(newInfo[0]);
            }    
        }
        
        //Inserting sensors with new Base_Station__c
        if(newBaseStationNames.size() > 0){
            String newBaseNames = newBaseStationNames.toString();
            String subStr = newBaseNames.substring(1, newBaseNames.length()-1);
            List<String> arrOfNewBaseNames = subStr.split(',');
            for(Integer j=0; j<arrOfNewBaseNames.size(); j++){
                Base_Station__c newBase = new Base_Station__c();
                newBase.Name = arrOfNewBaseNames[j];
                toInsertBaseStation.add(newBase);
            }
            
            if(toInsertBaseStation.size() > 0){
                insert toInsertBaseStation;
            }
            
            for(Integer k=0; k<deferredInfo.size(); k++){
                List<String> newInfoDeferred = deferredInfo[k].split(',');
                String baseNameDeferred = newInfoDeferred[0];
                List<Base_Station__c> currBaseDeferred = [SELECT Id, Name FROM Base_Station__c WHERE Name =: baseNameDeferred];
                
                Sensor__c newItemD = new Sensor__c();
                newItemD.Name = newInfoDeferred[1];
                newItemD.Status__c = newInfoDeferred[2];
                newItemD.Model__c = newInfoDeferred[3];
                newItemD.Base_Station__c = currBaseDeferred[0].Id;
                
                toInsertSensor.add(newItemD);
            }
        }
        
        
        if(toInsertSensor.size() > 0){
            insert toInsertSensor;
        }
    }
    
    @AuraEnabled
    public static List<Sensor__c> getStartInfo(){
        
        //Checks access to Objects
        if(!Schema.sObjectType.Sensor__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        if(!Schema.sObjectType.Base_Station__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        //Checks access to Fields(necessary or all)
        String[] baseStationFields = new String[] {'Id', 'Name'};
            Map<String, Schema.SObjectField> mapBS = Schema.SObjectType.Base_Station__c.fields.getMap();
        for (String fieldToCheck : baseStationFields) {
            if (!mapBS.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
        
        String[] sensorFields = new String[] {'Id', 'Name', 'Status__c', 'Model__c', 'Base_Station__c'};
            Map<String, Schema.SObjectField> mapSensorField = Schema.SObjectType.Sensor__c.fields.getMap();
        for (String fieldToCheck : sensorFields) {
            if (!mapSensorField.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
        
        //Getting data to display
        List<Sensor__c> allInfo = new List<Sensor__c>();
        allInfo = [SELECT Name, Base_Station__c, Base_Station__r.Name, Status__c, Model__c FROM Sensor__c];
        return allInfo;
    }
      
}