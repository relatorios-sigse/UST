SELECT
/** 
Creación:  
16-05-2022. Andrés Del Río. Lista los concursos, proyectos, ejecuciones de proyecto, solicitudes de cambio,
de tal forma que el CIED realizar las gestiones que correspondan
Versión: 2.1.8.49
Ambiente: https://ust.softexpert.com/
Panel de análisis: REPCONPRO - Reporte de Concursos y Proyectos
        
Modificaciones: 
08-06-2022. Andrés Del Río. Ajuste de registros de ideas y proyectos.
14-06-2022. Andrés Del Río. Inclusión de columna "adjudicacion" y "presupuesto_cumple"
20-06-2022. Andrés Del Río. Incidente. Registros duplicados en vista de postulaciones. Solución:
consulta de columna "presupuesto_cumple" se hace como subconsulta en lugar de hacer JOIN.
Esto bajo el supuesto que solamente puede haber una evaluación financiera en cada proyecto.

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
        PROYECTO.titulo_wkf_idea_proy,
        PROYECTO.titulo_idea_proy,
        PROYECTO.investigador_idea_proy,
        PROYECTO.estado_idea,
        PROYECTO.descripcion_idea_proy,
        PROYECTO.admisibilidad,
        PROYECTO.adjudicacion,
        PROYECTO.promedio_eval_tecnica,
        (SELECT
            CASE                  
                WHEN FORMEVAL.prescump = 1 THEN 'Si'                  
                WHEN FORMEVAL.prescump = 2 THEN 'No'                  
            END                                          
        FROM
            WFPROCESS WFP              
        JOIN
            WFPROCESS WP                      
                ON WFP.IDPARENTPROCESS = WP.IDOBJECT                                                                       
        LEFT JOIN
            GNASSOCFORMREG REG                                                                 
                ON WFP.CDASSOCREG = REG.CDASSOC                                                                        
        LEFT JOIN
            DYNgridevalfina FORMEVAL                                                           
                ON REG.OIDENTITYREG=FORMEVAL.OID                
        LEFT JOIN
            GNREVISIONSTATUS GNRS                      
                ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS                          
        WHERE
            WFP.CDPROCESSMODEL = 247                 
            AND WFP.FGSTATUS <= 5   
            AND FORMEVAL.prescump IS NOT NULL
            AND WP.IDPROCESS = PROYECTO.id_wkf_idea_proy             LIMIT 1) presupuesto_cumple,
        PROYECTO.cantidad_idea_proy,
        PROYECTO.situacion_idea_proy,
        PROYECTO.plazo_idea_proy,
        PROYECTO.id_situacion_idea_proy,
        PROYECTO.nombre_situacion_idea_proy,
        PROYECTO.id_actividad_proyecto,
        CURRENT_DATE fecha_hoy,
        1 cantidad,
        EVALUACION.id_wkf_eval_tecn,
        EVALUACION.titulo_wkf_eval_tecn,
        EVALUACION.situacion_eval_tecn,
        EVALUACION.evaluador,
        EVALUACION.conflicto_interes,
        EVALUACION.puntaje1,
        EVALUACION.puntaje2,
        EVALUACION.puntaje3,
        EVALUACION.puntaje4,
        EVALUACION.puntaje5,
        EVALUACION.puntaje6,
        EVALUACION.puntaje7,
        EVALUACION.puntaje8,
        EVALUACION.puntaje9,
        EVALUACION.puntaje10,
        EVALUACION.resulpunta1,
        EVALUACION.comentario1,
        EVALUACION.comentario2,
        EVALUACION.comentario3,
        EVALUACION.comentario4,
        EVALUACION.comentario5,
        EVALUACION.comenatario6,
        EVALUACION.comentario7,
        EVALUACION.comentario8,
        EVALUACION.comentario9,
        EVALUACION.comentario10,
        EVALUACION.cantidad_eval_tecn        
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
            AND WFP.FGSTATUS <= 5
        ) CONCURSO         
    LEFT JOIN
        (
            SELECT
                WFP.idprocess id_wkf_idea_proy,
                WFP.nmprocess titulo_wkf_idea_proy,
                FORMPROY.nombredelproyec titulo_idea_proy,
                FORMPROY.usrconectado investigador_idea_proy,
                '' estado_idea,
                FORMPROY.idconcurso id_wkf_concurso,
                FORMPROY.texto1 descripcion_idea_proy,
                FORMPROY.defadmi admisibilidad,
                FORMPROY.adjuproy adjudicacion,
                FORMPROY.promeval promedio_eval_tecnica,
                CASE WFP.FGSTATUS                      
                    WHEN 1 THEN '#{103131}'                      
                    WHEN 2 THEN '#{107788}'                      
                    WHEN 3 THEN '#{104230}'                      
                    WHEN 4 THEN '#{100667}'                      
                    WHEN 5 THEN '#{200712}'                  
                END AS situacion_idea_proy,
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
                END AS plazo_idea_proy,
                GNRS.IDREVISIONSTATUS id_situacion_idea_proy,
                GNRS.NMREVISIONSTATUS nombre_situacion_idea_proy,
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
                1 as cantidad_idea_proy                                             
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
        LEFT JOIN
            (
                SELECT
                    WFP.idprocess id_wkf_eval_tecn,
                    WFP.nmprocess titulo_wkf_eval_tecn,
                    WP.idprocess id_wkf_proyecto,
                    CASE WFP.FGSTATUS                      
                        WHEN 1 THEN '#{103131}'                      
                        WHEN 2 THEN '#{107788}'                      
                        WHEN 3 THEN '#{104230}'                      
                        WHEN 4 THEN '#{100667}'                      
                        WHEN 5 THEN '#{200712}'                  
                    END AS situacion_eval_tecn,
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
                    END AS plazo_eval_tecn,
                    GNRS.IDREVISIONSTATUS id_situacion_eval_tecn,
                    GNRS.NMREVISIONSTATUS nombre_situacion_eval_tecn,
                    FORMEVAL.nombinvestigado evaluador,
                    FORMEVAL.confinte conflicto_interes,
                    FORMEVAL.puntaje1,
                    FORMEVAL.puntaje2,
                    FORMEVAL.puntaje3,
                    FORMEVAL.puntaje4,
                    FORMEVAL.puntaje5,
                    FORMEVAL.puntaje6,
                    FORMEVAL.puntaje7,
                    FORMEVAL.puntaje8,
                    FORMEVAL.puntaje9,
                    FORMEVAL.puntaje10,
                    FORMEVAL.resulpunta1,
                    FORMEVAL.comentario1,
                    FORMEVAL.comentario2,
                    FORMEVAL.comentario3,
                    FORMEVAL.comentario4,
                    FORMEVAL.comentario5,
                    FORMEVAL.comenatario6,
                    FORMEVAL.comentario7,
                    FORMEVAL.comentario8,
                    FORMEVAL.comentario9,
                    FORMEVAL.comentario10,
                    1 as cantidad_eval_tecn                                             
                FROM
                    WFPROCESS WFP              
                JOIN
                    WFPROCESS WP                      
                        ON WFP.IDPARENTPROCESS = WP.IDOBJECT                                                                       
                LEFT JOIN
                    GNASSOCFORMREG REG                                                                                                                                
                        ON WFP.CDASSOCREG = REG.CDASSOC                                                                        
                LEFT JOIN
                    DYNformusrgrideval FORMEVAL                                                                                                                                
                        ON REG.OIDENTITYREG=FORMEVAL.OID                
                LEFT JOIN
                    GNREVISIONSTATUS GNRS                      
                        ON WFP.CDSTATUS=GNRS.CDREVISIONSTATUS                          
                WHERE
                    WFP.CDPROCESSMODEL = 246                 
                    AND WFP.FGSTATUS <= 5         
                ) EVALUACION 
                    ON EVALUACION.id_wkf_proyecto = PROYECTO.id_wkf_idea_proy  
            UNION
            SELECT
                '' id_wkf_concurso,
                '' titulo_wkf_concurso,
                '' titulo_concurso,
                '' descripcion_concurso,
                '' tipo_evaluacion,
                null cantidad_concursos,
                null fecha_apertura,
                null fecha_cierre,
                null hora_cierre,
                null fecha_limite_consultas,
                '' situacion_concurso,
                '' plazo_concurso,
                '' id_situacion_concurso,
                '' nombre_situacion_concurso,
                WFP.idprocess id_wkf_idea_proy,
                WFP.nmprocess titulo_wkf_idea_proy,
                FORMPROY.tituidea titulo_idea_proy,
                FORMPROY.usrconectado investigador_idea_proy,
                CASE                      
                    WHEN FORMPROY.regiidea = 1 THEN 'Registrar Nueva Idea'                                  
                    WHEN FORMPROY.regiidea = 2 THEN 'Seleccionar Idea Previamente Registrada'                                   
                    WHEN FORMPROY.regiidea = 3 THEN 'Continuar a Crear Perfil de Proyecto Sin Registrar Idea'                                  
                    ELSE ''                              
                END estado_idea,
                '' descripcion_idea_proy,
                '' admisibilidad,
                '' adjudicacion,
                NULL promedio_eval_tecnica,
                '' presupuesto_cumple,
                1 cantidad_idea_proy,
                CASE WFP.FGSTATUS                      
                    WHEN 1 THEN '#{103131}'                      
                    WHEN 2 THEN '#{107788}'                      
                    WHEN 3 THEN '#{104230}'                      
                    WHEN 4 THEN '#{100667}'                      
                    WHEN 5 THEN '#{200712}'                  
                END AS situacion_idea_proy,
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
                END AS plazo_idea_proy,
                GNRS.IDREVISIONSTATUS id_situacion_idea_proy,
                GNRS.NMREVISIONSTATUS nombre_situacion_idea_proy,
                '' id_actividad_proyecto,
                CURRENT_DATE fecha_hoy,
                1 cantidad,
                '' id_wkf_eval_tecn,
                '' titulo_wkf_eval_tecn,
                '' situacion_eval_tecn,
                '' evaluador,
                '' conflicto_interes,
                NULL puntaje1,
                NULL puntaje2,
                NULL puntaje3,
                NULL puntaje4,
                NULL puntaje5,
                NULL puntaje6,
                NULL puntaje7,
                NULL puntaje8,
                NULL puntaje9,
                NULL puntaje10,
                NULL resulpunta1,
                '' comentario1,
                '' comentario2,
                '' comentario3,
                '' comentario4,
                '' comentario5,
                '' comenatario6,
                '' comentario7,
                '' comentario8,
                '' comentario9,
                '' comentario10,
                NULL cantidad_eval_tecn                
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