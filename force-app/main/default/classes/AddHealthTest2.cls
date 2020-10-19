@isTest
public class AddHealthTest2 {
	static testMethod void test1(){
        AddHealth2 ctrl = new AddHealth2();
        ctrl.method1();
        ctrl.method2();
        ctrl.method3();
        ctrl.method5();
         ctrl.method6();
          ctrl.method7();
           ctrl.method8();
		   system.assertNotEquals(ctrl.a, null); 
    }
}