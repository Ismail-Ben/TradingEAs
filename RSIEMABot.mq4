#include <TradingFunctions2.mqh>

int rsiPeriod = 7;
int emaPeriod = 100;
int magicNumber = 1111;
double stopLoss = 0.0;
double takeProfit = 0.0 ;
int swingRange = 10;
double stopMargin = 20.0 *_Point * 10;
double lotsToTrade = 1.0;
double profitMargin = 10.0 * _Point *10;
datetime timeOfTick = 0;


// Improvement options:
// smaller profits, make dynamic profits that change with the rsi
//trade during newyork london
//check rsi on last 4 or 3 bars


void OnTick()
  {
    if( isNewCandle() /*TimeCurrent()- timeOfTick >(Period()*60.0/60)*/){
        if (OrdersTotal()<1){
        
           // Print("****",RSIMA(rsiPeriod,emaPeriod));
            
            if(longRSIMA(rsiPeriod,emaPeriod)){
           
                stopLoss = swingLow(swingRange)- (1 * _Point * 10);
                
                takeProfit = Ask + (Ask - stopLoss);
                
                if (stopLoss> Bid)stopLoss = Ask - stopMargin;
                
                lotsToTrade = optimalLotSize(1,stopLoss,Ask);
                
                makeOrder(OP_BUY,lotsToTrade,stopLoss,takeProfit,magicNumber);
                
            }else if(shortRSIMA(rsiPeriod, emaPeriod)){
            
                stopLoss = swingHigh(swingRange) + (1*_Point*10);
                takeProfit = Bid - (stopLoss - Bid);
                
                if (stopLoss< Ask ) stopLoss = Bid + stopMargin;
                
                lotsToTrade = optimalLotSize(1,stopLoss,Bid);                
                makeOrder(OP_SELL,lotsToTrade,stopLoss,takeProfit,magicNumber);
                
            }
        
        }
        //timeOfTick = TimeCurrent();
   }
  }
//+------------------------------------------------------------------+
