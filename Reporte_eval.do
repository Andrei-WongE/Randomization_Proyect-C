///-----------------------------------------------------------------------------
/// Project: Acelaracion de la Innovacion - FONCYTEC/WB
/// Creation date: 08/08/2020
/// Last modification: 08/06/2020
/// Last modification: 14/08/202 ~ assigned numeric scores
/// Author: Andrei Wong Espejo, awongespejo@worldbank.org
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off            // Disable partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // clear all macros
    capture log close       // Close existing log files
    //log using judge_scores.txt, text replace      // Open log file
///-----------------------------------------------------------------------------


///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
    1. Cleaning variables
        //General cleaning
        //Saving variables order
        //Reshape
        //Encode
    2. Assigning numeric score
    3. Order variables in original sequence and saves dta

    */
///-----------------------------------------------------------------------------

    //Set directory
   global base "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\"
   cd "$base"
   
    //Install required packages!
   /*
    net from https://www.sealedenvelope.com/ // Install xfill
   */

   import delimited using "reporte-evaluacion-aceleracion 22052020.csv", varn(1) /// 
   delimiters(",") bindquote(strict) maxquotedrows(unlimited) numericc(1) clear
   d,s //Vars. 47
   assert c(N) ==  264 
   d


//1. Cleaning variables
////////////////////////////
    //General cleaning
    rename razónsocial admin_business_name_e 
    replace admin_business_name_e = strproper(admin_business_name_e)
    cleanchars, in("sac Sac SAC $C") out(S.A.C.) vval
    cleanchars, in("eirl Eirl E.I.R.L.") out(EIRL) vval
    cleanchars, in("ltda") out(LTDA) vval
    replace admin_business_name_e = strtrim(admin_business_name_e) 

    rename nombredelpostulante admin_respondent_name_e
    replace admin_respondent_name_e = strproper(admin_respondent_name_e)
     
    rename registro                             admin_participant_id
    distinct admin_participant_id // 264 unique IDs
    
    rename i1experienciaenejecucióndenegoci     business_exp_e_1
    rename i2experienciaentecnología            tech_exp_e_1
    rename i3trabajoenequipo                    team_work_e_1
    rename i4habilidadesblandasautoconfianz     soft_skilss_e_1
    rename ii1contenidodeid                     id_content_e_1
    rename ii2novedad                           novelty_e_1
    rename iii1tamañopotencial                  potential_size_e_1
    rename iii2conocimientosobrepotenciales     compet_knowledge_e_1
    rename iii3gestióndebarrerasdeentrada       entry_barrers_e_1
    rename iv1validaciónconclientes             validation_clients_e_1
    rename iv2adicionalidad                     adicionality_e_1
    rename v1calidaddelpitch                    pitch_qual_e_1
    rename comentarios                          comments_e_1
    rename calificaciónindividual               judge_score_e_1
    replace judge_score_e_1                     = strproper(judge_score_e_1)
    rename calificaciónfinal                    final_score_e
    replace final_score_e                     = strproper(final_score_e)
    rename comentariosreportado                 comments_reported_e
    
    rename v18                                  business_exp_e_2
    rename v19                                  tech_exp_e_2
    rename v20                                  team_work_e_2
    rename v21                                  soft_skilss_e_2
    rename v22                                  id_content_e_2
    rename v23                                  novelty_e_2
    rename v24                                  potential_size_e_2
    rename v25                                  compet_knowledge_e_2
    rename v26                                  entry_barrers_e_2
    rename v27                                  validation_clients_e_2
    rename v28                                  adicionality_e_2
    rename v29                                  pitch_qual_e_2
    rename v30                                  comments_e_2
    rename v31                                  judge_score_e_2
    replace judge_score_e_2                     = strproper(judge_score_e_2)
  
    rename v32                                  business_exp_e_3
    rename v33                                  tech_exp_e_3
    rename v34                                  team_work_e_3
    rename v35                                  soft_skilss_e_3
    rename v36                                  id_content_e_3
    rename v37                                  novelty_e_3
    rename v38                                  potential_size_e_3
    rename v39                                  compet_knowledge_e_3
    rename v40                                  entry_barrers_e_3
    rename v41                                  validation_clients_e_3
    rename v42                                  adicionality_e_3
    rename v43                                  pitch_qual_e_3
    rename v44                                  comments_e_3
    rename v45                                  judge_score_e_3
    replace judge_score_e_3                     = strproper(judge_score_e_3)
       
    sort admin_participant_id   
           
    //Reshape
    reshape long business_exp_e tech_exp_e team_work_e soft_skilss_e id_content_e ///
    novelty_e potential_size_e compet_knowledge_e entry_barrers_e  ///
    validation_clients_e adicionality_e pitch_qual_e comments_e judge_score_e /// 
    , i(admin_participant_id admin_business_name_e admin_respondent_name_e final_score_e comments_reported_e) j(judge) string
    
  
    //Encode
    #delimit ;  
    local varlist3
    business_exp_e tech_exp_e team_work_e soft_skilss_e id_content_e novelty_e
    potential_size_e compet_knowledge_e entry_barrers_e validation_clients_e 
    adicionality_e pitch_qual_e;
    #delimit cr
    
    label define score 1 "Muy Bueno" 2 "Bueno" 3 "Regular", replace
   
    foreach var of local varlist3 {
      encode `var', g(`var'_2) l(score)
      drop `var'
      rename `var'_2 `var'
    }
    
    label define score2 1 "Aprobado" 0 "Desaprobado", replace

    foreach var of varlist judge_score_e final_score_e {
      encode `var', g(`var'_2) l(score2)
      drop `var'
      rename `var'_2 `var'
    }
    
    encode judge, g(judge_2)
    drop judge
    rename judge_2 judge
        
    //check results
    br

///2. Assigning numeric score
//////////////////////////////
    foreach var of local varlist3 {
        gen `var'_score     = `var', a(`var')
        replace `var'_score = 10 if `var'_score == 1
        replace `var'_score = 5  if `var'_score == 2
        replace `var'_score = 0  if `var'_score == 3        
    }
    //Different numeric scores for id_content_e_score novelty_e_score potential_size_e_score MB=20, B=10 and R=0
    local varlist4 id_content_e_score novelty_e_score potential_size_e_score
    
    foreach var of local varlist4 {
        replace `var' = 20 if `var' == 10
        replace `var' = 10 if `var' == 5     
    }
    
    //Automatic reject if more than one judge rejects on key criteria 
    #delimit ;
    gen reject_judge_e =
    cond(id_content_e_score     == 0,     1,
    cond(novelty_e_score        == 0,     1,
    cond(potential_size_e_score == 0,     1,
                                          0
                ))), a(pitch_qual_e_score);
    #delimit cr   
    
    egen count_rejections_e      = sum(reject_judge_e), by(admin_participant_id)
    bysort admin_participant_id: gen automatic_reject_e = cond(count_rejections_e > 1, 1, 0)
    label var automatic_reject_e "Automatic reject if 1> judge reject key criteria"
    label define reject  0 "PASS" 1 "AUTOMATIC REJECTION", replace
    label values automatic_reject_e reject
    
    /*156 automatic rejections the same as Evaluation report by Judge-panel_17-18-19_NEW_SCORECARD_SJA file in 3.3.9 (dropbox path)*/
        
    //Total score out of 150 points
    #delimit ;  
    local varlist5
    business_exp_e_score tech_exp_e_score team_work_e_score soft_skilss_e_score id_content_e_score novelty_e_score potential_size_e_score compet_knowledge_e_score entry_barrers_e_score validation_clients_e_score adicionality_e_score pitch_qual_e_score;    
    #delimit cr
    egen total_score_e         = rowtotal(`varlist5')
    order total_score_e, a(judge_score_e)
    
    //Average score across 3 judges
    egen average_judge_score_e = mean(total_score_e), by(admin_participant_id)
    order average_judge_score_e, a(final_score_e)
    
    //Ranking
    bysort admin_participant_id: gen group_id = _n
    
    gsort -average_judge_score_e
    
    egen ranking_scores_e  = rank(-average_judge_score_e) if automatic_reject_e != 1 &group_id== 1, unique
    //Dont forget to install xfill!!! See line 43.    
    xfill ranking_scores_e, i(admin_participant_id)
    
    sort ranking_scores_e
    drop group_id
    /*WARNING: Scores now include "Adicionalidad - Comercialización" scores hence 
    ranking positions have changed but same firms are selected. */

   
///3. Order variables in original sequence and saves dta
/////////////////////////////////////////////////////////
    /*order admin_participant_id judge admin_business_name_e admin_respondent_name_e ///
    business_exp_e tech_exp_e team_work_e soft_skilss_e id_content_e ///
    novelty_e potential_size_e compet_knowledge_e entry_barrers_e  ///
    validation_clients_e adicionality_e pitch_qual_e comments_e judge_score_e /// 
    final_score_e comments_reported_e */
    
    order reject_judge_e count_rejections_e automatic_reject_e, b(total_score_e)
    order judge, a(admin_participant_id)
    
    compress
    /*
    export excel using "Evaluation_scores_clean.xls", firstrow(variables) replace
    */
    
    save Evaluation_scores_clean, replace
       
/// Close the log, end the file
   //log close
   //exit