######## data export to just pull client data and no loan data
###### orrrrrrr, even better, I can pull the clients who still owe us money and make sure their account shows that

SELECT
	c.firstname AS "First Name",
	c.lastname AS "Last Name", 
	c.ss_number AS "SSN        ",
	a.ss_number AS "Aux-SSN    ",

	(
		CASE
			WHEN (c.ss_number NOT IN (SELECT ss_number FROM aux_client)) THEN "11/11/1111"
			WHEN LENGTH(a.dob) < 10 THEN "11/11/1111"
			WHEN a.dob IS NULL THEN "11/11/1111"
			ELSE a.dob
		END) AS "Birth Date",

	c.address AS "Home Address", 

	(
		CASE	
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Fed Heights Acct") THEN "Federal Heights"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Loveland Acct") THEN "Loveland"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Apple Valley Acct") THEN "Apple Valley"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Billings Acct") THEN "Billings"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Great Falls Acct") THEN "Great Falls"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Butte Office") THEN "Butte"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Denver Acct") THEN "Denver"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "IdahoFalls Acct") THEN "Idaho Falls"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Missoula Acct") THEN "Missoula"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') AND c.driver_license = "Pocatello Acct") THEN "Pocatello"	
			ELSE c.city
		END) AS "Home city", 

	(
		CASE	
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Fed Heights Acct") THEN "CO"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Loveland Acct") THEN "CO"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Apple Valley Acct") THEN "CA"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Billings Acct") THEN "MT"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Great Falls Acct") THEN "MT"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Butte Office") THEN "MT"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Denver Acct") THEN "CO"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "IdahoFalls Acct") THEN "ID"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Missoula Acct") THEN "MT"
			WHEN (c.city LIKE 'X%' AND c.driver_license = "Pocatello Acct") THEN "ID"	
			ELSE c.state
		END) AS "Home state", 

	c.zip AS "Home zip",

	(
		CASE
/*
			WHEN c.home_phone LIKE 'CC%' THEN trim( 'CC' FROM c.home_phone)
			WHEN c.home_phone LIKE 'cc%' THEN trim( 'cc' FROM c.home_phone)
			WHEN c.home_phone LIKE 'NC%' THEN trim('NC' FROM c.home_phone)
			WHEN c.home_phone LIKE 'cell%' THEN trim('cell' FROM c.home_phone)
			WHEN c.home_phone LIKE 'n/c%' THEN c.home_phone = trim('n/c' FROM c.home_phone)
*/

		### DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS for complete entries (just not entries that contain an actual phone number)
			WHEN (c.home_phone IS NULL 
					OR c.home_phone IN ( "303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`" )
					OR c.home_phone IN ( "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone")
					OR c.home_phone IN ( "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411")
					OR c.home_phone IN ("11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " X")
					) THEN ''

			WHEN c.home_phone IN (SELECT cell_phone FROM aux_client) THEN ''

		### REPLACEMENTS REPLACEMENTS REPLACEMENTS REPLACEMENTS --- NOTE: cannot have separate WHEN-statements for each REPLACE function - IT DOES NOT WORK
		### --------=================>>>>>>> IMPORTANT!: the statements get executed from the center out. so place the specific changes in the middle and then work out. avoid single letters
		### --------=================>>>>>>>>>>>>>>>>>>>> whenever possible. but if you must, then wait until the end. 
			WHEN c.home_phone IS NOT NULL THEN REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE(
																		REPLACE(
																			REPLACE(
																				REPLACE(
																					REPLACE(
																						REPLACE(
																							REPLACE(
																								REPLACE(
																									REPLACE(
																										REPLACE(
																											REPLACE(
																												REPLACE(
																													REPLACE(
																														REPLACE(
																															REPLACE(
																																REPLACE(
																																	REPLACE(
																																		REPLACE(
																																			REPLACE( ####### starts here
																																				REPLACE(
																																					REPLACE(
																																						REPLACE(
																																							REPLACE(
																																								REPLACE(
																																									REPLACE(
																																										REPLACE(
																																											REPLACE(
																																												REPLACE(
																																													REPLACE(
																																														REPLACE(
																																															REPLACE(
																																																REPLACE(
																																																	REPLACE(
																																																		REPLACE(
																																																			REPLACE(
																																																				REPLACE(
																																																					REPLACE(
																																																						REPLACE(
																																																							REPLACE(
																																																								REPLACE(c.home_phone, 'CELL ' , '')
																																																							, 'CC- ', '')
																																																						, ' (mess)', '')
																																																					, ' (Disc)' , '')		
																																																				, '(c)', '')
																																																			, ' Tempxx', '')
																																																		, 'Tmpx', '')
																																																	, 'tmpxx', '')
																																																, '-msg', '')
																																															, ' disc-', '')
																																														, ' disc', '')
																																													, ' (disc)', '')
																																												, ' (msg)', '')
																																											, ' msg' , '')
																																										, '#', '')
																																									,'xx', '')
																																								, '(msg)', '')
																																							, ' xxx' , '')
																																						, ' DISC' , '')
																																					, '-disconnect' , '')
																																				, 'msg ', '')
																																			, 'XXX' , '') ### started piling 'em on here
																																		, ' (cell)', '')
																																	, '(cell)', '')
																																, '?', '')
																															, 'cell: ', '')
																														, 'cell ', '')
																													, 'Cell ', '')
																												, 'Cell' , '')
																											, 'cc', '')
																										, 'N/C ', '')
																									, 'n/c ', '')
																								, 'N/C', '')
																							, 'n/c', '')
																						, 'n-c ', '')
																					, 'nc', '')
																				, 'N-C', '')
																			, 'n-c', '')
																		, 'X ', '')
																	, '/', '-')
																, '.', '-')
															, 'cell', '')
														, 'CC', '')
													, 'none', '')	
												, 'NC' , '')
															
		### CONCATINATION CONCATINATION CONCATINATION CONCATINATION CONCATINATION
			WHEN (length(c.home_phone) < 9 AND length(c.home_phone) > 4 AND (	c.city = "FRUITA" OR c.city = "Loveland" OR c.city = "Wellington" 
																				OR c.city = "Pierce" OR c.city = "Sterling" OR c.city = "Johnstown" 
																				OR c.city = "Loveland " OR c.city = "Estes Park" OR c.city = "Estes Pk" 
																				OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Ft. Collins" 
																				OR c.city = " Loveland" OR c.city = "FT.Collins" OR c.city = "Berthoud" 
																				OR c.city = "Kersey")) 													
																					THEN concat("970-" , c.home_phone)
			WHEN (length(c.home_phone) < 9 AND length(c.home_phone) > 4 AND (	c.city = "ARVADA" OR c.city = "AROURA" OR c.city = "AURARA" OR c.city = "BOULDER" 
																				OR c.city = "BRIGHTON" OR c.city = "CASTLE ROCK" OR c.city = "COMMERCE CITY" 
																				OR c.city = "ENGLEWOOD" OR c.city = "EVERGREEN" OR c.city = "FEDERAL HEIGHTS" 
																				OR c.city = "FEDERAL HTS." OR c.city = "FEDERAL HGTS" OR c.city = "FED HIGHT'" 
																				OR c.city = "FED HTS" OR c.city = "Fed Heights" OR c.city = "KITTREDGE" OR c.city = "LAFAYETTE" 
																				OR c.city = "Longmont" OR c.city = "LAKEWOOD" OR c.city = "Golden" OR c.city = "Broomfield" 
																				OR c.city = "BROOMFIELD" OR c.city = "WESTMINSTER" OR c.city = "Westminister" 
																				OR c.city = "WHEATRIDGE" OR c.city = "THORNTON" OR c.city = "THRONTON" OR c.city = "Thorton" 
																				OR c.city = "THRNTON" OR c.city = "NORTHGELNN" OR c.city = "NORTHGENN" OR c.city = "Northglenn" 
																				OR c.city = "Aurora") ) 												
																					THEN concat("720-" , c.home_phone)    ###### oh snap, you CAN use "and" in the WHEN statement. cool
			WHEN (length(c.home_phone) < 9 AND length(c.home_phone) > 4 AND (c.city = "Denver" OR c.city = "Dever" OR c.city = "DENVER") ) THEN concat("303-" , c.home_phone)    ###### oh snap, you CAN use "and" in the WHEN statement. cool			
			
			##### no c.city, but driver license shows fed heights fix -- or trying to fix god dammit
			WHEN (c.zip = "X" AND c.driver_license = "Fed Heights Acct" AND length(c.home_phone) < 9) THEN concat("720-", c.home_phone)
			
			ELSE c.home_phone
		END) AS "Home Phone", 

	(
		CASE
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
			###### Deletions for cell_phones with useless data -------> !!!!! Used to have IS NULL in the WHEN statement, which ruined things for importing the home_phone when no cp exists
			###### this first code block below is for clients in both client and aux_client databases with dead cp and dead hp, therefore, both should be empty
			###### and they need to be empty, not "NULL"
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND (	c.home_phone IS NULL 
						OR c.home_phone = ""
						OR c.home_phone IN ( 	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`"
											, "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone"
											, "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411"
											, "11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " X" ) 
					)
				AND (	a.cell_phone IS NULL
						OR a.cell_phone = ""
						OR a.cell_phone IN ( 	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`"
											, "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone"
											, "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411"
											, "11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " X" )
					)
						THEN ''
			

/*			///// ------>>>>>>> KEEP THIS CASHED FOR NOW -- seems to be doing double duty
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND (a.cell_phone IN ( 	"XXX", "OOO" , "000" , "00", "0", "(000)" , "(00 )", 
									"(   )", "( )", "none", "same", "xxx xxx xxxx",
									"NA", "N/A", " 000-0000", " 000-000", "(000) 000-0000", 
									"(000) 000-000", "(000)    -", "(   )    -", "(00 )    -"
									"XZ", "xx", "NA ", "") 
					OR a.cell_phone IS NULL ) 
				AND (c.home_phone IS NOT NULL OR c.home_phone != "")
				AND length(	REPLACE(
								REPLACE(c.home_phone, "CELL"
					THEN IF(length(REPLACE(c.home_phone, "CELL", '')) = 12, IF( 	(c.city = "Wellington" OR c.city = "Loveland"
																					OR	c.city = "FRUITA" OR c.city = "Loveland" OR c.city = "Wellington" 
																					OR c.city = "Pierce" OR c.city = "Sterling" OR c.city = "Johnstown" 
																					OR c.city = "Loveland " OR c.city = "Estes Park" OR c.city = "Estes Pk" 
																					OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Ft. Collins" 
																					OR c.city = " Loveland" OR c.city = "FT.Collins" OR c.city = "Berthoud" 
																					OR c.city = "Kersey" OR c.city = "X" ) 
																											, concat("970-", REPLACE(c.home_phone, " cell" , '')), ''), '')
*/
			##### IF the SSN is in client and aux client, but the cell phone is a bust for some reason, and the home phone has a tag to be removed
			##### SSN in client and aux_client
			##### CP is broken
			##### HP has tag to be removed before concatination 
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND (a.cell_phone IN ( 	"XXX", "OOO" , "000" , "00", "0", "(000)" , "(00 )", 
									"(   )", "( )", "none", "same", "xxx xxx xxxx",
									"NA", "N/A", " 000-0000", " 000-000", "(000) 000-0000", 
									"(000) 000-000", "(000)    -", "(   )    -", "(00 )    -"
									"XZ", "xx", "NA ", "") 
					OR a.cell_phone IS NULL ) 
				AND (c.home_phone IS NOT NULL OR c.home_phone != "")
				AND c.home_phone LIKE '%n/c%'
					THEN IF(length(	REPLACE( 					############### <<<<<<<<<<<<<<---- !!!!!! IF you add a replacement here you must add it to the REPLACE statement below 
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(c.home_phone, " cell", '')
														,'none', '')
													, 'CELL', '')
												, '-msg', '')
											, 'n/c ', '')
																			) = 8, IF( 	(c.city = "Wellington" OR c.city = "Loveland"
																						OR	c.city = "FRUITA" OR c.city = "Loveland" OR c.city = "Wellington" 
																						OR c.city = "Pierce" OR c.city = "Sterling" OR c.city = "Johnstown" 
																						OR c.city = "Loveland " OR c.city = "Estes Park" OR c.city = "Estes Pk" 
																						OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Ft. Collins" 
																						OR c.city = " Loveland" OR c.city = "FT.Collins" OR c.city = "Berthoud" 
																						OR c.city = "Kersey" OR c.city = "Bellevue" OR c.city = "FT. Collins" ) 
																												, concat("970-", REPLACE(
																																	REPLACE(
																																		REPLACE(
																																			REPLACE(
																																				REPLACE(c.home_phone, " cell" , '') 
																																					,'none', '')
																																				, 'CELL', '')
																																			, '-msg', '')
																																		, 'n/c ', '')
																						), 
																					''), 
																				'')


			#### IF the SSN is in client and aux_client, but the cell phone is a bust for some reason and the home phone is perfect, but only 8 digits long
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND (a.cell_phone IN ( 	"XXX", "OOO" , "000" , "00", "0", "(000)" , "(00 )", 
									"(   )", "( )", "none", "same", "xxx xxx xxxx",
									"NA", "N/A", " 000-0000", " 000-000", "(000) 000-0000", 
									"(000) 000-000", "(000)    -", "(   )    -", "(00 )    -"
									"XZ", "xx", "NA ", "") 
					OR a.cell_phone IS NULL ) 
				AND (c.home_phone IS NOT NULL AND c.home_phone != "")
					THEN IF(length(c.home_phone) = 8, 
														IF( 	(c.city = "Wellington" OR c.city = "Loveland"
															OR	c.city = "FRUITA" OR c.city = "Loveland" OR c.city = "Wellington" 
															OR c.city = "Pierce" OR c.city = "Sterling" OR c.city = "Johnstown" 
															OR c.city = "Loveland " OR c.city = "Estes Park" OR c.city = "Estes Pk" 
															OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Ft. Collins" 
															OR c.city = " Loveland" OR c.city = "FT.Collins" OR c.city = "Berthoud" 
															OR c.city = "Kersey" OR c.city = "X" OR c.city = "Millilken" ), 
																																IF(a.cell_phone IN ( 	"XXX", "OOO" , "000" , "00", "0", "(000)" , "(00 )", 
																																						"(   )", "( )", "none", "same", "xxx xxx xxxx",
																																						"NA", "N/A", " 000-0000", " 000-000", "(000) 000-0000", 
																																						"(000) 000-000", "(000)    -", "(   )    -", "(00 )    -"
																																						"XZ", "xx", "NA ", "")
																																												, concat("aaaaaaaaaaaaaaaa-",	REPLACE(
																																																					REPLACE(c.home_phone, 'CELL', '')
																																																						, 'none', '')
																																														) #--> concat closure
																	,'')
																																	
															,'')
														, '')



##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION
##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION
##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION
			#########------------->>>>>>>> concat() function for all cell phones that exist
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND length(a.cell_phone) = 8 
				AND (c.city = "Loveland" OR c.city = "loveland" OR c.city = "Ft. Collins"
												OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Wellington"
												OR c.city = "Ft.Collins" OR c.city = "Johnstown" OR c.city = "Berthoud"
												OR c.city = "Sterling" OR c.city = "Estes Park" OR c.city = "Pierce"
												OR c.city = "Ft.collins" OR c.city = "Estes Pk" OR c.city = " Loveland"
												OR c.city = " Loveland" OR c.city = "Kersey") 								THEN concat("970-" , a.cell_phone)
			WHEN length(a.cell_phone) = 9 AND (c.city = "Ft.collins") THEN concat("970" , a.cell_phone)
			WHEN length(a.cell_phone) <= 8 AND (c.city = "Longmont") THEN concat("720-" , a.cell_phone)

			####### REPLACE functions for cell phones that already exist
			WHEN a.cell_phone IS NOT NULL
				AND a.cell_phone != ""  ####!!!!!!!!!!!!!!!!!! good god, the LACK of this line really mucked things up. when it WASN'T here
										#### -----------------> then MySQL looked for even the blank entries and basically did nothing to them
										#### -----------------------> which just meant I had a shit ton of blank entries. 
											THEN REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE(
																		REPLACE(
																			REPLACE(
																				REPLACE(
																					REPLACE(
																						REPLACE(
																							REPLACE(a.cell_phone, '/', '-')
																								, 'XX-', '')
																							, 'N-A', '')
																						, 'n-a', '')
																					, 'N/A', '')
																				, 'NA', '')
																			, '(   )', '')
																		, '(00 )', '')
																	, '(000)', '')
																, 'XX', '')
															, ') ', '-')
														, '(', '')


			#### for the cases when a cell phone does not exist because there is no data in aux_client BUT THERE IS a FULL (12 character) home phone number available in client table
			WHEN length(c.home_phone) = 12
				AND c.home_phone NOT LIKE '%n/c%'
					THEN IF( c.ss_number NOT IN (SELECT ss_number FROM aux_client) OR (a.cell_phone IS NULL OR a.cell_phone = ''), c.home_phone, '' )
		


#### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! OKay, so here's the deal: if the cell phone has data in it (like "same" or "nc") then we will want to remove that and replace it with
										###### the home phone data. So long as the home phone data is already clean. Which means . . . something. 


			##### ========= okay, this one is sexier than the one I deleted. Mostly because it works. Nested IF functions FTW!!
			############# ======================== $$$$$$$$$$$$$$$$$$$$ ======================================= ####################
			####### NO REPLACE functions here because this is only searching out numbers that are just missing the prefix and weeding out all others#######
			WHEN c.ss_number NOT IN (SELECT ss_number FROM aux_client)
				AND length(c.home_phone) = 8 		###### only = to 8, because we don't want to concat larger or smaller numbers, we want the ones that 
												######### -------> are very likely full numbers minus the prefix. And for that reason, definitely NOT less than 13 ###### 
				AND c.home_phone != '' 
				AND c.home_phone IS NOT NULL
				AND ( 	c.home_phone NOT IN ( '', "303-" , "303 ", "303", "none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected"
												,"disconnected" ,"?" , "N", "N/A" , "n/c" , "N/A`" , "NO PHONE" , "UNLISTED 411" ) )
						THEN 	IF	( c.driver_license = "Great Falls Acct" , concat("406-", c.home_phone),
									IF	( c.driver_license = "Billings Acct" , concat("406-", c.home_phone), 
										IF ( c.driver_license = "Butte Office", concat("406-", c.home_phone), 
											IF ( c.driver_license = "Missoula Acct", concat("406-",  c.home_phone), 
												IF ( c.driver_license = "Apple Valley Acct", concat("760-",  c.home_phone), 
													IF ( c.driver_license = "IdahoFalls acct", concat("208-",  c.home_phone),
														IF ( c.driver_license = "Pocatello Acct", concat("208-",  c.home_phone),
															IF ( c.driver_license = "Loveland Acct", concat("970-",  c.home_phone),
																IF ( c.driver_license = "Denver Acct", concat("303-",  c.home_phone),
																	IF ( c.driver_license = "Fed Heights Acct", concat("720-",  c.home_phone), c.home_phone)
																		
																	)
																)
															)
														)
													)
												)
											)
										)
									)

			###### Concats the correct number when the CP is PERFECT , and the HP is OKAY, but only 8 charaters log
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND length(c.home_phone) = 8 		###### only = to 8, because we don't want to concat larger or smaller numbers, we want the ones that 
												######### -------> are very likely full numbers minus the prefix. And for that reason, definitely NOT less than 13 ###### 
				AND c.home_phone != '' 
				AND c.home_phone IS NOT NULL
				AND ( 	c.home_phone NOT IN ( '', "303-" , "303 ", "303", "none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected"
												,"disconnected" ,"?" , "N", "N/A" , "n/c" , "N/A`" , "NO PHONE" , "UNLISTED 411" ) )
						THEN 	IF	( c.driver_license = "Great Falls Acct" , concat("406-", c.home_phone),
									IF	( c.driver_license = "Billings Acct" , concat("406-", c.home_phone), 
										IF ( c.driver_license = "Butte Office", concat("406-", c.home_phone), 
											IF ( c.driver_license = "Missoula Acct", concat("406-",  c.home_phone), 
												IF ( c.driver_license = "Apple Valley Acct", concat("760-",  c.home_phone), 
													IF ( c.driver_license = "IdahoFalls acct", concat("208-",  c.home_phone),
														IF ( c.driver_license = "Pocatello Acct", concat("208-",  c.home_phone),
															IF ( c.driver_license = "Loveland Acct", concat("970-",  c.home_phone),
																IF ( c.driver_license = "Denver Acct", concat("303-",  c.home_phone),
																	IF ( c.driver_license = "Fed Heights Acct", concat("720-",  c.home_phone), c.home_phone)
																		
																	)
																)
															)
														)
													)
												)
											)
										)
									)


			WHEN length(c.home_phone) = 11
				AND a.ss_number NOT IN (SELECT ss_number FROM aux_client)
				AND c.home_phone != ''
				AND c.home_phone IS NOT NULL
				# AND (length(c.home_phone) <= 12) ###### this makes sure we return something with 8 characters or less, i.e., NOT a full number. hopefully
				AND (	c.home_phone NOT IN ( '', "303-" , "303 ", "303", "none" ,"303-none" , "0000" , "DISC" ,"N/A/" 
												,"Disconnnected" ,"disconnected" ,"?" , "N", "N/A" , "n/c" , "N/A`"
												, "xxx xxx xxxx", "NO PHONE", "UNLISTED 411", "X", "XZ", "xx", "NA"
												, "n/a(cell)" ))
					########## !!!!!!!! IMPORTANT !!!!!!!!!! ####################################
					###### -----------> the length() function is just an EXPRESSION for the IF() function. That is, nothing is STORED, it just tests
					###### -----------> so we have to place the REPLACE() function in the concat() function to make that REPLACE actually stick
					###### -----------> there is probably a better way, but this way works at least
						THEN 	IF( c.driver_license = "Loveland Acct" AND length(	REPLACE(
																						REPLACE(
																							REPLACE(
																								REPLACE(
																									REPLACE(
																										REPLACE(
																											REPLACE(
																												REPLACE(
																													REPLACE(
																														REPLACE(
																																REPLACE(c.home_phone , 'CC-', '')
																																, ' (cell)', '')
																															, ' cell', '')
																														, 'msg ', '')
																													, 'N/C ', '')
																												, 'n/c ', '')
																											, 'n/a ' , '')
																										, 'CELL ', '')
																									, 'CELL', '')
																								 , 'CC-' , '')
																							, 'cell' , '')
																					) <= 8 , concat("970-",	REPLACE(
																												REPLACE(
																													REPLACE(
																														REPLACE(
																															REPLACE(
																																REPLACE(
																																	REPLACE( 
																																		REPLACE(
																																			REPLACE(
																																				REPLACE(
																																						REPLACE(c.home_phone , 'n/c ', '')

																																						, ' (cell)', '')
																																					, ' cell', '')
																																				, 'msg ', '')
																																			, 'N/C ', '')
																																		, 'n/c ', '')
																																	, 'n/a ' , '')
																																, 'CELL ', '')
																															, 'CELL', '')
																														 , 'CC-' , '')
																													, 'cell' , '')
																									), c.home_phone)


	
			############## ---> used when the SSN exists in aux_client and client, but the cell phone does NOT exist AND the home phone is less than 12
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND length(c.home_phone) = 8
				AND a.cell_phone = ''
				AND c.city = "FT.Collins"
					THEN concat("970-" , c.home_phone)


		END) AS "Cell Phone" , 
		
		'' AS 'Best time to call', 
	
		IF( (a.email = "none"
				OR a.email = "NA"
				OR a.email = "N/A"
				OR a.email = "noine"
				OR a.email IS NULL ) , '', a.email) AS 'Email' ,

		IF( (c.payday_schedule IS NULL) , '', c.payday_schedule) AS 'Pay Frequency', 

		IF( a.net_from_paystubs IS NULL, '', a.net_from_paystubs) AS 'Monthly Income', 

		'' AS 'First Payday', 
		'' AS 'Second Payday', 
		
		IF( (c.employer IN ( "X", "N/A", "N/a", "NA", "na", "XXX", "None", "none") ) , '', c.employer) AS 'Employer', 
	
		'' AS 'Occupation',
		'' AS 'Hire Date', 
		
		c.work_phone AS 'Work Phone', 
		
		IF( (c.bank_name IN ("none", "None", "X", "N/A", "n/a", "x", "0", "NA", "/a", "na")), '', c.bank_name) AS 'Bank           ', 

		'checking' AS 'Account Type', 

	(
		CASE 
			WHEN employer IN ('Social Security', 'SSI', 'SS')
				OR employer LIKE '%SSI &%' 
				OR employer LIKE '%SSI %' 
				OR employer LIKE '%SSI/%'
				OR employer LIKE '%SS and%'
				OR employer LIKE '%SS & %'
				OR employer LIKE '%SS& %' THEN 'socialsecurity'
			WHEN employer IN ('SSDI', 'SSD', 'VA Disability', 'VA Dis', 'SSID') 
				OR employer LIKE '%Disab%' THEN 'disability'
			WHEN employer LIKE '%Retired%'
				OR employer LIKE '%VA Benefit%' 
				OR employer LIKE '%VA and SS%'
				OR employer LIKE '%Va SSI%'
				OR employer LIKE '%VA & SS%'
				OR employer LIKE '%Retire%'
				OR employer LIKE '%Pension%'
				OR employer IN ('Retired', 'Retire', 'VA') THEN 'retirement'
			WHEN employer LIKE '%Self emp%'
				OR employer LIKE '%self%'
				OR employer LIKE '%Self Emp%' THEN 'selfemployed'
			WHEN employer IS NULL
				OR  employer IN ("X", "N/A", "N/a", "NA", "na", "XXX", "None", "none") THEN 'other'
			ELSE 'employment'
	END) as 'Income Type', 

	'directdeposit' AS 'Payroll Type',

	( 
		CASE
			WHEN (a.routing_number IS NULL OR a.routing_number = '')
				AND c.bank_name = 'Wells Fargo' THEN 102000076 
			WHEN a.routing_number REGEXP '[a-z]'  #### cool af. regexp checks to see if there are any letters in the string. ferk yeah
				AND c.bank_name = 'Wells Fargo' THEN 102000076
			WHEN a.routing_number IS NULL
				AND c.bank_name LIKE '%Weld Schools%' THEN 307076724
			WHEN a.routing_number IS NULL
				AND ( c.bank_name IN (	"Wash Mutual", "WAMU", 
										"Wash Mutl", "Wash Mutua", 
										"Chase")) THEN 102001017
			WHEN ( (a.routing_number IS NULL OR a.routing_number = '')
					AND c.bank_name IN ("US Bank", "US bank", "U.S. Bank") ) THEN 102000021
			WHEN a.routing_number IS NULL
				AND (
					c.bank_name LIKE '%St Vrain%' 
					OR c.bank_name LIKE '%St. Vrain%'
					OR c.bank_name LIKE '%ST Vrain%'
					) THEN 307077053
			WHEN ( (a.routing_number IS NULL OR a.routing_number = "0" OR a.routing_number = '') 
					AND (c.bank_name LIKE '%/%' OR c.bank_name = '' OR c.bank_name IN("0", "x", "None", "na") ) )
						THEN 	IF	( c.bank_name REGEXP '^Academy', 107001481,
									IF	( c.bank_name REGEXP '^1st Natl', 107000262, 
										IF	( c.bank_name REGEXP '^Bank One', 107006444,
											IF 	( (c.bank_name REGEXP '^Centennial' OR c.bank_name REGEXP '^Centinnial'), 082902757,
												IF	(c.bank_name REGEXP '^Chase', 102001017,
													IF	(c.bank_name REGEXP '^ABECU', 281082915, "000000000")
													)
												)
											)
										)
									)
			WHEN (a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("stop pmt", "0"))
				AND c.bank_name IN ("1st Bank") THEN 107005047
			WHEN (a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number = "0")
				AND c.bank_name IN ("1st National", "1st Natl", "1st Natl Bank", 
									"1st National Bank", "1st Natl-Estes Pk", "!st Natl") THEN 107000262
			WHEN (a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number = "0")
				AND c.bank_name IN ( "Home State", " Home State")  THEN 107004776
			WHEN (a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number = "0")
				AND c.bank_name IN ( "Academy", "Acadamy")  THEN 107001481
			WHEN a.routing_number REGEXP '[a-z]'  #### cool af. regexp checks to see if there are any letters in the string. ferk yeah
				AND c.bank_name IN ( "Academy", "Acadamy") THEN 107001481
		ELSE a.routing_number
	END) AS 'ABA Number',

	(
		CASE	
			WHEN c.bank_account REGEXP '[a-z]' THEN '000'
			WHEN c.bank_account IN (1, 0) THEN '000'
			WHEN c.bank_account REGEXP '/' THEN '000'
			ELSE c.bank_account 
	END) AS 'Account Number'
			
	

FROM
	client c
    LEFT JOIN aux_client a ON c.ss_number = a.ss_number 	### left join makes sure that no accounts are left in the dust. JOIN (right join) only returns accounts that are in BOTH databases
	WHERE c.driver_license = "Loveland Acct"
#		AND c.lastname = "Taylor"
#		AND right( c.ss_number, 4) LIKE '%4576%'
LIMIT 40000;
		
		
	

	
