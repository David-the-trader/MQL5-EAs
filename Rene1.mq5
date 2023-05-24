//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
input double lots = 0.1;

input ENUM_TIMEFRAMES timeframe = PERIOD_H1;
input int periods = 100;
input ENUM_MA_METHOD MaMethod = MODE_SMA;

int MaHandle;
int barsTotal;
int maDirection = 0;

CTrade trade;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   MaHandle = iMA(_Symbol,timeframe,periods,0,MaMethod,PRICE_CLOSE);
   barsTotal = iBars(_Symbol,timeframe);


   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int bars = iBars(_Symbol,timeframe);
   if(barsTotal < bars)
     {
      barsTotal = bars;
      double ma[];
      CopyBuffer(MaHandle,MAIN_LINE,1,2,ma);
      if(ma[1] > ma[0] && maDirection <=0){
         maDirection = 1;

      trade.PositionClose(_Symbol);
      trade.Buy(lots);
     }
   else
      if(ma[1] < ma[0] && maDirection >=0)
        {
         maDirection = -1;

         trade.PositionClose(_Symbol);
         trade.Sell(lots);


        }
  }

 } 

//+------------------------------------------------------------------+
