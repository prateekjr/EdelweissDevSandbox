({
	helperFun : function(component,event,secId) {
	  	var acc = component.find(secId);
        var divId = secId.replace('toggel','div');
        var iconId1 = secId.replace('toggel','icon1');
        var iconId2 = secId.replace('toggel','icon2');
        var divele = document.getElementById(divId);
        $A.util.toggleClass(divele, 'slds-show');  
        $A.util.toggleClass(divele, 'slds-hide');  
        var icon1ele = document.getElementById(iconId1);
        $A.util.toggleClass(icon1ele, 'slds-show');  
        $A.util.toggleClass(icon1ele, 'slds-hide');
        var icon2ele = document.getElementById(iconId2);
        $A.util.toggleClass(icon2ele, 'slds-show');  
        $A.util.toggleClass(icon2ele, 'slds-hide');
	}
})