void setTrailingStop (double stopLoss,double startingPoint, int magicNumber ) //buy=0;sell=1 , stopLoss in pips
{
   int modify;
   if(OrderSymbol()== Symbol()&& OrderCloseTime() == 0 && OrderMagicNumber()== magicNumber)
   {
      if(OrderType()== OP_BUY)
      {
         if(OrderStopLoss()< startingPoint-(stopLoss))//stop in pips
         {
            modify=  OrderModify(OrderTicket(),OrderOpenPrice(),startingPoint -(stopLoss), OrderTakeProfit(),0);
            
         } 
      }
      else if (OrderType()==OP_SELL)
      {
         if(OrderStopLoss()==0 || OrderStopLoss()>startingPoint +(stopLoss))
         {
            modify= OrderModify(OrderTicket(),OrderOpenPrice(),startingPoint +(stopLoss), OrderTakeProfit(),0);
         }
      }
   }   
}

void setStop (double stopLossPrice,int magicNumber){
   int modify;
   if(OrderSymbol()== Symbol()&& OrderCloseTime() == 0 && OrderMagicNumber()== magicNumber)
   {
      modify = OrderModify(OrderTicket(),OrderOpenPrice(), stopLossPrice, OrderTakeProfit(),0);
      
   }
   
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

void entryOrder(){

}

void closeOrder(int magicNumber){
   int close;
   double closeSlippage = 10.0; // in Points
   
   if(OrderSymbol()== Symbol()&& OrderCloseTime() == 0 && OrderMagicNumber()== magicNumber){   
      if (OrderType()== OP_BUY){
         close=OrderClose(OrderTicket(),OrderLots(),Bid,closeSlippage);
      }
      else if(OrderType()== OP_SELL){
         close=OrderClose(OrderTicket(),OrderLots(),Ask,closeSlippage);
      }
   }
}







bool isProfitReached(double goal, int magicNumber){
   if(OrderType()== OP_BUY && Bid >=goal) return true;
   else if (OrderType()== OP_SELL && Ask<= goal) return true ;
   else return false;

}

bool longVolumeMA(double level){
 
 if(iClose(NULL,0,1)>iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,1)+level && iOpen(NULL,0,1)<iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,1)+level && iOpen(NULL,0,2)<iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,2)+level){
   if(iVolume(NULL,0,1)>iVolume(NULL,0,2) && iVolume(NULL,0,2)>iVolume(NULL,0,3)){
      
      return true;
   }
 } 
 return false;

}

bool shortVolumeMA(double level){
   if(iClose(NULL,0,1)<iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,1)-level && iOpen(NULL,0,1)>iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,1)-level && iOpen(NULL,0,2)>iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,2)-level){
      if(iVolume(NULL,0,1)>iVolume(NULL,0,2) && iVolume(NULL,0,2)>iVolume(NULL,0,3)){
         return true;
      }
   } 
   return false;

}

bool isNewCandle(){
   static datetime savedCandleTime;
   if (Time[0] == savedCandleTime) return false;
   
   else{
      savedCandleTime = Time[0];
      return true;
   }

}

double RSIMA(int rsiPeriod, int emaPeriod){
    
    double rsi_buffer[];
    ArrayResize(rsi_buffer,emaPeriod*20);
    double ema;
    int i;
    ArraySetAsSeries(rsi_buffer,true);
    for(i=0; i<emaPeriod*20; i++){
        rsi_buffer[i]=iRSI(NULL,0,rsiPeriod,PRICE_CLOSE,i);
        
    
    }
    
    ema= iMAOnArray(rsi_buffer,0,emaPeriod,1,MODE_EMA,0);
    return ema;

}

bool longRSIMA( int rsiPeriod, int emaPeriod){

    double ema = RSIMA(rsiPeriod, emaPeriod);
    
    if (iRSI(NULL, 0,rsiPeriod, PRICE_CLOSE,2)< ema && iRSI(NULL,0, rsiPeriod,PRICE_CLOSE,1)>ema ){
        for(int i = 1; i<4; i++){
            if(iRSI(NULL,0,rsiPeriod,PRICE_CLOSE,i)<29.5){
                return true;
            }
        
        }
    }
    return false;

}

bool shortRSIMA( int rsiPeriod, int emaPeriod){

    double ema = RSIMA(rsiPeriod, emaPeriod);
    
    if (iRSI(NULL, 0,rsiPeriod, PRICE_CLOSE,2)> ema && iRSI(NULL,0, rsiPeriod,PRICE_CLOSE,1)<ema ){
        for(int i = 1; i<4; i++){
            if(iRSI(NULL,0, rsiPeriod,PRICE_CLOSE,i)>70.5){
                return true;
            }
        
        }
    }
    return false;

}

double swingHigh( int range){
    int indexOfHigh = iHighest(NULL,0,MODE_HIGH,range,0);
    return iHigh(NULL,0,indexOfHigh);
}

double swingLow(int range){
    int indexOfLow = iLowest(NULL,0,MODE_LOW,range,0);
    return iLow(NULL,0,indexOfLow);

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

