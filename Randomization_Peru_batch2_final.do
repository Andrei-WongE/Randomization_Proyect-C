///-----------------------------------------------------------------------------
/// Project: C-Batch_2
/// Author: Andrei Wong Espejo, awongespejo@worldbank.org
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------
/// Program Setup
///-----------------------------------------------------------------------------

    version 16              // Set Version number for backward compatibility
    set more off            // Disable partitioned output
    clear all               // Start with a clean slate
    set linesize 80         // Line size limit to make output more readable
    macro drop _all         // Clear all macros
    capture log close       // Close existing log files
    set scheme plotplain    // Set plot scheme
///-----------------------------------------------------------------------------

///-----------------------------------------------------------------------------

    /* RUNS THE FOLLOWING:
    1. Data wrangling
    2. Merge
    3. Generating descriptive variables
    4. Generating stratification variables
    5. Generating randomization dataset
    6. Randomization
    7. Balance checks

    */
///-----------------------------------------------------------------------------

    //Set directory
    global base "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Batch2\Output"
    cd "$base"

    global out "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Batch2\Random2\Ran_results_2"

    //Creating log file
    log using "$out\randomization", smcl replace // Open log file

    //Install required packages

   
    ssc install histbox, replace
    ssc install nmissing, replace
    net install randomize, from(https://raw.githubusercontent.com/ck37/randomize_ado/master/)
    //Manual install: Download the zip file of the repository (https://github.com/ck37/randomize_ado/archive/master.zip), unzip it, then add that folder to Stata's search path for ado files. Source: https://github.com/ck37/randomize_ado
    ssc install ttable2, replace
    ssc install balancetable, replace
    ssc install labutil2, replace
    net install balanceplot, from("https://tdmize.github.io/data/balanceplot")
    ssc instal ietoolkit
   

/////////////////////////////////////////////////////////////
//// 1. Data wrangling           ////
////////////////////////////////////////////////////////////

/// Dataset A: Baseline Survey
    use "$base\CONCYTEC_FONDECYT_Encuesta_Linea_Base_clean_Batch2_final", clear
    count // 179
    keep if bo_operational==1 //Only firms that have data (are operational)
    count // 179

    destring admin_participant_id, replace
	
	gen listed_firms = 0 //CHECK 213 firms that passed de judging panel!!!!!!! CHECK eligibility criteria mail
    # delimit ;
    replace listed_firms = 1 if inlist(admin_participant_id, 74990,
	75087,
	74809,
	74988,
	74531,
	74933,
	74994,
	74875,
	74909,
	74958,
	75047,
	74921,
	75058,
	75095,
	74510,
	74523,
	74987,
	74744,
	74795,
	74577,
	75100,
	74941,
	75014,
	74748,
	74844,
	74884,
	74824,
	74981,
	75081,
	74714,
	74833,
	74534,
	74513,
	74571,
	74935,
	74831,
	74700,
	74958,
	74718,
	74971,
	74557,
	74983,
	74981,
	74928,
	75071,
	74783,
	74774,
	74524,
	75004,
	75085,
	74733,
	75053,
	74757,
	75098,
	75037,
	74970,
	74917,
	75027,
	75002,
	75021,
	74938,
	74983,
	74873,
	75043,
	75005,
	74877,
	74480,
	74789,
	74579,
	74858,
	75025,
	74814,
	74980,
	74752,
	74973,
	74807,
	74791,
	74753,
	75117,
	74732,
	74910,
	74750,
	74818,
	74707,
	74585,
	74738,
	74525,
	74880,
	74879,
	74785,
	74925,
	74581,
	74854,
	75035,
	75108,
	74951,
	74772,
	75001,
	74701,
	74929,
	74878,
	74887,
	74798,
	75052,
	74841,
	74878,
	74899,
	75000,
	74725,
	74758,
	74942,
	74914,
	74519,
	74848,
	74711,
	74838,
	74754,
	75008,
	74558,
	74884,
	74878,
	74888,
	74898);
    # delimit cr

    keep if listed_firms==1
	assert c(N)==123
    
	d, s

    tempfile baseline_survey
    save `baseline_survey'

/// Dataset B: Judge scores
    use "$base\Evaluation_scores_clean", clear
    count // 576 hence only 192 firms went through the judging panel
	
    destring admin_participant_id, replace

    d, s

    tempfile judge_survey
    save `judge_survey'

/// Dataset C: Recruitment_survey
    use "$base\Recruitment_survey_clean", clear
    count // 198 but only 179 filled in the Basline Survey
	
    destring admin_participant_id, replace

    tempfile recruitment_survey
    save `recruitment_survey'

/////////////////////////////////////////////////////////////
//// 2. Merge           ////
////////////////////////////////////////////////////////////
    use `baseline_survey', clear
    merge 1:m admin_participant_id using `recruitment_survey', force
    keep if _merge==3 // 75 observations deleted
    
    assert c(N)==123
    
    tempfile merged2
    save `merged2'

    use `baseline_survey', clear

    merge 1:m admin_participant_id using `judge_survey'
    keep if _merge==3 // 18 observations deleted
    
    assert c(N)==369

    tempfile merged3
    save `merged3'

/////////////////////////////////////////////////////////////
//// 3. Generating descriptive variables    ////
////////////////////////////////////////////////////////////
    use `merged2', clear
    assert c(N)==123

    labvalch3 * , lower
    //labvalch3 * , strfcn(proper(`"@"'))

    tab ent1_exp_ceo_fullttime_r, sort miss
    br ent1_exp_ceo_fullttime_r ent2_exp_ceo_fullttime_r ent3_exp_ceo_fullttime_r ent4_exp_ceo_fullttime_r ent5_exp_ceo_fullttime_r if ent1_exp_ceo_fullttime_r==. //No missing in ent1 BUT ent2 to ent10 ALL missing

    gen exp_ceo_fullttime_i    = ent1_exp_ceo_fullttime_r
    replace exp_ceo_fullttime = ent2_exp_ceo_fullttime_r if exp_ceo_fullttime_i==.
    replace exp_ceo_fullttime = ent3_exp_ceo_fullttime_r if exp_ceo_fullttime_i==.
    replace exp_ceo_fullttime = ent4_exp_ceo_fullttime_r if exp_ceo_fullttime_i==.
    label values exp_ceo_fullttime_i exp_ceo_fullttime_r
    label var exp_ceo_fullttime_i "CEO sectorial experience"

    //The founder’s sector experience in years (Experience):
    tab exp_ceo_fullttime_i
    gen founder_exp_score = 0
    replace founder_exp_score = 1 if inlist(exp_ceo_fullttime_i ,1 ,2 ,3)
    label var founder_exp_score "If founder has 3 or more years of experience"
    ///High experience if 3 or more years
    sum founder_exp_score

    //The age of the firm (in years): CHECK date!!!!!!!
    gen float age = ( mdy(12,4,2020) - bo_registration_date ) / 365.25
    label var age "Firm age"
    tabstat  age, stat(n mean median min max)
    sum age, d
    gen age_score = cond(age > r(p50),1,0)
    label var age_score "If firm has age equal or above medium"
    ///Old firm if age >=p50
    sum age_score

    //Technological practices
    tab practices_q3
    gen tech_practice_score = practices_q3
    recode tech_practice_score (999 = 0) // Dont know recoded as NO
    label value tech_practice_score yesno
    label var tech_practice_score "If firm applies technological procedures"
    sum tech_practice_score

    //Intensity of computer use (average of people using computers/total employees)
	tab emp_use_computer
    gen tech_comp = emp_use_computer/emp_total
    replace tech_comp = . if tech_comp>1 // 11 cases
    label var tech_comp "Intensity of computer use"
    sum tech_comp // 11 missing
    histbox tech_comp, mean freq normal xlabel(0(.25)1)

    sum tech_comp, d
    gen tech_comp_score = cond(tech_comp >= r(p50),1,0)
    label var tech_comp_score "Intensity of computer use high/low"
	sum tech_comp_score
	
    //Develops own tech for own use
    tab devlp_own_tech, sort

    //Develops and sells own tech
    tab sell_tech, sort
    gen tech_devsell_score = sell_tech
    recode tech_devsell_score (1 2 = 1) (3 4 = 0) // 2 and more times a year == 1
    label var tech_devsell_score "If firm has develops and sells own tech yes/no"
    sum tech_devsell_score

    //Industry / sector:
    tab apply_sector_r, sort

    //Area of knowledge of innovation:
    tab inno_knowledge_r, sort

    //Innovation type:
    tab inno_type_r, sort

    //Innovation phase (MVP with income/without income):
    tab inno_phase_r, sort

    //Innovation in products/services, process, organization or marketing in 2018/2019
    tab new_product_innovation, sort
    tab new_product_process, sort
    tab new_product_organization, sort
    tab new_product_marketing, sort

    //Innovation ammounts 2018 - 2019
    tabstat innovations_amount_2018 innovations_amount_2019, stat(n mean median min max) c(s)

    egen inno_invest = rowmean(innovations_amount_*)
    label var inno_invest "Average innovation investment"
    sum inno_invest, d
    gen inno_invest_score = cond(inno_invest >= r(p50),1,0)
    label var inno_invest_score "If firm has invested in innovation equal or above medium"
    ///If firm investment is >=p50
    sum inno_invest_score

    //Education team members
    ///Only full data available for 1st 2members, 1st tend to be the CEO //CHECK!!!
    tab ent1_edu_r, sort
    tab ent1_position_r // NO VALUES!!
    tab ent2_edu_r, sort
    tab ent2_position_r
    tab ent3_edu_r, sort
    tab ent3_position_r

    egen edu_team = rowtotal(ent*_edu_r)
    sum edu_team, d
    gen edu_team_score = cond(edu_team >= r(p50),1,0)
    label var edu_team_score "Level of education team high/low"
    ///If team education is >=p50
    sum edu_team_score

    //Time dedicated to the project by team members
    ///Only full data available for 1st 2members, 1st tend to be the CEO
    tab ent1_position_r // NO VALUES!!!!
    tab ent2_position_r
    tab ent1_dedication_r
    tab ent2_dedication_r

    histbox ent1_dedication_r, mean freq normal xlabel(6(7)105)
    histbox ent2_dedication_r, mean freq normal xlabel(5(7.15)105)
    histbox ent3_dedication_r, mean freq normal xlabel(4(14.7)70)

    sum ent1_dedication_r, d
    gen dedication_score = cond(ent1_dedication_r >= r(p50),1,0)
    label var dedication_score "If weekly time dedicated to the proyect is equal or above medium"
    ///If CEO is highly dedicated is >=p50
    sum dedication_score

    save `merged2', replace


/////////////////////////////////////////////////////////////
//// 4. Generating stratification variables    ////
////////////////////////////////////////////////////////////
    use `merged3', clear
    assert c(N)== 369 //123 fims that were selected
   
   //Variable 1: Region 
    replace bo_biz_location_town = strlower(bo_biz_location_town) // put in lower case

	gen region = .
	replace region = 8  if strpos(bo_biz_location_town, "lima")
	replace region = 8  if strpos(bo_biz_location_town, "molina")
	replace region = 8  if strpos(bo_biz_location_town, "callao")
	replace region = 8  if strpos(bo_biz_location_town, "barranco")
	replace region = 8  if strpos(bo_biz_location_town, "ate")
	replace region = 8  if strpos(bo_biz_location_town, "bellavista")
	replace region = 8  if strpos(bo_biz_location_town, "lurin")
	replace region = 3  if strpos(bo_biz_location_town, "ollantaytambo")
	replace region = 3  if strpos(bo_biz_location_town, "cusco")
	replace region = 11 if strpos(bo_biz_location_town, "piura")
	replace region = 2  if strpos(bo_biz_location_town, "cajamarca")
	replace region = 1  if strpos(bo_biz_location_town, "arequipa")
	replace region = 13 if strpos(bo_biz_location_town, "ucayali")
	replace region = 4  if strpos(bo_biz_location_town, "huancavelica")
	replace region = 7  if strpos(bo_biz_location_town, "chiclayo")
	replace region = 12 if strpos(bo_biz_location_town, "shilcayo")
	replace region = 6  if strpos(bo_biz_location_town, "trujillo")
	replace region = 14 if strpos(bo_biz_location_town, "ica")
	replace region = 12 if strpos(bo_biz_location_town, "tarapoto")
	replace region = 12 if strpos(bo_biz_location_town, "san martin")
	replace region = 5  if strpos(bo_biz_location_town, "huancayo")
	replace region = 17 if strpos(bo_biz_location_town, "madre de dios")
	replace region = 20 if strpos(bo_biz_location_town, "puno")
	replace region = 21 if strpos(bo_biz_location_town, "tacna")
	replace region = 22 if strpos(bo_biz_location_town, "ayacucho")


    replace region = 15 if admin_participant_id == 74873
    replace region =  5 if admin_participant_id == 74486
    replace region = 16 if admin_participant_id == 74785
    replace region = 17 if admin_participant_id == 74980
    replace region = 18 if admin_participant_id == 74741
	replace region = 14 if admin_participant_id == 74844
	replace region = 6  if admin_participant_id == 74699
	replace region = 17 if admin_participant_id == 74748
	replace region = 2  if admin_participant_id == 74855
	replace region = 19 if admin_participant_id == 74758
	replace region = 3  if admin_participant_id == 75065
	replace region = 2  if admin_participant_id == 74807
	replace region = 20 if admin_participant_id == 74564
	replace region = 12 if admin_participant_id == 74917
	replace region = 2  if admin_participant_id == 74678
	replace region = 8  if admin_participant_id == 74733
	replace region = 8  if admin_participant_id == 74791
	replace region = 18 if admin_participant_id == 74866
	replace region = 8  if admin_participant_id == 75029
	replace region = 17 if admin_participant_id == 74707
	replace region = 8  if admin_participant_id == 74513
	replace region = 11 if admin_participant_id == 74667
	replace region = 5  if admin_participant_id == 75004
	replace region = 11 if admin_participant_id == 75014	
	replace region = 1  if admin_participant_id == 75052	
	
	
	
    label define region 1 "Arequipa" 2 "Cajamarca" 3 "Cusco" 4 "Huancavelica"  ///
    5 "Junin" 6 "La Libertad" 7 "Lambayeque" 8 "Lima metropolitana y Callao"  ///
    9 "Loreto" 10 "Madre de Dios" 11 "Piura" 12 "San Martin" 13 "Ucayali" 14 "Ica"  ///
	15 "Huanuco" 16 "Lima Region" 17 "Madre de Dios" 18 "Ancash" 19 "Amazonas" ///
	20 "Puno" 21 "Tacna" 22 "Ayacucho", replace
	
    label values region region
    drop _merge

    gen region_score = cond(region == 8, 1, 0)
    tab region_score
	
	/*
   //Checking if region is OK by verifying with recruitment data
    tempfile merged1
    save `merged1'

   //preserve

    use "$base\Recruitment_survey_clean", clear
    keep admin_participant_id dep_r
    merge 1:m admin_participant_id using `merged1'
	keep if _merge == 3
	assert c(N) == 369
	br admin_participant_id dep_r region bo_biz_location_town
    //Different info between recruitment data / baseline data
    // WARNING: I have changed it to reflect recruitment data
    // 74513 check, should be Lima
	// 74667 Piura / a nivel nacional (perú)-virtual
	// 75004 JUNÍN / surco, lima
    // 75014 PIURA / Lima
	// 75052 AREQUIPA / ubicacion gps, google maps -16.37458505027958, -71.55409699655499

   //restore
   */

   //Variable 2: Performance_score
    gen performance = 0
    replace performance = 1 if id_content_e== 1&novelty_e== 1&potential_size_e== 1&(tech_efficiency== 1|tech_efficiency== 2)

    bysort admin_participant_id: gen group_id = _n
    bysort admin_participant_id: egen performance_score = total(performance)

    recode performance_score (3=1) (2=0)

    sum performance_score if group_id == 1

   //Variable 3: Size_score

    histbox assets_total, mean freq normal bin(20) //Outliers!
    egen size_score = std(assets_total)
    sum size_score if group_id == 1, d
    gen size_asset_score= cond(size_score >= r(p50),1,0)
    drop size_score

    histbox emp_total, mean freq normal bin(30)  //Outliers!
    egen size_score = std(emp_total)
    sum size_score if group_id == 1, d
    gen size_employees_score = cond(size_score >= r(p50),1,0)
    drop size_score

    sum size_*_score if group_id == 1

    //Variable 4: Sales_score

    sum sales_last_year sales_last_month sales_typical_month cust_total_impt //Typical month
    nmissing sales_last_year sales_last_month sales_typical_month cust_total_impt
    // 18 missing in cust_total_impt
    histbox cust_total_impt, mean freq normal bin(30)  //Outliers!
    histbox sales_typical_month, mean freq normal bin(30)  //Outliers, but less than other var.
    sum sales_typical_month if sales_typical_month==0 // 8 firms have CERO sales
    sum cust_total_impt if cust_total_impt==0 // 4 firms have CERO important customers

    gen ratio_sc = sales_typical_month / cust_total_impt // 30 missing values generated!
    egen size_score = std(ratio_sc)
    sum size_score if group_id == 1, d
    gen sales2c_score = cond(size_score >= r(p50),1,0)
    drop size_score ratio_sc

    sum sales2c_score if group_id == 1

    keep if group_id == 1
    tempfile merged1
    save `merged1'

    //Variable 5: Acccess_score
    use `merged2', clear

    //Potential declared access deduced from inno_reach_r 
    gen inno_reach_r_i = .
	replace inno_reach_r_i = 2 if admin_participant_id == 74480
	replace inno_reach_r_i = 2 if admin_participant_id == 74510
	replace inno_reach_r_i = 2 if admin_participant_id == 74513
	replace inno_reach_r_i = 3 if admin_participant_id == 74519
	replace inno_reach_r_i = 3 if admin_participant_id == 74523
	replace inno_reach_r_i = 2 if admin_participant_id == 74524
	replace inno_reach_r_i = 2 if admin_participant_id == 74525
	replace inno_reach_r_i = 2 if admin_participant_id == 74531
	replace inno_reach_r_i = 3 if admin_participant_id == 74534
	replace inno_reach_r_i = 3 if admin_participant_id == 74558
	replace inno_reach_r_i = 3 if admin_participant_id == 74557
	replace inno_reach_r_i = 2 if admin_participant_id == 74581
	replace inno_reach_r_i = 4 if admin_participant_id == 74585
	replace inno_reach_r_i = 2 if admin_participant_id == 74571
	replace inno_reach_r_i = 4 if admin_participant_id == 74577
	replace inno_reach_r_i = 2 if admin_participant_id == 74579
	replace inno_reach_r_i = 3 if admin_participant_id == 74858
	replace inno_reach_r_i = 3 if admin_participant_id == 74887
	replace inno_reach_r_i = 2 if admin_participant_id == 74875
	replace inno_reach_r_i = 3 if admin_participant_id == 74878
	replace inno_reach_r_i = 4 if admin_participant_id == 74877
	replace inno_reach_r_i = 1 if admin_participant_id == 74878
	replace inno_reach_r_i = 2 if admin_participant_id == 74888
	replace inno_reach_r_i = 2 if admin_participant_id == 74898
	replace inno_reach_r_i = 4 if admin_participant_id == 74899
	replace inno_reach_r_i = 4 if admin_participant_id == 74700
	replace inno_reach_r_i = 2 if admin_participant_id == 74701
	replace inno_reach_r_i = 2 if admin_participant_id == 74707
	replace inno_reach_r_i = 2 if admin_participant_id == 74711
	replace inno_reach_r_i = 3 if admin_participant_id == 74714
	replace inno_reach_r_i = 3 if admin_participant_id == 74718
	replace inno_reach_r_i = 4 if admin_participant_id == 74725
	replace inno_reach_r_i = 4 if admin_participant_id == 74732
	replace inno_reach_r_i = 3 if admin_participant_id == 74733
	replace inno_reach_r_i = 2 if admin_participant_id == 74738
	replace inno_reach_r_i = 3 if admin_participant_id == 74744
	replace inno_reach_r_i = 4 if admin_participant_id == 74748
	replace inno_reach_r_i = 4 if admin_participant_id == 74750
	replace inno_reach_r_i = 4 if admin_participant_id == 74752
	replace inno_reach_r_i = 2 if admin_participant_id == 74753
	replace inno_reach_r_i = 2 if admin_participant_id == 74754
	replace inno_reach_r_i = 3 if admin_participant_id == 74758
	replace inno_reach_r_i = 3 if admin_participant_id == 74757
	replace inno_reach_r_i = 4 if admin_participant_id == 74783
	replace inno_reach_r_i = 4 if admin_participant_id == 74789
	replace inno_reach_r_i = 2 if admin_participant_id == 74772
	replace inno_reach_r_i = 4 if admin_participant_id == 74774
	replace inno_reach_r_i = 3 if admin_participant_id == 74785
	replace inno_reach_r_i = 3 if admin_participant_id == 74791
	replace inno_reach_r_i = 2 if admin_participant_id == 74795
	replace inno_reach_r_i = 3 if admin_participant_id == 74798
	replace inno_reach_r_i = 4 if admin_participant_id == 74807
	replace inno_reach_r_i = 3 if admin_participant_id == 74809
	replace inno_reach_r_i = 3 if admin_participant_id == 74814
	replace inno_reach_r_i = 3 if admin_participant_id == 74818
	replace inno_reach_r_i = 3 if admin_participant_id == 74824
	replace inno_reach_r_i = 3 if admin_participant_id == 74831
	replace inno_reach_r_i = 3 if admin_participant_id == 74833
	replace inno_reach_r_i = 2 if admin_participant_id == 74838
	replace inno_reach_r_i = 3 if admin_participant_id == 74841
	replace inno_reach_r_i = 4 if admin_participant_id == 74844
	replace inno_reach_r_i = 4 if admin_participant_id == 74848
	replace inno_reach_r_i = 2 if admin_participant_id == 74854
	replace inno_reach_r_i = 4 if admin_participant_id == 74880
	replace inno_reach_r_i = 2 if admin_participant_id == 74884
	replace inno_reach_r_i = 2 if admin_participant_id == 74873
	replace inno_reach_r_i = 2 if admin_participant_id == 74878
	replace inno_reach_r_i = 2 if admin_participant_id == 74879
	replace inno_reach_r_i = 4 if admin_participant_id == 74884
	replace inno_reach_r_i = 3 if admin_participant_id == 74909
	replace inno_reach_r_i = 3 if admin_participant_id == 74910
	replace inno_reach_r_i = 3 if admin_participant_id == 74914
	replace inno_reach_r_i = 2 if admin_participant_id == 74917
	replace inno_reach_r_i = 2 if admin_participant_id == 74921
	replace inno_reach_r_i = 2 if admin_participant_id == 74925
	replace inno_reach_r_i = 2 if admin_participant_id == 74928
	replace inno_reach_r_i = 2 if admin_participant_id == 74929
	replace inno_reach_r_i = 2 if admin_participant_id == 74933
	replace inno_reach_r_i = 3 if admin_participant_id == 74935
	replace inno_reach_r_i = 2 if admin_participant_id == 74938
	replace inno_reach_r_i = 2 if admin_participant_id == 74941
	replace inno_reach_r_i = 2 if admin_participant_id == 74942
	replace inno_reach_r_i = 3 if admin_participant_id == 74951
	replace inno_reach_r_i = 3 if admin_participant_id == 74958
	replace inno_reach_r_i = 3 if admin_participant_id == 74958
	replace inno_reach_r_i = 4 if admin_participant_id == 74981
	replace inno_reach_r_i = 3 if admin_participant_id == 74983
	replace inno_reach_r_i = 3 if admin_participant_id == 74987
	replace inno_reach_r_i = 3 if admin_participant_id == 74988
	replace inno_reach_r_i = 3 if admin_participant_id == 74970
	replace inno_reach_r_i = 2 if admin_participant_id == 74971
	replace inno_reach_r_i = 2 if admin_participant_id == 74973
	replace inno_reach_r_i = 4 if admin_participant_id == 74980
	replace inno_reach_r_i = 3 if admin_participant_id == 74981
	replace inno_reach_r_i = 4 if admin_participant_id == 74983
	replace inno_reach_r_i = 2 if admin_participant_id == 74990
	replace inno_reach_r_i = 1 if admin_participant_id == 74994
	replace inno_reach_r_i = 2 if admin_participant_id == 75000
	replace inno_reach_r_i = 3 if admin_participant_id == 75001
	replace inno_reach_r_i = 2 if admin_participant_id == 75002
	replace inno_reach_r_i = 3 if admin_participant_id == 75004
	replace inno_reach_r_i = 3 if admin_participant_id == 75005
	replace inno_reach_r_i = 3 if admin_participant_id == 75008
	replace inno_reach_r_i = 3 if admin_participant_id == 75014
	replace inno_reach_r_i = 2 if admin_participant_id == 75021
	replace inno_reach_r_i = 3 if admin_participant_id == 75025
	replace inno_reach_r_i = 3 if admin_participant_id == 75027
	replace inno_reach_r_i = 3 if admin_participant_id == 75035
	replace inno_reach_r_i = 2 if admin_participant_id == 75037
	replace inno_reach_r_i = 3 if admin_participant_id == 75043
	replace inno_reach_r_i = 2 if admin_participant_id == 75047
	replace inno_reach_r_i = 1 if admin_participant_id == 75052
	replace inno_reach_r_i = 3 if admin_participant_id == 75053
	replace inno_reach_r_i = 3 if admin_participant_id == 75058
	replace inno_reach_r_i = 2 if admin_participant_id == 75085
	replace inno_reach_r_i = 4 if admin_participant_id == 75087
	replace inno_reach_r_i = 4 if admin_participant_id == 75071
	replace inno_reach_r_i = 3 if admin_participant_id == 75081
	replace inno_reach_r_i = 2 if admin_participant_id == 75095
	replace inno_reach_r_i = 2 if admin_participant_id == 75098
	replace inno_reach_r_i = 2 if admin_participant_id == 75100
	replace inno_reach_r_i = 3 if admin_participant_id == 75108
	replace inno_reach_r_i = 3 if admin_participant_id == 75117

    label define reach 1 "Region" 2 "Peru" 3 "America Latina" 4 "Mundo"
    label values inno_reach_r_i reach

    gen access_size_score = cond(inno_reach_r_i==2|inno_reach_r_i==3 ,1 ,0)
    sum access_size_score

    gen cust_total_impt_i     = cust_total_impt
    replace cust_total_impt_i = 0 if cust_total_impt == . // 30 firms don´t have customers

    egen size_score = std(cust_total_impt_i)
    sum size_score, d
    gen access_customers_score = cond(size_score >= r(p50),1,0)
    drop size_score
    sum access_customers_score

    //Variable 6: capital_score
    gen capitals = capital_types_loan + capital_types_equity + capital_types_grant
    sum capitals

    gen capital_score = cond(capitals==0, 0, 1)
    sum capital_score

    //Variable 7: customers_score
    egen first_amount = rowtotal(cust_impt*_first_amount)

    egen size_score = std(first_amount)
    sum size_score, d
    gen customers_score = cond(size_score >= r(p50),1,0)
    drop size_score
    sum customers_score

    save `merged2', replace

    use `merged1', clear
    assert c(N)==123

  ///After meeting with SJA (7/08/2020), the FINAL stratification variables are: CHECK!!!!!
    ///See randomization narrative document in Dropbox (3.5.).

    //1) Region, if firm is located in Lima our outside Lima. See line 361.
    tab region_score
    sum region_score

    //2) Growth potential of MVP, median of final weighted average judge score.
    tab average_judge_score_e
    sum average_judge_score_e
	
    label var average_judge_score_e "Average judge score"

    sum average_judge_score_e, d
    gen growthMVP_score = cond(average_judge_score_e >= r(p50), 1, 0)
    sum growthMVP_score

    //3) Sales (last month, typical month, last year), profit (last month, typical month, last year) and assets not including land, buildings and IP, Index of average of winzorised and IHS variables.
	
	//LAST MONTH   == OCTOBER 2020!!!!!//
	//LAST MONTH_2 == FEBRUARY 2020!!!!//
	//WE USE OCTOBER 2020!!!!!!!!!!!!!!//
	//---------------------------------//
	
    //Preparing variables
    gen sales_lyear_month   = sales_last_year   /12
    gen profits_lyear_month = profits_last_year /12   // Negative values
	
    /*SA: My preference is to only use the Sales variables and the Profits variables when constructing this performance index.  One reason is that assets can be quite noisy; and we also don't have a good sense yet on how to measure this for more tech/R&D firms.  A second reason is that if we put assets into this index (and report it as such for stratification) then it handcuffs a bit later -- i.e., there might be an expectation to do some analysis or show some results for 'assets' as part of the main effect results (which I'm reluctant to do).*/
    egen assets               = rowtotal(asset_lgvehicle_value     ///
                                        asset_smvehicle_value      ///
                                        asset_machine_value        ///
                                        asset_tools_value          ///
                                        asset_itech_value          ///
                                        asset_furniture_value      ///
                                        asset_wc1_stock_value      ///
                                        asset_wc2_materials_value  ///
                                        asset_wc3_money_value)
    /*Assets variable created for balance table (assets_w)*/

    //Winsorize, generates *_w variables
    foreach var in sales_last_month sales_typical_month sales_lyear_month profits_last_month profits_typical_month profits_lyear_month assets {

        winsor2 `var', cuts(1 99)
    }

    //Inverse Hyperbolic Sine (IHS) using raw values
    foreach var in sales_last_month sales_typical_month sales_lyear_month profits_last_month profits_typical_month profits_lyear_month /*assets*/ {

        gen `var'_ihs = asinh(`var')
    }

    //Average of variables
    egen sales_baseline_w    = rowmean(sales_last_month_w      ///
                                       sales_typical_month_w    ///
                                       sales_lyear_month_w)
    egen sales_baseline_ihs  = rowmean(sales_last_month_ihs   ///                                    
									   sales_typical_month_ihs  ///
                                       sales_lyear_month_ihs)
    egen profits_baseline_w  = rowmean(profits_last_month_w    ///
                                       profits_typical_month_w  ///
                                       profits_lyear_month_w)
    egen profits_baseline_ihs= rowmean(profits_last_month_ihs  ///                                      
									   profits_typical_month_ihs  ///
                                       profits_lyear_month_ihs)
    /*
    rename assets_w            assets_baseline_w
    rename assets_ihs          assets_baseline_ihs
    */
    sum *_baseline_* // Negative profits.

    //Creating index (average of standardized values)
    foreach var in sales_baseline_w sales_baseline_ihs profits_baseline_w profits_baseline_ihs /*assets_baseline_w assets_baseline_ihs*/ {

        egen std_`var' = std(`var')
    }

    egen composite_baseline_index = rowmean(std_*)
		label var composite_baseline_index "Sales and profit Index"
		drop std_*

    foreach var in sales_last_month_w sales_typical_month_w sales_lyear_month_w sales_last_month_ihs sales_typical_month_ihs sales_lyear_month_ihs profits_last_month_w profits_typical_month_w profits_lyear_month_w profits_last_month_ihs profits_typical_month_ihs profits_lyear_month_ihs {

        egen std12_`var' = std(`var')
    }

    egen composite_baseline_index12 = rowmean(std12_*)
		label var composite_baseline_index12 "Sales and profit Index_12"
		drop std12_*

    sum composite_baseline_index*

    //Creating stratification variable, median cut-off point of standardized index
    sum composite_baseline_index, d
    gen composite_index_score = cond(composite_baseline_index > r(p50), 1, 0)
    sum composite_index_score

    sum composite_baseline_index12, d
    gen composite_index12_score = cond(composite_baseline_index12 > r(p50), 1, 0)
    sum composite_index12_score
 
    //4) Number of Important customers winzorised and ISH and cust_impt*_sales and winzorised and IHS, Index of average of winzorised and IHS variables.

    //Preparing variables, total of important sales in 2019
    egen cust_impt_sales2019 = rowtotal(cust_impt*_sales2019) // 35 obs. with CERO sales, 5 obs. with millions in sales
	tab cust_total_impt, miss // 27 ob. missing and 3 with CERO important customers
	replace cust_total_impt = 0 if 	cust_total_impt == . //CHECK!!!
	
    //Winsorize, generates *_w variables
    foreach var in cust_total_impt cust_impt_sales2019 {

        winsor2 `var', cuts(1 99)
    }

    //Inverse Hyperbolic Sine (IHS) using raw values
    foreach var in cust_total_impt cust_impt_sales2019 {

        gen `var'_ihs = asinh(`var')
    }

    //Rename variables, no average needed
    rename cust_total_impt_w cust_impt_baseline_w
    rename cust_impt_sales2019_w cust_impt_sales_baseline_w
    rename cust_total_impt_ihs cust_impt_baseline_ihs
    rename cust_impt_sales2019_ihs cust_impt_sales_baseline_ihs

    sum cust_*_baseline_*

    //Creating index (average of standardized values)
    foreach var in cust_impt_baseline_w cust_impt_sales_baseline_w cust_impt_baseline_ihs cust_impt_sales_baseline_ihs {

        egen std_`var' = std(`var')
    }

    egen customers_baseline_index = rowmean(std_cust_*)
    label var customers_baseline_index "Important customers sales Index"
	drop std_*

    sum customers_baseline_index

    //Creating stratification variables, median cut-off point of standardized index
    sum customers_baseline_index, d
    gen customers_index_score = cond(customers_baseline_index > r(p50), 1, 0)
    sum customers_index_score

    //5) Capitals amount and quantity (capital_loans*_amount, equity and grants) winzorised and ISH, Index of average of winzorised and IHS variables.

    //Preparing variables, total by type of asset
    //egen loans_value     = rowtotal(capital_loan*_amount)
    //egen equity_value    = rowtotal(capital_equity*_amount)
    //egen grants_value    = rowtotal(capital_grant*_value)

    egen capitals_value     = rowtotal(capital_loan*_amount capital_equity*_amount capital_grant*_value)

    //rename capital_loans   loans_amount
    //rename capital_equity  equity_amount
    //rename capital_grants  grants_amount

    egen capitals_count     = rowtotal(capital_loans capital_equity capital_grants)

    //Winsorize, generates *_w variables
    foreach var in capitals_value capitals_count {

        winsor2 `var', cuts(1 99)
    }

    //Inverse Hyperbolic Sine (IHS) using raw values
    foreach var in capitals_value capitals_count {

        gen `var'_ihs = asinh(`var')
    }

    //Rename variables, no average needed
    rename capitals_value_w capitals_value_baseline_w
    rename capitals_value_ihs capitals_value_baseline_ihs
    rename capitals_count_w capitals_count_baseline_w
    rename capitals_count_ihs capitals_count_baseline_ihs

    sum capitals_*_baseline_*

    //Creating index (average of standardized values)
    foreach var in capitals_value_baseline_w capitals_count_baseline_w capitals_value_baseline_ihs capitals_count_baseline_ihs {

        egen std_`var' = std(`var')
    }

    egen capitals_baseline_index = rowmean(std_*)
    label var capitals_baseline_index "Capitals (loans, equity and grants) Index"
	drop std_*

    sum capitals_baseline_index

    //Creating stratification variables
    sum capitals_baseline_index, d
    gen capitals_baseline_index_score = cond(capitals_baseline_index > r(p50), 1, 0)
    sum capitals_baseline_index_score
    //Note: 8 firms on the 50th percentile, that´s why we use >.

    //Checking indexes
    dotplot *_index // WARNING: sales & profits index and important customers have outliers!!!

////CHECKED until here 26112020//////////////////////////////
	
/////////////////////////////////////////////////////////////
//// 5. Generating randomization dataset   ////
////////////////////////////////////////////////////////////
   //5 variables + ID
    /*
   merge 1:1 admin_participant_id using `merged1', gen(_merge2)
   count
   keep if _merge2 == 3
   assert c(N) == 109
   */
    save `merged1', replace

  preserve
   keep admin_participant_id admin_business_name
   save "$out\aleatorizacion_key.dta", replace
  restore
    /*
   keep admin_participant_id region_score performance_score size_asset_score size_employees_score sales2c_score access_size_score access_customers_score customers_score performance1_score performance2_score
   */
    keep admin_participant_id region_score growthMVP_score composite_index_score customers_index_score capitals_baseline_index_score

    assert c(N) == 123

   save "$out\aleatorizacion_final.dta", replace

/////////////////////////////////////////////////////////////
//// 6. Randomization      ////
////////////////////////////////////////////////////////////

    clear all
    use "$out\aleatorizacion_final.dta", clear

    assert c(N) == 123

    sort admin_participant_id

    // Set stratification variables
    global ranvar "region_score growthMVP_score composite_index_score customers_index_score capitals_baseline_index_score"
    
    randtreat, generate(treatment) strata($ranvar) setseed(20201204) misfits(wglobal) unequal(43/100 43/100 14/100) replace  
    //NOTE: Group size according to the MOE, this is, the size of treatment group should be 45%, control group (45%) and replacement group (10%).
    
    //Label treatment
	label def treat 2 "Grupo de accesitarios"  1 "Grupo de Control" 0 "Grupo de Tratamiento", replace
	sort treatment
	label val treatment treat
	tab treatment

    //Save results
    tempfile randomized2
    save `randomized2'

    rename admin_participant_id entrep_id

    keep entrep_id treatment

    export excel using "$out\aleatorizacion_resultados_batch2.xls", firstrow(variables) sheet("Resultados") replace

/////////////////////////////////////////////////////////////
//// 7. Balance checks      ////
////////////////////////////////////////////////////////////
    //ssc install ttable2
    //ssc install balancetable
    //goldstein sumtable site:statalist.org

    //Stratification variables
	///CHECK treatment!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
    use `randomized2', clear
    ttable2 $ranvar if treatment == 1 | treatment == 0, by(treatment)
        
    //Indexes (continous variables)
    use `merged1', clear
    merge 1:1 admin_participant_id using `randomized2', gen(_merge3)
    keep if _merge3 == 3
    drop _merge3
    merge 1:1 admin_participant_id using `merged2', gen(_merge3)
    assert c(N) == 123
    drop _merge3
    
    //Re coding of variables
    recode ent1_sex_r (1 = 0) (2 = 1) //Mujer O Hombre 1
    recode practices_q1-practices_q12 (999 =  0) //No sabe = No
    
    //Factorise variables
    tab tech_efficiency
	gen effi_ = tech_efficiency
	recode effi_ (3 4 = 0) ( 1 2= 1) //Una vez o menos al año = 0 - Entre 2 a más veces al año = 1
	label var effi_ "tech_efficiency"
	label define effi_  1 "Más de 2 veces al año" 0 "Una o menos al año", replace
	label values effi_ effi_
	
    tab devlp_own_tech
	gen own_ = devlp_own_tech
	recode own_ (3 4 = 0) ( 1 2= 1) //Una vez o menos al año = 0 - Entre 2 a más veces al año = 1
	label var own_ "devlp_own_tech"
	label define own_  1 "Más de 2 veces al año" 0 "Una o menos al año", replace
	label values own_ own_
	
    tab patent_tech  //Más de 5 veces al año only two obs.!!
 	gen paten_ = patent_tech
	recode paten_ (3 4 = 0) ( 1 2= 1) //Una vez o menos al año = 0 - Entre 2 a más veces al año = 1
	label var paten_ "patent_tech"
	label define paten_  1 "Más de 2 veces al año" 0 "Una o menos al año", replace // Más de 2 veces al año 7 Obs.
	label values paten_ paten_
	
	tab sell_tech
 	gen sel_ = sell_tech
	recode sel_ (3 4 = 0) ( 1 2= 1) //Una vez o menos al año = 0 - Entre 2 a más veces al año = 1
	label var sel_ "sell_tech"
	label define sel_  1 "Más de 2 veces al año" 0 "Una o menos al año", replace
	label values sel_ sel_	
	
    
    tab inno_knowledge_r, gen(know_area_) // Nanotech (13) only one obs.!!
    tab apply_sector_r, gen(sector_) // Maquinaria en general (12) only one obs.!!
    tab inno_phase_r, gen(phase_)
    tab inno_type_r, gen(type_)

    //Change/apply lables
        //edu_team change label
       //age change lable to years of buisness in operation
    
    
    save "$out\aleatorizacion_bda.dta", replace


    sum region_score average_judge_score_e *_index

    global randomization_vars "region_score average_judge_score_e growthMVP_score composite_baseline_index composite_index12_score customers_baseline_index customers_index_score capitals_baseline_index capitals_baseline_index_score"

    iebaltab $randomization_vars if treatment == 1 | treatment == 0, ///
	tblnote("Notes: This table presents baseline summary statistics for firms and entrepreneurs. Columns (1)-(2) present average values by experimental group. Column (3) presents average values for the full sample. Standard errors are in parentheses to the right. Column (4) present equality of means tests (t-tests) between the groups. The value displayed for a t-test is the difference in the means between experimental groups. The value displayed for the F-test is the F-statistic. Statistically significant p-values are highlighted by: * (10% significance level); ** (5% significance level); *** (1% significance level).") ///
    grpvar(treatment) save("$out\Table_randomization_indexes.xls") total rowvarlabels /*onerow*/ /*tblnonote*/ ftest fmissok /*nottest*/ /*feqtest*/ /*fixedeffect()*/ /*savebrowse*/ replace

    balanceplot treatment $randomization_vars if treatment == 1 | treatment == 0, group(treatment)
    graph export "$out\balanceplot_indexes.png", width(800) height(600) replace

    //Use other variables, education, age (entrepeneur variables) + other firm variables (all the input of indexes), etc.

    global entrepeneur "exp_ceo_fullttime_i ent1_sex_r edu_team practices_q1-practices_q12"

    sum $entrepeneur

    global performance "age emp_total sales_last_month_w sales_typical_month_w sales_lyear_month_w sales_baseline_w profits_last_month_w profits_typical_month_w profits_lyear_month_w profits_baseline_w cust_impt_baseline_w capitals_value_baseline_w capitals_count_baseline_w assets_w innovations_amount_2018 innovations_amount_2019 certification_quality certification_environ certification_social_liability certification_security certification_sanitary effi_ own_ paten_ sel_ "    

    sum $performance

    iebaltab $entrepeneur $performance if treatment == 1 | treatment == 0, ///
    tblnote("Notes: This table presents baseline summary statistics for firms and entrepreneurs. Columns (1)-(2) present average values by experimental group. Column (3) presents average values for the full sample. Standard errors are in parentheses to the right. Column (4) present equality of means tests (t-tests) between the groups. The value displayed for a t-test is the difference in the means between experimental groups. The value displayed for the F-test is the F-statistic. Statistically significant p-values are highlighted by: * (10% significance level); ** (5% significance level); *** (1% significance level).") ///
    grpvar(treatment) save("$out\Table_randomization_baseline.xls") total /*rowvarlabels*/ /*onerow*/ /*tblnonote*/ ftest fmissok /*nottest*/ /*feqtest*/ /*fixedeffect()*/ /*savebrowse*/ replace

    balanceplot treatment $entrepeneur $performance if treatment == 1 | treatment == 0, group(treatment)
    graph export "$out\balanceplot_baseline.png", width(800) height(600) replace

    global sectorial_vars "know_area_* sector_* phase_* type_*"

    sum know_area_* sector_* phase_* type_*

    iebaltab $sectorial_vars if treatment == 1 | treatment == 0, ///
    tblnote("Notes: This table presents baseline summary statistics for firms and entrepreneurs. Columns (1)-(2) present average values by experimental group. Column (3) presents average values for the full sample. Standard errors are in parentheses to the right. Column (4) present equality of means tests (t-tests) between the groups. The value displayed for a t-test is the difference in the means between experimental groups. The value displayed for the F-test is the F-statistic. Statistically significant p-values are highlighted by: * (10% significance level); ** (5% significance level); *** (1% significance level).") ///
    grpvar(treatment) save("$out\Table_randomization_sector.xls") total /*rowvarlabels*/ /*onerow*/ /*tblnonote*/ ftest fmissok /*nottest*/ /*feqtest*/ /*fixedeffect()*/ /*savebrowse*/ replace

    balanceplot treatment $sectorial_vars if treatment == 1 | treatment == 0, group(treatment)
    graph export "$out\balanceplot_sector.png", width(800) height(600) replace

cd "$out"
log close
translate randomization.smcl randomization_log.pdf, replace
