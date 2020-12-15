//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict

#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  2
//--- indicator parameters
input string comment="0=SMA, 1=EMA, 2=SMMA, 3=LWMA"; 
input int FastSlowType=1;
input int InpFastEMA=6;   // Fast EMA Period
input int InpSlowEMA=12;   // Slow EMA Period
input int SignalType=1;
input int InpSignalSMA=3;  // Signal SMA Period
input string comment1="0=Close, 1=Open, 2=High, 3=Low, 4=Median, 5=Typical, 6=Weighted";
input int price1=0;

//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,clrBlue);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD-Histogram-Reza("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
   {
      ExtMacdBuffer[i]=iCustom(Symbol(),0,"MACD-REZA",comment, FastSlowType, InpFastEMA, InpSlowEMA, SignalType, InpSignalSMA,comment1, price1,MODE_MAIN,i)
                      -iCustom(Symbol(),0,"MACD-REZA",comment, FastSlowType, InpFastEMA, InpSlowEMA, SignalType, InpSignalSMA,comment1, price1,MODE_SIGNAL,i);
     // iMACD(Symbol(),NULL,InpFastEMA,InpSlowEMA,InpSignalSMA,PRICE_CLOSE,MODE_MAIN,i);
      /*iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);*/
          
     //  ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,buffave);
                
   }
//--- signal line counted in the 2-nd buffer
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
  /*for(i=0; i<limit; i++)
  {
   buffave[i]=ExtMacdBuffer[i];
  }   */
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+