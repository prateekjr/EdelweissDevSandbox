({
	doInit : function(component, event, helper) {
        var ResultMap = component.get("v.fieldSetMap")[component.get("v.fieldSetName")];
        var Col1List = ResultMap['Col1'];
        var Col2List = ResultMap['Col2'];
   		
        Col1List = (Col1List==null ? new Array() : Col1List);
        Col2List = (Col2List==null ? new Array() : Col2List);
        var arrLen = (Col1List.length > Col2List.length) ?  Col1List.length : Col2List.length;
      	var result = [];
        
        for(var i = 0 ; i<arrLen;i++ ){
               var innerList = [];
        	   innerList[innerList.length] = Col1List[i];
			   if(component.get("v.isSingleColumnSection") != true)
               		innerList[innerList.length] = Col2List[i]; 	
			   result[i] = innerList;
        }
        component.set("v.iterateLst" , result);
        
        
        component.set("v.leftPanelLst" ,Col1List);
        component.set("v.rightPanelLst" ,Col2List);
	}
})