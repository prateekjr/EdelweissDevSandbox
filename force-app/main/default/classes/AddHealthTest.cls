@isTest
public class AddHealthTest{
    static testMethod void test1(){
        AddHealth ctrl = new AddHealth();
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