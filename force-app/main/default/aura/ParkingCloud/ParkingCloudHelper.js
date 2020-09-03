({
    initHelper: function (component) {
        
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
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
})