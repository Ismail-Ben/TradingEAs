
// Look for entry condition: 9 ema has been above or below 21 ema for the past 8 consecutive bars on H4 ** and on h1
// Enter on a wick rejection of the 9 ema on H1.
// Stop at previous fractal
// 1:1 Profit target
int magicNumber = 5678;
double stopLossPrice = 0.0;
double stopLossSize=0.0;
double takeProfitPrice=0.0;
double lotsToTrade = 0.0;
int swingRange = 8;
bool breakeven = False;
double riskPct = 2.0;

bool lookingForLong(){
    
    for ( int i = 0; i< 8 ; i++){
        
        if (iMA(NULL, PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,i)< iMA(NULL, PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,i)|| iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,i)< iMA(NULL, PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,i))
            return False;
    }   
    return True; 
}

bool lookingForShort(){
    
    for ( int i = 0; i< 8 ; i++){
        
        if (iMA(NULL, PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,i)> iMA(NULL, PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,i) || iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,i)> iMA(NULL, PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,i))
            return False;
    }   
    return True; 
}

bool goLong(){
    if (iLow(NULL,PERIOD_H1,1)< iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0) && iClose(NULL,PERIOD_H1,1)> iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0))
        return True;
    return False;
}

bool goShort(){
    if (iHigh(NULL,PERIOD_H1,1)> iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0) && iClose(NULL,PERIOD_H1,1)< iMA(NULL, PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0))
        return True;
    return False;
}

bool isNewCandle(){
   static datetime savedCandleTime;
   if (Time[0] == savedCandleTime) return false;
   
   else{
      savedCandleTime = Time[0];
      return true;
   }

}

double nominalPipValue(){
    double tickValue = MarketInfo(Symbol(),MODE_TICKVALUE);
        
    if (Digits == 3 || Digits == 5){
        tickValue = tickValue*10;
    }
    return tickValue;
}

double optimalLotSize(double riskPct,double stopLossPrice, double currentPrice){
    double pipValue = (_Point*10*AccountFreeMargin()* riskPct/100.0)/((MathAbs(currentPrice - stopLossPrice)));
    
  
    return MathRound(pipValue/nominalPipValue()*100)/100.0;
}

void makeOrder(int orderType, double lotsToTrade,double stopLoss, double takeProfit, int magicNumber){ //buy=0;sell=1
   
   int res;
   
   if(orderType==OP_BUY){
      res = OrderSend(Symbol(),orderType,lotsToTrade,Ask,3,stopLoss,takeProfit,"",magicNumber,0,Green);
   }
   else if (orderType==OP_SELL){
      res = OrderSend(Symbol(),orderType,lotsToTrade,Bid,3,stopLoss,takeProfit,"",magicNumber,0,Green);
   }
}

double swingHigh( int range){
    int indexOfHigh = iHighest(NULL,0,MODE_HIGH,range,0);
    return iHigh(NULL,0,indexOfHigh);
}

double swingLow(int range){
    int indexOfLow = iLowest(NULL,0,MODE_LOW,range,0);
    return iLow(NULL,0,indexOfLow);

}
void OnTick()
  {
    if (isNewCandle()&& OrdersTotal()<1){
        if (lookingForLong()){
            if (goLong()){
                
                stopLossPrice = swingLow(swingRange) - ( 1*_Point *10);
                stopLossSize = Ask - stopLossPrice;
                
                if (stopLossSize> 60* _Point *10) {
                    stopLossSize =60* _Point*10;
                    stopLossPrice = Ask - stopLossSize;
                }
                takeProfitPrice = Ask + stopLossSize;
                lotsToTrade = optimalLotSize(riskPct,stopLossPrice,Ask);
                
                makeOrder(OP_BUY,lotsToTrade/2.0,stopLossPrice,takeProfitPrice,magicNumber);
                makeOrder(OP_BUY,lotsToTrade/2.0,stopLossPrice,takeProfitPrice+ stopLossSize,magicNumber); 
                breakeven = False;               
                
            }
            
        }
        if (lookingForShort()){
            if(goShort()){
                stopLossPrice = swingHigh(swingRange)+ (1*_Point *10);
                stopLossSize = stopLossPrice - Bid;
                
                if (stopLossSize> 60* _Point *10) {
                    stopLossSize =60* _Point*10;
                    stopLossPrice = Bid + stopLossSize;
                }
                
                takeProfitPrice = Bid - stopLossSize;
                lotsToTrade = optimalLotSize(riskPct,stopLossPrice,Bid);
                
                makeOrder(OP_SELL,lotsToTrade/2.0,stopLossPrice,takeProfitPrice,magicNumber);
                makeOrder(OP_SELL,lotsToTrade/2.0,stopLossPrice,takeProfitPrice - stopLossSize,magicNumber);
                breakeven = False;
                
                
            }
            
        }
    
    }
    if (OrdersTotal()==1 && !breakeven){
            
        if (OrderSelect(0, SELECT_BY_POS) && OrderSymbol()== Symbol()&& OrderCloseTime() == 0 && OrderMagicNumber()== magicNumber){
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
            breakeven=True;
        }
           
    }
   
  }
//+------------------------------------------------------------------+
