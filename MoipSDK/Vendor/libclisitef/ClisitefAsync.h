//
//  ClisitefAsync.h
//  clisitefasync
//
//  Created by Software Express - Desenvolvimento iOS on 31/07/13.
//  Copyright (c) 2013 Software Express - Desenvolvimento iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ClisitefiDelegates
@optional
-(void)respostaConfigura: (int)pResposta;
-(void)respostaInicia: (int)pResposta;
-(void)respostaContinua: (int)pResposta pComando:(int)pComando pTipoCampo:(long)pTipoCampo
         pTamanhoMinimo:(short)pTamanhoMinimo pTamanhoMaximo:(short)pTamanhoMaximo
         pBuffer:(NSString*)pBuffer;
-(void)respostaFinaliza;
-(void)respostaFinalizaEx: (int)pResposta;

-(void)respostaLeCartaoSeguro:(int)Resultado;
-(void)respostaLeSenhaDireto:(int)Resultado
                            Senha:(NSString*)Senha;
-(void)respostaObtemInformacoesPinPad:(int)pResultado
                          pFabricante:(NSString*)pFabricante
                              pModelo:(NSString*)pModelo
                            pFirmware:(NSString*)pFirmware
                               pEspec:(NSString*)pEspec
                           pAppBasica:(NSString*)pAppBasica
                            pNumSerie:(NSString*)pNumSerie;
@end


@interface ClisitefAsync : NSObject
{
  id<ClisitefiDelegates> _Delegates;
}

-(void) SetDelegates: (id<ClisitefiDelegates>) delegates;

-(void) ConfiguraIntSiTefInterativo: (NSString*)pEnderecoIP pCodigoLoja:(NSString*) pCodigoLoja
              pNumeroTerminal:(NSString*) pNumeroTerminal ConfiguraResultado:(short)ConfiguraResultado
              pParametrosAdicionais:(NSString*) pParametrosAdicionais;
							
-(void) IniciaFuncaoSiTefInterativo: (int)pModalidade
                             pValor:(NSString*)pValor
                 pNumeroCupomFiscal:(NSString*)pNumeroCupomFiscal
                        pDataFiscal:(NSString*)pDataFiscal
                           pHorario:(NSString*)pHorario
                          pOperador:(NSString*)pOperador
                        pRestricoes:(NSString*)pRestricoes;

-(void) ContinuaFuncaoSiTefInterativo: (int)pContinua pBuffer:(NSString*)pBuffer;

-(void) FinalizaTransacaoSiTefInterativo: (short)pConfirma
                   pNumeroCupomFiscal:(NSString*)pNumeroCupomFiscal
                          pDataFiscal:(NSString*)pDataFiscal
                             pHorario:(NSString*)pHorario;
														 
-(void) FinalizaTransacaoSiTefInterativoEx: (short)pConfirma
                   pNumeroCupomFiscal:(NSString*)pNumeroCupomFiscal
                          pDataFiscal:(NSString*)pDataFiscal
                             pHorario:(NSString*)pHorario
							  pParametrosAdicionais:(NSString*)pParametrosAdicionais;
														 
-(void) LeCartaoSeguro: (NSString*)pMensagem;

-(void) LeSenhaDireto: (NSString*)pChave;

-(void) ObtemInformacoesPinPad;										 

@end
