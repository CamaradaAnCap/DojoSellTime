//+------------------------------------------------------------------+
//|                                       quant-Bot 1k Sell Time.mq5 |
//|                                               Eric Reis, quant-B |
//|                                                       quantb.com |
//+------------------------------------------------------------------+
#property copyright "Eric Reis, quant-B"
#property link      "quantb.com"
#property version   "1.00"
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
input bool ligarSegundaEntrada = true; // Ligar Segunda Entrada
input ePosicoes Modo02 = Venda; // Direção da Segunda Entrada
input int horaSegundaEntrada = 9; // Hora da Segunda Entrada
input int minutoSegundaEntrada = 40; // Minuto da Segunda Entrada
input bool ligarTerceiraEntrada = true; // Ligar Terceira Entrada
input ePosicoes Modo03 = Venda; // Direção da Terceira Entrada
input int horaTerceiraEntrada = 9; // Hora da Terceira Entrada
input int minutoTerceiraEntrada = 40; // Hora da Terceira Entrada
input bool ligarQuartaEntrada = true; // Ligar Quarta Entrada
input ePosicoes Modo04 = Venda; // Direção da Quarta Entrada
input int horaQuartaEntrada = 9; // Hora da Quarta Entrada
input int minutoQuartaEntrada = 40; // Hora da Quarta Entrada
input group "Parametros de Controle de Risco e Posição"
input double Volume = 1; // Volume
input double StopLoss = 300; // Stop Loss
input double TakeProfit = 300; // Take Profit
input bool Ligar_BreakEven = false; // Ligar Breakeven
input double BreakEven_Gatilho = 300; // Gatilho do Breakeven (ou TrailingStop)
input bool Ligar_TrailingStop = false; // Ligar Trailing Stop
input double TrailingStop_Passo = 100; // Passo do Trailing Stop
input bool Ligar_Limite_Perda_e_Ganho = false; // Ligar Meta Financera de Loss ou Gain
input double Perda_Maxima = -80; // Loss Financeiro Máximo Diário
input double Ganho_Maximo =  40; // Gain Financeiro Máximo Diário


#include <Trade\Trade.mqh>
CTrade trade;

MqlRates rates[];
MqlTick ultimoTick;
MqlDateTime horaAtual;

double actualCandle;
double newCandle;

int op_exec_01;
int op_exec_02;
int op_exec_03;
int op_exec_04;
bool be_ativo;
bool meta_allow;
bool tmp_placar = true;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(rates, true);
   op_exec_01 = 0;
   op_exec_02 = 0;
   op_exec_03 = 0;
   op_exec_03 = 0;
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
    
    if(HoraFechamento())op_exec_01 = 0;
    if(HoraFechamento())op_exec_02 = 0;
    if(HoraFechamento())op_exec_03 = 0;
    if(HoraFechamento())op_exec_04 = 0;
    
    if(!Ligar_Limite_Perda_e_Ganho) meta_allow = true;
    if(funcao_verifica_meta_ou_perda_atingida() && Ligar_Limite_Perda_e_Ganho)meta_allow = false;
    if(!funcao_verifica_meta_ou_perda_atingida() && Ligar_Limite_Perda_e_Ganho)meta_allow = true;
        
    if(PositionsTotal() == 0 && OrdersTotal() == 0 && HoraNegociacao() && meta_allow){
    
    be_ativo = false;
    
    if(HoraPrimeiraEntrada() && op_exec_01 < 1){
    if(Modo01 == Venda)trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 1º Entrada");
    if(Modo01 == Compra)trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 1º Entrada");
    op_exec_01 = op_exec_01 + 1;
    addTakeStop(StopLoss, TakeProfit);
    }
    
    if(HoraSegundaEntrada() && op_exec_02 < 1 && ligarSegundaEntrada){
    if(Modo02 == Venda)trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 2º Entrada");
    if(Modo02 == Compra)trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 2º Entrada");
    op_exec_02 = op_exec_02 + 1;
    addTakeStop(StopLoss, TakeProfit);
    }
    
    if(HoraTerceiraEntrada() && op_exec_03 < 1 && ligarTerceiraEntrada){
    if(Modo03 == Venda)trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 3º Entrada");
    if(Modo03 == Compra)trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 3º Entrada");
    op_exec_03 = op_exec_03 + 1;
    addTakeStop(StopLoss, TakeProfit);
    }
    
    if(HoraQuartaEntrada() && op_exec_04 < 1 && ligarQuartaEntrada){
    if(Modo04 == Venda)trade.Sell(Volume, Symbol(), 0, 0, 0, "Venda 4º Entrada");
    if(Modo04 == Compra)trade.Buy(Volume, Symbol(), 0, 0, 0, "Compra 4º Entrada");
    op_exec_04 = op_exec_04 + 1;
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
  
 bool HoraPrimeiraEntrada()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaPrimeiraEntrada && horaAtual.hour <= horaPrimeiraEntrada + 1*60)
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
            if(horaAtual.hour == horaPrimeiraEntrada + 1*60)
               {
                  if(horaAtual.min <= minutoPrimeiraEntrada + 1*60)
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
   
   
  
  
  bool HoraSegundaEntrada()
   {
      TimeToStruct(TimeCurrent(), horaAtual);
      if(horaAtual.hour >= horaSegundaEntrada && horaAtual.hour <= horaSegundaEntrada + 1*60)
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
            if(horaAtual.hour == horaSegundaEntrada + 1*60)
               {
                  if(horaAtual.min <= minutoSegundaEntrada + 1*60)
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
      if(horaAtual.hour >= horaTerceiraEntrada && horaAtual.hour <= horaTerceiraEntrada + 1*60)
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
            if(horaAtual.hour == horaTerceiraEntrada + 1*60)
               {
                  if(horaAtual.min <= minutoTerceiraEntrada + 1*60)
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
      if(horaAtual.hour >= horaQuartaEntrada && horaAtual.hour <= horaQuartaEntrada + 1*60)
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
            if(horaAtual.hour == horaQuartaEntrada + 1*60)
               {
                  if(horaAtual.min <= minutoQuartaEntrada + 1*60)
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