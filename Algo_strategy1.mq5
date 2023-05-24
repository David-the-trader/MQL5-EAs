#include <Trade/Trade.mqh>
CTrade trade;

int short_trend = 5 ;
int long_term = 20;
int OnInit()
  {

  

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  
  }

void OnTick()
  {
double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
double stopbuy = ask - 0.15;
stopbuy = NormalizeDouble(stopbuy,3);
double stopsell = bid + 0.15;
stopsell = NormalizeDouble(stopsell,3);
double buytp = ask + (0.15 * 1.5);
buytp = NormalizeDouble(buytp,3);
double selltp = bid - (0.15 * 1.5);
selltp = NormalizeDouble(selltp,3);

 double current_close = iClose(_Symbol,PERIOD_CURRENT,1);
 double short_close = iClose(_Symbol,PERIOD_CURRENT,short_trend);
 double long_close = iClose(_Symbol,PERIOD_CURRENT,long_term);
 if (current_close > short_close && current_close < long_close) {trade.Buy(1.0,_Symbol,ask,stopbuy,buytp);}
 else if( current_close < short_close && current_close > long_close) {trade.Sell(1.0,_Symbol,bid,stopsell,selltp);  }
  }
