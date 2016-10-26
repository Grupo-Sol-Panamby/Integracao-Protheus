#include "protheus.ch"

User Function WSC()
// Criando o objeto Web Service
_oWSTeste := WSComputerUnit():New()
// A Variavel NCOMPUTERVALUE é o numero que deseja converter
_oWSTeste:NCOMPUTERVALUE := 1000
// A Variavel _oWSTeste:oWSFROMCOMPUTERUNIT:VALUE é de qual medida deseja

// converter
_oWSTeste:oWSFROMCOMPUTERUNIT:VALUE := "Gigabyte"
// A Variavel _oWSTeste:oWSFROMCOMPUTERUNIT:VALUE é para qual medida deseja

// converter
_oWSTeste:oWSTOCOMPUTERUNIT:VALU := "Kilobyte"
// Executa o metodo ChangeComputerUnit
_oWSTeste:ChangeComputerUnit()
// Mostra o resultado
MsgStop(_oWSTeste:NCHANGECOMPUTERUNITRESULT)
Return