SELECT
        WFP.IDPROCESS idconcurso,
        WFP.NMPROCESS nminstancia,
        CONCURSO.nomcombocatoria nmconcurso,
        CASE WHEN CONCURSO.tipoagen = 1 THEN 'INTERNA'
        WHEN CONCURSO.tipoagen = 2 THEN 'EXTERNA' ELSE '' END tipoconcurso,
        CASE WHEN CONCURSO.tipoeval = 1 THEN 'INTERNA'
        WHEN CONCURSO.tipoeval = 2 THEN 'EXTERNA'
        WHEN CONCURSO.tipoeval = 3 THEN 'MIXTA'
        WHEN CONCURSO.tipoeval = 4 THEN 'NO APLICA' END tipoevaluacion
    FROM
        WFPROCESS WFP      
    JOIN
        GNASSOCFORMREG REG              
            ON WFP.CDASSOCREG = REG.CDASSOC      
    JOIN
        DYNFORM CONCURSO              
            ON REG.OIDENTITYREG=CONCURSO.OID          
    WHERE
        CDPROCESSMODEL = 15  