SELECT
/** 
Creación:  
16-05-2022. Andrés Del Río. Lista los concursos, proyectos, ejecuciones de proyecto, solicitudes de cambio,
de tal forma que el CIED realizar las gestiones que correspondan
Versión: 2.1.8.49
Ambiente: https://ust.softexpert.com/
Panel de análisis: 
        
Modificaciones: 
DD-MM-AAAA. Andrés Del Río. Descripción  


230 - concurso
244 - gestion proyecto
243 - conflicto
246 - eval técnica
247 - eval financiera
238 - ejecución de proyecto

**/       
        CONCURSO.id_wkf_concurso,
        CONCURSO.titulo_wkf_concurso,
        CONCURSO.titulo_concurso,
        CONCURSO.descripcion_concurso,
        CONCURSO.tipo_evaluacion,
        CONCURSO.cantidad_concursos,
        CONCURSO.fecha_apertura,
        CONCURSO.fecha_cierre,
        CONCURSO.hora_cierre,
        CONCURSO.fecha_limite_consultas,
        CONCURSO.situacion_concurso,
        CONCURSO.plazo_concurso,
        CONCURSO.id_situacion_concurso,
        CONCURSO.nombre_situacion_concurso,
        PROYECTO.id_wkf_idea_proy,
        PROYECTO.titulo_wkf_proyecto,
        PROYECTO.titulo_proyecto,
        PROYECTO.investigador_proyecto,
        PROYECTO.descripcion_proyecto,
        PROYECTO.admisibilidad,
        PROYECTO.promedio_eval_tecnica,
        PROYECTO.cantidad_proy,
        PROYECTO.situacion_proyecto,
        PROYECTO.plazo_proyecto,
        PROYECTO.id_situacion_proyecto,
        PROYECTO.nombre_situacion_proyecto,
        PROYECTO.id_actividad_proyecto,
        IDEA.titulo_idea,
        IDEA.investigador_idea,
        IDEA.estado_idea,
        IDEA.cantidad_ideas,
        IDEA.situacion_idea,
        IDEA.plazo_idea,
        IDEA.id_situacion_idea,
        IDEA.nombre_situacion_idea,
        CURRENT_DATE fecha_hoy, 
        1 as cantidad      
    FROM
        (SELECT
            WFP.idprocess id_wkf_concurso,
            WFP.nmprocess titulo_wkf_concurso,
            FORMCONC.nombconc titulo_concurso,
            FORMCONC.descrconvoca descripcion_concurso,
            CASE 
                WHEN tipoeval = 1 THEN 'Interna'             
                WHEN tipoeval = 2 THEN 'Externa'             
                WHEN tipoeval = 3 THEN 'Mixta'             
                WHEN tipoeval = 4 THEN 'Sin Evaluación'             
            END tipo_evaluacion,

            CASE WFP.FGSTATUS 
                    WHEN 1 THEN '#{103131}' 
                    WHEN 2 THEN '#{107788}' 
                    WHEN 3 THEN '#{104230}' 
                    WHEN 4 THEN '#{100667}' 
                    WHEN 5 THEN '#{200712}' 
            END AS situacion_concurso,

            CASE 
                    WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                        WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}' 
                        WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}' 
                    END) 
                    ELSE (CASE 
                        WHEN (( WFP.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
                            QTDAYS 
                        FROM
                            ADMAILTASKEXEC 
                        WHERE
                            CDMAILTASKEXEC=(SELECT
                                TASK.CDAHEAD 
                            FROM
                                ADMAILTASKREL TASK 
                            WHERE
                                TASK.CDMAILTASKREL=(SELECT
                                    TBL.CDMAILTASKSETTINGS 
                                FROM
                                    CONOTIFICATION TBL))), 0))) 
                        OR (WFP.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}' 
                        WHEN (( WFP.DTESTIMATEDFINISH=CAST( cast(now() as date) AS DATE) 
                        AND WFP.NRTIMEESTFINISH >= (extract('minute' 
                    FROM
                        now()) + extract('hour' 
                    FROM
                        now()) * 60)) 
                        OR (WFP.DTESTIMATEDFINISH > CAST( cast(now() as date) AS DATE))) THEN '#{201639}' 
                        ELSE '#{100899}' 
                    END) 
                END AS plazo_concurso,

                GNRS.IDREVISIONSTATUS id_situacion_concurso,
                GNRS.NMREVISIONSTATUS nombre_situacion_concurso,

            1 as cantidad_concursos,
            FORMCONC.fapertura fecha_apertura,
            FORMCONC.fcierre fecha_cierre,
            FORMCONC.horacierr hora_cierre,
            FORMCONC.fconsulta fecha_limite_consultas                                  
        FROM
            WFPROCESS WFP                                                           
        JOIN
            GNASSOCFORMREG REG                                                                                                           
                ON WFP.CDASSOCREG = REG.CDASSOC                                                           
        JOIN
            DYNFORM FORMCONC                                                                                                           
                ON REG.OIDENTITYREG=FORMCONC.OID  
        LEFT JOIN
                GNREVISIONSTATUS GNRS 
                    ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS           
        WHERE
            WFP.CDPROCESSMODEL = 230
            AND WFP.FGSTATUS <= 5) CONCURSO    
    LEFT JOIN
        (
            SELECT
                WFP.idprocess id_wkf_idea_proy,
                WFP.nmprocess titulo_wkf_proyecto,
                FORMPROY.nombredelproyec titulo_proyecto,
                FORMPROY.usrconectado investigador_proyecto,
                FORMPROY.idconcurso id_wkf_concurso,
                FORMPROY.texto1 descripcion_proyecto,
                FORMPROY.defadmi admisibilidad,
                FORMPROY.promeval promedio_eval_tecnica,

                CASE WFP.FGSTATUS 
                    WHEN 1 THEN '#{103131}' 
                    WHEN 2 THEN '#{107788}' 
                    WHEN 3 THEN '#{104230}' 
                    WHEN 4 THEN '#{100667}' 
                    WHEN 5 THEN '#{200712}' 
                END AS situacion_proyecto,

                            CASE 
                    WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                        WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}' 
                        WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}' 
                    END) 
                    ELSE (CASE 
                        WHEN (( WFP.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
                            QTDAYS 
                        FROM
                            ADMAILTASKEXEC 
                        WHERE
                            CDMAILTASKEXEC=(SELECT
                                TASK.CDAHEAD 
                            FROM
                                ADMAILTASKREL TASK 
                            WHERE
                                TASK.CDMAILTASKREL=(SELECT
                                    TBL.CDMAILTASKSETTINGS 
                                FROM
                                    CONOTIFICATION TBL))), 0))) 
                        OR (WFP.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}' 
                        WHEN (( WFP.DTESTIMATEDFINISH=CAST( cast(now() as date) AS DATE) 
                        AND WFP.NRTIMEESTFINISH >= (extract('minute' 
                    FROM
                        now()) + extract('hour' 
                    FROM
                        now()) * 60)) 
                        OR (WFP.DTESTIMATEDFINISH > CAST( cast(now() as date) AS DATE))) THEN '#{201639}' 
                        ELSE '#{100899}' 
                    END) 
                END AS plazo_proyecto,

                GNRS.IDREVISIONSTATUS id_situacion_proyecto,
                GNRS.NMREVISIONSTATUS nombre_situacion_proyecto,

                (SELECT
            MAX(WFS.IDSTRUCT)                                    
        FROM
            WFPROCESS WFP2                                                    
        INNER JOIN
            WFSTRUCT WFS                                                                                                            
                ON WFS.IDPROCESS=WFP2.IDOBJECT                                                    
        INNER JOIN
            WFACTIVITY WFA                                                                                                            
                ON WFS.IDOBJECT=WFA.IDOBJECT                                 
        WHERE
            WFP2.FGSTATUS <= 5                                    
            AND   WFS.FGSTATUS = 2
            AND WFP2.IDPROCESS = WFP.IDPROCESS) id_actividad_proyecto,

                1 as cantidad_proy                                
            FROM
                WFPROCESS WFP                                                           
            JOIN
                GNASSOCFORMREG REG                                                                                                           
                    ON WFP.CDASSOCREG = REG.CDASSOC                                                           
            JOIN
                DYNFORM FORMPROY                                                                                                           
                    ON REG.OIDENTITYREG=FORMPROY.OID   
            LEFT JOIN
                GNREVISIONSTATUS GNRS 
                    ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS             
            WHERE
                WFP.CDPROCESSMODEL = 244
                AND WFP.FGSTATUS <= 5
        ) PROYECTO 
            ON PROYECTO.id_wkf_concurso = CONCURSO.id_wkf_concurso 
    RIGHT JOIN
        (
            SELECT
                WFP.idprocess id_wkf_idea,
                FORMPROY.tituidea titulo_idea,
                FORMPROY.usrconectado investigador_idea,
                CASE 
                    WHEN FORMPROY.regiidea = 1 THEN 'Registrar Nueva Idea'             
                    WHEN FORMPROY.regiidea = 2 THEN 'Seleccionar Idea Previamente Registrada'              
                    WHEN FORMPROY.regiidea = 3 THEN 'Continuar a Crear Perfil de Proyecto Sin Registrar Idea'             
                    ELSE ''             
                END estado_idea,

                CASE WFP.FGSTATUS 
                    WHEN 1 THEN '#{103131}' 
                    WHEN 2 THEN '#{107788}' 
                    WHEN 3 THEN '#{104230}' 
                    WHEN 4 THEN '#{100667}' 
                    WHEN 5 THEN '#{200712}' 
                END AS situacion_idea,

                            CASE 
                    WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE 
                        WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}' 
                        WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}' 
                    END) 
                    ELSE (CASE 
                        WHEN (( WFP.DTESTIMATEDFINISH > (CAST(<!%TODAY%> AS DATE) + COALESCE((SELECT
                            QTDAYS 
                        FROM
                            ADMAILTASKEXEC 
                        WHERE
                            CDMAILTASKEXEC=(SELECT
                                TASK.CDAHEAD 
                            FROM
                                ADMAILTASKREL TASK 
                            WHERE
                                TASK.CDMAILTASKREL=(SELECT
                                    TBL.CDMAILTASKSETTINGS 
                                FROM
                                    CONOTIFICATION TBL))), 0))) 
                        OR (WFP.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}' 
                        WHEN (( WFP.DTESTIMATEDFINISH=CAST( cast(now() as date) AS DATE) 
                        AND WFP.NRTIMEESTFINISH >= (extract('minute' 
                    FROM
                        now()) + extract('hour' 
                    FROM
                        now()) * 60)) 
                        OR (WFP.DTESTIMATEDFINISH > CAST( cast(now() as date) AS DATE))) THEN '#{201639}' 
                        ELSE '#{100899}' 
                    END) 
                END AS plazo_idea,

                GNRS.IDREVISIONSTATUS id_situacion_idea,
                GNRS.NMREVISIONSTATUS nombre_situacion_idea,

                1 as cantidad_ideas                              
            FROM
                WFPROCESS WFP                                                           
            JOIN
                GNASSOCFORMREG REG                                                                                                           
                    ON WFP.CDASSOCREG = REG.CDASSOC                                                           
            JOIN
                DYNFORM FORMPROY                                                                                                           
                    ON REG.OIDENTITYREG=FORMPROY.OID             
            LEFT JOIN
                GNREVISIONSTATUS GNRS 
                    ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS   
            WHERE
                WFP.CDPROCESSMODEL = 244
                AND WFP.FGSTATUS <= 5
        ) IDEA 
            ON IDEA.id_wkf_idea = PROYECTO.id_wkf_idea_proy 