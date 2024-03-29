@isTest
private class ProgressTrackerTaskModalTests {
    @TestSetup
    static void makeContactTaskAssignment(){
        Training_Task__c dummyTrainingTask = new Training_Task__c();
        dummyTrainingTask.Name = 'Task 1';
        dummyTrainingTask.Expected_Duration_In_Minutes__c = 12;
        dummyTrainingTask.Task_Type__c = 'Meeting';
        insert dummyTrainingTask;  
        
        Training_Task__c dummyTrainingTask2 = new Training_Task__c();
        dummyTrainingTask2.Name = 'Task 2';
        dummyTrainingTask2.Expected_Duration_In_Minutes__c = 15;
        dummyTrainingTask2.Task_Type__c = 'Meeting';
        insert dummyTrainingTask2; 

        Contact dummyContact = new Contact();
        dummyContact.LastName = 'Smith';
        dummyContact.Start_Date__c = Date.today();
        insert dummyContact;

        Training_Program__c dummyProgram = new Training_Program__c();
        dummyProgram.Name = 'First Program';
        dummyProgram.Duration_in_days__c = 5; 
        insert dummyProgram;

        List<Contact_Task_Assignment__c> testCtaList = new List<Contact_Task_Assignment__c>();
        
        Contact_Task_Assignment__c testCta = new Contact_Task_Assignment__c();
        testCta.Associated_Program__c = dummyProgram.Id;
        testCta.Contact__c = dummyContact.Id;
        testCta.Due_Day__c = Date.today();
        testCta.Training_Task__c = dummyTrainingTask.Id;
        testCta.Status__c = 'Not Started';
        testCtaList.add(testCta);

        Contact_Task_Assignment__c testCta2 = new Contact_Task_Assignment__c();
        testCta2.Associated_Program__c = dummyProgram.Id;
        testCta2.Contact__c = dummyContact.Id;
        testCta2.Due_Day__c = Date.today();
        testCta2.Training_Task__c = dummyTrainingTask2.Id;
        testCta2.Status__c = 'Not Started';
        testCtaList.add(testCta2);
        insert testCtaList;

        Program_Contact_Assignment__c manipulatedPca = new Program_Contact_Assignment__c();
        manipulatedPca.Start_Date__c = Date.today();
        manipulatedPca.Training_Program__c = dummyProgram.Id;
        manipulatedPca.Contact__c = dummyContact.Id;
        manipulatedPca.Time_Taken__c = 0;
        insert manipulatedPca;
    }

    @isTest
    static void populateModalTest() {
        Contact dummyContact = [SELECT Id, LastName 
                                    FROM Contact 
                                    LIMIT 1];
        Training_Program__c dummyProgram = [SELECT Id, Name 
                                                FROM Training_Program__c 
                                                LIMIT 1];
        List<Contact_Task_Assignment__c> result = ProgressTrackerTaskModal.populateModal(dummyContact.Id, dummyProgram.Id, '');
        System.assertEquals('First Program', result[0].Associated_Program__r.Name);
    }

    @isTest
    static void populateModalWithSearchTest() {
        Contact dummyContact = [SELECT Id, LastName 
                                    FROM Contact 
                                    LIMIT 1];
        Training_Program__c dummyProgram = [SELECT Id, Name 
                                                FROM Training_Program__c 
                                                LIMIT 1];
        List<Contact_Task_Assignment__c> result = ProgressTrackerTaskModal.populateModal(dummyContact.Id, dummyProgram.Id, 'Task 1');
        System.assertEquals('Task 1', result[0].Training_Task__r.Name);
    }

    @isTest
    static void completeTrainingTaskTest() {
        Contact_Task_Assignment__c cta = [SELECT Status__c, Completion_Date__c 
                                                    FROM Contact_Task_Assignment__c
                                                    LIMIT 1];
        Contact_Task_Assignment__c result = ProgressTrackerTaskModal.completeTrainingTask(cta.Id);
        System.assertEquals('Complete', result.Status__c);
    }

    @isTest
    static void bulkCompleteTrainingTaskTest() {
        List<Contact_Task_Assignment__c> ctaList = [SELECT Status__c, Completion_Date__c 
                                                    FROM Contact_Task_Assignment__c];

        List<Id> idList = new List<Id>();
        for (Contact_Task_Assignment__c cta : ctaList){
            idList.add(cta.Id);
        }
        List<Contact_Task_Assignment__c> result = ProgressTrackerTaskModal.bulkCompleteTrainingTask(idList);

        System.assertEquals(2, result.size());
        for(Contact_Task_Assignment__c resultCta: result){
            System.assertEquals('Complete', resultCta.Status__c);
        }
    }
}
