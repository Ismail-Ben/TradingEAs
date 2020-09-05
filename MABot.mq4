
#include <TradingFunctions.mqh>  

int magicNumber = 1234;
double lotsToTrade = 1.0;
double stopLoss = 15.0 * _Point *10; 
datetime timeOfOrder = 0;
datetime timeOfTick=0; 
bool goLong = false;
bool goShort = false;
int fastMA = 9;
int slowMA = 21;
double takeProfit= 0.0;
double profitMargin = 10.0*_Point*10;
double initialStop = 0.0;
int res;
double orderOpenPrice=0;

void OnTick()
  {
   if(TimeCurrent()- timeOfTick >(Period()*60.0/120.0)){
   
   if (OrdersTotal()<1){
      if (TimeCurrent()-timeOfOrder>Period()*60*3){
         
         if ( iADX(Symbol(),Period(),14,PRICE_CLOSE,0,0)>25){
            
            if (longSSMACrossover(fastMA,slowMA)) {
               
               
               initialStop =  Ask- stopLoss;
               
               
               res = OrderSend(Symbol(),OP_BUY,lotsToTrade,Ask,3,initialStop,0,"",magicNumber,0,Green);
               
               orderOpenPrice = Ask;
               timeOfOrder = TimeCurrent();
               takeProfit = Ask+profitMargin;
              
               
               
            }else if (shortSSMACrossover(fastMA,slowMA)){
               
               initialStop = Bid+ stopLoss;
               
               res = OrderSend(Symbol(),OP_SELL,lotsToTrade,Bid,3,initialStop,0,"",magicNumber,0,Green);
               
               orderOpenPrice = Bid;
               timeOfOrder = TimeCurrent();
               takeProfit = Bid-profitMargin;
               
               
            }
         }
      }  
      
      
   }
   
   if (OrdersTotal()>=1){
      for(int b = 0;b< OrdersTotal();b++){
            if(OrderSelect(b,SELECT_BY_POS)){
       
               if (OrderType()== OP_BUY){
                  //if(shortSSMACrossover(fastMA,slowMA)) closeOrder(magicNumber);
                  
                  //else{ 
                     if(Bid>= orderOpenPrice+profitMargin){
                        setTrailingStop(profitMargin,Bid, magicNumber);
                     }   
                 // }
               }
               else if (OrderType() == OP_SELL){
                  //if(longSSMACrossover(fastMA,slowMA)) closeOrder(magicNumber);
                  
                  //else {
                   if(Ask<= orderOpenPrice-profitMargin){
                        setTrailingStop(profitMargin,Ask, magicNumber);
                        }
                 // }
               }  
               
            }
         }
      }   
  
   timeOfTick = TimeCurrent();
   }
   
  }
