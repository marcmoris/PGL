Create View vexpdia 
      ( ciecle,
        expnumexp,
        blinumbli,
        dianum002,
        emdpriuni,
        ftrnumfac,
        comnumcom,
        v_qte_tot_dia )
As
 Select lch.ciecle,
        lch.expnumexp,
        lch.blinumbli,
        emd.dianum002,
        Max( emd.emdpriuni ),
        bli.ftrnumfac,
        ftr.comnumcom,
        prosig_nvln( ( Select Sum( emd1.emdqteprd ) From pdembal_diag    emd1,
                                                         pdlivre_caisson lch1
                                Where emd1.dianum002 = emd.dianum002
                                  And emd1.cainumcai = lch1.cainumcaI
                                  And lch1.expnumexp = lch.expnumexp
                                  And lch1.blinumbli = lch.blinumbli ) )
   From pdlivre_caisson lch,
        pdembal_diag    emd,
        pdfact_bon_livr bli,
        pdfacture       ftr
  Where lch.ciecle       = emd.ciecle 
    And lch.cainumcai    = emd.cainumcai
    And lch.expnumexp    = bli.expnumexp
    And lch.blinumbli    = bli.blinumbli
    And bli.ftrnumfac    = ftr.ftrnumfac
    And emd.comnumcom    = ftr.comnumcom
  Group By lch.ciecle,
           lch.expnumexp,
           lch.blinumbli,
           bli.ftrnumfac,
           ftr.comnumcom,
           emd.dianum002;
