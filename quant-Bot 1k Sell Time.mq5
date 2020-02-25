//+------------------------------------------------------------------+
//|                                       quant-Bot 1k Sell Time.mq5 |
//|                                               Eric Reis, quant-B |
//|                                                       quantb.com |
//+------------------------------------------------------------------+
#property copyright "Eric Reis, quant-B"
#property link      "quantb.com"
#property version   "1.51"
#property icon "quantBotIcon.ico"
#property description "O robô do Setup maluco e simples"
#property description "Para a comunidade de desenvolvimento mql5, Dojo de estudo contínuo"
#property description "  "
#property description "  "
#property description "  "
#property description "  "
#property description "  "
#property description "  "
#property description "Deixe-me ir/Preciso andar/Vou por aí a procurar/Sorrir pra não chorar. Cartola"
#property description "  "
#property description "  "
#property description "  "

enum ePosicoes
{
   Compra,
   Venda
   };

enum eForma
{
   Ligar_Signal_e_Barra,
   Ligar_Signal,
   Ligar_Barra
};

input group "Parametros de Controle de Horario"
input int horaInicioAbertura = 9; // Hora inicial para abertura das posições
input int minutoInicioAbertura = 30; // Minuto inicial para abertura das posições
input int horaFimAbertura = 16; // Hora final para abertura das posições
input int minutoFimAbertura = 45; // Minuto final para abertura das posições
input bool Ligar_Fechamento = false; // Ligar fechamento da posições ao fim do dia
input int horaInicioFechamento = 17; // Hora de Fechamento
input int minutoInicioFechamento = 20; // Minuto de Fechamento
input group "Parametros de Entrada"
input ePosicoes Modo01 = Venda; // Direção da Primeira Entrada
input int horaPrimeiraEntrada = 9; // Hora da Primeira Entrada
input int minutoPrimeiraEntrada = 40; // Minuto da Primeira Entrada
input int horaFimPrimeiraEntrada = 9; // Hora Limite da Primeira Entrada
input int minutoFimPrimeiraEntrada = 40; // Minuto Limite da Primeira Entrada
input bool ligarSegundaEntrada = true; // Ligar Segunda Entrada
input ePosicoes Modo02 = Venda; // Direção da Segunda Entrada
input int horaSegundaEntrada = 9; // Hora da Segunda Entrada
input int minutoSegundaEntrada = 40; // Minuto da Segunda Entrada
input int horaFimSegundaEntrada = 9; // Hora Limite da Segunda Entrada
input int minutoFimSegundaEntrada = 40; // Minuto Limite da Segunda Entrada
input bool ligarTerceiraEntrada = true; // Ligar Terceira Entrada
input ePosicoes Modo03 = Venda; // Direção da Terceira Entrada
input int horaTerceiraEntrada = 9; // Hora da Terceira Entrada
input int minutoTerceiraEntrada = 40; // Hora da Terceira Entrada
input int horaFimTerceiraEntrada = 9; // Hora Limite da Terceira Entrada
input int minutoFimTerceiraEntrada = 40; // Hora Limite da Terceira Entrada
input bool ligarQuartaEntrada = true; // Ligar Quarta Entrada
input ePosicoes Modo04 = Venda; // Direção da Quarta Entrada
input int horaQuartaEntrada = 9; // Hora da Quarta Entrada
input int minutoQuartaEntrada = 40; // Hora da Quarta Entrada
input int horaFimQuartaEntrada = 9; // Hora Limite da Quarta Entrada
input int minutoFimQuartaEntrada = 40; // Hora Limite da Quarta Entrada
input group "Parametros de Controle de Risco e Posição"
input double Volume = 1; // Volume de Entrada sem sinal MACD
input bool Ligar_Position_MACD = false; // Ligar Position Sizing com sinal de filtro MACD
input double Volume_MACD = 2; // Volume da Entrada com sinal MACD
input double StopLoss = 300; // Stop Loss
input double TakeProfit = 300; // Take Profit
input bool Ligar_BreakEven = false; // Ligar Breakeven
input double BreakEven_Gatilho = 300; // Gatilho do Breakeven (ou TrailingStop)
input bool Ligar_TrailingStop = false; // Ligar Trailing Stop
input double TrailingStop_Passo = 100; // Passo do Trailing Stop
input bool Ligar_Limite_Perda_e_Ganho = false; // Ligar Meta Financera de Loss ou Gain
input double Perda_Maxima = -80; // Loss Financeiro Máximo Diário
input double Ganho_Maximo =  40; // Gain Financeiro Máximo Diário
input bool Ligar_Timer_Position = true; // Ligar Limite de Tempo para uma Posição aberta
input int Exp_Position = 60; // Tempo em Minutos para Encerrar a Posição aberta
input group "Parametros do Filtro MACD"
input bool Ligar_MACD = false; // Ligar Filtro MACD
input eForma Forma = Ligar_Barra; // Estratégia do Filtro
input int media_lenta_MACD = 89; // Média Lenta do MACD
input int media_rapida_MACD = 21; // Média Rápida do MACD
input int media_sinal_MACD = 42; // Linha de Sinal do MACD
input group "Estrátegia de Entrada Waiting Trade ADX Signal"
input bool Ligar_Waiting_ADX = false; // Ligar estratégia de espera de sinal ADX (Cuidado! Backtest não confiável)
input int Periodo_ADX = 14; // Periodo do ADX Wilder
input int Corte_ADX = 20; // Nível do ADX para Considerar Força



#include <Trade\Trade.mqh>
CTrade trade;

MqlRates rates[];
MqlTick ultimoTick;
MqlDateTime horaAtual;
MqlDateTime hora1;
MqlDateTime hora2;
MqlDateTime hora3;
MqlDateTime hora4;

double actualCandle;
double newCandle;

int op_exec_01;
int op_exec_02;
int op_exec_03;
int op_exec_04;
bool be_ativo;
bool meta_allow;
bool tmp_placar = true;
bool allow_buy_MACD;
bool allow_sell_MACD;
bool allow_trade_sizing;
bool adx_allow_buy;
bool adx_allow_sell;
int adx_espera;

int h_macd;
double Buffer_macd_signal[];
double Buffer_macd_barra[];

int h_adx;
double Buffer_adx_dxplus[];
double Buffer_adx_dxminus[];
double Buffer_adx_signal[];

datetime pic_time_1;
datetime pic_time_2;
datetime pic_time_3;
datetime pic_time_4;

int pic_1;
int pic_2;
int pic_3;
int pic_4;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(Buffer_macd_signal, true);
   ArraySetAsSeries(Buffer_macd_barra, true);
   ArraySetAsSeries(Buffer_adx_signal, true);
   ArraySetAsSeries(Buffer_adx_dxplus, true);
   ArraySetAsSeries(Buffer_adx_dxminus, true);
   
   op_exec_01 = 0;
   op_exec_02 = 0;
   op_exec_03 = 0;
   op_exec_03 = 0;
   
   pic_1 = 0;
   pic_2 = 0;
   pic_3 = 0;
   pic_4 = 0;
   
   h_macd = iMACD(Symbol(), Period(), media_rapida_MACD, media_lenta_MACD, media_sinal_MACD, PRICE_CLOSE);
   h_adx = iADXWilder(Symbol(), Period(), Periodo_ADX);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    CopyRates(Symbol(), Period(), 0, 5, rates);
    CopyBuffer(h_macd,0, 0, 5, Buffer_macd_barra);
    CopyBuffer(h_macd,1, 0, 5, Buffer_macd_signal);
    CopyBuffer(h_adx, 0, 0, 5, Buffer_adx_signal);
    CopyBuffer(h_adx, 1, 0, 5, Buffer_adx_dxplus);
    CopyBuffer(h_adx, 2, 0, 5, Buffer_adx_dxminus);
    
    if(HoraFechamento())op_exec_01 = 0;
    if(HoraFechamento())op_exec_02 = 0;
    if(HoraFechamento())op_exec_03 = 0;
    if(HoraFechamento())op_exec_04 = 0;
    
    if(!Ligar_Limite_Perda_e_Ganho) meta_allow = true;
    if(funcao_verifica_meta_ou_perda_atingida() && Ligar_Limite_Perda_e_Ganho)meta_allow = false;
    if(!funcao_verifica_meta_ou_perda_atingida() && Ligar_Limite_Perda_e_Ganho)meta_allow = true;
    
            
    if(PositionsTotal() == 0 && OrdersTotal() == 0 && HoraNegociacao() && meta_allow){
    
    //----------------------------//-----------------------//-------------------------------//---------------------------
        
    if(Ligar_Position_MACD && !Ligar_MACD){
    if(Forma == Ligar_Signal_e_Barra){
    if(Buffer_macd_barra[0] < 0 && Buffer_macd_signal[0] - Buffer_macd_signal[1] > 0) allow_buy_MACD = true; else allow_buy_MACD = false;
    
    if(Buffer_macd_barra[0] > 0 && Buffer_macd_signal[0] - Buffer_macd_signal[1] < 0) allow_sell_MACD = true; else allow_sell_MACD = false;
    }
    
    if(Forma == Ligar_Signal){
    if(Buffer_macd_signal[0] - Buffer_macd_signal[1] > 0) {allow_buy_MACD = true; allow_sell_MACD = false;} else {allow_buy_MACD = false;}
    
    if(Buffer_macd_signal[0] - Buffer_macd_signal[1] < 0) {allow_sell_MACD = true; allow_buy_MACD = false;} else {allow_sell_MACD = false;}
    }
    
    if(Forma == Ligar_Barra){
    if(Buffer_macd_barra[0] < 0) {allow_buy_MACD = true; allow_sell_MACD = false;} else {allow_buy_MACD = false;}
    
    if(Buffer_macd_barra[0] > 0) {allow_sell_MACD = true; allow_buy_MACD = false;} else {allow_sell_MACD = false;}
    }
      }
    
    //---------------------------//----------------------------//--------------------------------//--------------------------
    
    if(Ligar_MACD && Ligar_Position_MACD){
    allow_buy_MACD = true;
    allow_sell_MACD = true;
    }
    
    if(Ligar_MACD && !Ligar_Position_MACD){
    allow_buy_MACD = true;
    allow_sell_MACD = true;
    }
    
    if(!Ligar_MACD && !Ligar_Position_MACD){
    allow_buy_MACD = false;
    allow_sell_MACD = false;
    }
    
    //--------------------------------------//----------------------------//--------------------//-----------------------------//-----------
    
    if(!Ligar_Waiting_ADX){
    adx_allow_buy = true;
    adx_allow_sell = true;
    }
    
    if(Ligar_Waiting_ADX){
    if(Buffer_adx_dxplus[1] >= Buffer_adx_dxminus[1] && Buffer_adx_dxplus[0] < Buffer_adx_dxminus[0] && Buffer_adx_signal[0] >= Corte_ADX) {adx_allow_buy = true;} else {adx_allow_buy = false;}
    if(Buffer_adx_dxplus[1] <= Buffer_adx_dxminus[1] && Buffer_adx_dxplus[0] > Buffer_adx_dxminus[0] && Buffer_adx_signal[0] >= Corte_ADX) {adx_allow_sell = true;} else {adx_allow_sell = false;}
    }
    
    //-------------------------------------//------------------------------------//----------------------------//-------------------------
    
    be_ativo = false;
    
    if(HoraPrimeiraEntrada() && op_exec_01 < 1){
    
    if(Modo01 == Venda && adx_allow_sell && !allow_sell_MACD){trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 1º Entrada"); op_exec_01 = op_exec_01 + 1;}
    if(Modo01 == Compra && adx_allow_buy && !allow_buy_MACD){trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 1º Entrada"); op_exec_01 = op_exec_01 + 1;}
    
    if(Modo01 == Venda && allow_sell_MACD  && adx_allow_sell){trade.Sell(Volume_MACD, Symbol(), 0, 0, 0, "Venda Sinal MACD 1º Entrada"); op_exec_01 = op_exec_01 + 1;}
    if(Modo01 == Compra && allow_buy_MACD && adx_allow_buy){trade.Buy(Volume_MACD, Symbol(), 0, 0, 0, "Compra Sinal MACD 1º Entrada"); op_exec_01 = op_exec_01 + 1;}
    
    //op_exec_01 = op_exec_01 + 1;
    addTakeStop(StopLoss, TakeProfit);
    
    }
    
    if(HoraSegundaEntrada() && op_exec_02 < 1 && ligarSegundaEntrada){
    
    if(Modo02 == Venda && adx_allow_sell && !allow_sell_MACD){trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 2º Entrada"); op_exec_02 = op_exec_02 + 1;}
    if(Modo02 == Compra && adx_allow_buy && !allow_buy_MACD){trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 2º Entrada"); op_exec_02 = op_exec_02 + 1;}
    
    if(Modo02 == Venda && allow_sell_MACD && adx_allow_sell){trade.Sell(Volume_MACD, Symbol(), 0, 0, 0, "Venda Sinal MACD 2º Entrada"); op_exec_02 = op_exec_02 + 1;}
    if(Modo02 == Compra && allow_buy_MACD && adx_allow_buy){trade.Buy(Volume_MACD, Symbol(), 0, 0, 0, "Compra Sinal MACD 2º Entrada"); op_exec_02 = op_exec_02 + 1;}
    
    //op_exec_02 = op_exec_02 + 1;
    addTakeStop(StopLoss, TakeProfit);
    
    }
    
    if(HoraTerceiraEntrada() && op_exec_03 < 1 && ligarTerceiraEntrada){
    
    if(Modo03 == Venda && adx_allow_sell && !allow_sell_MACD){trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 3º Entrada"); op_exec_03 = op_exec_03 + 1;}
    if(Modo03 == Compra && adx_allow_buy && !allow_buy_MACD){trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 3º Entrada"); op_exec_03 = op_exec_03 + 1;}
    
    if(Modo03 == Venda && allow_sell_MACD && adx_allow_sell){trade.Sell(Volume_MACD, Symbol(), 0, 0, 0, "Venda Sinal MACD 3º Entrada"); op_exec_03 = op_exec_03 + 1;}
    if(Modo03 == Compra && allow_buy_MACD && adx_allow_buy){trade.Buy(Volume_MACD, Symbol(), 0, 0, 0, "Compra Sinal MACD 3º Entrada"); op_exec_03 = op_exec_03 + 1;}
    
    //op_exec_03 = op_exec_03 + 1;
    addTakeStop(StopLoss, TakeProfit);
    
    }
    
    if(HoraQuartaEntrada() && op_exec_04 < 1 && ligarQuartaEntrada){
    
    if(Modo04 == Venda && adx_allow_sell && !allow_sell_MACD){trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 4º Entrada"); op_exec_04 = op_exec_04 + 1;}
    if(Modo04 == Compra && adx_allow_buy && !allow_buy_MACD){trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 4º Entrada"); op_exec_04 = op_exec_04 + 1;}
    
    if(Modo04 == Venda && allow_sell_MACD && adx_allow_sell){trade.Sell(Volume_MACD, Symbol(), 0, 0, 0, "Venda Sinal MACD 4º Entrada"); op_exec_04 = op_exec_04 + 1;}
    if(Modo04 == Compra && allow_buy_MACD && adx_allow_buy){trade.Buy(Volume_MACD, Symbol(), 0, 0, 0, "Compra Sinal MACD 4º Entrada"); op_exec_04 = op_exec_04 + 1;}
    
    //op_exec_04 = op_exec_04 + 1;
    addTakeStop(StopLoss, TakeProfit);
    
    }
    
    }
    
  if(PositionsTotal() > 0 && HoraFechamento() && Ligar_Fechamento){
  
  for(int i = PositionsTotal() - 1; i>=0; i--){
    string symbol = PositionGetSymbol(i);
    
     if(symbol == Symbol()){
     ulong ticket = PositionGetInteger(POSITION_TICKET);
     trade.PositionClose(ticket);
      }
    }
  }
    
 if(PositionsTotal() > 0 && HoraNegociacao() && Ligar_TrailingStop && (be_ativo == true ||  Ligar_BreakEven == false)){
 if(Ligar_BreakEven == false) addTrailingStop(rates[0].close , BreakEven_Gatilho, TrailingStop_Passo);
 if(Ligar_BreakEven == true) addTrailingStop(rates[0].close , BreakEven_Gatilho + TrailingStop_Passo, TrailingStop_Passo);
 }
 
 if(PositionsTotal() > 0 && HoraNegociacao() && Ligar_BreakEven && be_ativo == false){
 addBreakEven(rates[0].close , BreakEven_Gatilho);
 } 
 
if(PositionsTotal() > 0 && Ligar_Timer_Position){
     TimerPosition(Exp_Position);
   }
   
   
  }
//+------------------------------------------------------------------+

void addTakeStop(double p_sl, double p_tp){
   
   for(int i = PositionsTotal() - 1; i>=0; i--){
    string symbol = PositionGetSymbol(i);
    
     if(symbol == Symbol()){
     ulong ticket = PositionGetInteger(POSITION_TICKET);
     double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
     
     double newSL;
     double newTP;
     
     if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
     newSL = NormalizeDouble(entryPrice - (p_sl) , _Digits);
     newTP = NormalizeDouble(entryPrice + (p_tp) , _Digits);
      
      trade.PositionModify(ticket, newSL, newTP);
     
     }
      else 
     if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
     newSL = NormalizeDouble(entryPrice + (p_sl), _Digits);
     newTP = NormalizeDouble(entryPrice - (p_tp), _Digits);
      
      trade.PositionModify(ticket, newSL, newTP);
     
     }
     
     }
   }
  }
  
 bool HoraSegundaEntrada()
   {
     TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaSegundaEntrada && horaAtual.hour <= horaFimSegundaEntrada)
         {
            if(horaAtual.hour == horaSegundaEntrada)
               {
                  if(horaAtual.min >= minutoSegundaEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            if(horaAtual.hour == horaFimSegundaEntrada)
               {
                  if(horaAtual.min <= minutoFimSegundaEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   } 
   
   
  
  
 bool HoraTerceiraEntrada()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaTerceiraEntrada && horaAtual.hour <= horaFimTerceiraEntrada)
         {
            if(horaAtual.hour == horaTerceiraEntrada)
               {
                  if(horaAtual.min >= minutoTerceiraEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            if(horaAtual.hour == horaFimTerceiraEntrada)
               {
                  if(horaAtual.min <= minutoFimTerceiraEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   } 
   
   
   bool HoraQuartaEntrada()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaQuartaEntrada && horaAtual.hour <= horaFimQuartaEntrada)
         {
            if(horaAtual.hour == horaQuartaEntrada)
               {
                  if(horaAtual.min >= minutoQuartaEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            if(horaAtual.hour == horaFimQuartaEntrada)
               {
                  if(horaAtual.min <= minutoFimQuartaEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   } 
   
   bool HoraPrimeiraEntrada()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaPrimeiraEntrada && horaAtual.hour <= horaFimPrimeiraEntrada)
         {
            if(horaAtual.hour == horaPrimeiraEntrada)
               {
                  if(horaAtual.min >= minutoPrimeiraEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            if(horaAtual.hour == horaFimPrimeiraEntrada)
               {
                  if(horaAtual.min <= minutoFimPrimeiraEntrada)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   } 
      
   
   
  bool HoraNegociacao()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaInicioAbertura && horaAtual.hour <= horaFimAbertura)
         {
            if(horaAtual.hour == horaInicioAbertura)
               {
                  if(horaAtual.min >= minutoInicioAbertura)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            if(horaAtual.hour == horaFimAbertura)
               {
                  if(horaAtual.min <= minutoFimAbertura)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   }
   
  bool HoraFechamento()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaInicioFechamento)
         {
            if(horaAtual.hour == horaInicioFechamento)
               {
                  if(horaAtual.min >= minutoInicioFechamento)
                     {
                        return true;
                     }
                  else
                     {
                        return false;
                     }
               }
            return true;
         }
      return false;
   }
   
 bool IsNewBar(datetime barTime = 0, ENUM_TIMEFRAMES Tempo_Trava = PERIOD_D1)
{
   barTime = (barTime != 0) ? barTime : iTime(_Symbol, Tempo_Trava, 0);
   static datetime barTimeLast = 0;
   bool result = barTime != barTimeLast;
   barTimeLast = barTime;
   return result;
}

 
void addTrailingStop(double preco, double gatilho_ts, double step_ts){
  for(int i = PositionsTotal()-1; i>=0; i--){
   string symbol = PositionGetSymbol(i);
   
   if(symbol == _Symbol){
    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double StopLossCorrente = PositionGetDouble(POSITION_SL);
    double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
    double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
    if(preco >= (StopLossCorrente + gatilho_ts + StopLoss)){
     double newSL = NormalizeDouble(StopLossCorrente + step_ts, _Digits);
     trade.PositionModify(PositionTicket, newSL, TakeProfitCorrente);
     Print("TS ativado");
    }
    } 
    else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
    if(preco <= (StopLossCorrente - gatilho_ts - StopLoss)){
    double newSL = NormalizeDouble(StopLossCorrente - step_ts, _Digits);
     trade.PositionModify(PositionTicket, newSL, TakeProfitCorrente);
     Print("TS ativado");    
    }
    }
   
   }
  
  }

 }
 
 void addBreakEven(double preco, double gatilho_be){
 gatilho_be = NormalizeDouble(gatilho_be, _Digits);
 for(int i = PositionsTotal()-1; i>=0; i--){
 string symbol = PositionGetSymbol(i);
 
 if(symbol == Symbol()){
    ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
    double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
    
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
      if(preco >= (entryPrice + gatilho_be)){
      trade.PositionModify(PositionTicket, entryPrice, TakeProfitCorrente);
      Print("BE ativado");
      be_ativo = true;
      }
    }
    
    else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
      if(preco <= (entryPrice - gatilho_be)){
      trade.PositionModify(PositionTicket, entryPrice, TakeProfitCorrente);
      Print("BE ativado");
      be_ativo = true;
      }
    }
 
 }
 
 }
 }
 
 bool funcao_verifica_meta_ou_perda_atingida()  
{
   //tmpOrigem = comentario de qual local EA foi chamado a função
   //tmpValorMaximoPerda = valor máximo desejado como perda máxima
   //tmpValor_Maximo_Ganho = valor estipulado de meta do  dia
   //tmp_placar = true exibe no comment o resultado das negociações do dia
   
   //Print("Pesquisa funcao_verifica_meta_ou_perda_atingida (" + tmpOrigem + ")");
   string         tmp_x;
   double         tmp_resultado_financeiro_dia;
   int            tmp_contador;
   MqlDateTime    tmp_data_b;
   
   TimeCurrent(tmp_data_b);
   tmp_resultado_financeiro_dia = 0;
   tmp_x = string(tmp_data_b.year) + "." + string(tmp_data_b.mon) + "." + string(tmp_data_b.day) + " 00:00:01";
   
   HistorySelect(StringToTime(tmp_x),TimeCurrent()); 
      int      tmp_total=HistoryDealsTotal(); 
      ulong    tmp_ticket=0; 
      double   tmp_price; 
      double   tmp_profit; 
      datetime tmp_time; 
      string   tmp_symboll; 
      long     tmp_typee; 
      long     tmp_entry; 
         
   //--- para todos os negócios 
      for(tmp_contador=0;tmp_contador<tmp_total;tmp_contador++) 
        { 
         //--- tentar obter ticket negócios 
         if((tmp_ticket=HistoryDealGetTicket(tmp_contador))>0) 
           { 
            //--- obter as propriedades negócios 
            tmp_price =HistoryDealGetDouble(tmp_ticket,DEAL_PRICE); 
            tmp_time  =(datetime)HistoryDealGetInteger(tmp_ticket,DEAL_TIME); 
            tmp_symboll=HistoryDealGetString(tmp_ticket,DEAL_SYMBOL); 
            tmp_typee  =HistoryDealGetInteger(tmp_ticket,DEAL_TYPE); 
            tmp_entry =HistoryDealGetInteger(tmp_ticket,DEAL_ENTRY); 
            tmp_profit=HistoryDealGetDouble(tmp_ticket,DEAL_PROFIT); 
            //--- apenas para o símbolo atual 
            if(tmp_symboll==Symbol()) tmp_resultado_financeiro_dia = tmp_resultado_financeiro_dia + tmp_profit;

           } 
        } 
   
   if (tmp_resultado_financeiro_dia == 0)
      {
          if (tmp_placar == true) Comment("Placar  0x0");
          return(false); //sem ordens no dia
      }
   else
      {
         if ((tmp_resultado_financeiro_dia > 0) && (tmp_resultado_financeiro_dia != 0))
            {
               if (tmp_placar == true) Comment("Lucro R$" + DoubleToString(NormalizeDouble(tmp_resultado_financeiro_dia, 2),2) );
            }
         else
            {
               if (tmp_placar == true) Comment("Prejuizo R$" + DoubleToString(NormalizeDouble(tmp_resultado_financeiro_dia, 2),2));
            }
         
         if (tmp_resultado_financeiro_dia < Perda_Maxima)
            {
               //Print("Perda máxima alcançada.");
               return(true);
            }
         else
            {
               if (tmp_resultado_financeiro_dia > Ganho_Maximo)
               {
                  //Print("Meta Batida.");
                  return(true);
               }
            }    
        }  
   return(false);
}    



void TimerPosition(double _positionExp){
 
  int positions=PositionsTotal();

   for(int i=0;i<positions;i++)
     {
      ResetLastError();
      
      ulong pos_ticket=PositionGetTicket(i);
      if(pos_ticket!=0)
        {
         double pos_price_open  =PositionGetDouble(POSITION_PRICE_OPEN);
         datetime pos_time_setup=PositionGetInteger(POSITION_TIME);
         string pos_symbol      =PositionGetString(POSITION_SYMBOL);
         if(pos_time_setup + 60*_positionExp < rates[0].time){
         PrintFormat("Position #%d for %s was set out %s and will be deleted",pos_ticket,pos_symbol,TimeToString(pos_time_setup));
         trade.PositionClose(pos_ticket);      
         }
         
        }
      else 
        {
         PrintFormat("Error when obtaining an order from the list to the cache. Error code: %d",GetLastError());
        }   
        
     }
     
     }
