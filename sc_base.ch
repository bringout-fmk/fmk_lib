#define EXEPATH   FilePath(Arg0())
#define SIFPATH   trim(cDirSif)+SLASH
#define PRIVPATH  trim(cDirPriv)+SLASH
#define KUMPATH   trim(cDirRad)+SLASH
#define CURDIR    "."+SLASH

#command ESC_EXIT  => if lastkey()=K_ESC;
                      ;exit             ;
                      ;endif

#command ESC_RETURN <x> => if lastkey()=K_ESC;
                           ;return <x>       ;
                           ;endif

#command ESC_RETURN    => if lastkey()=K_ESC;
                           ;return        ;
                           ;endif
#command HSEEK <xpr>     => dbSeek(<xpr> ,.f.)
#command MSEEK <xpr>             => dbSeek(<xpr> )


#command SET MRELATION                                                  ;
         [<add:ADDITIVE>]                                               ;
         [TO <key1> INTO <(alias1)> [, [TO] <keyn> INTO <(aliasn)>]]    ;
                                                                        ;
      => if ( !<.add.> )                                                ;
       ;    dbClearRel()                                                ;
       ; end                                                            ;
                                                                        ;
       ; dbSetRelation( <(alias1)>,{||'1'+<key1>}, "'1'+"+<"key1"> )      ;
      [; dbSetRelation( <(aliasn)>,{||'1'+<keyn>}, "'1'+"+<"keyn"> ) ]


#command EJECTA0          => qqout(chr(13)+chr(10)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0

#command EJECTNA0         => qqout(chr(13)+chr(10)+chr(18)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0


#command FF               => gPFF()
#command P_FF               => gPFF()

#xcommand P_INI              =>  gpini()
#xcommand P_NR              =>   gpnr()
#xcommand P_COND             =>  gpCOND()
#xcommand P_COND2            =>  gpCOND2()
#xcommand P_10CPI            =>  gP10CPI()
#xcommand P_12CPI            =>  gP12CPI()
#xcommand F10CPI            =>  gP10CPI()
#xcommand F12CPI            =>  gP12CPI()
#xcommand P_B_ON             =>  gPB_ON()
#xcommand P_B_OFF            =>  gPB_OFF()
#xcommand P_I_ON             =>  gPI_ON()
#xcommand P_I_OFF            =>  gPI_OFF()
#xcommand P_U_ON             =>  gPU_ON()
#xcommand P_U_OFF            =>  gPU_OFF()

#xcommand P_PO_P             =>  gPO_Port()
#xcommand P_PO_L             =>  gPO_Land()
#xcommand P_RPL_N            =>  gRPL_Normal()
#xcommand P_RPL_G            =>  gRPL_Gusto()

#xcommand P_PIC_H <xpr>      =>  gpPicH(xpr)
#xcommand P_PIC_F            =>  gpPicF()

// stari interfejs
#xcommand INI             =>  gPB_ON()
#xcommand B_ON             =>  gPB_ON()
#xcommand B_OFF            =>  gPB_OFF()
#xcommand I_ON             =>  gPI_ON()
#xcommand I_OFF            =>  gPI_OFF()
#xcommand U_ON             =>  gPU_ON()
#xcommand U_OFF            =>  gPU_OFF()

#xcommand PO_P             =>  gPO_Port()
#xcommand PO_L             =>  gPO_Land()
#xcommand RPL_N            =>  gRPL_Normal()
#xcommand RPL_G            =>  gRPL_Gusto()


#xcommand RESET            =>  gPRESET()



#ifdef CAX
#xcommand CLOSERET   => if used(); set filter to; dbunlockall(); end; return
#else
#xcommand CLOSERET   => close all; return
#endif

#xcommand CLOSERET2   => close all; return

#xcommand CLOSERET <x>  => close all; return <x>

#xcommand ESC_BCR   => if lastkey()=K_ESC;
                           ; close all        ;
                           ; BoxC()           ;
                           ;return            ;
                           ;endif



***
*  @..SAYB
*

#command @ <row>, <col> SAYB <xpr>                                      ;
                        [PICTURE <pic>]                                 ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => DevPos( m_x+<row>, m_y+<col> )                                 ;
       ; DevOutPict( <xpr>, <pic> [, <color>] )


***
*  @..GETB
*

#command @ <row>, <col> GETB <var>                                      ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( m_x+<row>, m_y+<col> )                                 ;
       ; AAdd(                                                          ;
               GetList,                                                 ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )      ;
             )                                                          ;
      [; ATail(GetList):<msg>]


***
*   @..SAYB..GETB
*

#command @ <row>, <col> SAYB <sayxpr>                                   ;
                        [<sayClauses,...>]                              ;
                        GETB <var>                                      ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> SAYB <sayxpr> [<sayClauses>]                    ;
       ; @ Row(), Col()+1 GETB <var> [<getClauses>]


#xcommand DO WHILESC <exp>      => while <exp>                     ;
                                   ;if inkey()==27                 ;
                                   ; dbcloseall()                  ;
                                   ;   SET(_SET_DEVICE,"SCREEN")   ;
                                   ;   SET(_SET_CONSOLE,"ON")      ;
                                   ;   SET(_SET_PRINTER,"")        ;
                                   ;   SET(_SET_PRINTFILE,"")      ;
                                   ;   MsgC()                      ;
                                   ;   return                      ;
                                   ;endif

#command KRESI <x> NA <len> =>  <x>:=left(<x>,<len>)

#command START PRINT CRET <x> =>  if !StartPrint()       ;
                                  ;close all             ;
                                  ;return <x>            ;
                                  ;endif

				
#command START PRINT CRET     =>  if !StartPrint()       ;
                                  ;close all             ;
                                  ;return                ;
                                  ;endif

#command START PRINT CRET DOCNAME <y>    =>  if !StartPrint(nil, nil, <y>)    ;
                                             ;close all             ;
                                             ;return                ;
                                             ;endif

#command START PRINT CRET <x> DOCNAME  <y> =>  if !StartPrint(nil, nil, <y>  )  ;
                                  ;close all             ;
                                  ;return <x>            ;
                                  ;endif



#command START PRINT RET <x>  =>  if !StartPrint()       ;
                                  ;return <x>            ;
                                  ;endif
#command START PRINT RET      =>  if !StartPrint()       ;
                                  ;return                ;
                                  ;endif

#command START PRINT2 CRET <p>, <x> =>  IF !SPrint2(<p>)       ;
                                        ;close all             ;
                                        ;return <x>            ;
                                        ;endif
#command START PRINT2 CRET <p>   =>  if !Sprint2(<p>)          ;
                                     ;close all             ;
                                     ;return                ;
                                     ;endif

#command END PRN2 <x> => Eprint2(<x>)

#command END PRN2     => Eprint2()

#command END PRINT => EndPrint()

#command EOF CRET <x> =>  if EofFndret(.t.,.t.)       ;
                          ;return <x>                 ;
                          ;endif
#command EOF CRET     =>  if EofFndret(.t.,.t.)       ;
                          ;return                     ;
                          ;endif

#command EOF RET <x> =>   if EofFndret(.t.,.f.)      ;
                          ;return <x>             ;
                          ;endif
#command EOF RET     =>   if EofFndret(.t.,.f.)      ;
                          ;return                 ;
                          ;endif

#command NFOUND CRET <x> =>  if EofFndret(.f.,.t.)       ;
                             ;return <x>                 ;
                             ;endif
#command NFOUND CRET     =>  if EofFndret(.f.,.t.)       ;
                             ;return                     ;
                             ;endif

#command NFOUND RET <x> =>  if EofFndret(.f.,.f.)       ;
                            ;return  <x>                ;
                            ;endif
#command NFOUND RET     =>  if EofFndret(.f.,.f.)       ;
                            ;return                     ;
                            ;endif


#command USEX <(db)>                                                   ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      =>  PreUseEvent(<(db)>,.f.,gReadOnly)				;
        ;  dbUseArea(                                                    ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                     .f., gReadOnly       ;
                  )                                                     ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]



#define DE_REF      12      // Force reread/redisplay of all data rows
