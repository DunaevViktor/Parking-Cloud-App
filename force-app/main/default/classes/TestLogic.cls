@isTest private class TestLogic {
    
    @isTest static void testStartInfoFunc() {
        Base_Station__c bs = new Base_Station__c();
        bs.Name = 'Test Base';
        insert bs;
        
        Sensor__c sensor = new Sensor__c();
        sensor.Name = '123abc';
        sensor.Status__c = 'Works';
        sensor.Model__c = 'model';
        sensor.Base_Station__c = bs.Id;
        insert sensor;
        
        List<Sensor__c> listSensors = ParkingCloudApexController.getStartInfo();
        System.assertEquals('123abc', listSensors[0].Name); 
    }
    
    @isTest static void testLogic(){
        Base_Station__c bs = new Base_Station__c();
        bs.Name = 'Test Base';
        insert bs;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Sensors',
            PathOnClient = 'Sensors.csv',
            VersionData = Blob.valueOf('base,id,status,model\n' +
                                       'Test Base,id123re,Works,sony45\n' +
                                       'Minsk Base,id456re,Works,huaweis3\n' +
                                       'Minsk Base,id789re,Bad Test,huaweis5'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE
                                           Id = :contentVersion_1.Id LIMIT 1];
        
        String fileId = contentVersion_2.ContentDocumentId;
        ParkingCloudApexController.getFileInfo(fileId);
        
        List<Sensor__c> listS = [SELECT Id, Name FROM Sensor__c];
        List<Base_Station__c> listB = [SELECT Id, Name FROM Base_Station__c];
        System.assertEquals(2, listS.size());
        System.assertEquals(2, listB.size());
        
        List<String> str = new List<String>();
        String str0 = 'base,id,status,model';
        str.add(str0);
        String str1 = 'New Base,id123re,Broken,sony45';
        str.add(str1);
        
        List<String> corr = ParkingCloudApexController.isCorrectAndNotDuplicate(str);
        List<Sensor__c> listS1 = [SELECT Id, Name FROM Sensor__c];
        List<Base_Station__c> listB1 = [SELECT Id, Name FROM Base_Station__c];
        System.assertEquals(2, listS1.size());
        System.assertEquals(3, listB1.size());
        
        List<String> str2 = new List<String>();
        String str3 = 'base,id,status,model';
        str2.add(str3);
        String str4 = 'Minsk Base,id123re,Broken,sony45';
        str2.add(str4);
        
        List<String> corr1 = ParkingCloudApexController.isCorrectAndNotDuplicate(str2);
        List<Sensor__c> listS2 = [SELECT Id, Name FROM Sensor__c];
        List<Base_Station__c> listB2 = [SELECT Id, Name FROM Base_Station__c];
        System.assertEquals(2, listS2.size());
        System.assertEquals(3, listB2.size());
        
    }
    
}