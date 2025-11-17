Create View vexpsub1
      ( ciecle,
        expnumexp,
        blinumbli,
        ftrnumfac,
        comnumcom )
As
 Select bli.ciecle,   
        bli.expnumexp,
        bli.blinumbli,
        bli.ftrnumfac,
        ftr.comnumcom
   From pdfact_bon_livr bli,
        pdfacture       ftr
  Where BLI.FTRNUMFAC    = FTR.FTRNUMFAC;

Create View vexpsub2
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
        lch.cainumcai,
        emt.tranumtra002,
        emt.emtpriuni,
        bli.ftrnumfac,
        emt.comnumcom,
        prosig_nvln( ( Select Sum( emt1.emtqteprd ) From pdembal_tranche emt1,
                                                         pdlivre_caisson lch1
                                Where emt1.tranumtra002 = emt.tranumtra002
                                  And emt1.cainumcai = lch1.cainumcai
                                  And lch1.expnumexp = lch.expnumexp
                                  And lch1.blinumbli = lch.blinumbli ) )
   From pdlivre_caisson lch,
        pdembal_tranche emt,
        pdfact_bon_livr bli
  Where LCH.CIECLE       = EMT.CIECLE
    And LCH.CAINUMCAI    = EMT.CAINUMCAI
    And LCH.CIECLE       = BLI.CIECLE
    And LCH.EXPNUMEXP    = BLI.EXPNUMEXP
    And LCH.BLINUMBLI    = BLI.BLINUMBLI;

Create View vexpsub
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
 Select vs2.ciecle,
        vs2.expnumexp,
        vs2.blinumbli,
        vs2.cainumcai,
        vs2.tranumtra002,
        vs2.emtpriuni,
        vs2.ftrnumfac,
        vs2.comnumcom,
        vs2.v_qte_tot_tra
   From vexpsub2 vs2,
        vexpsub1 vs1 
  Where vs2.CIECLE       = vs1.CIECLE
    And vs2.EXPNUMEXP    = vs1.EXPNUMEXP
    And vs2.BLINUMBLI    = vs1.BLINUMBLI
    And vs2.CIECLE       = vs1.CIECLE
    And vs2.FTRNUMFAC    = vs1.FTRNUMFAC
    And vs2.COMNUMCOM    = vs1.COMNUMCOM;


drop view vexptra;

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
 Select vpb.ciecle,
        vpb.expnumexp,
        vpb.blinumbli,
        max( vpb.cainumcai ),
        vpb.tranumtra002,
        max( vpb.emtpriuni ),
        vpb.ftrnumfac,
        vpb.comnumcom,
        max( vpb.v_qte_tot_tra )
   From vexpsub vpb
  Group By vpb.CIECLE,
           vpb.EXPNUMEXP,
           vpb.BLINUMBLI,
           vpb.FTRNUMFAC,
           vpb.COMNUMCOM,
           vpb.TRANUMTRA002;




