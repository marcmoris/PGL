create View vmacall
As
 Select m1.ciecle       as maccie,
        m1.mficodmac    as maccod,
        m1.mfidsc001    as macdsc,
        'Finition'      as macori
   From PDMACH_DE_FINIT m1
union
 Select m2.ciecle       as maccie,
        m2.mdecodmac    as maccod,
        m2.mdedsc001    as macdsc,
        'Débitage'      as macori
   From PDMACH_DEBITAGE m2
union
 Select m3.ciecle       as maccie,
        m3.mopcodmac    as maccod,
        m3.mopdsc001    as macdsc,
        'Surface '      as macori
   From PDMACH_OP_SURF  m3
union
 Select m4.ciecle       as maccie,
        m4.scinumsci    as maccod,
        m4.scidsc001    as macdsc,
        'Scies   '      as macori
   From PDSCIES         m4
