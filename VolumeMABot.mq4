//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <TradingFunctions2.mqh>

int magicNumber = 4321;
double level = 20.0 *_Point *10;
double stopLoss= 0.0;
double takeProfit = 60.0 * _Point*10;
double lotsToTrade = 1.0;
double orderOpenPrice = 0.0;
double stopMargin = 30.0*_Point*10;
int lastOrderType=-1;
datetime lastOrderTime = 0;
bool notPastInitialStop = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
   {
    if(OrdersTotal()<1 && isNewCandle())
       {
        if((iBarShift(NULL,0, lastOrderTime)> 1 ))
           {
             if(longVolumeMA(level))
               {
                stopLoss = iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,0)- level;
                
                makeOrder(OP_BUY, lotsToTrade, stopLoss,Ask+takeProfit,magicNumber);

                if(OrderSelect(0,SELECT_BY_POS))
                   {
                    orderOpenPrice = Ask;
                    lastOrderType = OP_BUY;
                    notPastInitialStop = true;
                   }
               }
           
       
               
                else if(shortVolumeMA(level))
                   {
                    stopLoss = iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,0)+level;
                    
                    makeOrder(OP_SELL, lotsToTrade, stopLoss,Bid-takeProfit,magicNumber);

                    if(OrderSelect(0,SELECT_BY_POS))
                       {
                        orderOpenPrice = Bid;
                        lastOrderType = OP_SELL;
                        notPastInitialStop = true;
                       }
                   }
               }



       }


    if(OrdersTotal()>=1)
       {
        for(int b = 0; b< OrdersTotal(); b++)
           {
            if(OrderSelect(b,SELECT_BY_POS))
               {

                lastOrderTime = TimeCurrent();

                if(OrderType()== OP_BUY)
                   {

                    if(notPastInitialStop && Bid>= orderOpenPrice+ stopMargin)
                       {
                        setStop(orderOpenPrice + 2 * _Point *10,magicNumber);
                        notPastInitialStop = false;
                                            
                       }
                    else if( Bid>= orderOpenPrice + 40 * _Point * 10)
                           {
                              setTrailingStop( 10 *_Point *10,Bid, magicNumber);
                           }

                   }
                else if(OrderType() == OP_SELL)
                       {

                    if(notPastInitialStop && Ask<= orderOpenPrice-stopMargin)
                       {
                        setStop(orderOpenPrice - 2* _Point *10,magicNumber);
                        notPastInitialStop = false;

                       }
                    else if(Ask<= orderOpenPrice - 40*_Point*10)
                           {
                           setTrailingStop( 10*_Point* 10,Ask, magicNumber);
                           }
                       }

               }
           }
       }
   }

//+------------------------------------------------------------------+
