({
    doInit : function(component, event, helper) {
        
        component.set('v.wColumns', [
            {label: 'Sensor ID', fieldName: 'Name', type: 'text', cellAttributes: { alignment: "center" }},
            {label: 'Base Station', fieldName: 'Base_Station__c', type: 'text', cellAttributes: { alignment: "center" }},
            {label: 'Status', fieldName: 'Status__c', type: 'text', cellAttributes: { alignment: "center" }},
            {label: 'Model', fieldName: 'Model__c', type: 'text', cellAttributes: { alignment: "center" }}
        ]);
        
        var action = component.get("c.getStartInfo");
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                
                for(var i=0; i<obj.length; i++){
                    obj[i].Base_Station__c = obj[i].Base_Station__r.Name;
                }
                component.set("v.sensorList", obj);
            }
            else if(state === "ERROR"){
                component.set("v.displayError", true);
                component.set("v.displayBody", false);
                var errors = action.getError();
                if (errors) {
                    alert('No access, contact the administrator.');
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    handleUploadFinished: function (component, event, helper) {
        
        var uploadedFiles = event.getParam("files");
        var elementId = uploadedFiles[0].documentId;
        
        var action = component.get("c.getFileInfo");
        action.setParams({
            fileId: elementId
        });
        $A.enqueueAction(action);
        
        helper.initHelper(component);     
    },
    
})