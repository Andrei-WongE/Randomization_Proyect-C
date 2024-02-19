**
**Author: SK
**Purpose: Daily HFCs for Peru Project 
**Dealing with missing values and data consistency
*

*set trace on
*set maxvar 10000

******************************************************************************************************
* 										Part. A.INITIALIZING										 *			
******************************************************************************************************

	 clear all
	 set more off
	 pause on
	 log close _all
	 set maxvar 8000
	 
	  *** Set working directory -- !
	 *cd "/Volumes/Secomba/kagera/Boxcryptor/Box Sync/Peru/Baseline/"
 
** Setting drive to within ________ folder
 
	*global raw "1_Raw"
	global raw "Raw"
	global iddata "Data"
	global dofiles "Dofile"
	global hfc "High Frequency"
  
  
*** Set dates 
 
	*global date "5/04/2020" // change every day to reflect the data that you are checking // 
	global date : di %tdnn/dd/CCYY date(c(current_date), "DMY") // date of the data
	global filedate : di %tdCCYY.NN.DD date(c(current_date), "DMY") // date of the data
	*format $date %tdnn/dd/YY
 
 
 *** Open log// creates a log of what has been done in stata 

    *cap log close _all
    *log using "Peru_$filedate.smcl", name(Baseline), replace
	


	
 ** Setting a global with main vars for high frequency checks	

	global biz_info "admin_participant_id  admin_firstname admin_lastname bo_biz_name admin_interview_date"   /// add variable names for surveyor ID and survey date
	

	
 *use "$iddata/CONCYTEC_FONDECYT_Encuesta_Linea_Base.dta"	
 cd "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Data check\04052020"
 
 use CONCYTEC_FONDECYT_Encuesta_Linea_Base
 *use CONCYTEC_FONDECYT_Encuesta_Linea_Base_20042020_clean_new 
******************************************************************************************************
* 											**Drop programming variables										 *			
******************************************************************************************************


		
	drop deviceid	subscriberid	simid	devicephonenum 	ci_biz_name_num ci_firstname_num ci_lastname_num ci_phone_1	ci_phone_2  

	
	destring admin_participant_id,replace
	destring emp_total,replace
	destring assets_total,replace ignore(",")


******************************************************************************************************
* 											**Rename and label Multiple select variables										 *			
******************************************************************************************************
	
	label define yesno 1 "Yes" 0 "No",modify


    ren bo_primary_how_1 bo_primary_how_BuyResell
	ren bo_primary_how_2 bo_primary_how_Manufacture
	ren bo_primary_how_3 bo_primary_how_Services
	
	foreach var of varlist bo_primary_how_BuyResell bo_primary_how_Manufacture bo_primary_how_Services{
	destring `var',replace
	lab val `var' yesno
	}
	
		
** Business Structure variables	

	
	ren bo_structure_1 bo_struct_home 
	label var bo_struct_home "In someone's home (e.g., owner, founder or manager)."

	ren bo_structure_2 bo_struct_ownerroom 
	label var bo_struct_ownerroom "In someone's home (e.g., owner, founder or manager), but in a room or area used only for the business."

	ren bo_structure_3 bo_struct_cust_home 
	label var bo_struct_cust_home "At the customers’ home (e.g. selling products or providing services)."

	ren bo_structure_4 bo_struct_cust_bizlocation 
	label var bo_struct_cust_bizlocation "At the customers’ business location (e.g. store, office, factory)."

	ren bo_structure_5 bo_struct_mrkt_stand 
	label var bo_struct_mrkt_stand "At a marketplace stall or stand (not a permanent physical structure)."

	ren bo_structure_6 bo_struct_container  
	label var bo_struct_container "In a shipping container or similar physical structure (stand alone)."

	ren bo_structure_7 bo_struct_smallstandalone 
	label var bo_struct_smallstandalone "In a small shop (stand alone). NOTE:  A rent or lease is regularly paid."

	ren bo_structure_8 bo_struct_stripmall 
	label var bo_struct_stripmall "Small shop located in a strip mall or outdoor plaza.NOTE:  A rent or lease is regularly paid."

	ren bo_structure_9 bo_struct_largestandalone 
	label var bo_struct_largestandalone "In a large shop/storefront (stand alone).NOTE:  A rent or lease is regularly paid."

	ren bo_structure_10 bo_struct_shoppingmall 
	label var bo_struct_shoppingmall "Large shop/storefront located in a shopping mall or retail building.NOTE:  A rent or lease is regularly paid."

	ren bo_structure_11 bo_struct_office_bldn 
	label var bo_struct_office_bldn "In an office located within a larger office building or complex.NOTE:  A rent or lease is regularly paid."

	ren bo_structure_12 bo_struct_factory 
	label var bo_struct_factory "In a large stand alone building (e.g. factory, facility, warehouse, or office building).NOTE:  A rent or lease is regularly paid."

	ren bo_structure_13 bo_struct_other 
	label var bo_struct_other "Other: please describe."

	foreach var of varlist bo_struct_home bo_struct_ownerroom bo_struct_cust_home bo_struct_cust_bizlocation bo_struct_mrkt_stand bo_struct_container bo_struct_smallstandalone bo_struct_stripmall bo_struct_largestandalone bo_struct_shoppingmall bo_struct_office_bldn bo_struct_factory{
	destring `var',replace
	lab val `var' yesno
	}
	

*** Customer interactions 

	ren cust*_interactions_total_1 cust*_interct_inpersonBIZ
	foreach var of varlist cust*_interct_inpersonBIZ {
	label var `var' "In-person at my business location"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren cust*_interactions_total_2 cust*_interct_cust_home
	foreach var of varlist cust*_interct_cust_home{
	label var `var' "In-person at the customer's home or business"
		destring `var',replace
	lab val `var' yesno
	}
	

	ren cust*_interactions_total_3 cust*_interct_difloctn
	foreach var of varlist cust*_interct_difloctn {
	label var `var' "In-person at a different location (not my business or the customer's home/business)"
	destring `var',replace
	lab val `var' yesno
	}
	

	ren cust*_interactions_total_4 cust*_interct_courier
	foreach var of varlist cust*_interct_courier {
	label var `var'  "Mail: regular post or courier (e.g., personal letter, promotional flyer, etc.)"
	destring `var',replace
	lab val `var' yesno
	}
	
	

	ren cust*_interactions_total_5 cust*_interct_phonevoice
	foreach var of varlist cust*_interct_phonevoice {
	label var `var'  "Phone: voice call (private, one-on-one discussion)"
	destring `var',replace
	lab val `var' yesno
	}
	
	

	ren cust*_interactions_total_6 cust*_interct_phonetext
	foreach var of varlist cust*_interct_phonetext {
	label var `var'  "Phone: text message or SMS (private, one-on-one message)"
	destring `var',replace
	lab val `var' yesno
	}
	
	

	ren cust*_interactions_total_7 cust*_interct_EmailInvd
	foreach var of varlist cust*_interct_EmailInvd {
	label var `var'  "Email: individual (one-on-one message)"
	destring `var',replace
	lab val `var' yesno
	}
	

	ren cust*_interactions_total_8 cust*_interct_Emailgroup	
	foreach var of varlist cust*_interct_Emailgroup	 {
	label var  `var'  "Email: group (one-to-many message or promotion)"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren cust*_interactions_total_9 cust*_interct_Whatsapone
	foreach var of varlist cust*_interct_Whatsapone{
	label var  `var'  "WhatsApp: individual (one-on-one message)"
	destring `var',replace
	lab val `var' yesno
	}
	
	
	ren v387 cust_impt10_interct_Whatsapgrp
	ren cust*_interactions_total_10 cust*_interct_Whatsapgrp
	foreach var of varlist cust*_interct_Whatsapgrp {
	label var  `var'  "WhatsApp: group (one-to-many message or promotion)"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren v388 cust_impt10_interct_fb_one
	ren cust*_interactions_total_11 cust*_interct_fb_one
	foreach var of varlist cust*_interct_fb_one {
	label var  `var'  "Facebook: individual (one-on-one message)"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren v389 cust_impt10_interct_fb_grp
	ren cust*_interactions_total_12 cust*_interct_fb_grp 
	
	foreach var of varlist cust*_interct_fb_grp  {
	label var  `var' "Facebook: group (one-to-many message or promotion)"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren v390 cust_impt10_interct_instagram
	ren cust*_interactions_total_13 cust*_interct_instagram
	
	foreach var of varlist cust*_interct_instagram  {
	label var  `var'  "Instagram"
	destring `var',replace
	lab val `var' yesno
	}
	
	ren v391 cust_impt10_interct_twitter
	ren cust*_interactions_total_14 cust*_interct_twitter
	
	foreach var of varlist cust*_interct_twitter {
	label var `var'  "Twitter"
	destring `var',replace
	lab val `var' yesno
	}

	ren v392 cust_impt10_interct_other
	ren cust*_interactions_total_15 cust*_interct_other
	
	foreach var of varlist cust*_interct_other {
	label var  `var' "Other"
	destring `var',replace
	lab val `var' yesno
	}

	ren v393 cust_impt10_interct_DKN
	ren cust*_interactions_total_99 cust*_interct_DKN
	foreach var of varlist cust*_interct_DKN  {
	label var  `var' "Don't know"
	destring `var',replace
	lab val `var' yesno
	}

	 ren v133 cust_impt1_interct_NA

	 ren v162 cust_impt2_interct_NA

	 ren v191 cust_impt3_interct_NA

	 ren v220 cust_impt4_interct_NA

	 ren v249 cust_impt5_interct_NA

	 ren v278 cust_impt6_interct_NA

	 ren v307 cust_impt7_interct_NA

	 ren v336 cust_impt8_interct_NA

	 ren v365 cust_impt9_interct_NA

	 ren v394 cust_impt10_interct_NA

	foreach var of varlist cust*_interct_NA  {
	label var  `var' "Not applicable"
	
	destring `var',replace
	lab val `var' yesno
	}


** Capital types	
	
	ren capital_types_0 capital_types_noexternal
	lab var capital_types_noexternal "None (zero outside money has been raised for your business)"
	
	ren capital_types_1 capital_types_loan
	lab var capital_types_loan "Loans  (money borrowed from a lender that your business must repay)"

	ren capital_types_2 capital_types_equity
	lab var capital_types_equity "Equity  (money obtained from an investor in exchange for partial ownership of your business)"

	ren capital_types_3 capital_types_grant
	lab var capital_types_grant "Grants  (money received from a formal donor that your business does not need to repay)"

	
	ren capital_types_997 capital_types_DKN
	lab var capital_types_DKN "Don't know"
	
	ren capital_types_999 capital_types_NA
	lab var capital_types_NA "Not applicable"
	
	
	
	foreach var of varlist capital_types_noexternal capital_types_loan capital_types_equity capital_types_grant capital_types_DKN  capital_types_NA {	
	destring `var',replace
	lab val `var' yesno
	}
	
	
	** Order date variables
	order bo_transactions_last_date, after(bo_operational_close_reason)
	
	order bo_registration_date, after(bo_registration_number)
	order admin_survey_date, before(admin_participant_id)
	
	
	order cust_impt1_recent_date, after(cust_impt1_reason)
	order cust_impt2_recent_date, after(cust_impt2_reason)
	order cust_impt3_recent_date, after(cust_impt3_reason)
	order cust_impt4_recent_date, after(cust_impt4_reason)
	order cust_impt5_recent_date, after(cust_impt5_reason)
	order cust_impt6_recent_date, after(cust_impt6_reason)
	order cust_impt7_recent_date, after(cust_impt7_reason)
	order cust_impt8_recent_date, after(cust_impt8_reason)
	order cust_impt9_recent_date, after(cust_impt9_reason)
	order cust_impt10_recent_date, after(cust_impt10_reason)


	order cust_impt1_first_date, before(cust_impt1_first_amount)
	order cust_impt2_first_date, before(cust_impt2_first_amount)
	order cust_impt3_first_date, before(cust_impt3_first_amount)
	order cust_impt4_first_date, before(cust_impt4_first_amount)
	order cust_impt5_first_date, before(cust_impt5_first_amount)
	order cust_impt6_first_date, before(cust_impt6_first_amount)
	order cust_impt7_first_date, before(cust_impt7_first_amount)
	order cust_impt8_first_date, before(cust_impt8_first_amount)
	order cust_impt9_first_date, before(cust_impt9_first_amount)
	order cust_impt10_first_date, before(cust_impt10_first_amount)

	order capital_loan1_date, after(capital_loan1_source_other)
	order capital_loan2_date, after(capital_loan2_source_other)
	order capital_loan3_date, after(capital_loan3_source_other)
	order capital_loan4_date, after(capital_loan4_source_other)
	order capital_loan5_date, after(capital_loan5_source_other)
	order capital_loan6_date, after(capital_loan6_source_other)
	order capital_loan7_date, after(capital_loan7_source_other)
	order capital_loan8_date, after(capital_loan8_source_other)
	order capital_loan9_date, after(capital_loan9_source_other)
	order capital_loan10_date, after(capital_loan10_source_other)
	
	
	order capital_equity1_date, after(capital_equity1_source_other)
	order capital_equity2_date, after(capital_equity2_source_other)
	order capital_equity3_date, after(capital_equity3_source_other)
	order capital_equity4_date, after(capital_equity4_source_other)
	order capital_equity5_date, after(capital_equity5_source_other)

	
	ren capital_grant*_other capital_grant*_source_other
	
	order capital_grant1_date, after(capital_grant1_source_other)
	order capital_grant2_date, after(capital_grant2_source_other)
	order capital_grant3_date, after(capital_grant3_source_other)
	order capital_grant4_date, after(capital_grant4_source_other)
	order capital_grant5_date, after(capital_grant5_source_other)
	

******  Data cleaning Capital types 
	replace capital_equity2 ="" if admin_participant_id==68040 // respondent entered amount on the counts
	replace capital_equity2_source=. if admin_participant_id==68040
	replace capital_equity2_date=. if admin_participant_id==68040	
	replace capital_equity2_amount=. if admin_participant_id==68040	
	replace capital_equity2_purpose="" if admin_participant_id==68040
	replace capital_equity2_researchdev=. if admin_participant_id==68040
	replace capital_equity2_involvement=. if admin_participant_id==68040
	replace capital_equity2_verifiable=. if admin_participant_id==68040

	replace capital_equity3 ="" if admin_participant_id==68040
	replace capital_equity3_source=. if admin_participant_id==68040
	replace capital_equity3_date=. if admin_participant_id==68040	
	replace capital_equity3_amount=. if admin_participant_id==68040	
	replace capital_equity3_purpose="" if admin_participant_id==68040
	replace capital_equity3_researchdev=. if admin_participant_id==68040
	replace capital_equity3_involvement=. if admin_participant_id==68040
	replace capital_equity3_verifiable=. if admin_participant_id==68040

	replace capital_equity4 ="" if admin_participant_id==68040
	replace capital_equity4_source=. if admin_participant_id==68040
	replace capital_equity4_date=. if admin_participant_id==68040	
	replace capital_equity4_amount=. if admin_participant_id==68040	
	replace capital_equity4_purpose="" if admin_participant_id==68040
	replace capital_equity4_researchdev=. if admin_participant_id==68040
	replace capital_equity4_involvement=. if admin_participant_id==68040
	replace capital_equity4_verifiable=. if admin_participant_id==68040

	replace capital_equity5="" if admin_participant_id==68040
	replace capital_equity5_source=. if admin_participant_id==68040
	replace capital_equity5_date=. if admin_participant_id==68040	
	replace capital_equity5_amount=. if admin_participant_id==68040
	replace capital_equity5_purpose="" if admin_participant_id==68040
	replace capital_equity5_researchdev=. if admin_participant_id==68040
	replace capital_equity5_involvement=. if admin_participant_id==68040
	replace capital_equity5_verifiable=. if admin_participant_id==68040
		
	replace capital_equity=1 if admin_participant_id==68040
	replace capital_equity=5 if admin_participant_id==68070

	replace capital_equity3 ="" if admin_participant_id==68339  // respondent entered amount on the counts
	replace capital_equity3_source=. if admin_participant_id==68339
	replace capital_equity3_date=. if admin_participant_id==68339	
	replace capital_equity3_amount=. if admin_participant_id==68339	
	replace capital_equity3_purpose="" if admin_participant_id==68339
	replace capital_equity3_researchdev=. if admin_participant_id==68339
	replace capital_equity3_involvement=. if admin_participant_id==68339
	replace capital_equity3_verifiable=. if admin_participant_id==68339

	replace capital_equity4 ="" if admin_participant_id==68339
	replace capital_equity4_source=. if admin_participant_id==68339
	replace capital_equity4_date=. if admin_participant_id==68339	
	replace capital_equity4_amount=. if admin_participant_id==68339	
	replace capital_equity4_purpose="" if admin_participant_id==68339
	replace capital_equity4_researchdev=. if admin_participant_id==68339
	replace capital_equity4_involvement=. if admin_participant_id==68339
	replace capital_equity4_verifiable=. if admin_participant_id==68339

	replace capital_equity5="" if admin_participant_id==68339
	replace capital_equity5_source=. if admin_participant_id==68339
	replace capital_equity5_date=. if admin_participant_id==68339	
	replace capital_equity5_amount=. if admin_participant_id==68339
	replace capital_equity5_purpose="" if admin_participant_id==68339
	replace capital_equity5_researchdev=. if admin_participant_id==68339
	replace capital_equity5_involvement=. if admin_participant_id==68339
	replace capital_equity5_verifiable=. if admin_participant_id==68339
	
	replace capital_equity=2 if admin_participant_id==68339

	
	replace capital_grant2="" if admin_participant_id==67694  // respondent entered amount on the counts
	replace capital_grant2_source=. if admin_participant_id==67694	
	replace capital_grant2_date=. if admin_participant_id==67694	
	replace capital_grant2_value=. if admin_participant_id==67694		
	replace capital_grant2_purpose="" if admin_participant_id==67694	
	replace capital_grant2_researchdev=. if admin_participant_id==67694	
	replace capital_grant2_involvement=. if admin_participant_id==67694		
	replace capital_grant2_verifiable=. if admin_participant_id==67694	
	
	replace capital_grant3="" if admin_participant_id==67694		
	replace capital_grant3_source=. if admin_participant_id==67694		
	replace capital_grant3_date=. if admin_participant_id==67694	
	replace capital_grant3_value=. if admin_participant_id==67694		
	replace capital_grant3_purpose="" if admin_participant_id==67694	
	replace capital_grant3_researchdev=. if admin_participant_id==67694	
	replace capital_grant3_involvement=. if admin_participant_id==67694		
	replace capital_grant3_verifiable=. if admin_participant_id==67694	
	
	replace capital_grant4="" if admin_participant_id==67694		
	replace capital_grant4_source=. if admin_participant_id==67694	
	replace capital_grant4_date=. if admin_participant_id==67694	
	replace capital_grant4_value=. if admin_participant_id==67694		
	replace capital_grant4_purpose="" if admin_participant_id==67694		
	replace capital_grant4_researchdev=. if admin_participant_id==67694	
	replace capital_grant4_involvement=. if admin_participant_id==67694		
	replace capital_grant4_verifiable=. if admin_participant_id==67694	
	
	replace capital_grant5="" if admin_participant_id==67694	
	replace capital_grant5_source=. if admin_participant_id==67694		
	replace capital_grant5_date=. if admin_participant_id==67694	
	replace capital_grant5_value=. if admin_participant_id==67694		
	replace capital_grant5_purpose="" if admin_participant_id==67694	
	replace capital_grant5_researchdev=. if admin_participant_id==67694	
	replace capital_grant5_involvement=. if admin_participant_id==67694		
	replace capital_grant5_verifiable=. if admin_participant_id==67694	

	replace capital_grants=1 if admin_participant_id==67694

	
	replace capital_grant2="" if admin_participant_id==68309  // respondent entered amount on the counts
	replace capital_grant2_source=. if admin_participant_id==68309	
	replace capital_grant2_date=. if admin_participant_id==68309	
	replace capital_grant2_value=. if admin_participant_id==68309		
	replace capital_grant2_purpose="" if admin_participant_id==68309	
	replace capital_grant2_researchdev=. if admin_participant_id==68309	
	replace capital_grant2_involvement=. if admin_participant_id==68309		
	replace capital_grant2_verifiable=. if admin_participant_id==68309	
	
	replace capital_grant3="" if admin_participant_id==68309		
	replace capital_grant3_source=. if admin_participant_id==68309		
	replace capital_grant3_date=. if admin_participant_id==68309	
	replace capital_grant3_value=. if admin_participant_id==68309		
	replace capital_grant3_purpose="" if admin_participant_id==68309	
	replace capital_grant3_researchdev=. if admin_participant_id==68309	
	replace capital_grant3_involvement=. if admin_participant_id==68309		
	replace capital_grant3_verifiable=. if admin_participant_id==68309	
	
	replace capital_grant4="" if admin_participant_id==68309		
	replace capital_grant4_source=. if admin_participant_id==68309	
	replace capital_grant4_date=. if admin_participant_id==68309	
	replace capital_grant4_value=. if admin_participant_id==68309		
	replace capital_grant4_purpose="" if admin_participant_id==68309		
	replace capital_grant4_researchdev=. if admin_participant_id==68309	
	replace capital_grant4_involvement=. if admin_participant_id==68309		
	replace capital_grant4_verifiable=. if admin_participant_id==68309	
	
	replace capital_grant5="" if admin_participant_id==68309	
	replace capital_grant5_source=. if admin_participant_id==68309		
	replace capital_grant5_date=. if admin_participant_id==68309	
	replace capital_grant5_value=. if admin_participant_id==68309		
	replace capital_grant5_purpose="" if admin_participant_id==68309	
	replace capital_grant5_researchdev=. if admin_participant_id==68309	
	replace capital_grant5_involvement=. if admin_participant_id==68309		
	replace capital_grant5_verifiable=. if admin_participant_id==68309	

	replace capital_grants=1 if admin_participant_id==68309
	
	
	replace capital_grant2="" if admin_participant_id==68139  // respondent entered amount on the counts
	replace capital_grant2_source=. if admin_participant_id==68139	
	replace capital_grant2_date=. if admin_participant_id==68139	
	replace capital_grant2_value=. if admin_participant_id==68139		
	replace capital_grant2_purpose="" if admin_participant_id==68139	
	replace capital_grant2_researchdev=. if admin_participant_id==68139	
	replace capital_grant2_involvement=. if admin_participant_id==68139		
	replace capital_grant2_verifiable=. if admin_participant_id==68139	
	
	replace capital_grant3="" if admin_participant_id==68139		
	replace capital_grant3_source=. if admin_participant_id==68139		
	replace capital_grant3_date=. if admin_participant_id==68139	
	replace capital_grant3_value=. if admin_participant_id==68139		
	replace capital_grant3_purpose="" if admin_participant_id==68139	
	replace capital_grant3_researchdev=. if admin_participant_id==68139	
	replace capital_grant3_involvement=. if admin_participant_id==68139		
	replace capital_grant3_verifiable=. if admin_participant_id==68139	
	
	replace capital_grant4="" if admin_participant_id==68139		
	replace capital_grant4_source=. if admin_participant_id==68139	
	replace capital_grant4_date=. if admin_participant_id==68139	
	replace capital_grant4_value=. if admin_participant_id==68139		
	replace capital_grant4_purpose="" if admin_participant_id==68139		
	replace capital_grant4_researchdev=. if admin_participant_id==68139	
	replace capital_grant4_involvement=. if admin_participant_id==68139		
	replace capital_grant4_verifiable=. if admin_participant_id==68139	
	
	replace capital_grant5="" if admin_participant_id==68139	
	replace capital_grant5_source=. if admin_participant_id==68139		
	replace capital_grant5_date=. if admin_participant_id==68139	
	replace capital_grant5_value=. if admin_participant_id==68139		
	replace capital_grant5_purpose="" if admin_participant_id==68139	
	replace capital_grant5_researchdev=. if admin_participant_id==68139	
	replace capital_grant5_involvement=. if admin_participant_id==68139		
	replace capital_grant5_verifiable=. if admin_participant_id==68139	

	replace capital_grants=1 if admin_participant_id==68139
    forval i = 2/5 {
    
    replace capital_grant`i'="" if admin_participant_id==68139  
    replace capital_grant`i'_source=. if admin_participant_id==68139
   	replace capital_grant`i'_source_other="" if admin_participant_id==68139
	replace capital_grant`i'_date=. if admin_participant_id==68139	
	replace capital_grant`i'_value=. if admin_participant_id==68139	
	replace capital_grant`i'_purpose="" if admin_participant_id==68139
	replace capital_grant`i'_researchdev=. if admin_participant_id==68139
	replace capital_grant`i'_involvement=. if admin_participant_id==68139
	replace capital_grant`i'_verifiable=. if admin_participant_id==68139
     }
        
       
    replace capital_equity=5  if admin_participant_id==68084 
        
   
    replace capital_equity=5  if admin_participant_id==68137 
 
 
    replace capital_equity= 2  if admin_participant_id== 68094
    forval i = 3/5 {

    replace capital_equity`i'="" if admin_participant_id==68094  
	replace capital_equity`i'_source=. if admin_participant_id==68094
    replace capital_equity`i'_source_other="" if admin_participant_id==68094
	replace capital_equity`i'_date=. if admin_participant_id==68094	
	replace capital_equity`i'_amount=. if admin_participant_id==68094	
	replace capital_equity`i'_purpose="" if admin_participant_id==68094
	replace capital_equity`i'_researchdev=. if admin_participant_id==68094
	replace capital_equity`i'_involvement=. if admin_participant_id==68094
	replace capital_equity`i'_verifiable=. if admin_participant_id==68094
    }
    replace capital_types = "2" if admin_participant_id==68094 
    replace capital_types_grant = 0 if admin_participant_id==68094 
    
    
    replace capital_loans = 2 if admin_participant_id== 68795	
    forval i = 3/10 {

    replace capital_loan`i'="" if admin_participant_id== 68795  
	replace capital_loan`i'_source=. if admin_participant_id== 68795
	replace capital_loan`i'_source_other="" if admin_participant_id== 68795
	replace capital_loan`i'_date=. if admin_participant_id== 68795	
	replace capital_loan`i'_amount=. if admin_participant_id== 68795	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68795
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68795
	replace capital_loan`i'_status=. if admin_participant_id== 68795
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68795
    }      
    replace capital_equity = 0 if admin_participant_id== 68795	
    forval i = 1/5 {

    replace capital_equity`i'="" if admin_participant_id==68795  
	replace capital_equity`i'_source=. if admin_participant_id==68795
    replace capital_equity`i'_source_other="" if admin_participant_id==68795
	replace capital_equity`i'_date=. if admin_participant_id==68795	
	replace capital_equity`i'_amount=. if admin_participant_id==68795	
	replace capital_equity`i'_purpose="" if admin_participant_id==68795
	replace capital_equity`i'_researchdev=. if admin_participant_id==68795
	replace capital_equity`i'_involvement=. if admin_participant_id==68795
	replace capital_equity`i'_verifiable=. if admin_participant_id==68795
    }
    *Ojo con 68795 ver notes*
    replace capital_types = "1" if admin_participant_id==68795 
    replace capital_types_equity = 0 if admin_participant_id==68795 
    
	
    replace capital_grants = 1 if admin_participant_id== 67996	
    forval i = 2/5 {
    
    replace capital_grant`i'="" if admin_participant_id== 67996  
	replace capital_grant`i'_source=. if admin_participant_id== 67996
   	replace capital_grant`i'_source_other="" if admin_participant_id== 67996
	replace capital_grant`i'_date=. if admin_participant_id== 67996	
	replace capital_grant`i'_value=. if admin_participant_id== 67996	
	replace capital_grant`i'_purpose="" if admin_participant_id== 67996
	replace capital_grant`i'_researchdev=. if admin_participant_id== 67996
	replace capital_grant`i'_involvement=. if admin_participant_id== 67996
	replace capital_grant`i'_verifiable=. if admin_participant_id== 67996
     }
     

    replace capital_grants = 2 if admin_participant_id== 68021
    forval i = 3/5 {
    
    replace capital_grant`i'="" if admin_participant_id== 68021  
	replace capital_grant`i'_source=. if admin_participant_id== 68021
   	replace capital_grant`i'_source_other="" if admin_participant_id== 68021
	replace capital_grant`i'_date=. if admin_participant_id== 68021	
	replace capital_grant`i'_value=. if admin_participant_id== 68021	
	replace capital_grant`i'_purpose="" if admin_participant_id== 68021
	replace capital_grant`i'_researchdev=. if admin_participant_id== 68021
	replace capital_grant`i'_involvement=. if admin_participant_id== 68021
	replace capital_grant`i'_verifiable=. if admin_participant_id== 68021
     }
    replace capital_equity= 2 if admin_participant_id== 68021
    forval i = 3/5 {

    replace capital_equity`i'="" if admin_participant_id== 68021  
	replace capital_equity`i'_source=. if admin_participant_id== 68021
	replace capital_equity`i'_source_other="" if admin_participant_id== 68021
	replace capital_equity`i'_date=. if admin_participant_id== 68021	
	replace capital_equity`i'_amount=. if admin_participant_id== 68021	
	replace capital_equity`i'_purpose="" if admin_participant_id== 68021
	replace capital_equity`i'_researchdev=. if admin_participant_id== 68021
	replace capital_equity`i'_involvement=. if admin_participant_id== 68021
	replace capital_equity`i'_verifiable=. if admin_participant_id== 68021
    }           
    replace capital_equity1_amount= 266400 if admin_participant_id== 68021
    replace capital_equity2_amount= 1000000 if admin_participant_id== 68021
    *Ojo con 68021 ver notes*
    
    
    replace capital_grants = 1 if admin_participant_id== 68067
    forval i = 2/5 {
    
    replace capital_grant`i'="" if admin_participant_id== 68067	
	replace capital_grant`i'_source=. if admin_participant_id== 68067
	replace capital_grant`i'_source_other="" if admin_participant_id== 68067
	replace capital_grant`i'_date=. if admin_participant_id== 68067	
	replace capital_grant`i'_value=. if admin_participant_id== 68067		
	replace capital_grant`i'_purpose="" if admin_participant_id== 68067	
	replace capital_grant`i'_researchdev=. if admin_participant_id== 68067	
	replace capital_grant`i'_involvement=. if admin_participant_id== 68067		
	replace capital_grant`i'_verifiable=. if admin_participant_id== 68067	
    }
    
    
    replace capital_grants = 1 if admin_participant_id== 67679
    forval i = 2/5 {
    
    replace capital_grant`i'="" if admin_participant_id== 67679	
	replace capital_grant`i'_source=. if admin_participant_id== 67679
	replace capital_grant`i'_source_other="" if admin_participant_id== 67679  
	replace capital_grant`i'_date=. if admin_participant_id== 67679	
	replace capital_grant`i'_value=. if admin_participant_id== 67679		
	replace capital_grant`i'_purpose="" if admin_participant_id== 67679	
	replace capital_grant`i'_researchdev=. if admin_participant_id== 67679	
	replace capital_grant`i'_involvement=. if admin_participant_id== 67679		
	replace capital_grant`i'_verifiable=. if admin_participant_id== 67679	
    }
    
    
    replace capital_equity= 2 if admin_participant_id== 68101
    forval i = 3/5 {

    replace capital_equity`i'="" if admin_participant_id== 68101  
	replace capital_equity`i'_source=. if admin_participant_id== 68101
	replace capital_equity`i'_source_other="" if admin_participant_id== 68101
	replace capital_equity`i'_date=. if admin_participant_id== 68101	
	replace capital_equity`i'_amount=. if admin_participant_id== 68101	
	replace capital_equity`i'_purpose="" if admin_participant_id== 68101
	replace capital_equity`i'_researchdev=. if admin_participant_id== 68101
	replace capital_equity`i'_involvement=. if admin_participant_id== 68101
	replace capital_equity`i'_verifiable=. if admin_participant_id== 68101
    }

    replace capital_loans = 0 if admin_participant_id == 68172
    forval i = 1/10 {

    replace capital_loan`i'="" if admin_participant_id== 68172  
	replace capital_loan`i'_source=. if admin_participant_id== 68172
	replace capital_loan`i'_source_other="" if admin_participant_id== 68172
	replace capital_loan`i'_date=. if admin_participant_id== 68172	
	replace capital_loan`i'_amount=. if admin_participant_id== 68172	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68172
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68172
	replace capital_loan`i'_status=. if admin_participant_id== 68172
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68172
    }
    *Ojo con 68172 ver notes*
    replace capital_types = "" if admin_participant_id== 68172 
    replace capital_types_loan = 0 if admin_participant_id== 68172 
    
    
    replace capital_loans = 3 if admin_participant_id == 68173
    forval i = 4/10 {

    replace capital_loan`i'="" if admin_participant_id== 68172  
	replace capital_loan`i'_source=. if admin_participant_id== 68172
	replace capital_loan`i'_source_other="" if admin_participant_id== 68172
	replace capital_loan`i'_date=. if admin_participant_id== 68172	
	replace capital_loan`i'_amount=. if admin_participant_id== 68172	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68172
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68172
	replace capital_loan`i'_status=. if admin_participant_id== 68172
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68172
    }
    
    
    replace capital_loans = 3 if admin_participant_id == 68432
    forval i = 4/10 {

    replace capital_loan`i'="" if admin_participant_id== 68432  
	replace capital_loan`i'_source=. if admin_participant_id== 68432
	replace capital_loan`i'_source_other="" if admin_participant_id== 68432
	replace capital_loan`i'_date=. if admin_participant_id== 68432	
	replace capital_loan`i'_amount=. if admin_participant_id== 68432	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68432
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68432
	replace capital_loan`i'_status=. if admin_participant_id== 68432
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68432
    }    

    
    replace capital_loans=6  if admin_participant_id==68870
    forval i = 7/10 {

    replace capital_loan`i'="" if admin_participant_id== 68870  
	replace capital_loan`i'_source=. if admin_participant_id== 68870
	replace capital_loan`i'_source_other="" if admin_participant_id== 68870
	replace capital_loan`i'_date=. if admin_participant_id== 68870	
	replace capital_loan`i'_amount=. if admin_participant_id== 68870	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68870
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68870
	replace capital_loan`i'_status=. if admin_participant_id== 68870
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68870
    } 
    
    
    replace capital_loans=3  if admin_participant_id==68129
    forval i = 4/10 {

    replace capital_loan`i'="" if admin_participant_id== 68129  
	replace capital_loan`i'_source=. if admin_participant_id== 68129
	replace capital_loan`i'_source_other="" if admin_participant_id== 68129
	replace capital_loan`i'_date=. if admin_participant_id== 68129	
	replace capital_loan`i'_amount=. if admin_participant_id== 68129	
	replace capital_loan`i'_purpose="" if admin_participant_id== 68129
	replace capital_loan`i'_researchdev=. if admin_participant_id== 68129
	replace capital_loan`i'_status=. if admin_participant_id== 68129
	replace capital_loan`i'_verifiable=. if admin_participant_id== 68129
    }  
    
   
    replace capital_grants = 3 if admin_participant_id== 68010
    forval i = 2/5 {
    
    replace capital_grant`i'="" if admin_participant_id== 68010	
	replace capital_grant`i'_source=. if admin_participant_id== 68010
	replace capital_grant`i'_source_other="" if admin_participant_id== 68010  
	replace capital_grant`i'_date=. if admin_participant_id== 68010	
	replace capital_grant`i'_value=. if admin_participant_id== 68010		
	replace capital_grant`i'_purpose="" if admin_participant_id== 68010	
	replace capital_grant`i'_researchdev=. if admin_participant_id== 68010	
	replace capital_grant`i'_involvement=. if admin_participant_id== 68010		
	replace capital_grant`i'_verifiable=. if admin_participant_id== 68010	
    }    
    
    *Falta grant 68144
    
        
    replace capital_equity= 3 if admin_participant_id== 67819
    forval i = 4/5 {

    replace capital_equity`i'="" if admin_participant_id== 67819  
	replace capital_equity`i'_source=. if admin_participant_id== 67819
	replace capital_equity`i'_source_other="" if admin_participant_id== 67819
	replace capital_equity`i'_date=. if admin_participant_id== 67819	
	replace capital_equity`i'_amount=. if admin_participant_id== 67819	
	replace capital_equity`i'_purpose="" if admin_participant_id== 67819
	replace capital_equity`i'_researchdev=. if admin_participant_id== 67819
	replace capital_equity`i'_involvement=. if admin_participant_id== 67819
	replace capital_equity`i'_verifiable=. if admin_participant_id== 67819
    }
    replace capital_types = "2" if admin_participant_id== 67819 
    replace capital_types_grant = 0 if admin_participant_id== 67819 
    replace capital_equity1_amount = 60000 if admin_participant_id== 67819 
    
    
    
    
    ******  Data cleaning, test/duplicate IDs  
    drop if admin_participant_id==12345 //test entry
    drop if admin_participant_id==68056 & admin_consent==0 //double entry
    
     
    ******  Data cleaning, profit/sales see baseline tracking sheet for notes

    destring profits_last_year, replace force
    replace profits_last_year = 1000000 if admin_participant_id== 67679
    replace profits_last_month_scale = 1 if admin_participant_id== 67679
        
    replace profits_last_month = 390 if admin_participant_id== 67662
    
    replace sales_last_month = 9000 if admin_participant_id== 67725
    replace sales_last_month_scale =  1 if admin_participant_id== 67725
    
    replace sales_last_month = 0 if admin_participant_id== 67932
    replace sales_last_month_scale = 0 if admin_participant_id== 67932
    replace sales_typical_month = 0 if admin_participant_id== 67932
    replace sales_typical_month_scale = 0 if admin_participant_id== 67932
    replace bo_transactions_frequency = 0 if admin_participant_id== 67932
    *Ojo con 67932 ver notes*
    replace sales_last_month = 60000 if admin_participant_id== 68886
    replace sales_last_month_scale = 2 if admin_participant_id== 68886    
    replace profits_last_month = 25000 if admin_participant_id== 68886
    replace profits_last_month_scale = 3 if admin_participant_id== 68886
    
    replace sales_last_month = 35000 if admin_participant_id== 68887

    replace profits_last_month = 13840 if admin_participant_id== 67996
    
    replace profits_last_month_scale = 1 if admin_participant_id== 68329
    replace profits_typical_month_scale = 1 if admin_participant_id== 68329    
    replace profits_last_year_scale = 12 if admin_participant_id== 68329 

    replace profits_typical_month_scale = 8 if admin_participant_id== 68466    
    replace profits_last_year_scale = 8 if admin_participant_id== 68466 

    replace profits_last_year_scale = 2 if admin_participant_id== 68378

    replace profits_typical_month_scale = 3 if admin_participant_id== 68296    
    replace profits_last_year_scale = 3 if admin_participant_id== 68296
    
    replace profits_last_month = 2051 if admin_participant_id== 68147
    
    replace profits_last_month = 0 if admin_participant_id== 68432
    replace profits_last_month_scale = 0 if admin_participant_id== 68432
    
    replace profits_last_year = 0 if admin_participant_id== 68417
    *Ganancias fueron reinvertidas
    
    replace bo_transactions_frequency = 0 if admin_participant_id== 67656
    
    *Ojo con 67872 ver notes*
    replace sales_last_month = 25000 if admin_participant_id== 67872
    replace sales_last_month_scale = 1 if admin_participant_id== 67872    
    replace profits_last_month = 18000 if admin_participant_id== 67872
    replace profits_last_month_scale = 2 if admin_participant_id== 67872
    
               
    ******  Data cleaning, dates see baseline tracking sheet for notes
    replace cust_impt1_first_date = td(01mar2017) if admin_participant_id== 68887


    ******  Data cleaning, assets see baseline tracking sheet for notes
    replace asset_land_value = 1000000 if admin_participant_id==68021    
    replace asset_itech_value = 8250 if admin_participant_id== 68101
    replace assets_total = 1552500 if admin_participant_id== 68101
    
    
    replace asset_wc3_money_value = 0 if admin_participant_id== 68145
    replace assets_total = 100000 if admin_participant_id== 68145
    
    replace assets_total = 0 if admin_participant_id== 68902
    
    *Ojo con 67872 ver notes*
    replace asset_ip_value = 3360000 if admin_participant_id== 67872

           
    ******  Data cleaning, other see baseline tracking sheet for notes
    replace emp_use_computer = 7 if admin_participant_id== 68056
       
    replace emp_partners = 3 if admin_participant_id== 68145
    replace emp_executives = 0 if admin_participant_id== 68145
    replace emp_fulltime = 0 if admin_participant_id== 68145
    replace emp_parttime = 0 if admin_participant_id== 68145

    replace bo_transactions_frequency = 0 if admin_participant_id== 68417
    
    replace bo_transactions_frequency = 0 if admin_participant_id== 68461
     
    
    ******  Data cleaning, business_names, respondent_names, respondent_position,
    **cust_total_lastyear
    
     replace admin_business_name = strproper(admin_business_name)
     cleanchars, in("sac Sac SAC") out(S.A.C.) vval 
     cleanchars, in("eirl Eirl E.I.R.L.") out(EIRL) vval 
     
     replace admin_respondent_name = strproper(admin_respondent_name)
     replace admin_contact_name = strproper(admin_contact_name)
     replace bo_biz_location_street = strproper(bo_biz_location_street)
     
     
     replace admin_contact_name = "" if admin_participant_id==68383 
     replace admin_contact_name = "" if admin_participant_id==68550
     replace admin_contact_name = "" if admin_participant_id==68026
     replace admin_contact_name = "" if admin_participant_id==68295
     
     
    label define cust 0 "0" 1 "Entre_1__y_50" 2 "Entre_51_y_100" ///
    3 "Entre_101_y_150" 4 "Entre_151_y_200" 5 "Entre_201_y_250" 6 "Entre_251_y_300" ///
    7 "Entre_301_y_350" 8 "Entre_351_y_400" 9 "Entre_451_y_500" 10 "más_de_500"    
    encode cust_total_lastyear, g(cust_total_lastyear_2) l(cust)
    drop cust_total_lastyear
    rename cust_total_lastyear_2 cust_total_lastyear
    order cust_total_lastyear, b(debt_govt_institution)
     
     
     gen admin_respondent_position2 = ""
     replace admin_respondent_position2 = "Fundadora y Gerente General" if admin_participant_id== 67593
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67627
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67662
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67690
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 67694
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67708
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67724
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67725
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67746
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67770
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67801
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67872
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67932
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67944
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67947
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67965
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68006
    replace admin_respondent_position2 = "Fundador y Gerente General" if admin_participant_id== 68011
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68016
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68040
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68070
    replace admin_respondent_position2 = "Gerente General- Director técnico" if admin_participant_id== 68139
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68164
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68175
    replace admin_respondent_position2 = "CEO y fundador" if admin_participant_id== 68187
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68228
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68303
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68309
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68314
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68323
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68336
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68339
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68359
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68378
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68383
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68406
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68429
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68454
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68466
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68484
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68518
    replace admin_respondent_position2 = "Gerente general y fundador" if admin_participant_id== 68536
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68550
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68676
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68698
    replace admin_respondent_position2 = "CEO y fundador" if admin_participant_id== 68793
    replace admin_respondent_position2 = "Gerente general y fundador" if admin_participant_id== 68835
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68886
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68887
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 12345
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68795
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68472
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67996
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68010
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68021
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68838
    replace admin_respondent_position2 = "Desarrollo de producto e investigación" if admin_participant_id== 68713
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68727
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67773
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68013
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68144
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68695
    replace admin_respondent_position2 = "Gerente general y fundador" if admin_participant_id== 68129
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68067
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68329
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68277
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68471
    replace admin_respondent_position2 = "Chief Market Officer / Cofundador" if admin_participant_id== 68072
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68502
    replace admin_respondent_position2 = "Gerente General y Representante Legal" if admin_participant_id== 68790
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67749
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68137
    replace admin_respondent_position2 = "Coordinador de Proyectos de Innovación" if admin_participant_id== 68282
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67679
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67824
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67875
    replace admin_respondent_position2 = "" if admin_participant_id== 67918
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67973
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 67987
    replace admin_respondent_position2 = "" if admin_participant_id== 68023
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68026
    replace admin_respondent_position2 = "CEO y Fundador de la empresa" if admin_participant_id== 68084
    replace admin_respondent_position2 = "" if admin_participant_id== 68094
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68101
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68132
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68147
    replace admin_respondent_position2 = "CEO" if admin_participant_id== 68149
    replace admin_respondent_position2 = "Gerente general" if admin_participant_id== 68172
    replace admin_respondent_position2 = "Gerente general y co-fundador" if admin_participant_id== 68173
    replace admin_respondent_position2 = "CEO & CTO" if admin_participant_id== 68192
    replace admin_respondent_position2 = "" if admin_participant_id== 68295
    replace admin_respondent_position2 = "CEO y fundador" if admin_participant_id== 68296
    replace admin_respondent_position2 = "General Manager" if admin_participant_id== 68432
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68448
    replace admin_respondent_position2 = "CEO y co-fundador" if admin_participant_id== 68503
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68516
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68870
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68902
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67568
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67656
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67720
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67813
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67817
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67819
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67859
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 67963
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68002
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68008
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68032
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68056
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68145
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68394
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68417
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68461
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68867
    replace admin_respondent_position2 = "Gerente General" if admin_participant_id== 68889
    
     
    order admin_respondent_position2, a(admin_respondent_name)

    gen admin_contact_position2 = ""
    
    replace admin_contact_position2 = "Administradora" if admin_participant_id== 67593
    replace admin_contact_position2 = "Socia, sub gerente, jefe de comercialización, diseñadora y Community Manager" if admin_participant_id== 67627
    replace admin_contact_position2 = "Investigación y Desarrollo de Polimeros" if admin_participant_id== 67662
    replace admin_contact_position2 = "Responsable administrativo y de producto" if admin_participant_id== 67690
    replace admin_contact_position2 = "Asesor Técnico" if admin_participant_id== 67694
    replace admin_contact_position2 = "Socio" if admin_participant_id== 67708
    replace admin_contact_position2 = "CTO Perú" if admin_participant_id== 67724
    replace admin_contact_position2 = "Gerente de investigación y operaciones" if admin_participant_id== 67725
    replace admin_contact_position2 = "CTO" if admin_participant_id== 67746
    replace admin_contact_position2 = "Gerente de Operaciónes" if admin_participant_id== 67770
    replace admin_contact_position2 = "Director comercial" if admin_participant_id== 67801
    replace admin_contact_position2 = "" if admin_participant_id== 67872
    replace admin_contact_position2 = "Administrador (Zona Iquitos)" if admin_participant_id== 67932
    replace admin_contact_position2 = "Analista de marketing" if admin_participant_id== 67944
    replace admin_contact_position2 = "CTO" if admin_participant_id== 67947
    replace admin_contact_position2 = "COO" if admin_participant_id== 67965
    replace admin_contact_position2 = "Socio" if admin_participant_id== 68006
    replace admin_contact_position2 = "Gerente de Administracion" if admin_participant_id== 68011
    replace admin_contact_position2 = "CMO y CFO" if admin_participant_id== 68016
    replace admin_contact_position2 = "COO" if admin_participant_id== 68040
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68070
    replace admin_contact_position2 = "" if admin_participant_id== 68139
    replace admin_contact_position2 = "Encargado de Operaciones, Producción, Despacho y Ventas de Productos." if admin_participant_id== 68164
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68175
    replace admin_contact_position2 = "" if admin_participant_id== 68187
    replace admin_contact_position2 = "Tecnología" if admin_participant_id== 68228
    replace admin_contact_position2 = "Sub Gerente" if admin_participant_id== 68303
    replace admin_contact_position2 = "Gerente de Investigación" if admin_participant_id== 68309
    replace admin_contact_position2 = "Gerente de Finanzas" if admin_participant_id== 68314
    replace admin_contact_position2 = "Administración y finanzas" if admin_participant_id== 68323
    replace admin_contact_position2 = "Gerente Comercial" if admin_participant_id== 68336
    replace admin_contact_position2 = "Socio" if admin_participant_id== 68339
    replace admin_contact_position2 = "Gerente de Investigación, Innovación y Desarrollo" if admin_participant_id== 68359
    replace admin_contact_position2 = "Administradora" if admin_participant_id== 68378
    replace admin_contact_position2 = "" if admin_participant_id== 68383
    replace admin_contact_position2 = "Gerente Comercial" if admin_participant_id== 68406
    replace admin_contact_position2 = "CO-CEO" if admin_participant_id== 68429
    replace admin_contact_position2 = "Administrador" if admin_participant_id== 68454
    replace admin_contact_position2 = "IT developer" if admin_participant_id== 68466
    replace admin_contact_position2 = "Project Manager" if admin_participant_id== 68484
    replace admin_contact_position2 = "" if admin_participant_id== 68518
    replace admin_contact_position2 = "Fundador y Jefe de Comunicaciones e Identidad Institucional" if admin_participant_id== 68536
    replace admin_contact_position2 = "Líder de producción" if admin_participant_id== 68550
    replace admin_contact_position2 = "CFO" if admin_participant_id== 68676
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68698
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68793
    replace admin_contact_position2 = "Gerente Administrativo y Co-fundador" if admin_participant_id== 68835
    replace admin_contact_position2 = "Director Comercial" if admin_participant_id== 68886
    replace admin_contact_position2 = "Gerente del área de tecnología y proyectos" if admin_participant_id== 68887
    replace admin_contact_position2 = "" if admin_participant_id== 12345
    replace admin_contact_position2 = "COO" if admin_participant_id== 68795
    replace admin_contact_position2 = "Directora de Terapias y Socia" if admin_participant_id== 68472
    replace admin_contact_position2 = "Representante Comercial" if admin_participant_id== 67996
    replace admin_contact_position2 = "Gerente financiera" if admin_participant_id== 68010
    replace admin_contact_position2 = "" if admin_participant_id== 68021
    replace admin_contact_position2 = "Gerente Comercial" if admin_participant_id== 68838
    replace admin_contact_position2 = "Investigación" if admin_participant_id== 68713
    replace admin_contact_position2 = "Administradora" if admin_participant_id== 68727
    replace admin_contact_position2 = "Coordinador I+D+i" if admin_participant_id== 67773
    replace admin_contact_position2 = "Gerente comercial y administradora" if admin_participant_id== 68013
    replace admin_contact_position2 = "Coordinadora de Proyectos" if admin_participant_id== 68144
    replace admin_contact_position2 = "Jefe de Marca" if admin_participant_id== 68695
    replace admin_contact_position2 = "Administradora" if admin_participant_id== 68129
    replace admin_contact_position2 = "Profesional en Comercialización" if admin_participant_id== 68067
    replace admin_contact_position2 = "Director" if admin_participant_id== 68329
    replace admin_contact_position2 = "" if admin_participant_id== 68277
    replace admin_contact_position2 = "COO" if admin_participant_id== 68471
    replace admin_contact_position2 = "CEO y Co-Fundador" if admin_participant_id== 68072
    replace admin_contact_position2 = "Gerente de Operaciones" if admin_participant_id== 68502
    replace admin_contact_position2 = "Gerente Administración y Finanzas" if admin_participant_id== 68790
    replace admin_contact_position2 = "" if admin_participant_id== 67749
    replace admin_contact_position2 = "Jefe de Operaciones" if admin_participant_id== 68137
    replace admin_contact_position2 = "Gerente General" if admin_participant_id== 68282
    replace admin_contact_position2 = "Representante Legal" if admin_participant_id== 67679
    replace admin_contact_position2 = "Gerente de desarrollo de negocios" if admin_participant_id== 67824
    replace admin_contact_position2 = "COO" if admin_participant_id== 67875
    replace admin_contact_position2 = "CTO" if admin_participant_id== 67918
    replace admin_contact_position2 = "COO" if admin_participant_id== 67973
    replace admin_contact_position2 = "COO" if admin_participant_id== 67987
    replace admin_contact_position2 = "Administradora de proyectos" if admin_participant_id== 68023
    replace admin_contact_position2 = "Representante en eventos" if admin_participant_id== 68026
    replace admin_contact_position2 = "COO" if admin_participant_id== 68084
    replace admin_contact_position2 = "Encargado del area de ventas" if admin_participant_id== 68094
    replace admin_contact_position2 = "Administrador contable" if admin_participant_id== 68101
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68132
    replace admin_contact_position2 = "" if admin_participant_id== 68147
    replace admin_contact_position2 = "COO" if admin_participant_id== 68149
    replace admin_contact_position2 = "" if admin_participant_id== 68172
    replace admin_contact_position2 = "Co-fundador, Representante Legal, Gerente de Producción en Campo y Relaciónes Comunitarias" if admin_participant_id== 68173
    replace admin_contact_position2 = "Coordinador pedagógico" if admin_participant_id== 68192
    replace admin_contact_position2 = "jefe de operaciones" if admin_participant_id== 68295
    replace admin_contact_position2 = "COO" if admin_participant_id== 68296
    replace admin_contact_position2 = "Administración y Gerente de Finanzas" if admin_participant_id== 68432
    replace admin_contact_position2 = "Jefe de ventas" if admin_participant_id== 68448
    replace admin_contact_position2 = "CTO y Co-fundador" if admin_participant_id== 68503
    replace admin_contact_position2 = "COO" if admin_participant_id== 68516
    replace admin_contact_position2 = "Gerente Comercial" if admin_participant_id== 68870
    replace admin_contact_position2 = "" if admin_participant_id== 68902
    replace admin_contact_position2 = "Responsable de Investigación e Innovación" if admin_participant_id== 67568
    replace admin_contact_position2 = "" if admin_participant_id== 67656
    replace admin_contact_position2 = "Responsable del Area de Estudios Ambientales" if admin_participant_id== 67720
    replace admin_contact_position2 = "" if admin_participant_id== 67813
    replace admin_contact_position2 = "" if admin_participant_id== 67817
    replace admin_contact_position2 = "CTO" if admin_participant_id== 67819
    replace admin_contact_position2 = "" if admin_participant_id== 67859
    replace admin_contact_position2 = "Gerente de Desarrollo de Producto" if admin_participant_id== 67963
    replace admin_contact_position2 = "" if admin_participant_id== 68002
    replace admin_contact_position2 = "" if admin_participant_id== 68008
    replace admin_contact_position2 = "" if admin_participant_id== 68032
    replace admin_contact_position2 = "Responsable de los sistemas de tecnologías de la información" if admin_participant_id== 68056
    replace admin_contact_position2 = "Asesor contable" if admin_participant_id== 68145
    replace admin_contact_position2 = "" if admin_participant_id== 68394
    replace admin_contact_position2 = "CTO" if admin_participant_id== 68417
    replace admin_contact_position2 = "Asistente de Gerencia" if admin_participant_id== 68461
    replace admin_contact_position2 = "" if admin_participant_id== 68867
    replace admin_contact_position2 = "Gerente de operaciones" if admin_participant_id== 68889


    order admin_contact_position2 , a(admin_contact_name)
    
    replace admin_contact_name = "Luis Torres Damas" if admin_participant_id== 68145
    replace admin_contact_email = "ltorresd@conssolid.pe" if admin_participant_id== 68145
    replace admin_contact_name = "Luz Terlinda De la Cruz rodriguez" if admin_participant_id== 68295
    

save "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Data check\04052020\CONCYTEC_FONDECYT_Encuesta_Linea_Base_clean_final.dta", replace

export delimited using "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Data check\04052020\CONCYTEC_FONDECYT_Encuesta_Linea_Base_CLEAN.csv", replace
    

    
        window stopbox rusure "Do you want to continue to run high frequency checks?`=char(13)'Yes=continue; No=stop here."
    window stopbox note "Good choice!"
    


*****************************************************************************************	 
	 *** RUN HIGH FREQUENCY CHECKS**

*****************************************************************************************
{

	global filename "Peru"                // change to the location of interest


	*keep if admin_survey_date==td(25mar2020)      // change to the date of interest
*********************************************************************************************	

		 
		 
** Set files		 
		 
		local hfc_file "$Dailyhfc_$filename$filedate.csv"
		destring admin_participant_id,replace


		export excel using  "$Dailyhfc_$filename$filedate.csv", replace
		
*fixing data
		foreach var of varlist _all{
			char `var'[charname] "`var'"
		}



		global biz_info "admin_participant_id  admin_respondent_name "



		duplicates tag admin_participant_id, generate(id_dup)
		
		listtab $biz_info  using `hfc_file' if id_dup==1, delimiter(",") replace headlines("Duplicate Respondent ID") headchars(charname) 



** Respondent haven't made a sale and sales not =0

		listtab $biz_info  bo_transactions_frequency sales_last_month profits_last_month if bo_transactions_frequency==0 & sales_last_month !=0,delimiter(",")appendto(`hfc_file') replace headlines("Respondent haven't made a sale and sales not 0") headchars(charname)

** Respondent with sales less than 100

 		listtab $biz_info  bo_transactions_frequency sales_last_month profits_last_month if sales_last_month <=100 ,delimiter(",")appendto(`hfc_file') replace headlines("Respondent with sales less than 100") headchars(charname)


**** Sales/Profit ratios for different business types
		
		destring sales_last_month sales_typical_month profits_last_month profits_typical_month, replace
		
		gen sales_profit_ratio = profits_last_month/sales_last_month
		
		listtab $biz_info sales_last_month profits_last_month   if sales_profit_ratio > .5 & bo_primary_how_BuyResell ==1, delimiter(",")appendto(`hfc_file') replace headlines("Resellers with sales/Profits off") headchars(charname)
		
		listtab $biz_info  sales_last_month profits_last_month if sales_profit_ratio > .75 & bo_primary_how_Manufacture ==1, delimiter(",")appendto(`hfc_file') replace headlines("Manufacturers with sales/Profits off") headchars(charname)
		
		listtab $biz_info  sales_last_month profits_last_month if sales_profit_ratio > .75 & bo_primary_how_Services ==1, delimiter(",")appendto(`hfc_file') replace headlines("service providers with sales/Profits off") headchars(charname)



	
	**** Checking outliers in sales and profits
	
	set trace on
			gen flag_outlier = 0
			foreach x in 1.5 3 {
			foreach var of varlist  sales_last_month profits_last_month  {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds 
			}
		}	
	
	

	**** Outliers in number of employees
	destring emp_total,replace
	drop flag_outlier
	gen flag_outlier = 0
		
		foreach x in 1.5 3 {
			foreach var of varlist emp_total {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds 
			}
		}		

		
	**** Outliers in asset value by asset groups

	drop flag_outlier
	gen flag_outlier = 0
	local asset asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value
		
		foreach var of local asset {
			destring `var',force replace
				foreach x in 1.5 3 {
						egen mean = mean(`var')
						egen sd = sd(`var')
						generate sds = (`var' - mean) / sd
						format mean sd sds %9.2f
						sort admin_participant_id
						char sd [charname] "SD"
						char sds [charname] "Standard SD"
						char mean [charname] "Mean"
						listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in op_`var'_value (`x' SDs from the mean):") headchars(charname)
						replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
						drop mean sd sds 
			}
		}		
	
	**** Checking outliers in stock value, materials value, and working capital
	
			drop flag_outlier
			gen flag_outlier = 0
			
			foreach x in 1.5 3 {
			foreach var of varlist asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value   {
				egen mean = mean(`var')
				egen sd = sd(`var')
				generate sds = (`var' - mean) / sd
				format mean sd sds %9.2f
				sort admin_participant_id
				char sd [charname] "SD"
				char sds [charname] "Standard SD"
				char mean [charname] "Mean"
				listtab $biz_info `var' mean sd sds if abs(sds) > `x' & !missing(sds), delimiter(",") appendto(`hfc_file') replace headlines("Displaying potential outliers in `var' (`x' SDs from the mean):") headchars(charname)
				replace flag_outlier = 1 if abs(sds) > `x' & !missing(sds)
				drop mean sd sds 
			}
		}	
	
	
	
	
	drop flag_outlier
	
	
	/*** Check answers text coded responses
	foreach var of varlist {
		tostring `var', replace
		replace `var'="" if `var'=="."
		listtab $biz_info `var' if `var' !="" , delimiter(",") appendto(`hfc_file') replace headlines(" "`var'" others") headchars(charname)
		}
*/

	
** Sales Scale does not correspond with the sales amount 	
	
	destring sales_last_month, replace
	
	replace sales_last_month=0 if sales_last_month==.
	
	gen sales_last_month_scale_dum= sales_last_month_scale
	order sales_last_month_scale_dum,after(sales_last_month_scale)
	tostring sales_last_month_scale_dum,replace           //values that will be used for comparison
	destring sales_last_month_scale_dum,replace
	
	

	gen sales_comparison =0
	replace sales_comparison =1 if sales_last_month	>=1 & sales_last_month <=50000
	replace sales_comparison =2 if sales_last_month	>=50001  & sales_last_month <= 100000 
	replace sales_comparison =3 if sales_last_month	>=100001 & sales_last_month <= 150000 
	replace sales_comparison =4 if sales_last_month	>=150001 & sales_last_month <= 200000 
	replace sales_comparison =5 if sales_last_month	>=200001 & sales_last_month <= 250000 
	replace sales_comparison =6 if sales_last_month	>=250001 & sales_last_month <= 300000 
	replace sales_comparison =7 if sales_last_month	>=300001 & sales_last_month <= 350000 
	replace sales_comparison =8 if sales_last_month	>=350001 & sales_last_month <= 400000 
	replace sales_comparison =9 if sales_last_month	>=400001  & sales_last_month <= 450000 
	replace sales_comparison =10 if sales_last_month >=450001  & sales_last_month <= 500000 
	replace sales_comparison =11 if sales_last_month >=500001  & sales_last_month <= 550000 
	replace sales_comparison =12 if sales_last_month >=550001  & sales_last_month <= 600000 
	replace sales_comparison =13 if sales_last_month >=600001  & sales_last_month <= 650000 
	replace sales_comparison =14 if sales_last_month >=650001  & sales_last_month <= 700000 
	replace sales_comparison =15 if sales_last_month >=700001  & sales_last_month <= 750000 
	replace sales_comparison =16 if sales_last_month >=750001  & sales_last_month <= 800000 
	replace sales_comparison =17 if sales_last_month >=800001  & sales_last_month <= 850000 
	replace sales_comparison =18 if sales_last_month >=850001  & sales_last_month <= 900000 
	replace sales_comparison =19 if sales_last_month >=900001  & sales_last_month <= 950000 
	replace sales_comparison =20 if sales_last_month >=950001  & sales_last_month <= 1000000 
	replace sales_comparison =21 if sales_last_month >= 1000001 
	
	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}

	
	listtab $biz_info   sales_last_month sales_last_month_scale_dum sales_comparison if sales_comparison !=sales_last_month_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Sales value and enumerator scale are different?") headchars(charname)
	
	listtab $biz_info  bo_primary_how sales_last_month  sales_typical_month   if sales_last_month - sales_typical_month >3000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and typical month have difference greater than 3K") headchars(charname)

	listtab $biz_info  bo_primary_how sales_last_month  sales_typical_month   if sales_last_month -sales_typical_month >3000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and Typical sales have huge differences") headchars(charname)
	
	
	
*Profit in scale does not align with profit value 
	cap drop profits_comparison
	gen profits_comparison =profits_last_month	
	replace profits_comparison=0 if profits_last_month <=0
	replace profits_comparison=1 if profits_last_month >=1 &  profits_last_month <= 10000
	replace profits_comparison=2 if profits_last_month >=10001 &  profits_last_month <= 20000
	replace profits_comparison=3 if profits_last_month >=20001 &  profits_last_month <= 30000
	replace profits_comparison=4 if profits_last_month >=30001 &  profits_last_month <= 40000
	replace profits_comparison=5 if profits_last_month >=40001 &  profits_last_month <= 50000
	replace profits_comparison=6 if profits_last_month >=50001 &  profits_last_month <= 60000
	replace profits_comparison=7 if profits_last_month >=60001 &  profits_last_month <= 70000
	replace profits_comparison=8 if profits_last_month >=70001 &  profits_last_month <= 80000
	replace profits_comparison=9 if profits_last_month >=80001 &  profits_last_month <= 90000
	replace profits_comparison=10 if profits_last_month >=90001 &  profits_last_month <= 100000
	replace profits_comparison=11 if profits_last_month >=100001 &  profits_last_month <= 110000
	replace profits_comparison=12 if profits_last_month >=110001 &  profits_last_month <= 120000
	replace profits_comparison=13 if profits_last_month >=120001 &  profits_last_month <= 130000
	replace profits_comparison=14 if profits_last_month >=130001 &  profits_last_month <= 140000
	replace profits_comparison=15 if profits_last_month >=140001 &  profits_last_month <= 150000
	replace profits_comparison=16 if profits_last_month >=150001 &  profits_last_month <= 160000
	replace profits_comparison=17 if profits_last_month >=160001 &  profits_last_month <= 170000
	replace profits_comparison=18 if profits_last_month >=170001 &  profits_last_month <= 180000
	replace profits_comparison=19 if profits_last_month >=180001 &  profits_last_month <= 190000
	replace profits_comparison=20 if profits_last_month >=190001 &  profits_last_month <= 200000
	replace profits_comparison=21  if profits_last_month >= 200001 &  profits_last_month !=.
	
	cap drop profits_last_month_scale_dum
	gen profits_last_month_scale_dum=profits_last_month_scale
	order profits_last_month_scale_dum, after (profits_last_month_scale)
	tostring profits_last_month_scale_dum,replace
	destring profits_last_month_scale_dum,replace
	
	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}
	
	listtab $biz_info profits_comparison profits_last_month_scale_dum profits_last_month  if profits_comparison !=profits_last_month_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Profit value and scale are off?") headchars(charname)
	
	listtab $biz_info profits_last_month  profits_typical_month   if profits_last_month - profits_typical_month>50000 & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Last Month sales and Typical sales have huge differences?") headchars(charname)

    
*Sales last year in scale does not align with sales value last year 
	destring sales_last_year, replace
	
	replace sales_last_year=0 if sales_last_year==.
	
	gen sales_last_year_scale_dum= sales_last_year_scale
	order sales_last_year_scale_dum,after(sales_last_year_scale)
	tostring sales_last_year_scale_dum,replace           //values that will be used for comparison
	destring sales_last_year_scale_dum,replace
    
    	gen sales_comparison_last =0
	replace sales_comparison_last =1 if sales_last_year	>=1 & sales_last_year <=50000
	replace sales_comparison_last =2 if sales_last_year	>=50001  & sales_last_year <= 100000 
	replace sales_comparison_last =3 if sales_last_year	>=100001 & sales_last_year <= 150000 
	replace sales_comparison_last =4 if sales_last_year	>=150001 & sales_last_year <= 200000 
	replace sales_comparison_last =5 if sales_last_year	>=200001 & sales_last_year <= 250000 
	replace sales_comparison_last =6 if sales_last_year	>=250001 & sales_last_year <= 300000 
	replace sales_comparison_last =7 if sales_last_year	>=300001 & sales_last_year <= 350000 
	replace sales_comparison_last =8 if sales_last_year	>=350001 & sales_last_year <= 400000 
	replace sales_comparison_last =9 if sales_last_year	>=400001  & sales_last_year <= 450000 
	replace sales_comparison_last =10 if sales_last_year >=450001  & sales_last_year <= 500000 
	replace sales_comparison_last =11 if sales_last_year >=500001  & sales_last_year <= 550000 
	replace sales_comparison_last =12 if sales_last_year >=550001  & sales_last_year <= 600000 
	replace sales_comparison_last =13 if sales_last_year >=600001  & sales_last_year <= 650000 
	replace sales_comparison_last =14 if sales_last_year >=650001  & sales_last_year <= 700000 
	replace sales_comparison_last =15 if sales_last_year >=700001  & sales_last_year <= 750000 
	replace sales_comparison_last =16 if sales_last_year >=750001  & sales_last_year <= 800000 
	replace sales_comparison_last =17 if sales_last_year >=800001  & sales_last_year <= 850000 
	replace sales_comparison_last =18 if sales_last_year >=850001  & sales_last_year <= 900000 
	replace sales_comparison_last =19 if sales_last_year >=900001  & sales_last_year <= 950000 
	replace sales_comparison_last =20 if sales_last_year >=950001  & sales_last_year <= 1000000 
	replace sales_comparison_last =21 if sales_last_year >= 1000001 
	
	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}

	
	listtab $biz_info   sales_last_year sales_last_year_scale_dum sales_comparison_last if sales_comparison_last !=sales_last_year_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Sales value and enumerator scale LAST YEAR are different?") headchars(charname)
	
    
    
*Profit last year in scale does not align with profit value last year 

	cap drop profits_comparison_last
	gen profits_comparison_last =profits_last_year	
	replace profits_comparison_last=0 if profits_last_year <=0
	replace profits_comparison_last=1 if profits_last_year >=1 &  profits_last_year <= 10000
	replace profits_comparison_last=2 if profits_last_year >=10001 &  profits_last_year <= 20000
	replace profits_comparison_last=3 if profits_last_year >=20001 &  profits_last_year <= 30000
	replace profits_comparison_last=4 if profits_last_year >=30001 &  profits_last_year <= 40000
	replace profits_comparison_last=5 if profits_last_year >=40001 &  profits_last_year <= 50000
	replace profits_comparison_last=6 if profits_last_year >=50001 &  profits_last_year <= 60000
	replace profits_comparison_last=7 if profits_last_year >=60001 &  profits_last_year <= 70000
	replace profits_comparison_last=8 if profits_last_year >=70001 &  profits_last_year <= 80000
	replace profits_comparison_last=9 if profits_last_year >=80001 &  profits_last_year <= 90000
	replace profits_comparison_last=10 if profits_last_year >=90001 &  profits_last_year <= 100000
	replace profits_comparison_last=11 if profits_last_year >=100001 &  profits_last_year <= 110000
	replace profits_comparison_last=12 if profits_last_year >=110001 &  profits_last_year <= 120000
	replace profits_comparison_last=13 if profits_last_year >=120001 &  profits_last_year <= 130000
	replace profits_comparison_last=14 if profits_last_year >=130001 &  profits_last_year <= 140000
	replace profits_comparison_last=15 if profits_last_year >=140001 &  profits_last_year <= 150000
	replace profits_comparison_last=16 if profits_last_year >=150001 &  profits_last_year <= 160000
	replace profits_comparison_last=17 if profits_last_year >=160001 &  profits_last_year <= 170000
	replace profits_comparison_last=18 if profits_last_year >=170001 &  profits_last_year <= 180000
	replace profits_comparison_last=19 if profits_last_year >=180001 &  profits_last_year <= 190000
	replace profits_comparison_last=20 if profits_last_year >=190001 &  profits_last_year <= 200000
	replace profits_comparison_last=21  if profits_last_year >= 200001 &  profits_last_year !=.
	
	cap drop profits_last_year_scale_dum
	gen profits_last_year_scale_dum=profits_last_year_scale
	order profits_last_year_scale_dum, after (profits_last_year_scale)
	tostring profits_last_year_scale_dum,replace
	destring profits_last_year_scale_dum,replace
	
	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}
	
	listtab $biz_info profits_comparison_last profits_last_year_scale_dum profits_last_year  if profits_comparison_last !=profits_last_year_scale_dum & bo_operational==1, delimiter(",") appendto(`hfc_file') replace headlines("Profit value and scale LAST YEAR are off?") headchars(charname)
	
	
**Calculated Assets doesn't equal survey totals	
	cap drop assets_total_Check
	local asset asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value
	foreach var of  local assets {
	destring `var', replace
	replace `var'=0 if `var'==. & bo_operational==1
	}

	egen assets_total_Check=rowtotal( asset_land_value asset_building_value asset_lgvehicle_value asset_smvehicle_value asset_machine_value asset_tools_value asset_itech_value asset_furniture_value asset_wc1_stock_value asset_wc2_materials_value asset_wc3_money_value asset_ip_value),missing

	foreach var of varlist _all{
			char `var'[charname] "`var'"
		}
	
	
	replace assets_total = subinstr(assets_total,",","",.)
	destring assets_total	assets_total_Check ,replace
	listtab $biz_info assets_total assets_total_Check if assets_total != assets_total_Check  , delimiter(",") appendto(`hfc_file') replace headlines("Calculated Assets doesn't equal survey totals") headchars(charname)
	

	
**Respondent with  more than 100 employees	
	listtab $biz_info   bo_operational emp_total  bo_primary_what if emp_total >=100  , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with  more than 100 employees") headchars(charname)
	



	
**Respondent with more higher level practices than lower level practices eg has buget but doesnt seperate finances	
	
	
	egen level1_practices=rowtotal(practices_q1 practices_q2 practices_q3 practices_q4 practices_q5 practices_q6 practices_q7),missing
	egen level2_practices= rowtotal(practices_q8 practices_q9 practices_q10 practices_q11 practices_q12),missing
	
	listtab $biz_info  bo_primary_how practices_q1- practices_q12 if level2_practices > level1_practices , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more higher level practices than lower level practices") headchars(charname)

**Respondent with more than 1 capital type
	
	foreach var of varlist	capital_loan1_amount capital_loan2_amount capital_loan3_amount capital_loan4_amount capital_loan5_amount capital_loan6_amount capital_loan7_amount capital_loan8_amount capital_loan9_amount capital_loan10_amount {
	gen `var'_count=0
	replace `var'_count =1 if `var'>0 & `var' !=.
	}

	egen capital_loan_count= rowtotal (capital_loan1_amount_count capital_loan2_amount_count capital_loan3_amount_count capital_loan4_amount_count capital_loan5_amount_count capital_loan6_amount_count capital_loan7_amount_count capital_loan8_amount_count capital_loan9_amount_count capital_loan10_amount_count),missing
		
	foreach var of varlist capital_equity1_amount capital_equity2_amount capital_equity3_amount capital_equity4_amount capital_equity5_amount {
	gen `var'_count=0
	replace `var'_count	=1 if `var'>0 & `var' !=.
	}

	egen capital_equity_count = rowtotal(capital_equity1_amount_count capital_equity2_amount_count capital_equity3_amount_count capital_equity4_amount_count capital_equity5_amount_count),missing

	 
	 
	foreach var of varlist capital_grant1_value capital_grant2_value capital_grant3_value capital_grant4_value capital_grant5_value{
	gen `var'_count=0
	replace `var'_count	=1 if `var'>0 & `var' !=.
	}
	egen capital_grant_count = rowtotal(capital_grant1_value_count capital_grant2_value_count capital_grant3_value_count capital_grant4_value_count capital_grant5_value_count),missing	
	
	
	listtab $biz_info  capital_equity if capital_equity != capital_equity_count  & capital_equity !=., delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 equity capital") headchars(charname)
	listtab $biz_info  capital_loans if capital_loans != capital_loan_count & capital_loans !=. , delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 loan capital") headchars(charname)
	listtab $biz_info  capital_grants if capital_grants != capital_grant_count & capital_grants !=., delimiter(",") appendto(`hfc_file') replace headlines("Respondent with more than 1 grant capital") headchars(charname)

	
	*drop ci_biz_name_num ci_firstname_num ci_lastname_num ci_phone_1	ci_phone_2   //drop PII
    
}
 
     window stopbox rusure "Do you want to continue to run summary stats?`=char(13)'Yes=continue; No=stop here."
    window stopbox note "Good choice!"
    
****
* drop IDs
{
/*
# delimit ;
egen dr = anymatch(admin_participant_id), values(67593
67627
67662
67690
67694
67708
67724
67725
67746
67770
67801
67872
67932
67944
67947
67965
68006
68011
68016
68040
68070
68139
68164
68175
68187
68228
68303
68309
68314
68323
68336
68339
68359
68378
68383
68406
68429
68454
68466
68484
68518
68536
68550
68676
68698
68793
68835
68886
68887
12345
68795
68472
67996
68010
68021
68838
68713
68727
67773
68013
68144
68695
68129
68067
68329
68277
68471
68072
68502
68790
67749
68137
68282
67679
67824
67875
67918
67973
67987
68023
68026
68084
68094
68101
68132
68147
68149
68172
68173
68192
68295
68296
68432
68448
68503
68516
68870
68902);
# delimit cr 

drop if dr 
*/
}

		
*****************************************************************************************	 
	 *** IMPORTANT VARIABLES **

*****************************************************************************************
*cd "D:\Documents\Consultorias\World_Bank\Peru Innovation\Survey\Data check\28042020"

*exclude closed firms

drop if  bo_operational==0

tab bo_transactions_frequency
tab bo_operational

egen ass_tot = sum(assets_total)
egen vent_tot = sum(sales_last_year)

destring profits_last_year, replace force

//replace profits_last_year=1000000 if admin_participant_id==67679

egen ganan_tot = sum(profits_last_year) if profits_last_year>=0 

di ass_tot 
di vent_tot
di ganan_tot

tab acess_finance

tab fin_formal_bank_2018
tab fin_formal_bank_2019

tab patent_brand_2018 
tab patent_brand_2019

*CUidado con valores!

egen inno_18 = median(innovations_amount_2018)
egen inno_19 = median(innovations_amount_2019)

di inno_18
di inno_19

*Business_structure

 preserve
     forval i = 1/13 {
    
        egen tot_bo_structure_`i' = sum(bo_structure_`i')
    }

    gen id=_n
    keep tot_bo_structure_* id
    keep if id==1
    reshape long tot_bo_structure, i(id) j(str, string) 
    drop id
    
    replace str = "Casa de alguien" if str=="_1"
    replace str = "Casa de alguien, area" if str=="_2"
    replace str = "Casa clientes" if str=="_3"
    replace str = "Ubicacion comercial clientes" if str=="_4"
    replace str = "Puesto" if str=="_5"
    replace str = "Contenedor" if str=="_6"
    replace str = "Tienda pequeña, independiente" if str=="_7"
    replace str = "Tienda pequeña en centro comercial" if str=="_8"
    replace str = "Pequeña grande, independiente" if str=="_9"
    replace str = "Tienda grande en centro comercial" if str=="_10"
    replace str = "Oficina" if str=="_11"
    replace str = "Edificio independiente" if str=="_12"
    replace str = "Otro" if str=="_13"
    
    tempfile temp_1
    save "`temp_1'"
 restore

 
 *Validate RUC
  gen ruc_val = ustrlen(bo_registration_number)
  tab ruc*
  
  *FALTA*
 
 *Edad_legal_empresas
 gen float age = ( mdy(4,28,2020) - bo_registration_date ) / 365.25
 tabstat  age, stat(min max mean median)
 
 **bo_primary_what 
*ssc install txttool
preserve
 keep bo_primary_what
 txttool bo_primary_what, gen(cleaned)
 txttool bo_primary_what, gen(stopped) stopwords("stopwordexample.txt")
 txttool bo_primary_what, gen(bagged) stopwords("stopwordexample.txt") bagwords prefix(w_) 
 list w_*
 keep w_*
 drop w_a w_necesidad w_solamente w_medir w_reas w_paso w_expuerto w_1cliente w_ms w_500 w_us w_2cliente w_5 w_final w_cada w_3cliente w_crdito w_crditos w_3 w_real w_expone w_as w_tambin w_basado w_rf w_nootascom w_mvil w_segn w_explican w_repaso w_cuestin w_est w_mayo w_lograr w_debi w_travs w_oma w_cfd w_fem w_da w_rels w_funcin w_eliminar w_20 w_250 w_90 w_10 w_50 w_1500 w_400 w_02 w_4
 
 collapse (sum) *
 
 gen id=_n
 keep if (w_* > 10)
 
  save "`temp_2'"
restore

use `temp_1', clear
append using `temp_2', force

save "cuadros_1_2", replace


**bo_primary_how 
preserve
   keep bo_primary_how*
   
   forval i = 1/3 {
    
        egen tot_bo_primary_how_`i' = sum(bo_primary_how_`i')
    }
    
    gen id=_n
    keep tot_bo_primary_how_* id
    keep if id==1
    reshape long tot_bo_primary_how, i(id) j(str, string) 
    drop id
    
    replace str = "Compra y vende inventario" if str=="_1"
    replace str = "Fabrica o manufactura sus propios productos" if str=="_2"
    replace str = "Proporciona servicios" if str=="_3"   
  
  save "`temp_3'"
restore

**How long did it take to end the survey?
gen hours = hours( starttime- endtime)

************************************
******EDA
drop admin_survey_date admin_contact_name admin_participant_id_confirm admin_survey_start admin_business_name admin_consent admin_respondent_name admin_respondent_position2 admin_respondent_position admin_respondent_phone1 admin_respondent_phone2 admin_respondent_email admin_contact_position2 admin_contact_position admin_contact_phone1 admin_contact_phone2 admin_contact_email bo_biz_location_street bo_biz_location_landmark

*Check missing values
	misstable sum
	misstable tree
    
     missings dropvars, force
  
  drop cust_impt* capital_loan* capital_equity1* capital_equity2* capital_equity3* capital_equity4* capital_equity5* capital_grant1* capital_grant2* capital_grant3* capital_grant4* capital_grant5* *_other *_others instancename-capital_grant_count
  
  
  *DO NOT FORGET to have LaTeX on/installed!

*winexec miktex-console
winexec C:\Users\Woody\AppData\Local\Programs\MiKTeX 2.9\miktex\bin\x64\miktex-console.exe


set graphics off
eda, r("C:\Users\Woody\Downloads") o("Reporte Linea de Base Ventanilla 1") comp scheme(edatest) auth("Andrei Wong Espejo awongespejo@worldbank.org") repo("Linea de Base") nodistro nopiec noladder nomosaic noheat nohisto perc miss grlabl(45)
set graphics on
beep
beep
*Include \pdfminorversion=6 in Latex
*file close _all
*/

************************************
*****Cluster
*Check missing values
	misstable sum
	misstable tree
    
    missings dropvars, force

drop admin_survey_date admin_contact_name admin_participant_id_confirm admin_survey_start admin_business_name admin_consent admin_respondent_name admin_respondent_position2 admin_respondent_position admin_respondent_phone1 admin_respondent_phone2 admin_respondent_email admin_contact_position2 admin_contact_position admin_contact_phone1 admin_contact_phone2 admin_contact_email bo_biz_location_street bo_biz_location_landmark instancename formdef_version key submissiondate starttime endtime

* drop closed businesses
 drop if bo_operational==0 //n=3
 assert c(N)==109
 
 drop bo_operational bo_operational_close_reason
 
 gen origin = 
 
 
 




