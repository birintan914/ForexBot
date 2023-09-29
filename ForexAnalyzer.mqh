//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double macd_shift(string currency,ENUM_TIMEFRAMES period, int shift)
  {
   double macd = iCustom(currency,period,"MACD_Platinum",12,26,9,true,true,true,false,0,shift);
   double  avg = iCustom(currency,period,"MACD_Platinum",12,26,9,true,true,true,false,1,shift);
   return macd-avg;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string macdplat(string currency,ENUM_TIMEFRAMES period, int shift)
  {
   double cross0 = macd_shift(currency, period, shift);
   double cross1 = macd_shift(currency, period, shift+1);
   double macd = iCustom(currency,period,"MACD_Platinum",12,26,9,true,true,true,false,0,shift);

   if(macd<0 && cross0 > 0 && cross1 < 0)
     {
      return "B";
     }
   else
      if(macd>0 && cross0 < 0 && cross1 > 0)
        {
         return "S";
        }
      else
        {
         return "N";
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BBEntry(string currency, ENUM_TIMEFRAMES period, int shift)
  {
   double UpperBB = iBands(currency,period,200,2,0,PRICE_CLOSE,MODE_UPPER,shift);
   double LowerBB = iBands(currency,period,200,2,0,PRICE_CLOSE,MODE_LOWER,shift);
   double ask = NormalizeDouble(SymbolInfoDouble(currency,SYMBOL_ASK),_Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(currency,SYMBOL_BID),_Digits);
   
   if(ask>=UpperBB)
     {
      return "S";
     }
   else
      if(bid<=LowerBB)
        {
         return "B";
        }
      else
        {
         return "N";
        }
//Sell:
   /*
   if((Ask < (UpperBB + PipPoint(currency)*5)) && (Bid > (UpperBB - PipPoint(currency)*5))){
      entry = "S";
   }

   //Buy:
   if((Bid > (LowerBB - PipPoint(currency)*5)) && (Ask < (LowerBB + PipPoint(currency)*5))){
      entry = "B";
   }
   */
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BolingMacd(string currency,ENUM_TIMEFRAMES period, int shift)
  {
   string BH1;
   string MH1;
   BH1 = BBEntry(currency,period, shift);
   MH1 = macdplat(currency,period, shift);
   if(BH1=="B" && MH1=="B")
     {
      return "B";
     }

   else
      if(BH1=="S" && MH1=="S")
        {
         return "S";
        }
      else
        {
         return "N";
        }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipPoint(string currency)
  {
   if(currency=="XAUUSD")
     {
      return 0.5;
     }
   else
      if(currency=="USDJPY")
        {
         return 0.01;
        }
      else
        {
         return 0.0001;
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TradingHours(int x,int y)
  {
   int startHour = x +7;   //5am
   int endHour = y +7;    //12pm
   if(Hour() >=startHour && Hour()<=endHour)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TradingHours()
  {
   return TradingHours(5,12);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bolingstop(int shift)
  {
   double UpperBB = iBands(_Symbol,PERIOD_CURRENT,200,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double LowerBB = iBands(_Symbol,PERIOD_CURRENT,200,2,0,PRICE_CLOSE,MODE_LOWER,1);
   int i = shift;

   if(Close[i] > UpperBB)
     {
      double hi = High[i];
      while(Close[i] > UpperBB)
        {
         if(High[i] > hi)
           {
            hi = High[i];
           }
         i = i+1;
        }
     return hi; 
     }
   else
      if(Close[i] < LowerBB)
        {
         double lo = Low[i];
         while(Close[i] < LowerBB){
            if(Low[i] < lo){
               lo = Low[i];
            }
            i = i+1;
         }
       return lo;
       }
       return Close[i];
  }
  
double OrderBuy(double LotSize,double stoploss, double takeprofit)
{
   RefreshRates();
   return OrderSend(_Symbol,OP_BUY,LotSize,Ask,3,stoploss,takeprofit,0);
}

double OrderSell(double LotSize,double stoploss, double takeprofit)
{  
   RefreshRates();
   return OrderSend(_Symbol,OP_SELL,LotSize,Bid,3,stoploss,takeprofit,0);
}

void CreateArrow(int type){
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true);
   int data = CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInfo);
   int NumCandles = Bars(Symbol(),Period());
   string strNumCandles = IntegerToString(NumCandles);
   
   if(type==1){ //buy
      ObjectCreate(_Symbol,"Buy:"+strNumCandles,OBJ_ARROW_BUY,0,TimeCurrent(),iLow(Symbol(),Period(),0)-0.0010);
      ObjectSet("Buy:"+strNumCandles,OBJPROP_COLOR,clrSpringGreen);
   }
   else if(type==2){ //sell
      ObjectCreate(_Symbol,"Sell:"+strNumCandles,OBJ_ARROW_SELL,0,TimeCurrent(),iHigh(Symbol(),Period(),0)+0.0010);
      ObjectSet("Sell:"+strNumCandles,OBJPROP_COLOR,clrCrimson);
   }
}

double ATR(int multiplyer){
   double atr = iATR(_Symbol,_Period,14,0)*multiplyer;
   return atr;
}

void CrossAlert(string currency, double targetPrice, int mode){
   double ask = NormalizeDouble(SymbolInfoDouble(currency,SYMBOL_ASK),_Digits);
   double bid = NormalizeDouble(SymbolInfoDouble(currency,SYMBOL_BID),_Digits);
   //mode 0 = cross below
   //mode 1 = cross above
   if(mode==0){
      if(ask<=targetPrice){
         Alert(currency + "("+ask+"):" + ": Crossed Below " + targetPrice);
         SendNotification(currency + ": Crossed Below " + targetPrice);
      }
   }
   else if(mode==1){
      if(bid>=targetPrice){
         Alert(currency + "("+bid+"):" + "Crossed Above " + targetPrice);
         SendNotification(currency + ": Crossed Above " + targetPrice);
      }
   }  

}
//+------------------------------------------------------------------+
