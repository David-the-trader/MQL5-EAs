//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, DAVID BUTA"
#include <Trade/Trade.mqh>

CTrade trade;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT;

input ENUM_APPLIED_PRICE pr = PRICE_CLOSE;
double zones [] = {102.839,134.560,126.212,119.395,122.873,110.074,105.622,108.462,107.042,115.933,111.364,
                         112.043,124.640,121.182,117.662,132.729,123.775,128.715,114.053,104.511,109.226,116.932,120.298,118.628,
                         127.912,131.377,112.887,105.042,103.962,102.100,103.398,115.243,125.355,121.679,107.633,106.390
                        };
int bars ;
int barstotal;
int expires = 0;
int OnInit()
  {
  Print(expires);
for (int i = 0; i < ArraySize(zones); i++)
    {
        double level = zones[i];
        string objName = "zone" + DoubleToString(level, 4);

        // Create horizontal line object
        ObjectCreate(0, objName, OBJ_HLINE, 0, 0, level);

        // Set line color to red
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
    }
   barstotal = iBars(_Symbol,tf);
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
   bars = iBars(_Symbol,tf);
   
     

      double low1 = iLow(_Symbol,tf,1);// 106.370
      double low2 = iLow(_Symbol,tf,2);// 106.690
      double high1 = iHigh(_Symbol,tf,1);// 106.780
      double high2 = iHigh(_Symbol,tf,2);// 106.940
      double close1 = iClose(_Symbol,tf,1); // 106.720
      double open1 = iOpen(_Symbol,tf,1);// 106.780

      int low_index = iLowest(_Symbol,tf,MODE_LOW,7,1);// 1
      int high_index = iHighest(_Symbol,tf,MODE_HIGH,7,1);// 7
      double range = high1 - low1;// 0.41
      range = NormalizeDouble(range,3);// 0.410
      double top_third = high1 - (0.3 * range);// 106.657
      top_third = NormalizeDouble(top_third,3);// 106.657
      double bottom_third = low1 + (0.3 * range);// 106.493
      bottom_third = NormalizeDouble(bottom_third,3);// 106.493
      double top_5th = high1 - (range * 0.2);//
      top_5th = NormalizeDouble(top_5th,3);// 
      double bottom_5th = low1 + (range * 0.2);// 
      bottom_5th = NormalizeDouble(bottom_5th,3);// 

      double range_value = range  / 2;// 
      range_value = NormalizeDouble(range_value,3);// 
      
    
      double money = 1.0;
       // big shadow setup description starts
                     if(close1 > open1 || close1 < open1)  // bullish or bearish
        {
         double body = close1 > open1 ? close1 - open1 : open1 - close1; // bullish ? then body is that value,0.13
         bool candle_type_bullish = close1 > open1 ? true : false; // true is bullish , false is bearish,true
         if(low1 < low2 && high1 > high2) // engulfs
           {
            if(body > range_value) // not a weakie
              {
               if(low_index == 1  && at_zone(high1,low1)) // highest low value of the previous 7 candles, starting from
                 {
                  if(candle_type_bullish == true && close1 >= top_5th)
                    {
                     BUY_STOP(money,high1,low1);
                    }
                  else
                     if(candle_type_bullish == false && close1 <= bottom_5th)
                       {
                        BUY_STOP(money,high1,low1);

                       }

                     else
                        if(high_index == 1 && at_zone(high1,low1))
                          {
                           if(candle_type_bullish == true && close1 >= top_5th)
                             {
                              SELL_STOP(money,low1,high1);
                             }
                           else
                              if(candle_type_bullish == false && close1 <= bottom_5th)
                                {

                                 SELL_STOP(money,low1,high1);
                                }
                          }
                 }// big setup description shadow ends
              }
           }
        }





      else // kangaroo tail setup description  description starts
         if((close1 >= top_third && open1 >= top_third) ||(close1 <= bottom_third && open1 <= bottom_third))  // bullish or bearish kt
           {
            if(low_index == 1  && at_zone(high1,low1))
              {
               if(close1 < high2 && close1 > low2 && open1 < high2 && open1 > low2) // original kt setup, within range
                 {
                  BUY_STOP(money,high1,low1);

                 }
              }
            else
               if(high_index == 1 && at_zone(high1,low1))
                 {
                  if(close1 < high2 && close1 > low2 && open1 < high2 && open1 > low2)
                    {
                     SELL_STOP(money,low1,high1);
                    }

                 }// kangaroo tail  setup description ends
           
      //+------------------------------------------------------------------+
     }
   else
      trail_position(high1,low1,range);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool at_zone(double high,double low)// this function proves whether the setup is on a support and resistance zone or not
  {
   int v = 0;
   for(int i=0; i< ArraySize(zones); i++)
     {
      if(high > zones[i] && low < zones[i])   // INCLUDE THE PIPS FOR SLIPPAGE, as well as the indication values
        {
         v +=1;
        }
     }
   if(v >= 1)
     {
      return true;
     }
   else
      return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calclots(double riskpercent,double sldistance)  // sldistance is the range in pips
  {

   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(ticksize == 0 || tickvalue == 0 || lotstep == 0)
     {
      return 0;
     }

   double riskmoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskpercent / 100;
   double moneylotstep = (sldistance / ticksize) * tickvalue * lotstep ;
   if(moneylotstep == 0){return 0;}
   double amount = MathFloor(riskmoney / moneylotstep) * lotstep;
   return amount;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trail_position(double high,double low,double range)
  { range = NormalizeDouble(range,1);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   bid = NormalizeDouble(bid,3);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   ask = NormalizeDouble(ask,3);
   for(int i = PositionsTotal() - 1 ; i >= 0; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
     {
      double posSL = PositionGetDouble(POSITION_SL);
         double posTP = PositionGetDouble(POSITION_TP);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            double tp1 = high + (range * 1.5);
            if(ask > tp1)
              {
               double tp2 = high + (range * 2.5);
               trade.PositionModify(posTicket,tp1,tp2);
              }

           }
         else
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           { 
            double tp1 = low - (range * 1.5);
               if(bid < tp1)
                 {
                  double tp2 = low - (range * 2.5);
                  trade.PositionModify(posTicket,tp1,tp2);
                 }
              }
        }
     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BUY_STOP(double amount,double entry,double loss)
  { entry += 0.002;
  entry = NormalizeDouble(entry,3);
  loss = NormalizeDouble(loss,3);
   trade.BuyStop(amount,entry,_Symbol,loss,0.0,ORDER_TIME_GTC,0.0,"buy");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SELL_STOP(double amount,double entry,double loss)
  { entry -=  0.002;
  entry = NormalizeDouble(entry,3);
  loss = NormalizeDouble(loss,3);
   trade.SellStop(amount,entry,_Symbol,loss,0.0,ORDER_TIME_GTC,0.0,"sell");
  }
//+------------------------------------------------------------------+
bool newBar(){
static int lastbarcount = 0;
if(Bars(_Symbol,PERIOD_CURRENT) > lastbarcount){
lastbarcount= Bars(_Symbol,PERIOD_CURRENT);
return true;
}
else return false;
}