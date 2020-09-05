({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.checkAccessToFiledsAndObjects");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var status = response.getReturnValue();
                if(status == 'ACCESS'){
                    helper.initHelper(component);
                }
                else{
                    component.set("v.displayError", true);
                    component.set("v.displayBody", false);
                }
            }
            else {
                console.log("Failed with state: " + state);
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