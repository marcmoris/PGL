/*
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL
*/

Create View vexptra 
      ( ciecle,
        expnumexp,
        blinumbli,
        cainumcai,
        tranumtra002,
        emtpriuni,
        ftrnumfac,
        comnumcom,
        v_qte_tot_tra )
As
 Select lch.ciecle,
        lch.expnumexp,
        lch.blinumbli,
        Max( lch.cainumcai ),
        emt.tranumtra002,
        Max( emt.emtpriuni ),
        bli.ftrnumfac,
        ftr.comnumcom,
        prosig_nvln( ( Select Sum( emt1.emtqteprd ) From pdembal_tranche emt1,
                                                         pdlivre_caisson lch1
                                Where emt1.tranumtra002 = emt.tranumtra002
                                  And emt1.cainumcai = lch1.cainumcai
                                  And lch1.expnumexp = lch.expnumexp
                                  And lch1.blinumbli = lch.blinumbli ) )
   From pdlivre_caisson lch,
        pdembal_tranche emt,
        pdfact_bon_livr bli,
        pdfacture       ftr
  Where LCH.CIECLE       = EMT.CIECLE
    And LCH.CAINUMCAI    = EMT.CAINUMCAI
    And LCH.CIECLE       = BLI.CIECLE
    And LCH.EXPNUMEXP    = BLI.EXPNUMEXP
    And LCH.BLINUMBLI    = BLI.BLINUMBLI
    And LCH.CIECLE       = FTR.CIECLE
    And BLI.FTRNUMFAC    = FTR.FTRNUMFAC
    And EMT.COMNUMCOM    = FTR.COMNUMCOM
  Group By LCH.CIECLE,
           LCH.EXPNUMEXP,
           LCH.BLINUMBLI,
           BLI.FTRNUMFAC,
           FTR.COMNUMCOM,
           EMT.TRANUMTRA002;
