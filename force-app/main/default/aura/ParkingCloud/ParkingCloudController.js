({
    doInit : function(component, event, helper) {
        helper.initHelper(component);
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