///-----------------------------------------------------------------------------
/// Project: Acelaracion de la Innovacion - FONCYTEC/WB
/// Creation date: 11/05/2020
/// Last modification: 03/05/2020
/// Corrections: 14/07/2020
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
    //log using teachermobility.txt, text replace      // Open log file
///-----------------------------------------------------------------------------


///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
    1. Cleaning variables
        //Finds long variable names
        //Saves original variables order
        //General cleaning
    2. Label variables
    3. Order variables in original sequence and saves dta

    */
///-----------------------------------------------------------------------------

    //Set directory
   global base "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\"
   cd "$base"

   import excel "Recruitment_survey_E061-2019-BM_clean.xlsx", cellrange(A4:RR119) firstrow clear
   d,s //Vars. 486
   assert c(N) == 115
   d

   //Install required packages
   //ssc install labutil2, replace

//1. Cleaning variables
////////////////////////////
    //Find long variable names
    findname, any(length("@") > 25) //max length 32!

    //Saving variables order
    ds
    local order `r(varlist)'

    //General cleaning
    destring admin_participant_id, replace
    unique admin_participant_id //Unique 115 IDs

    destring bo_registration_number admin_respondent_phone_r turnover_cumul_r, replace force
    format bo_registration_number %11.0f
    format admin_respondent_phone_r %9.0f

    replace admin_business_name_r = strproper(admin_business_name_r)
    cleanchars, in("sac Sac SAC") out(S.A.C.) vval
    cleanchars, in("eirl Eirl E.I.R.L.") out(EIRL) vval
    
    replace admin_respondent_name_r = strproper(admin_respondent_name_r)
    replace admin_legal_name_r = strproper(admin_legal_name_r)
    replace venture_name_r = strproper(venture_name_r)

    forvalues i = 1/14 {
      gen comunication`i'_r_2 = .
      replace comunication`i'_r_2 = 1 if inlist("Página Web",comunication`i'_r)
      replace comunication`i'_r_2 = 2 if inlist("Facebook",comunication`i'_r)
      replace comunication`i'_r_2 = 3 if inlist("Linkedin",comunication`i'_r)
      replace comunication`i'_r_2 = 4 if inlist("Otros",comunication`i'_r)
    }

    forvalues i = 1/14 {
      label variable comunication`i'_r_2 " "
      label define comunication_r 1 "Página Web" 2 "Facebook" 3 "Linkedin" 4 "Otros", replace
      label values comunication`i'_r_2 comunication_r
    }
    drop comunication*_r
    br  comunication*

    label define yesno 0 "No" 1 "Si", replace
    foreach var of varlist finance_gov_r finance_private_r incub_private_r mvp_r sales_r marketing_off_r marketing_off_fulltime_r {
      encode `var', g(yesno)
      drop `var'
      rename yesno `var'
    }

    br finance_gov_r finance_private_r incub_private_r mvp_r ///
    sales_r marketing_off_r marketing_off_fulltime_r

    //Encode
    #delimit ;
    local varlist
    inno_knowledge_r
    apply_sector_r
    inno_type_r
    inno_phase_r
    b_inno_type_r
    inno_result_r;
    #delimit cr

    foreach var of local varlist {
      encode `var', g(`var'_2) l(`var')
      drop `var'
      rename `var'_2 `var'
    }

    //cleanchars, in(*) values
    //br `varlist'
    //for some F#$ reason the loop doesnt work with all variables, so had to divide variables
    #delimit ;
    local varlist2
    inno_temp_act_r
    val_stage_r
    marketing_off_contract_r;
    #delimit cr

    foreach var of local varlist2 {
      encode `var', g(`var'_2) l(`var')
      drop `var'
      rename `var'_2 `var'
    }
    sum `varlist2' `varlist'
    misstable sum `varlist2' `varlist' //checking for missing values

    forvalues i = 1/8 {
      encode inno_entity`i'_r, g(inno_entity`i'_r_2) l(inno_entity`i'_r)
      drop inno_entity`i'_r
      rename inno_entity`i'_r_2 inno_entity`i'_r
    }
    sum inno_entity*_r
    misstable sum inno_entity*_r //Missing values! Check

    forvalues i = 1/6 {
      encode inno_result`i'_mandat_r, g(inno_result`i'_mandat_r_2) l(inno_result`i'_mandat_r)
      drop inno_result`i'_mandat_r
      rename inno_result`i'_mandat_r_2 inno_result`i'_mandat_r
    }
    sum inno_result*_mandat_r
    misstable sum inno_result*_mandat_r //NO Missing values.

    forvalues i = 1/17 {
      encode ent`i'_time_r, g(ent`i'_time_r_2) l(ent`i'_time_r)
      drop ent`i'_time_r
      rename ent`i'_time_r_2 ent`i'_time_r
    }
    sum ent*_time_r
    misstable sum ent*_time_r //Missing values! Check

    /*
    forvalues i = 1/10 {
    rename ent`i'_spec_exp_years_r  ent`i'_spe_exp_y_r
    rename ent`i'_position_project_r ent`i'_pos_pro_r
    rename ent`i'_exp_ceo_parttime_r ent`i'_exp_ceo_part_r
    rename ent`i'_exp_ceo_fullttime_r ent`i'_exp_ceo_full_r
    }
    */
    
cap noisily { 
    #delimit ;
    local varlist3
    spec_exp_years_r
    nac_r
    doc_r
    birth_dep_r
    birth_prov_r
    position_project_r
    general_exp_r
    exp_ceo_parttime_r
    exp_cto_r
    exp_ceo_other_r
    occupation_r;
    #delimit cr

    forvalues i = 1/10 {
            foreach var of local varlist3  {
            encode ent`i'_`var', g(ent`i'_`var'_2) l(ent`i'_`var')
            drop ent`i'_`var'
            rename ent`i'_`var'_2 ent`i'_`var'
        }
    }

    forvalues i = 1/10 {
        foreach var of local varlist3  {
            sum ent`i'_`var'
            misstable sum ent`i'_`var'
        }
    }
}
    //Verify!!! Look carefully!
    forvalues i = 1/10 {
        foreach var of local varlist3  {
            br ent`i'_`var'
        }
    }
    
    label define exp_ceo_fullttime_r 1 "No tiene" 2 "menos de 1 año" 3 "1 año a más" ///
    4 "3 años a más" 5 "5 años a más", replace
    forvalues i = 1/4 {
           encode ent`i'_exp_ceo_fullttime_r, g(ent`i'_exp_ceo_fullttime_r_2) l(exp_ceo_fullttime_r)
            drop ent`i'_exp_ceo_fullttime_r
            rename ent`i'_exp_ceo_fullttime_r_2 ent`i'_exp_ceo_fullttime_r
    }
    
    label define ent_edu_r 1 "Secundaria completa" 2 "Técnico incompleto" 3 "Técnico completo" 4 "Universitaria incompleta" 5 "Universitaria completa" 6 "Postgrado incompleto" 7"Postgrado completo", replace
    //only values 6 of 10
    forvalues i = 1/6  {
           encode ent`i'_edu_r, g(ent`i'_edu_r_2) l(ent_edu_r)
            drop ent`i'_edu_r
            rename ent`i'_edu_r_2 ent`i'_edu_r
    }
    
    ///names
    forvalues i = 1/8 {
        replace inno_name`i'_r = strproper(inno_name1_r)
    }
    //Only till 6 of 10
    forvalues i = 1/6 {
        replace ent`i'_name_r = strproper(ent1_name_r) 
    }
    
    ///Binary
    //Only till 7 of 10
cap noisily {
    forvalues i = 1/7 {
      encode ent`i'_sex_r, g(ent`i'_sex_r_2) l(ent_sex_r)
      drop ent`i'_sex_r
      rename ent`i'_sex_r_2 ent`i'_sex_r
    }
   }
    label define ent_sex_r 1 "Mujer" 2 "Hombre", replace

    ///Text

    #delimit ;
    local varlist4
    inno_prob_r
    inno_prod_serv_r
    inno_advan_r
    inno_reach_r
    inno_alt_r
    inno_proces_r
    market_landmark_r
    market_landmark_plan_r
    market_size_r
    market_knowledge_r
    market_plan_r
    market_plan_landmark1_r
    market_plan_landmark2_r
    market_contac_r
    market_competitors_r
    market_advantages_r
    market_social_benefits_r
    market_barriers_r
    market_barriers_strat_r
    prod_capacity_r
    val_charac_r
    val_users_r
    revenue_strat_r
    prod_acceptance_r;
    #delimit cr

    foreach var of local varlist4  {
    replace `var'= substr(`var', 1, 1)+ lower(substr(`var', 2, .))
    }
   
    //br `varlist4'

    local varlist5 job_r spec_exp_r project_des_r
    //Only till 6 cause rest have no values (|->10)
    forvalues i = 1/6 {
      foreach var of local varlist5 {
        replace ent`i'_`var' = substr(ent`i'_`var', 1, 1)+ lower(substr(ent`i'_`var', 2, .))
      }
    }

    forvalues i = 1/20 {
      replace networks`i'_r = substr(networks`i'_r, 1, 1)+ lower(substr(networks`i'_r, 2, .))
    }

    forvalues i = 1/17 {
      replace ent`i'_work_exp_r = substr(ent`i'_work_exp_r, 1, 1)+ lower(substr(ent`i'_work_exp_r, 2, .))
    }

    //br networks*_r  ent*_work_exp_r

    //Text and numbes
    //sales_last_year_r
    //users_clients_r

    // same values
    //drop habilitada_r sin_oblig_r ent1_restrict1_r	ent1_restrict2_r	ent1_restrict3_r
    //ent2_restrict1_r	ent2_restrict2_r	ent2_restrict3_r

///2. label variables
//////////////////////
  *--------------
    # delimit;
    labvars
    admin_participant_id	"ID de participante"
    bo_registration_number	"RUC"
    admin_business_name_r	"Razón social"
    admin_legal_name_r	"Nombre del representante legal"
    admin_respondent_name_r	"Nombre del postulante"
    admin_respondent_email_r	"Correo"
    admin_respondent_phone_r	"Teléfono"
    bo_biz_location_street_r	"Domicilio fiscal"
    dep_r	"Departamento"
    prov_r	"Provincia"
    dist_r	"Distrito"
    bo_primary_what_r	"Antecedentes de la Entidad"
    habilitada_r	"La entidad participante no está inhabilitada de contratar con el Estado"
    sin_oblig_r	"Entidad o GG no tiene obligaciones pendientes con FONDECYT o RENOES"
    venture_name_r	"1A.Nombre del Emprendimiento"
    turnover_cumul_r	"1B.Facturación acumulada de la empresa en soles desde incio de las actividades"
    turnover_r	"1C.¿Cuál fue la facturación de la empresa en el 2018 en soles (S/)?"
    comunication1_r	"Comm #1: 2A.Presencia en internet y redes sociales"
    link1_r	"Comm #1: 2B.Link 1"
    comunication2_r	"Comm #2: 2C.Presencia en internet y redes sociales"
    link2_r	"Comm #2: 2D.Link 2"
    comunication3_r	"Comm #3: 2E.Presencia en internet y redes sociales"
    link3_r	"Comm #3: 2F.Link 3"
    comunication4_r	"Comm #4: 2G.Presencia en internet y redes sociales"
    link4_r	"Comm #4: 2H.Link 4"
    comunication5_r	"Comm #5: 2I.Presencia en internet y redes sociales"
    link5_r	"Comm #5: 2J.Link 5"
    comunication6_r	"Comm #6: 2K.Presencia en internet y redes sociales"
    link6_r	"Comm #6: 2L.Link 6"
    comunication7_r	"Comm #7: 2M.Presencia en internet y redes sociales"
    link7_r	"Comm #7: 2N.Link 7"
    comunication8_r	"Comm #8: 2O.Presencia en internet y redes sociales"
    link8_r	"Comm #8: 2P.Link 8"
    comunication9_r	"Comm #9: 2Q.Presencia en internet y redes sociales"
    link9_r	"Comm #9: 2R.Link 9"
    comunication10_r	"Comm #10: 2S.Presencia en internet y redes sociales"
    link10_r	"Comm #10: 2T.Link 10"
    comunication11_r	"Comm #11: 2U.Presencia en internet y redes sociales"
    link11_r	"Comm #11: 2V.Link 11"
    comunication12_r	"Comm #12: 2W.Presencia en internet y redes sociales"
    link12_r	"Comm #12: 2X.Link 12"
    comunication13_r	"Comm #13: 2Y.Presencia en internet y redes sociales"
    link13_r	"Comm #13: 2Z.Link 13"
    comunication14_r	"Comm #14: 2AA.Presencia en internet y redes sociales"
    link14_r	"Comm #14: 2BB.Link 14"
    finance_gov_r	"3A .¿La empresa/emprendimiento ha recibido financiamiento por programas del Estado?"
    finance_private_r	"3B .¿La empresa/emprendimiento ha tenido financiamiento de Inversionistas Privados?"
    incub_private_r	"3C .¿Has sido incubado o acelerado? Menciona en qué institución"
    inno_knowledge_r	"4A .Area de conocimiento a partir de la cual se desarrolla la innovacion"
    inno_knowledge_other_r	"4B .Otro Sector de Innovación"
    apply_sector_r	"4C .Industria o cadena productiva donde se aplica la innovacion"
    apply_sector_other_r	"4A.Otro Sector de Aplicación"
    inno_type_r	"4B.Tipo de producto o servicio"
    mvp_r	"4C.¿Tienes un Producto Mínimo Viable?"
    inno_phase_r	"4D.Etapa de la Innovación"
    inno_phase_link_r	"4E.Existencia de Producto Mínimo Viable (PMV) o producto de venta Link de video"
    inno_phase_link_soft_r	"4F.Link de prueba (solo software)"
    b_inno_type_r	"4G.Tipo de Modelo de Negocio de la innovación"
    inno_prob_r	"4H.Describa el problema u oportunidad que aprovechará el proyecto"
    inno_prod_serv_r	"4I.Describe tu producto o servicio"
    inno_advan_r	"4J.Describe cuál es la innovación y ventaja competitiva de tu proyecto"
    inno_reach_r	"4K.¿Qué alcance tiene tu innovación? A nivel país, región o mundial"
    inno_alt_r	"4L.Menciona como se diferencia de alternativas ya existentes en el mercado peruano/regional o mundial"
    inno_result_r	"4M.La innovación es resultado de:"
    inno_temp_act_r	"4N.¿Por cuanto tiempo fue el desarrollo de estas actividades?"
    inno_proces_r	"4O.Cuentanos cual fue el proceso de investigacion, desarrollo tecnologico o actividades tecnicas que realizaste para obtener el producto o servicio innovador"
    inno_entity1_r	"Entity #1: 5A.Persona/Entidad desarrollo de actividades 1"
    inno_name1_r	"Entity #1: 5B.Nombre 1"
    inno_entity2_r	"Entity #2: 5C.Persona/Entidad desarrollo de actividades 2"
    inno_name2_r	"Entity #2: 5D.Nombre 2"
    inno_entity3_r	"Entity #3: 5E.Persona/Entidad desarrollo de actividades 3"
    inno_name3_r	"Entity #3: 5F.Nombre 3"
    inno_entity4_r	"Entity #4: 5G.Persona/Entidad desarrollo de actividades 4"
    inno_name4_r	"Entity #4: 5H.Nombre 4"
    inno_entity5_r	"Entity #5: 5I.Persona/Entidad desarrollo de actividades 5"
    inno_name5_r	"Entity #5: 5J.Nombre 5"
    inno_entity6_r	"Entity #6: 5K.Persona/Entidad desarrollo de actividades 6"
    inno_name6_r	"Entity #6: 5L.Nombre 6"
    inno_entity7_r	"Entity #7: 5M.Persona/Entidad desarrollo de actividades 7"
    inno_name7_r	"Entity #7: 5N.Nombre 7"
    inno_entity8_r	"Entity #8: 5O.Persona/Entidad desarrollo de actividades 8"
    inno_name8_r	"Entity #8: 5P.Nombre 8"
    inno_target1_mandat_r	"Results #1: 6A.Meta 1"
    inno_result1_mandat_r	"Results #1: 6B.Resultado 1"
    inno_target2_mandat_r	"Results #2: 6C.Meta 2"
    inno_result2_mandat_r	"Results #2: 6D.Resultado 2"
    inno_target3_mandat_r	"Results #3: 6E.Meta 3"
    inno_result3_mandat_r	"Results #3: 6F.Resultado 3"
    inno_target4_mandat_r	"Results #4: 6G.Meta 4"
    inno_result4_mandat_r	"Results #4: 6H.Resultado 4"
    inno_target5_mandat_r	"Results #5: 6I.Meta 5"
    inno_result5_mandat_r	"Results #5: 6J.Resultado 5"
    inno_target6_mandat_r	"Results #6: 6K.Meta 6"
    inno_result6_mandat_r	"Results #6: 6L.Resultado 6"
    inno_target1_optional_r	"Results op. #1: 7A.Meta 1"
    inno_result1_optional_r	"Results op. #1: 7B.Resultado 1"
    inno_target2_optional_r	"Results op. #2: 7C.Meta 2"
    inno_result2_optional_r	"Results op. #3: 7D.Resultado 2"
    market_landmark_r	"8A.Comenta los hitos alcanzados en relacion a tu innovacion y/o emprendimiento"
    market_landmark_plan_r	"8B.Comenta hitos mas relevantes por lograr en los siguientes 12 meses en relacion a tu innovacipon y/o emprendimiento"
    market_size_r	"9A.Describe potencialidad de tu mercado: ¿Tiene potencialidad Global, Regional o local? ¿Cual es el tamaño estimado de tu mercado?"
    market_knowledge_r	"9B.Demuestra que conoces tu mercado Describe y dimensiona a tu mercado objetivo en los proximos 12 meses Menciona el perfil del cliente y/o usuarios"
    market_plan_r	"9C.¿Cuál es tu plan para entrar a este mercado?"
    market_plan_landmark1_r	"9D.Hito 1"
    market_plan_landmark2_r	"9E.Hito 2"
    market_contac_r	"9F.Específica que contactos te van a ayudar en tu estrategia de mercado"
    market_competitors_r	"10A.Describe y dimensiona a tus competidores o potenciales competidores En que mercado operan, que tipo de empresa son y cuales son sus fortalezas"
    market_advantages_r	"10B.¿Cuales son las ventajas de tu emprendimiento/proyecto sobre los competidores? Cual es tu estrategia de diferenciacion"
    market_social_benefits_r	"10C.¿Cuales son los beneficios sociales y/o medioambientales de tu empresa/ emprendimiento? Cuantifica y describe"
    market_barriers_r	"11A.¿Cuales son las principales barreras o limitaciones para el despegue comercial y expansion en el mercado?"
    market_barriers_strat_r	"11B.¿Cuál es tu estrategia para superar estas barreras?"
    prod_capacity_r	"11C.¿Cuál es tu actual capacidad productiva y/o de operaciones?"
    val_stage_r	"12A.¿En qué etapa de validación te encuentras?"
    val_charac_r	"12B.¿Que características de tu emprendimiento/proyecto has validado y que has mejorado?"
    val_users_r	"12C.¿Con cuantos usuarios o potenciales clientes has validado tu innovacion en los últimos dos años? Considera el volumen de productos validados"
    sales_r	"12D.¿Has tenido ventas?"
    sales_last_year_r	"12E.¿Cual ha sido el volumen de ventas (S/ y cantidad) en los dos últimos años? "
    revenue_strat_r	"12F.Describe cómo generas o cómo vas a generar ingresos"
    prod_acceptance_r	"12G.Comenta la aceptacion que ha tenido tu producto a nivel de las ventas en este periodo"
    users_clients_r	"12H.¿Cuántos usuarios y clientes tienes? ¿Has tenido incremento?"
    emp_fulltime_r	"12I.¿Cuántas personas trabajan a tiempo completo en la empresa/emprendimiento?"
    emp_parttime_r	"12J.¿Cuántas personas trabajan a tiempo parcial en la empresa/ emprendimiento?"
    ent1_name_r	"Team #1: 13A.Nombres y Apellidos"
    ent1_position_r	"Team #1: 13B.Rol"
    ent1_sex_r	"Team #1: 13C.Sexo"
    ent1_age_r	"Team #1: 13D.Edad"
    ent1_nac_r	"Team #1: 13E.Nacionalidad"
    ent1_doc_r	"Team #1: 13F.Tipo de documento"
    ent1_nid_r	"Team #1: 13G.Documento de identidad"
    ent1_birth_dep_r	"Team #1: 13H.Lugar de nacimiento - Departamento"
    ent1_birth_prov_r	"Team #1: 13I.Lugar de nacimiento - Provincia"
    ent1_edu_r	"Team #1: 13J.Nivel educativo alcanzado"
    ent1_occupation_r	"Team #1: 13K.Profesión / formación"
    ent1_job_r	"Team #1: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent1_linkedin_r	"Team #1: 13M.Perfil de LinkedIn (ingresar link)"
    ent1_dedication_r	"Team #1: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent1_position_project_r	"Team #1: 13O.ROL en el emprendimiento/proyecto"
    ent1_general_exp_r	"Team #1: 13P.N° Años de Experiencia General Profesional"
    ent1_spec_exp_years_r	"Team #1: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent1_spec_exp_r	"Team #1: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent1_project_des_r	"Team #1: 13S.Defina en una frase su función actual en el emprendimiento"
    ent1_restrict1_r	"Team #1: 13T.No se encuentra reportado en el REDAM"
    ent1_restrict2_r	"Team #1: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent1_restrict3_r	"Team #1: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent1_exp_ceo_parttime_r	"Team #1: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent1_exp_cto_r	"Team #1: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent1_exp_ceo_fullttime_r	"Team #1: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent1_exp_ceo_other_r	"Team #1: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent1_restrict4_r	"Team #1: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent1_phone_r	"Team #1: 13BB.Teléfono de contacto"
    ent1_email1_r	"Team #1: 13CC.Correo electrónico 1"
    ent1_email2_r	"Team #1: 13DD.Correo electrónico 2"
    ent2_name_r	"Team #2: 13A.Nombres y Apellidos"
    ent2_position_r	"Team #2: 13B.Rol"
    ent2_sex_r	"Team #2: 13C.Sexo"
    ent2_age_r	"Team #2: 13D.Edad"
    ent2_nac_r	"Team #2: 13E.Nacionalidad"
    ent2_doc_r	"Team #2: 13F.Tipo de documento"
    ent2_nid_r	"Team #2: 13G.Documento de identidad"
    ent2_birth_dep_r	"Team #2: 13H.Lugar de nacimiento - Departamento"
    ent2_birth_prov_r	"Team #2: 13I.Lugar de nacimiento - Provincia"
    ent2_edu_r	"Team #2: 13J.Nivel educativo alcanzado"
    ent2_occupation_r	"Team #2: 13K.Profesión / formación"
    ent2_job_r	"Team #2: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent2_linkedin_r	"Team #2: 13M.Perfil de LinkedIn (ingresar link)"
    ent2_dedication_r	"Team #2: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent2_position_project_r	"Team #2: 13O.ROL en el emprendimiento/proyecto"
    ent2_general_exp_r	"Team #2: 13P.N° Años de Experiencia General Profesional"
    ent2_spec_exp_years_r	"Team #2: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent2_spec_exp_r	"Team #2: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent2_project_des_r	"Team #2: 13S.Defina en una frase su función actual en el emprendimiento"
    ent2_restrict1_r	"Team #2: 13T.No se encuentra reportado en el REDAM"
    ent2_restrict2_r	"Team #2: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent2_restrict3_r	"Team #2: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent2_exp_ceo_parttime_r	"Team #2: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent2_exp_cto_r	"Team #2: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent2_exp_ceo_fullttime_r	"Team #2: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent2_exp_ceo_other_r	"Team #2: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent2_restrict4_r	"Team #2: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent2_phone_r	"Team #2: 13BB.Teléfono de contacto"
    ent2_email1_r	"Team #2: 13CC.Correo electrónico 1"
    ent2_email2_r	"Team #2: 13DD.Correo electrónico 2"
    ent3_name_r	"Team #3: 13A.Nombres y Apellidos"
    ent3_position_r	"Team #3: 13B.Rol"
    ent3_sex_r	"Team #3: 13C.Sexo"
    ent3_age_r	"Team #3: 13D.Edad"
    ent3_nac_r	"Team #3: 13E.Nacionalidad"
    ent3_doc_r	"Team #3: 13F.Tipo de documento"
    ent3_nid_r	"Team #3: 13G.Documento de identidad"
    ent3_birth_dep_r	"Team #3: 13H.Lugar de nacimiento - Departamento"
    ent3_birth_prov_r	"Team #3: 13I.Lugar de nacimiento - Provincia"
    ent3_edu_r	"Team #3: 13J.Nivel educativo alcanzado"
    ent3_occupation_r	"Team #3: 13K.Profesión / formación"
    ent3_job_r	"Team #3: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent3_linkedin_r	"Team #3: 13M.Perfil de LinkedIn (ingresar link)"
    ent3_dedication_r	"Team #3: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent3_position_project_r	"Team #3: 13O.ROL en el emprendimiento/proyecto"
    ent3_general_exp_r	"Team #3: 13P.N° Años de Experiencia General Profesional"
    ent3_spec_exp_years_r	"Team #3: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent3_spec_exp_r	"Team #3: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent3_project_des_r	"Team #3: 13S.Defina en una frase su función actual en el emprendimiento"
    ent3_restrict1_r	"Team #3: 13T.No se encuentra reportado en el REDAM"
    ent3_restrict2_r	"Team #3: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent3_restrict3_r	"Team #3: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent3_exp_ceo_parttime_r	"Team #3: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent3_exp_cto_r	"Team #3: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent3_exp_ceo_fullttime_r	"Team #3: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent3_exp_ceo_other_r	"Team #3: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent3_restrict4_r	"Team #3: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent3_phone_r	"Team #3: 13BB.Teléfono de contacto"
    ent3_email1_r	"Team #3: 13CC.Correo electrónico 1"
    ent3_email2_r	"Team #3: 13DD.Correo electrónico 2"
    ent4_name_r	"Team #4: 13A.Nombres y Apellidos"
    ent4_position_r	"Team #4: 13B.Rol"
    ent4_sex_r	"Team #4: 13C.Sexo"
    ent4_age_r	"Team #4: 13D.Edad"
    ent4_nac_r	"Team #4: 13E.Nacionalidad"
    ent4_doc_r	"Team #4: 13F.Tipo de documento"
    ent4_nid_r	"Team #4: 13G.Documento de identidad"
    ent4_birth_dep_r	"Team #4: 13H.Lugar de nacimiento - Departamento"
    ent4_birth_prov_r	"Team #4: 13I.Lugar de nacimiento - Provincia"
    ent4_edu_r	"Team #4: 13J.Nivel educativo alcanzado"
    ent4_occupation_r	"Team #4: 13K.Profesión / formación"
    ent4_job_r	"Team #4: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent4_linkedin_r	"Team #4: 13M.Perfil de LinkedIn (ingresar link)"
    ent4_dedication_r	"Team #4: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent4_position_project_r	"Team #4: 13O.ROL en el emprendimiento/proyecto"
    ent4_general_exp_r	"Team #4: 13P.N° Años de Experiencia General Profesional"
    ent4_spec_exp_years_r	"Team #4: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent4_spec_exp_r	"Team #4: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent4_project_des_r	"Team #4: 13S.Defina en una frase su función actual en el emprendimiento"
    ent4_restrict1_r	"Team #4: 13T.No se encuentra reportado en el REDAM"
    ent4_restrict2_r	"Team #4: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent4_restrict3_r	"Team #4: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent4_exp_ceo_parttime_r	"Team #4: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent4_exp_cto_r	"Team #4: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent4_exp_ceo_fullttime_r	"Team #4: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent4_exp_ceo_other_r	"Team #4: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent4_restrict4_r	"Team #4: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent4_phone_r	"Team #4: 13BB.Teléfono de contacto"
    ent4_email1_r	"Team #4: 13CC.Correo electrónico 1"
    ent4_email2_r	"Team #4: 13DD.Correo electrónico 2"
    ent5_name_r	"Team #5: 13A.Nombres y Apellidos"
    ent5_position_r	"Team #5: 13B.Rol"
    ent5_sex_r	"Team #5: 13C.Sexo"
    ent5_age_r	"Team #5: 13D.Edad"
    ent5_nac_r	"Team #5: 13E.Nacionalidad"
    ent5_doc_r	"Team #5: 13F.Tipo de documento"
    ent5_nid_r	"Team #5: 13G.Documento de identidad"
    ent5_birth_dep_r	"Team #5: 13H.Lugar de nacimiento - Departamento"
    ent5_birth_prov_r	"Team #5: 13I.Lugar de nacimiento - Provincia"
    ent5_edu_r	"Team #5: 13J.Nivel educativo alcanzado"
    ent5_occupation_r	"Team #5: 13K.Profesión / formación"
    ent5_job_r	"Team #5: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent5_linkedin_r	"Team #5: 13M.Perfil de LinkedIn (ingresar link)"
    ent5_dedication_r	"Team #5: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent5_position_project_r	"Team #5: 13O.ROL en el emprendimiento/proyecto"
    ent5_general_exp_r	"Team #5: 13P.N° Años de Experiencia General Profesional"
    ent5_spec_exp_years_r	"Team #5: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent5_spec_exp_r	"Team #5: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent5_project_des_r	"Team #5: 13S.Defina en una frase su función actual en el emprendimiento"
    ent5_restrict1_r	"Team #5: 13T.No se encuentra reportado en el REDAM"
    ent5_restrict2_r	"Team #5: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent5_restrict3_r	"Team #5: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent5_exp_ceo_parttime_r	"Team #5: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent5_exp_cto_r	"Team #5: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent5_exp_ceo_fullttime_r	"Team #5: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent5_exp_ceo_other_r	"Team #5: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent5_restrict4_r	"Team #5: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent5_phone_r	"Team #5: 13BB.Teléfono de contacto"
    ent5_email1_r	"Team #5: 13CC.Correo electrónico 1"
    ent5_email2_r	"Team #5: 13DD.Correo electrónico 2"
    ent6_name_r	"Team #6: 13A.Nombres y Apellidos"
    ent6_position_r	"Team #6: 13B.Rol"
    ent6_sex_r	"Team #6: 13C.Sexo"
    ent6_age_r	"Team #6: 13D.Edad"
    ent6_nac_r	"Team #6: 13E.Nacionalidad"
    ent6_doc_r	"Team #6: 13F.Tipo de documento"
    ent6_nid_r	"Team #6: 13G.Documento de identidad"
    ent6_birth_dep_r	"Team #6: 13H.Lugar de nacimiento - Departamento"
    ent6_birth_prov_r	"Team #6: 13I.Lugar de nacimiento - Provincia"
    ent6_edu_r	"Team #6: 13J.Nivel educativo alcanzado"
    ent6_occupation_r	"Team #6: 13K.Profesión / formación"
    ent6_job_r	"Team #6: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent6_linkedin_r	"Team #6: 13M.Perfil de LinkedIn (ingresar link)"
    ent6_dedication_r	"Team #6: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent6_position_project_r	"Team #6: 13O.ROL en el emprendimiento/proyecto"
    ent6_general_exp_r	"Team #6: 13P.N° Años de Experiencia General Profesional"
    ent6_spec_exp_years_r	"Team #6: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent6_spec_exp_r	"Team #6: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent6_project_des_r	"Team #6: 13S.Defina en una frase su función actual en el emprendimiento"
    ent6_restrict1_r	"Team #6: 13T.No se encuentra reportado en el REDAM"
    ent6_restrict2_r	"Team #6: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent6_restrict3_r	"Team #6: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent6_exp_ceo_parttime_r	"Team #6: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent6_exp_cto_r	"Team #6: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent6_exp_ceo_fullttime_r	"Team #6: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent6_exp_ceo_other_r	"Team #6: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent6_restrict4_r	"Team #6: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent6_phone_r	"Team #6: 13BB.Teléfono de contacto"
    ent6_email1_r	"Team #6: 13CC.Correo electrónico 1"
    ent6_email2_r	"Team #6: 13DD.Correo electrónico 2"
    ent7_name_r	"Team #7: 13A.Nombres y Apellidos"
    ent7_position_r	"Team #7: 13B.Rol"
    ent7_sex_r	"Team #7: 13C.Sexo"
    ent7_age_r	"Team #7: 13D.Edad"
    ent7_nac_r	"Team #7: 13E.Nacionalidad"
    ent7_doc_r	"Team #7: 13F.Tipo de documento"
    ent7_nid_r	"Team #7: 13G.Documento de identidad"
    ent7_birth_dep_r	"Team #7: 13H.Lugar de nacimiento - Departamento"
    ent7_birth_prov_r	"Team #7: 13I.Lugar de nacimiento - Provincia"
    ent7_edu_r	"Team #7: 13J.Nivel educativo alcanzado"
    ent7_occupation_r	"Team #7: 13K.Profesión / formación"
    ent7_job_r	"Team #7: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent7_linkedin_r	"Team #7: 13M.Perfil de LinkedIn (ingresar link)"
    ent7_dedication_r	"Team #7: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent7_position_project_r	"Team #7: 13O.ROL en el emprendimiento/proyecto"
    ent7_general_exp_r	"Team #7: 13P.N° Años de Experiencia General Profesional"
    ent7_spec_exp_years_r	"Team #7: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent7_spec_exp_r	"Team #7: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent7_project_des_r	"Team #7: 13S.Defina en una frase su función actual en el emprendimiento"
    ent7_restrict1_r	"Team #7: 13T.No se encuentra reportado en el REDAM"
    ent7_restrict2_r	"Team #7: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent7_restrict3_r	"Team #7: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent7_exp_ceo_parttime_r	"Team #7: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent7_exp_cto_r	"Team #7: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent7_exp_ceo_fullttime_r	"Team #7: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent7_exp_ceo_other_r	"Team #7: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent7_restrict4_r	"Team #7: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent7_phone_r	"Team #7: 13BB.Teléfono de contacto"
    ent7_email1_r	"Team #7: 13CC.Correo electrónico 1"
    ent7_email2_r	"Team #7: 13DD.Correo electrónico 2"
    ent8_name_r	"Team #8: 13A.Nombres y Apellidos"
    ent8_position_r	"Team #8: 13B.Rol"
    ent8_sex_r	"Team #8: 13C.Sexo"
    ent8_age_r	"Team #8: 13D.Edad"
    ent8_nac_r	"Team #8: 13E.Nacionalidad"
    ent8_doc_r	"Team #8: 13F.Tipo de documento"
    ent8_nid_r	"Team #8: 13G.Documento de identidad"
    ent8_birth_dep_r	"Team #8: 13H.Lugar de nacimiento - Departamento"
    ent8_birth_prov_r	"Team #8: 13I.Lugar de nacimiento - Provincia"
    ent8_edu_r	"Team #8: 13J.Nivel educativo alcanzado"
    ent8_occupation_r	"Team #8: 13K.Profesión / formación"
    ent8_job_r	"Team #8: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent8_linkedin_r	"Team #8: 13M.Perfil de LinkedIn (ingresar link)"
    ent8_dedication_r	"Team #8: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent8_position_project_r	"Team #8: 13O.ROL en el emprendimiento/proyecto"
    ent8_general_exp_r	"Team #8: 13P.N° Años de Experiencia General Profesional"
    ent8_spec_exp_years_r	"Team #8: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent8_spec_exp_r	"Team #8: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent8_project_des_r	"Team #8: 13S.Defina en una frase su función actual en el emprendimiento"
    ent8_restrict1_r	"Team #8: 13T.No se encuentra reportado en el REDAM"
    ent8_restrict2_r	"Team #8: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent8_restrict3_r	"Team #8: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent8_exp_ceo_parttime_r	"Team #8: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent8_exp_cto_r	"Team #8: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent8_exp_ceo_fullttime_r	"Team #8: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent8_exp_ceo_other_r	"Team #8: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent8_restrict4_r	"Team #8: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent8_phone_r	"Team #8: 13BB.Teléfono de contacto"
    ent8_email1_r	"Team #8: 13CC.Correo electrónico 1"
    ent8_email2_r	"Team #8: 13DD.Correo electrónico 2"
    ent9_name_r	"Team #9: 13A.Nombres y Apellidos"
    ent9_position_r	"Team #9: 13B.Rol"
    ent9_sex_r	"Team #9: 13C.Sexo"
    ent9_age_r	"Team #9: 13D.Edad"
    ent9_nac_r	"Team #9: 13E.Nacionalidad"
    ent9_doc_r	"Team #9: 13F.Tipo de documento"
    ent9_nid_r	"Team #9: 13G.Documento de identidad"
    ent9_birth_dep_r	"Team #9: 13H.Lugar de nacimiento - Departamento"
    ent9_birth_prov_r	"Team #9: 13I.Lugar de nacimiento - Provincia"
    ent9_edu_r	"Team #9: 13J.Nivel educativo alcanzado"
    ent9_occupation_r	"Team #9: 13K.Profesión / formación"
    ent9_job_r	"Team #9: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent9_linkedin_r	"Team #9: 13M.Perfil de LinkedIn (ingresar link)"
    ent9_dedication_r	"Team #9: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent9_position_project_r	"Team #9: 13O.ROL en el emprendimiento/proyecto"
    ent9_general_exp_r	"Team #9: 13P.N° Años de Experiencia General Profesional"
    ent9_spec_exp_years_r	"Team #9: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent9_spec_exp_r	"Team #9: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent9_project_des_r	"Team #9: 13S.Defina en una frase su función actual en el emprendimiento"
    ent9_restrict1_r	"Team #9: 13T.No se encuentra reportado en el REDAM"
    ent9_restrict2_r	"Team #9: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent9_restrict3_r	"Team #9: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent9_exp_ceo_parttime_r	"Team #9: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent9_exp_cto_r	"Team #9: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent9_exp_ceo_fullttime_r	"Team #9: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent9_exp_ceo_other_r	"Team #9: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent9_restrict4_r	"Team #9: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent9_phone_r	"Team #9: 13BB.Teléfono de contacto"
    ent9_email1_r	"Team #9: 13CC.Correo electrónico 1"
    ent9_email2_r	"Team #9: 13DD.Correo electrónico 2"
    ent10_name_r	"Team #10: 13A.Nombres y Apellidos"
    ent10_position_r	"Team #10: 13B.Rol"
    ent10_sex_r	"Team #10: 13C.Sexo"
    ent10_age_r	"Team #10: 13D.Edad"
    ent10_nac_r	"Team #10: 13E.Nacionalidad"
    ent10_doc_r	"Team #10: 13F.Tipo de documento"
    ent10_nid_r	"Team #10: 13G.Documento de identidad"
    ent10_birth_dep_r	"Team #10: 13H.Lugar de nacimiento - Departamento"
    ent10_birth_prov_r	"Team #10: 13I.Lugar de nacimiento - Provincia"
    ent10_edu_r	"Team #10: 13J.Nivel educativo alcanzado"
    ent10_occupation_r	"Team #10: 13K.Profesión / formación"
    ent10_job_r	"Team #10: 13L.Trabajo Actual: Industria, Nombre de Institución y Puesto"
    ent10_linkedin_r	"Team #10: 13M.Perfil de LinkedIn (ingresar link)"
    ent10_dedication_r	"Team #10: 13N.Horas semanales de dedicación al emprendimiento/proyecto"
    ent10_position_project_r	"Team #10: 13O.ROL en el emprendimiento/proyecto"
    ent10_general_exp_r	"Team #10: 13P.N° Años de Experiencia General Profesional"
    ent10_spec_exp_years_r	"Team #10: 13Q.Años de experiencia específica en la industria o area relacionada al emprendimiento/proyecto actual"
    ent10_spec_exp_r	"Team #10: 13R.Comenta tu experiencia profesional relevante: puestos, industrias, contactos clave, proyectos importantes"
    ent10_project_des_r	"Team #10: 13S.Defina en una frase su función actual en el emprendimiento"
    ent10_restrict1_r	"Team #10: 13T.No se encuentra reportado en el REDAM"
    ent10_restrict2_r	"Team #10: 13U.No cuento con acceso informacion privilegiada que sea relevante y determinante al concurso"
    ent10_restrict3_r	"Team #10: 13V.No soy funcionario o presto servicios bajo cualquier denominacion contractual en CONCYTEC/FONDECYT"
    ent10_exp_ceo_parttime_r	"Team #10: 13W.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, part time?"
    ent10_exp_cto_r	"Team #10: 13X.¿Cuantos años tiene el CTO de experiencia con el desarrollo u operacion de la tecnología de tu emprendimiento?"
    ent10_exp_ceo_fullttime_r	"Team #10: 13Y.¿Cuantos años de experiencia tiene el GG o CEO liderando este emprendimiento, full time?"
    ent10_exp_ceo_other_r	"Team #10: 13Z.¿Cuantos años de experiencia tiene el GGo CEO liderando tros emprendimientos (previos) a full time?"
    ent10_restrict4_r	"Team #10: 13AA.El GG o CEO no esta calificado negativamente en centrales de riesgo"
    ent10_phone_r	"Team #10: 13BB.Teléfono de contacto"
    ent10_email1_r	"Team #10: 13CC.Correo electrónico 1"
    ent10_email2_r	"Team #10: 13DD.Correo electrónico 2"
    marketing_off_r	"14A.Actualmente, ¿el emprendimiento tiene un Profesional en Comercialización ?"
    marketing_off_fulltime_r	"14B.¿El Profesional en Comercializacio se dedica a tiempo completo a labor comercial?"
    marketing_off_contract_r	"14C.¿ Bajo que modalidad se contratará al reponsable de comercialización?"
    marketing_off_need_r	"14D.Explica por que necesitas la asignacion de un Profesional en Comercializacion"
    marketing_off_role_r	"14E.¿Cual sería el aporte del Profesional en Comercializacion asignado al despegue comercial de tu innovacion?"
    networks1_r	"Networks # 1: 15A.Menciona otras redes y alianzas que puedan favorecer despegue comercial de tu innovacion"
    networks2_r	"Networks # 2: 15B.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks3_r	"Networks # 3: 15C.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks4_r	"Networks # 4: 15D.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks5_r	"Networks # 5: 15E.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks6_r	"Networks # 6: 15F.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks7_r	"Networks # 7: 15G.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks8_r	"Networks # 8: 15H.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks9_r	"Networks # 9: 15I.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks10_r	"Networks # 10: 15J.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks11_r	"Networks # 11: 15K.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks12_r	"Networks # 12: 15L.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks13_r	"Networks # 13: 15M.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks14_r	"Networks # 14: 15N.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks15_r	"Networks # 15: 15O.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks16_r	"Networks # 16: 15P.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks17_r	"Networks # 17: 15Q.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks18_r	"Networks # 18: 15R.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks19_r	"Networks # 19: 15S.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    networks20_r	"Networks # 20: 15T.Menciona otras redes y alianzas que puedan favorecer  despegue comercial de tu innovacion"
    ent1_time_r	"Experience # 1: 16A.Tiempo 1"
    ent1_work_exp_r	"Experience # 1: 16B.Experiencias laborales anteriores miembros equipo 1"
    ent2_time_r	"Experience # 2: 16C.Tiempo 2"
    ent2_work_exp_r	"Experience # 2: 16D.Experiencias laborales anteriores miembros equipo 2"
    ent3_time_r	"Experience # 3: 16E.Tiempo 3"
    ent3_work_exp_r	"Experience # 3: 16F.Experiencias laborales anteriores miembros equipo 3"
    ent4_time_r	"Experience # 4: 16G.Tiempo 4"
    ent4_work_exp_r	"Experience # 4: 16H.Experiencias laborales anteriores miembros equipo 4"
    ent5_time_r	"Experience # 5: 16I.Tiempo 5"
    ent5_work_exp_r	"Experience # 5: 16J.Experiencias laborales anteriores miembros equipo 5"
    ent6_time_r	"Experience # 6: 16K.Tiempo 6"
    ent6_work_exp_r	"Experience # 6: 16L.Experiencias laborales anteriores miembros equipo 6"
    ent7_time_r	"Experience # 7: 16M.Tiempo 7"
    ent7_work_exp_r	"Experience # 7: 16N.Experiencias laborales anteriores miembros equipo 7"
    ent8_time_r	"Experience # 8: 16O.Tiempo 8"
    ent8_work_exp_r	"Experience # 8: 16P.Experiencias laborales anteriores miembros equipo 8"
    ent9_time_r	"Experience # 9: 16Q.Tiempo 9"
    ent9_work_exp_r	"Experience # 9: 16R.Experiencias laborales anteriores miembros equipo 9"
    ent10_time_r	"Experience # 10: 16S.Tiempo 10"
    ent10_work_exp_r	"Experience # 10: 16T.Experiencias laborales anteriores miembros equipo 10"
    ent11_time_r	"Experience # 11: 16U.Tiempo 11"
    ent11_work_exp_r	"Experience # 11: 16V.Experiencias laborales anteriores miembros equipo 11"
    ent12_time_r	"Experience # 12: 16W.Tiempo 12"
    ent12_work_exp_r	"Experience # 12: 16X.Experiencias laborales anteriores miembros equipo 12"
    ent13_time_r	"Experience # 13: 16Y.Tiempo 13"
    ent13_work_exp_r	"Experience # 13: 16Z.Experiencias laborales anteriores miembros equipo 13"
    ent14_time_r	"Experience # 14: 16AA.Tiempo 14"
    ent14_work_exp_r	"Experience # 14: 16BB.Experiencias laborales anteriores miembros equipo 14"
    ent15_time_r	"Experience # 15: 16CC.Tiempo 15"
    ent15_work_exp_r	"Experience # 15: 16DD.Experiencias laborales anteriores miembros equipo 15"
    ent16_time_r	"Experience # 16: 16EE.Tiempo 16"
    ent16_work_exp_r	"Experience # 16: 16FF.Experiencias laborales anteriores miembros equipo 16"
    ent17_time_r	"Experience # 17: 16GG.Tiempo 17"
    ent17_work_exp_r	"Experience # 17: 16HH.Experiencias laborales anteriores miembros equipo 17"
    bo_biz_location_town_r	"17A.Localidad donde se encuentra su empredimiento"
    finantial_contribution_r	"18B.Monto (S/) contribucion financiera postulante"
    passed_r	"19C.Si el postulante es apto o no"
    result_evaluation_r	"20D.Resultado de la evaluacion"
    survey_r	"21E.Si el postulante lleno encuesta o no"
    ,alternate;
    # delimit cr

    note market_competitors_r: "Pueden ser productos sustitutos o industrias relacionadas de Startups, empresas, soluciones en desarrollo, entre otros."
    forvalues i = 1/20 {
      note networks`i'_r: "Respaldo de laboratorios, universidades, empresas, socios comerciales, etc"
    }
    note finance_private_r: "Redes de angeles, fondos de inversión, aceleradoras u otros"
    note market_landmark_r: "Hitos tecnicos, financieros, comerciales"
    note market_landmark_plan_r: "(hitos tecnicos, financieros, comerciales) ¿Cual es tu plan para hacerlo?"
    note market_size_r: "Menciona cifras y montos en USD"
    note market_knowledge_r: "Menciona cifras y montos en USD"
    note market_competitors_r: "Pueden ser productos sustitutos o industrias relacionadas de Startups, empresas, soluciones en desarrollo, entre otros"
    note market_barriers_r: "Pueden ser de operaciones, clientes, producto, tecnologías, legales, normas o certificaciones tecnicas, entre otras"
    note sales_last_year_r: "Puedes explicar el nivel de ventas separando por periodos mas cortos (semestres, o trimestres)"

    labvalch3 ,strfcn(proper("@"))

  *------------------
///3. Order variables in original sequence and saves dta
///////////////////////////////////////////
    order `order'
    compress
    save Recruitment_survey_clean, replace

/// Close the log, end the file
    //log close
    //exit
