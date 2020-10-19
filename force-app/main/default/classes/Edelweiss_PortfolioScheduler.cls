global class Edelweiss_PortfolioScheduler implements Schedulable {
    global void execute(SchedulableContext SC){
        Database.executeBatch(new Edelweiss_BatchUpdatePortfolio(), 500);
    } 
}