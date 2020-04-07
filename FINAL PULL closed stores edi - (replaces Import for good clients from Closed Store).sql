######## data export to just pull client data and no loan data
###### orrrrrrr, even better, I can pull the clients who still owe us money and make sure their account shows that

# ****************************************** cooool sh*t below *************************************************
###### ctrl f "FINDWP" "FINDCP" "FINDHP" "FINDINSERT" "FINDTRUEBOOL" "DEADCPCODE" "FINDDBLINSERT" "FINDABA" "FINDBANK" "FINDPD" (payday) "FINDEMP" (employer)
###### SELECT @var1 = c.ss_number; # creating a variable to really muck with things big time money goo goo baby bear habbahabba choochoo 
#SET @row_number = 0; ### numbering 'dem rows. Make a variable and add one each time. Clever girl.

SELECT
	#(@row_number:=@row_number + 1) AS row_num, 
	'13' AS 'Store ID', 
	trim(c.firstname) AS "First Name",
	trim(c.lastname) AS "Last Name", 

	(
		CASE
			### pretty cool, but also pretty useless at the moment, since with each successive upload, we get another iteration of the ss_number.
			### which isn't A smart, or B really very useful


			#WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN c.ss_number 
			#WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9]_$' THEN REPLACE(c.ss_number, '_', ROUND((RAND() * (10-1)))+1)
			#WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]__$' THEN REPLACE(c.ss_number, '__', ROUND((RAND() * (100-1)))+1)
			#WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-__-____$' THEN REPLACE(
				#														REPLACE(c.ss_number, '____', ROUND( (RAND() * (10000-1)) )+1 )
				#															, '__', ROUND( (RAND() * (100-1) ) ) +1 )

			########## THE 0s have to be strings. If they're not, then SQL automatically changes any padded zeros to a SINGLE 0, which mucks everything up. but good. 

			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN c.ss_number 
			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9]_$' THEN REPLACE(c.ss_number, '_', '0')
			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-_[0-9][0-9][0-9]$' THEN REPLACE(c.ss_number, '_', '0')
			WHEN c.ss_number REGEXP '^ [0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN REPLACE(c.ss_number, ' ', '0')
			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]__$' THEN REPLACE(c.ss_number, '__', '00')
			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-____$' THEN REPLACE(c.ss_number, '____', '0000')
			WHEN c.ss_number REGEXP '^[0-9][0-9][0-9]-__-____$' THEN REPLACE(
																		REPLACE(c.ss_number, '____', '0000' )
																			, '__', '00' )
			WHEN c.ss_number IS NULL 
				OR c.ss_number IN ("___-__-____") THEN 	REPLACE(
															REPLACE( 
																REPLACE(c.ss_number, '____', '0000' )
																	, '___', ROUND( (RAND() * (1000-1) ) ) +1 )
																, '__', ROUND( (RAND() * (100-1)) )+1  )

			WHEN c.ss_number IS NULL 
				OR c.ss_number IN ("   -  -") THEN '000-00-0000'

	
END) AS "SSN        ",
	

	#a.ss_number AS "Aux-SSN    ", #unnecessary unless you're trying to double check your data


	(
		CASE
			###### ------ > DELETIONS DELETIONS DELETIONS DELETIONS
			WHEN (c.ss_number NOT IN (SELECT ss_number FROM aux_client)) OR LENGTH(a.dob) < 10 OR a.dob IS NULL OR a.dob REGEXP '[a-z]' THEN ""
			WHEN a.dob REGEXP '^ [0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN INSERT(a.dob, 1, 1, '0')
			WHEN a.dob NOT REGEXP '^0000[-\/]00[-\/]00$|^00[-\/]00[-\/]0000$|^00[-\/]0000[-\/]00$' 
				AND a.dob LIKE '%/%' THEN REPLACE(a.dob, '/', '-')
			WHEN a.dob NOT REGEXP '^[0-9][0-9][-\/][0-9][0-9][-\/][0-9][0-9][0-9][0-9]$|^[0-9][0-9][0-9][0-9][-\/][0-9][0-9][-\/][0-9][0-9]$' THEN ''
			WHEN a.dob REGEXP '0000[-\/]00[-\/]00' THEN ''
			WHEN a.dob REGEXP '00[-\/]00[-\/]0000' THEN ''
			WHEN a.dob REGEXP '^[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN a.dob
			WHEN a.dob REGEXP '^0001-01-01$' THEN ''

			ELSE DATE_FORMAT(trim(a.dob), "%m-%d-%Y")
		END) AS "Birth Date",

	(	
		CASE
			WHEN c.driver_license IS NULL OR c.driver_license IN ("X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXXX", "XXXXXXXX", "XXXXXXXXX", "XXXXXXXXXX", 
								"XXXXXXXXXXX", "XXXXXXXXXXXX", "x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
								"xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", " x", " xx", " xxx", " XXX", "na", 
								"NA", " na", " na", " NA", "Na", "nA", "N/A", "n/a", "N/a", "n/A", "NONE", "none", "c", "00", "?", "0", " 0", "1", "") 
										THEN ''
			WHEN c.driver_license REGEXP '\\.|\\/' THEN REPLACE(
															REPLACE(c.driver_license, '.', '-')
																, '/', '-')
			WHEN c.driver_license REGEXP 'x*x$' THEN ''
			ELSE trim(c.driver_license)
		END) AS "Drivers License Number",

	(
		CASE
			WHEN (c.driver_license IN ("Bilings Acct", "Great Falls Acct", "Butte Office", "Missoula Acct") ) THEN "MT"
			WHEN (c.driver_license IN ("Fed Heights Acct", "Loveland Acct", "Denver Acct") ) THEN "CO"
			WHEN (c.driver_license IN ("IdahoFalls Acct", "Pocatello Acct")) THEN "ID"
			WHEN (c.driver_license IN ("Apple Valley Acct")) THEN "CA"
			WHEN c.driver_license LIKE 'CO%' THEN "CO"
			WHEN c.driver_license LIKE 'WY%' THEN "WY"
			WHEN c.driver_license LIKE 'AL%' THEN "AL"
			WHEN c.driver_license LIKE 'AK%' THEN "AK"
			WHEN c.driver_license LIKE 'AR%' THEN "AR"
			WHEN c.driver_license LIKE 'AZ%' THEN "AZ"
			WHEN c.driver_license LIKE 'CA%' THEN "CA"
			WHEN c.driver_license LIKE 'CT%' THEN "CT"
			WHEN c.driver_license LIKE 'DE%' THEN "DE"
			WHEN c.driver_license LIKE 'FL%' THEN "FL"
			WHEN c.driver_license LIKE 'GA%' THEN "GA"
			WHEN c.driver_license LIKE 'HI%' THEN "HI"
			WHEN c.driver_license LIKE 'ID%' THEN "ID"
			WHEN c.driver_license LIKE 'IL%' THEN "IL"
			WHEN c.driver_license LIKE 'IN%' THEN "IN"
			WHEN c.driver_license LIKE 'IA%' THEN "IA"
			WHEN c.driver_license LIKE 'KS%' THEN "KS"
			WHEN c.driver_license LIKE 'KY%' THEN "KY"
			WHEN c.driver_license LIKE 'LA%' THEN "LA"
			WHEN c.driver_license LIKE 'ME%' THEN "ME"
			WHEN c.driver_license LIKE 'MD%' THEN "MD"
			WHEN c.driver_license LIKE 'MA%' THEN "MA"
			WHEN c.driver_license LIKE 'MI%' THEN "MI"
			WHEN c.driver_license LIKE 'MN%' THEN "MN"
			WHEN c.driver_license LIKE 'MS%' THEN "MS"
			WHEN c.driver_license LIKE 'MO%' THEN "MO"
			WHEN c.driver_license LIKE 'MT%' THEN "MT"
			WHEN c.driver_license LIKE 'NE%' THEN "NE"
			WHEN c.driver_license LIKE 'NV%' THEN "NV"
			WHEN c.driver_license LIKE 'NH%' THEN "NH"
			WHEN c.driver_license LIKE 'NJ%' THEN "NJ"
			WHEN c.driver_license LIKE 'NM%' THEN "NM"
			WHEN c.driver_license LIKE 'NY%' THEN "NY"
			WHEN c.driver_license LIKE 'NC%' THEN "NC"
			WHEN c.driver_license LIKE 'ND%' THEN "ND"
			WHEN c.driver_license LIKE 'OH%' THEN "OH"
			WHEN c.driver_license LIKE 'OK%' THEN "OK"
			WHEN c.driver_license LIKE 'OR%' THEN "OR"
			WHEN c.driver_license LIKE 'PA%' THEN "PA"
			WHEN c.driver_license LIKE 'RI%' THEN "RI"
			WHEN c.driver_license LIKE 'SC%' THEN "SC"
			WHEN c.driver_license LIKE 'SD%' THEN "SD"
			WHEN c.driver_license LIKE 'TN%' THEN "TN"
			WHEN c.driver_license LIKE 'TX%' THEN "TX"
			WHEN c.driver_license LIKE 'UT%' THEN "UT"
			WHEN c.driver_license LIKE 'VT%' THEN "VT"
			WHEN c.driver_license LIKE 'VA%' THEN "VA"
			WHEN c.driver_license LIKE 'WA%' THEN "WA"
			WHEN c.driver_license LIKE 'WV%' THEN "WV"
			WHEN c.driver_license LIKE 'WI%' THEN "WI"
			WHEN c.driver_license LIKE 'WY%' THEN "WY"
			ELSE ("")
		END) AS "Drivers License State",


	(	
		CASE
			WHEN c.address IN (	"X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXXX", "XXXXXXXX", "XXXXXXXXX", "XXXXXXXXXX", 
								"XXXXXXXXXXX", "XXXXXXXXXXXX", "x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
								"xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxx", " x", " xx", " xxx", " XXX", 
								"MOVED", "moved", "Mail Returned", "Money Gram Transactions", "na", 
								"NA", " na", " na", " NA", "new", "NEW", "NEW ADDRESS", "new address", "NEW ADRESS", "new adress",
								"New Address", "New address", 
								"new Address", "c", "00", " 00", "?", "0", "1") 
				OR c.address REGEXP '^X--'
				OR c.address REGEXP '^X ' ### previously, this ws just 'X ', which effectively burned any accounts with an upper (or lower) case 'x' in it. 
				OR c.address REGEXP '^\/*\/$'
				OR c.address REGEXP '^_*_$'
				OR c.address REGEXP '^-*-$'
				OR c.address REGEXP '^x*x$'
				#OR c.address REGEXP '^-*\\.$'
				OR c.address REGEXP '^_*_$'
				OR c.address REGEXP '^\\.*\\.$'
					THEN ''
			ELSE trim(c.address)
		END) AS " Home Address",

	(
		CASE	
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%')
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Fed Heights Acct") THEN "Federal Heights"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%')
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Loveland Acct") THEN "Loveland"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Apple Valley Acct") THEN "Apple Valley"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Billings Acct") THEN "Billings"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Great Falls Acct") THEN "Great Falls"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Butte Office") THEN "Butte"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Denver Acct") THEN "Denver"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "IdahoFalls Acct") THEN "Idaho Falls"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Missoula Acct") THEN "Missoula"
			WHEN ((c.city LIKE 'X%' AND c.zip LIKE '%X%' AND c.address LIKE '%X%') 
				AND( c.city IN ("X", "x", "xx", "xX", "Xx")) AND c.driver_license = "Pocatello Acct") THEN "Pocatello"
			WHEN c.city IN  ("X", "x", "xx", "xX", "Xx", '', "00", "000", "0", " 00") OR c.city IS NULL 
				OR c.city REGEXP '\.*x'
					AND c.driver_license NOT IN ( 	"Billings Acct", "Great Falls Acct", "Butte Office", "Missoula Acct", "Fed Heights Acct", "Loveland Acct", 
													"Denver Acct", "IdahoFalls Acct", "Pocatello Acct", "Apple Valley Acct")
					THEN ''
			WHEN (c.city REGEXP 'X') THEN REPLACE(c.city, 'X', '')
			WHEN (c.city REGEXP '^ ') THEN LTRIM(c.city)  ######## NOICE - trims the preceding whitespace from a colum RTRIM will trim the trailing whitespace. Nifty. Thrifty. 
			ELSE trim(c.city)
		END) AS "Home City", 

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
		#####!!! -----> USE THE CODE BELOW TO CLEAN UP THE RESULTS		
			WHEN c.state = "C" OR c.state = "C " OR c.state = " C" THEN CONCAT(LTRIM(c.state), "O") ##### I combined the LTRIM with the CONCAT here to be sure that if there WAS preceding white space it is gone
			WHEN c.state = "W" OR c.state = "W " OR c.state = " W" THEN CONCAT(LTRIM(c.state), "Y")
		#####!!! ----> IF city is null and state is null then delete
			WHEN (c.state IS NULL OR c.state IN ("X", "x", "XX", "xx", "xX", "Xx", "0", "x ", "X ", " X", " x", '', "NA", "N/A", "na")  )
					AND (c.city IS NULL OR c.city IN ("X", "x", "XX", "XXXX", "xx", "xX", "Xx", "0", "x ", "X ", " X", " x", '', "NA", "N/A", "na") ) THEN ''
					
			WHEN (c.state IS NULL OR c.state IN ("X", "x", "XX", "xx", "xX", "Xx", "0", "x ", "X ", " X", " x", '', "NA", "N/A", "na", "OC", "C0", "CP")
				OR c.state NOT IN ("AL", "AK", "AZ", "AR", "CA", "CO", "co", " CO", "CO ", "WY ", " WY", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN",
									"IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC",
									"OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WY", "wy", "Wy", "wY", "WA", "WV", "WI"))
				THEN IF(c.city IS NOT NULL AND c.city NOT IN ("X", "x", "XX", "xx", "xX", "Xx", "0", "x ", "X ", " X", " x", '', "NA", "N/A", "na"), 
						IF	(c.city IN ("Agate", "Aguilar", "Alamosa", "Allenspark", "Alma", "Almont", "Amherst", "Anton", "Antonito", "Arapahoe", 
										"Arboles", "Arlington", "Arriba", "Arvada", "Aspen", "Atwood", "Ault", "Aurora", "Austin", "Avon", "Avondale", 
										"Bailey", "Basalt", "Battlement Mesa", "Bayfield", "Bedrock", "Bellvue", "Bennett", "Berthoud", "Bethune", 
										"Beulah", "Black Hawk", "Blanca", "Boncarbo", "Bond", "Boone", "Boulder", "Branson", "Breckenridge", "Briggsdale", 
										"Brighton", "Broomfield", "Brush", "Buena Vista", "Buffalo Creek", "Burlington", "Burns", "Byers", "Cahone", "Calhan", 
										"Campo", "Canon City", "Capulin", "Carbondale", "Carr", "Cascade", "Castle Rock", "Cedaredge", "Center", "Central City", 
										"Chama", "Cheraw", "Cheyenne Wells", "Chimney Rock", "Chromo", "Cimarron", "Clark", "Clifton", "Climax", "Coal Creek", 
										"Coaldale", "Coalmont", "Collbran", "Colorado City", "Colorado Springs", "Commerce City", "Como", "Conejos", "Conifer", 
										"Cope", "Cortez", "Cory", "Cotopaxi", "Cowdrey", "Craig", "Crawford", "Creede", "Crested Butte", "Crestone", "Cripple Creek", 
										"Crook", "Crowley", "Dacono", "De Beque", "Deer Trail", "Del Norte", "Delta", "Denver", "Dillon", "Dinosaur", "Divide", 
										"Dolores", "Dove Creek", "Drake", "Dumont", "Dupont", "Durango", "Eads", "Eagle", "Eastlake", "Eaton", "Eckert", "Eckley", 
										"Edwards", "Egnar", "Elbert", "Eldorado Springs", "Elizabeth", "Empire", "Englewood", "Erie", "Estes Park", "Evans", 
										"Evergreen", "Fairplay", "Firestone", "Flagler", "Fleming", "Florence", "Florissant", "Fort Collins", "Fort Garland", 
										"Fort Lupton", "Fort Lyon", "Fort Morgan", "Fountain", "Fowler", "Franktown", "Fraser", "Frederick", "Frisco", "Fruita", 
										"Galeton", "Gardner", "Gateway", "Genoa", "Georgetown", "Gilcrest", "Gill", "Glade Park", "Glen Haven", "Glenwood Springs", 
										"Golden", "Granada", "Granby", "Grand Junction", "Grand Lake", "Granite", "Grant", "Greeley", "Green Mountain Falls", "Grover", 
										"Guffey", "Gunnison", "Gypsum", "Hamilton", "Hartman", "Hartsel", "Hasty", "Haswell", "Haxtun", "Hayden", "Henderson", 
										"Hereford", "Hesperus", "Highlands Ranch", "Hillrose", "Hillside", "Hoehne", "Holly", "Holyoke", "Homelake", "Hooper", 
										"Hot Sulphur Springs", "Hotchkiss", "Howard", "Hudson", "Hugo", "Hygiene", "Idaho Springs", "Idalia", "Idledale", "Ignacio", 
										"Iliff", "Indian Hills", "Jamestown", "Jaroso", "Jefferson", "Joes", "Johnstown", "Julesburg", "Karval", "Keenesburg", 
										"Kersey", "Kim", "Kiowa", "Kirk", "Kit Carson", "Kittredge", "Kremmling", "La Jara", "La Junta", "La Salle", "La Veta", 
										"Lafayette", "Lake City", "Lake George", "Lakewood", "Lamar", "Laporte", "Larkspur", "Las Animas", "Lazear", "Leadville", 
										"Lewis", "Limon", "Lindon", "Littleton", "Livermore", "Log Lane Village", "Loma", "Longmont", "Louisville", "Louviers", 
										"Loveland", "Lucerne", "Lyons", "Mack", "Manassa", "Mancos", "Manitou Springs", "Manzanola", "Marvel", "Masonville", 
										"Matheson", "Maybell", "Mc Clave", "Mc Coy", "Mead", "Meeker", "Meredith", "Merino", "Mesa", "Mesa Verde National Park", 
										"Milliken", "Minturn", "Model", "Moffat", "Molina", "Monarch", "Monte Vista", "Montrose", "Monument", "Morrison", "Mosca", 
										"Nathrop", "Naturita", "Nederland", "New Castle", "New Raymer", "Niwot", "Norwood", "Nucla", "Nunn", "Oak Creek", "Ohio City", 
										"Olathe", "Olney Springs", "Ophir", "Orchard", "Ordway", "Otis", "Ouray", "Ovid", "Padroni", "Pagosa Springs", "Palisade", 
										"Palmer Lake", "Paoli", "Paonia", "Parachute", "Paradox", "Parker", "Parlin", "Parshall", "Peetz", "Penrose", "Peyton", 
										"Phippsburg", "Pierce", "Pine", "Pinecliffe", "Pitkin", "Placerville", "Platteville", "Pleasant View", "Poncha Springs", 
										"Powderhorn", "Pritchett", "Pueblo", "Ramah", "Rand", "Rangely", "Red Cliff", "Red Feather Lakes", "Redvale", "Rico", 
										"Ridgway", "Rifle", "Rockvale", "Rocky Ford", "Roggen", "Rollinsville", "Romeo", "Rush", "Rye", "Saguache", "Salida", 
										"San Luis", "Sanford", "Sargents", "Sedalia", "Sedgwick", "Seibert", "Severance", "Shawnee", "Sheridan Lake", "Silt", 
										"Silver Plume", "Silverthorne", "Silverton", "Simla", "Slater", "Snowmass", "Snowmass Village", "Snyder", "Somerset", 
										"South Fork", "Springfield", "Steamboat Springs", "Sterling", "Stoneham", "Strasburg", "Stratton", "Sugar City", "Swink", 
										"Tabernash", "Telluride", "Thornton", "Timnath", "Toponas", "Towaoc", "Trinchera", "Trinidad", "Twin Lakes", "Two Buttes", 
										"Usaf Academy", "Vail", "Vernon", "Victor", "Vilas", "Villa Grove", "Vona", "Walden", "Walsenburg", "Walsh", "Ward", 
										"Watkins", "Weldona", "Wellington", "Westcliffe", "Westminster", "Weston", "Wetmore", "Wheat Ridge", "WHEATRIDGE", "Whitewater", "Wiggins", 
										"Wild Horse", "Wiley", "Windsor", "Winter Park", "Wolcott", "Woodland Park", "Woodrow", "Woody Creek", "Wray", "Yampa", 
										"Yellow Jacket", "Yoder", "Yuma", "Akron"), "CO", '')
			   , '') ## connects to the first IF statement
																																																						
			WHEN c.state REGEXP '^ ' THEN LTRIM(c.state)
			ELSE trim(UPPER(c.state))
		END) AS "Home State", 


	( CASE
		WHEN c.zip REGEXP '[a-z]' OR length(c.zip) != 5 OR c.zip IN ("11111", "22222", "33333", "44444") THEN ''
		ELSE TRIM(c.zip)
		
	END) AS "Home Zip",


	( 	##################### FINDHP #########################################
		#######################################################################################################

		CASE
		########## THE WHEN STATEMENTS BELOW ARE REMOVED BUT KEPT FOR POSTERITY FOR SOME REASON dc 11/8/2019
			#WHEN c.home_phone LIKE 'CC%' THEN trim( 'CC' FROM c.home_phone)
			#WHEN c.home_phone LIKE 'cc%' THEN trim( 'cc' FROM c.home_phone)
			#WHEN c.home_phone LIKE 'NC%' THEN trim('NC' FROM c.home_phone)
			#WHEN c.home_phone LIKE 'cell%' THEN trim('cell' FROM c.home_phone)
			#WHEN c.home_phone LIKE 'n/c%' THEN c.home_phone = trim('n/c' FROM c.home_phone)


		### DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS for complete entries (just not entries that contain an actual phone number)
			WHEN (c.home_phone IS NULL 
					OR c.home_phone IN ( "303-" , "303 ","none" ,"303-none" , "0000" , "DISC" , "disc", "discon", "N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`",
										"N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone",
										"NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411",
										"11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " X", "(000)    -", "*",
										"0", "xxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", "xxxxxxxxx", 
										"DNC", "dnc", "DO NOT CALL", "000", "720-", "303-", "720", "303", "", "XXX-XXX-XXX", "XXX-XXX-XXXX", "xxx-xxx-xxxx", "( 00)    -",
										"NOT VALID", "NIS", "na", "NA", "nA", "Na")
					OR c.home_phone REGEXP '^[0-9]x'
					OR (c.home_phone REGEXP '[a-z]' AND c.home_phone NOT REGEXP '[0-9]') #### nice. This one looks for home phones that ain't nuttin but letters sans a number of any type
					OR length(c.home_phone) > 18
						##### really not sure how else to sort out phone numbers that might suffer from THIS particular problem 
					OR (length(c.home_phone) = 12 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]$')
					OR c.home_phone REGEXP '^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR (length(c.home_phone) = 14 AND c.home_phone REGEXP '^\\( [0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$')
					OR (length(c.home_phone) = 12 AND c.home_phone REGEXP '^\\( [0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9]$')
					) THEN ''


			WHEN c.home_phone IN (SELECT cell_phone FROM aux_client) THEN '' ### we will defer to the cell phone in all cases || no need to double the cell phone by adding to the home phone either
			
			#################################################################
			############## ----- INSERTS INSERTS INSERTS INSERTS!
			#################################################################
			WHEN length(c.home_phone) = 10
				AND c.home_phone REGEXP '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
					THEN INSERT(INSERT(c.home_phone, 7, 0, '-'), 4, 0, '-') ###### FINDDBLINSERT #### Ijust think this is the best ever. Not sure why 7 is good. 

			WHEN length(c.home_phone) = 11
				AND c.home_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' 
					THEN INSERT(REPLACE(c.home_phone, ' ', '-'), 8, 0, '-') ##### FINDINSERTREPLACE

			WHEN length(c.home_phone) = 11
				AND c.home_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' 
					THEN INSERT(INSERT(c.home_phone, 8, 0, '-'), 4, 1, '-')

			WHEN length(c.home_phone) = 11
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' 
					THEN INSERT(c.home_phone, 8, 0, '-')

			WHEN length(c.home_phone) = 11
				AND c.home_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					THEN INSERT(c.home_phone, 4, 0, '-')

			WHEN length(c.home_phone) = 12
				AND c.home_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					THEN INSERT(c.home_phone, 4, 1, '-')

			WHEN length(c.home_phone) = 12
				AND c.home_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$' 
					THEN REPLACE (c.home_phone, ' ', '-')

			WHEN length(c.home_phone) = 13
				AND c.home_phone REGEXP '^ [0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					THEN INSERT(INSERT(c.home_phone, 1, 1,''), 4, 1, '-') ##### FINDINSERTREPLACE

			WHEN length(c.home_phone) = 13
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-$' 
					THEN INSERT(c.home_phone, 13, 1, '') ##### FINDINSERTREPLACE

			WHEN (length(c.home_phone) = 14 AND c.home_phone REGEXP '^\\([0-9][0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					AND c.home_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
						THEN INSERT(REPLACE(
										REPLACE(c.home_phone, ') ', '')
											,'(', ''), 4, 0, '-')

			WHEN (length(c.home_phone) = 14 AND c.home_phone REGEXP '^\\([0-9][0-9][0-9]\\)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					AND c.home_phone REGEXP '[^a-z]')
						THEN REPLACE(
								REPLACE(c.home_phone, ')', '-')
									,'(', '')

			############# my great hope is that this one will operate to resolve any issues with good numbers that just happen to have tags of some type at the end, or the beginning
			############# and those tags should get resolved by the replacement nest below. 
			WHEN c.home_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]'
				AND c.home_phone REGEXP '[a-z]'
					THEN INSERT	(INSERT	(	REPLACE	(
												REPLACE	(c.home_phone, ' cell', '')
												,'cell', '')
										, 4, 1, '-'),
								8, 1, '-') #### the end of the inserts above

			WHEN c.home_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
				AND c.home_phone REGEXP '[a-z]'
					THEN INSERT	(	REPLACE	(
											REPLACE	(c.home_phone, ' cell', '')
											,'cell', '')
									, 4, 0, '-')

			WHEN c.home_phone REGEXP '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' #in this case, it only ENDS with all the digits we need. the letters are in the beginning
				AND c.home_phone REGEXP '[a-z]'
					THEN INSERT	(	INSERT	(	REPLACE	(
													REPLACE (
														REPLACE	(c.home_phone, ' cell', '')
															,'cell', '')
														, 'NC', '')
											, 4, 0, '-')
								, 8, 0, '-') ### the INSERTS(), here at least, come AFTER the replacement, so the normal spots for the hyphen are still, well, normal

			WHEN (	c.home_phone REGEXP '^7\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' ## In this case, this is the EXACT text we're looking for, hence ^ and $
					OR c.home_phone REGEXP '^3\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR c.home_phone REGEXP '^9\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' )
						THEN IF	(c.home_phone REGEXP	'^7\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE	(c.home_phone, '/', '20-'), 
								IF	(c.home_phone REGEXP '^3\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE (c.home_phone, '/', '03-'), 	
									IF	(c.home_phone REGEXP '^9\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE (c.home_phone, '/', '70-'),	'')
									)
								)

			WHEN c.home_phone REGEXP '^[HC]# [0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$|^[HP|CP]# [0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$'
				AND c.home_phone REGEXP '[a-z]'
					THEN INSERT	(INSERT	(	REPLACE	(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE	(c.home_phone, 'HP# ', '')
																		,'HP#', '')
																	, 'CP# ', '')
																, 'H# ', '')
															, 'H#', '')
														,'C# ', '')
													,'C#', '')
										, 4, 1, '-')
								,8, 1, '-')

			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^2nd[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '2nd' from c.home_phone)
			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^1st[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '1st' from c.home_phone)
			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][a-z]$' THEN trim(leading '1-' from trim(trailing 'c' from c.home_phone))
			WHEN length(c.home_phone) = 16 AND c.home_phone REGEXP '^1st[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][a-z]$' THEN trim(leading '1st' from trim(trailing 'c' from c.home_phone))
			WHEN length(c.home_phone) = 16 AND c.home_phone REGEXP '^2nd[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][a-z]$' THEN trim(leading '2nd' from trim(trailing 'c' from c.home_phone))
			WHEN length(c.home_phone) = 16 AND c.home_phone REGEXP '^[a-z][a-z]1/[0-9][0-9][0-9]/[0-9][0-9][0-9]/[0-9][0-9][0-9][0-9]$' THEN trim(leading 'NC1-' from REPLACE(c.home_phone, '/', '-')) #changed NC1/ to NC1- since the REPLACE() is changing all / to -. Ya dig? 
			WHEN length(c.home_phone) = 16 AND c.home_phone REGEXP '^[a-z][a-z]1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading 'CC1-' from c.home_phone)
			WHEN length(c.home_phone) = 16 AND c.home_phone REGEXP '^[a-z][a-z]-1[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading 'CC-1' from c.home_phone)
			WHEN length(c.home_phone) = 13 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]/$' THEN trim(trailing '/' from c.home_phone)
			WHEN length(c.home_phone) = 14 AND c.home_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] CC$' THEN trim(trailing ' CC' from INSERT(c.home_phone, 4, 0, '-'))
			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]  CC$' THEN trim(trailing ' CC' from INSERT(c.home_phone, 4, 0, '-'))
			WHEN length(c.home_phone) = 17 AND c.home_phone REGEXP '^1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] CC$' THEN 	trim(trailing ' CC' from 
																																			trim(leading '1-' from c.home_phone)
																																			)
			WHEN length(c.home_phone) = 18 AND c.home_phone REGEXP '^1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] DAD$' THEN 	trim(trailing ' DAD' from 
																																			trim(leading '1-' from c.home_phone)
																																			)
			WHEN length(c.home_phone) = 19 AND c.home_phone REGEXP '^1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] MESS$' THEN trim(trailing ' MESS' from 
																																			trim(leading '1-' from c.home_phone)
																																			)

		### REPLACEMENTS REPLACEMENTS REPLACEMENTS REPLACEMENTS --- NOTE: cannot have separate WHEN-statements for each REPLACE function - IT DOES NOT WORK
		### --------=================>>>>>>> IMPORTANT!: the statements get executed from the center out. so place the specific changes in the middle and then work out. avoid single letters
		### --------=================>>>>>>>>>>>>>>>>>>>> whenever possible. but if you must, then wait until the end. 
		###!!!!!!!!!!!!!!!! ------> oh sh*t, okay, I get it. I put "when c.home_phone IS NOT NULL" which meant that this replace sought to replace any c.home_phone that wasn't null
		###!!!!!!!!!!!!!!!! -----------------> when in actuality what it needed was to be more specific. ONLY replace the ones that have letters or specific punctuation in it
			WHEN c.home_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
				AND c.home_phone REGEXP '[a-z]|\\.|\\/' THEN  trim(REPLACE( ### not sure why the OG was [a-z]|./ 
	replace(
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
																																																																														REPLACE(
																																																																															REPLACE(
																																																																																REPLACE(
																																																																																	REPLACE(
																																																																																		REPLACE(
																																																																																			REPLACE(
																																																																																				REPLACE (
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
																																																																																																									REPLACE( REPLACE( 
																																																																																																										REPLACE( REPLACE( 
																																																																																																											REPLACE( REPLACE( 
																																																																																																												REPLACE( REPLACE(
																																																																																																							REPLACE(c.home_phone, 'CELL ' , '')
																																																																																																					, ' DAD', '') 
																																																																																																				, ' MOM', '')
																																																																																																				, '-MOM', '')
																																																																																																				, 'MOM', '')
																																																																																																				, '-DAD', '')
																																																																																																				, 'DAD', '')
																																																																																																			, ' pgr', '')
																																																																																																		, ' MS', '')							
																																																																																																	, ' NC', '')
																																																																																																, ' NC', '')
																																																																																															, 'C# ', '')
																																																																																														, 'DNC', '')								
																																																																																													, ' dnd', '')									
																																																																																												, 'dnd', '')											
																																																																																											, 'OR7', '')
																																																																																										, ' cl#', '')
																																																																																									, ' CL#', '')
																																																																																								, ' WK', '')						
																																																																																							, 'tmpxx', '')		
																																																																																						, 'cl ', '')
																																																																																					, 'c# ', '')
																																																																																				, ' c#', '')
																																																																																			, 'c#', '')							
																																																																																		,'.', '-')				
																																																																																	, 'tmpX', '')   ###### four of these "closing" pieces were tagged on at the bottom because they needed to be enacted last (more specific)
																																																																																, '/ ', '-')
																																																																															, 'CC- ', '')
																																																																															, 'CC-', '')
																																																																														, ' MESS', '')
																																																																														, ' (mess)', '')
																																																																													, ' (Disc)' , '')		
																																																																												, '(c)', '')
																																																																											, ' Tempxx', '')
																																																																										, 'Tmpx', '')
																																																																									, 'tmpx', '')
																																																																								, '-msg', '')
																																																																							, ' disc-', '')
																																																																						, ' disc', '')
																																																																					, ' (disc)', '')
																																																																				, '--disc', '')
																																																																			, 'disc', '')
																																																																		, ' (msg)', '')
																																																																	, ' msg' , '')
																																																																, '#', '')
																																																															,'xx', '')
																																																														, '(msg)', '')
																																																													, ' xxx' , '')
																																																												, '-DISC', '')
																																																												, ' DISC' , '')
																																																												, ' DIS', '')
																																																												, 'DIS', '')
																																																											, '-disconnect' , '')
																																																										, 'msg ', '')
																																																									, 'XXX' , '') ### started piling 'em on here
																																																								, ' (cell)', '')
																																																							, '(cell)', '')
																																																						, '?', '')
																																																					, 'cell: ', '')
																																																				, ' cell', '')
																																																			, 'cell ', '')
																																																		, 'Cell ', '')
																																																	, 'Cell' , '')
																																																, 'cc', '')
																																															, 'N/C ', '')
																																														, 'n/c ', '')
																																													, 'N/C', '')
																																												, 'n/c', '')
																																											, 'n-c ', '')
																																										, '-nc', '')
																																									, 'N-C', '')
																																								, 'n-c', '')
																																							, 'X ', '')
																																						, '/', '-')
																																					, '-fax', '')
																																				, 'cell:', '')
																																			, 'cell', '')
																																		, 'CC ', '')
																																		, ' CC', '')
																																	, 'none', '')	
																																, 'NC ' , '')
																															,'CC', '')
																														,'CELL', '')
																													, 'CEL', '')
																												,'temp', '')
																											,'NC- ', '')
																										,' c','')
																									, ' L', '')
																								, 'nc ', '')
																							, 'nc', '')
																						, 'NC-', '')
																					,'NC', '')
																				, 'c', '')
																			,'CALL', '')
																		,'  C', '')
																	, ' C', '')
																, 'C ', '')
															, 'C', '')
														, ' fax', '')
													, 'h', '')
												,'PH ', '')
											,'PH', '')
										,'H ', '')																																																																																										
) # end of trim() above 
			#########################################################################																				
			### CONCATINATION CONCATINATION CONCATINATION CONCATINATION CONCATINATION
			#########################################################################
			WHEN length(c.home_phone) = 8
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'	
				AND c.city IN (	"Akron", "Almont", "Amherst", "Anton", "Arboles", "Aspen", "ASPEN", "Atwood", "Ault", "Austin", 
								"Avon", "AVON", "Basalt", "Battlement Mesa", "Bayfield", "Bedrock", "Bellvue", "Berthoud", "BERTHOUD",
								"Breckenridge", "BRECKENRIDGE", "Briggsdale", "Brush", "Burns", "Cahone", "Carbondale", "CARBONDALE", "Carr", 
								"Cedaredge", "Chimney Rock", "Chromo", "Cimarron", "Clark", "CLARK", "Clifton", "Coalmont", 
								"Collbran", "Cope", "Cortez", "Cory", "Cowdrey", "Craig", "Crawford", "Crested Butte", "CRESTED BUTTE",
								"Crook", "De Beque", "DEBEQUE", "Delta", "DELTA", "Dillon", "DILLON", "Dinosaur", "Dolores", "Dove Creek", "Drake", 
								"Durango", "DURANGO", "Eagle", "EAGLE", "Eaton", "Eckert", "Eckley", "Edwards", "Egnar", "Estes Park", "ESTES PARK", 
								"Evans", "EVANS",
								"Fleming", "Fort Collins", "FT COLLINS", "FC", "FORT COLLINS", "Ft Colllins",
								"Fort Morgan", "Fraser", 
								"Frisco", "FRISCO", "Fruita", "FRUITA", "Galeton", "Gateway", 
								"Gilcrest", "Gill", "Glade Park", "Glen Haven", "Glenwood Springs", "GLENWOOD SPGS", "Granby", "GRANBY",
								"Grand Junction", "GRAND JCT",
								"GRAND JUNCTION", "GJ",
								"Grand Lake", "Greeley", "GREELEY", "GLY", "Grover", "Gunnison", "Gypsum", "Hamilton", "Haxtun", "Hayden", 
								"Hesperus", "Hillrose", "Holyoke", "Hot Sulphur Springs", "Hotchkiss", "Idalia", "Ignacio", 
								"Iliff", "Joes", "Johnstown", "JOHNSTOWN", "Julesburg", "Kersey", "Kirk", "Kremmling", "La Salle", 
								"Lake City", "Laporte", "Lazear", "Lewis", "Lindon", "Livermore", "Log Lane Village", 
								"Loma", "LOMA", "Loveland", "LOVELAND", "Lucerne", "Mack", "Mancos", "Marvel", "Masonville", "Maybell", 
								"McCoy", "Mead", "MEAD", "Meeker", "Meredith", "Merino", "Mesa", "MESA", "Mesa Verde National Park", 
								"Milliken", "Minturn", "Molina", "Montrose", "MONTROSE", "Naturita", "New Castle", "New Raymer", 
								"Norwood", "Nucla", "Nunn", "Oak Creek", "Olathe", "Ophir", "Orchard", "Otis", "Ouray", 
								"Ovid", "Padroni", "Pagosa Springs", "Palisade", "Paoli", "Paonia", "Parachute", "Paradox", 
								"Parlin", "Parshall", "Peetz", "Phippsburg", "Pierce", "Pitkin", "Placerville", "Platteville", 
								"Pleasant View", "Powderhorn", "Rand", "Rangely", "Red Cliff", "Red Feather Lakes", "Redvale", 
								"Rico", "Ridgway", "Rifle", "RIFLE", "Sargents", "Severance", "Silt", "Silverthorne", "Silverton", 
								"Slater", "Snowmass", "Snowmass Village", "Snyder", "Somerset", "Steamboat Springs", 
								"Sterling", "Stoneham", "Stratton", "Tabernash", "Telluride", "TELLURIDE", "Timnath", "Toponas", 
								"Towaoc", "Vail", "VAIL", "Vernon", "Walden", "Weldona", "Wellington", "WELLINGTON", "Whitewater",
								"WHITEWATER", "Wiggins", "WIGGINS",
								"Windsor", "Winter Park", "WINTER PARK", "Wolcott", "Woodrow", "Woody Creek", "Wray", "Yampa", "YAMPA",
								"Yellow Jacket", "Yuma", "YUMA" )
					THEN concat("970-" , c.home_phone)

			WHEN length(c.home_phone) = 8
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' AND (	c.city = "ARVADA" OR c.city = "AROURA" OR c.city = "AURARA" OR c.city = "BOULDER" 
																						OR c.city = "BRIGHTON" OR c.city = "CASTLE ROCK" OR c.city = "COMMERCE CITY" 
																						OR c.city = "ENGLEWOOD" OR c.city = "EVERGREEN" OR c.city = "FEDERAL HEIGHTS" 
																						OR c.city = "FEDERAL HTS." OR c.city = "FEDERAL HGTS" OR c.city = "FED HIGHT'" 
																						OR c.city = "FED HTS" OR c.city = "Fed Heights" OR c.city = "KITTREDGE" OR c.city = "LAFAYETTE" 
																						OR c.city = "Longmont" OR c.city = "LAKEWOOD" OR c.city = "Golden" OR c.city = "Broomfield" 
																						OR c.city = "BROOMFIELD" OR c.city = "WESTMINSTER" OR c.city = "Westminister" 
																						OR c.city = "WHEATRIDGE" OR c.city = "THORNTON" OR c.city = "THRONTON" OR c.city = "Thorton" 
																						OR c.city = "THRNTON" OR c.city = "NORTHGELNN" OR c.city = "NORTHGENN" OR c.city = "Northglenn" 
																						OR c.city = "Aurora") 												
					THEN concat("720-" , c.home_phone)    ###### oh snap, you CAN use "and" in the WHEN statement. cool

			WHEN (length(c.home_phone) BETWEEN 4 AND 8 AND (c.city = "Denver" OR c.city = "Dever" OR c.city = "DENVER") ) THEN concat("303-" , c.home_phone)    ###### oh snap, you CAN use "and" in the WHEN statement. cool			
			
			##### no c.city, but driver license shows fed heights fix -- or trying to fix god dammit
			WHEN (c.zip = "X" AND c.driver_license = "Fed Heights Acct" AND length(c.home_phone) < 9) THEN concat("720-", c.home_phone)
			
			WHEN length(c.home_phone) = 8 AND c.city = "Loveland" THEN concat("970-", c.home_phone)

			WHEN (length(c.home_phone) = 11 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' 
					AND c.home_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
				THEN INSERT(c.home_phone, 8, 0, '-')

			WHEN (length(c.home_phone) = 11 AND c.home_phone REGEXP '33-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
					AND c.home_phone REGEXP '[^a-z]')
				THEN INSERT(c.home_phone, 2, 0, '0')

			###########################################################
			###### TRIMMING TRIMMING TRIMMING TRIMMING TRIMMING
			###########################################################
			WHEN length(c.home_phone) = 13 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]1$' THEN trim(trailing '1' from c.home_phone)
			WHEN length(c.home_phone) = 13 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]2$' THEN trim(trailing '2' from c.home_phone)  
			WHEN length(c.home_phone) = 13 AND c.home_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]3$' THEN trim(trailing '3' from c.home_phone)
			WHEN length(c.home_phone) = 13 AND c.home_phone REGEXP '^ [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading ' ' from c.home_phone)
			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^1st[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '1st' from c.home_phone)
			WHEN length(c.home_phone) = 15 AND c.home_phone REGEXP '^2nd[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '2nd' from c.home_phone)

			############# trim the leading 1- from 'em
			WHEN c.home_phone REGEXP '^1-[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN INSERT(TRIM(leading '1-' from c.home_phone),4, 0, '-')
			
			WHEN c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$| [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] | [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' THEN trim(c.home_phone)

			ELSE ''

		END) AS "Home Phone", 


	( ########### FINDCP ##################################################################################################################################################
		CASE
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
########## ------------------------>>>>>> DELETIONS SECTION DELETIONS SECTION DELETIONS SECTION
			#First,let's f**king keep it f**king simple, you big stupid, f**k, you. 12/10/2019
			# Take care of some simple and quick deletions, you crazy bastard. 12/13/2019

			# so, if the client DOES have an aux_client profile, but the cp is a total  bust, and the HP won't swoop in to save it (easily) then just burn it. 
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND ( a.cell_phone IN (	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" , "disc", "discon", "N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`",
									"N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone",
									"NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411",
									"11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", "0", "000", "0000", "00000", "000000", "0000000",
									"0000000", "00000000", "000000000"," X", "(000)    -", "*", "000 0000",
									"0", "xxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", "xxxxxxxxx", 
									"DNC", "dnc", "DO NOT CALL", "000", "720-", "303-", "720", "303", "", "XXX-XXX-XXX", "XXX-XXX-XXXX", "xxx-xxx-xxxx", "( 00)    -", "( 00)    -",
									"NOT VALID", "NIS", "na", "NA", "nA", "Na", "(00 )    -", "(   )    -", "( 00)    -", "719-", "(719)    -", "( 71) 9  -", "719", "720", "970", "303",
									 "(720)    -", "(970)    -", "(303)    -")
					OR a.cell_phone REGEXP '[a-z]' AND a.cell_phone NOT REGEXP '[0-9]' 
					OR a.cell_phone IS NULL ) #not sure why it would BE null if the ss_number exists in aux_client, but you never know!
				AND (c.home_phone NOT REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$') # if the home phone can't save the cp, then burn it down
						THEN ''
		
			###### Deletions for cell_phones with useless data -------> !!!!! Used to have IS NULL in the WHEN statement, which ruined things for importing the home_phone when no cp exists
			###### this first code block below is for clients in both client and aux_client databases with dead cp and dead hp, therefore, both should be empty
			###### and they need to be empty, not "NULL"
			###### UPDATE 11/13/2019 - I think this is ACTUALLY used to find the accounts where it is IMPOSSIBLE to reconstruct a cell phone, 
			###### -------> since the cp is a bust AND the hp is a bust too - then we just make sure it's blank instead of NULL
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND (	c.home_phone IS NULL 
						OR c.home_phone = ""
						OR c.home_phone IN ( "303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`"
											, "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone"
											, "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411"
											, "11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", "000 0000"
											, "( 00)    -", "( 00)    -"," X" ) 
					)
				AND (	a.cell_phone IS NULL
						OR a.cell_phone = ""
						OR a.cell_phone IN ( 	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`"
											, "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone"
											, "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411"
											, "11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " 00", "000 0000", " X" , "0"
											, "( 00)    -", "( 00)    -", "-")
					)
						THEN ''

			##################################################################################
			########### REPLACEMENTS REPLACEMENTS REPLACEMENTS REPLACEMENTS
			##################################################################################
			##################################################################################
			WHEN (length(a.cell_phone) = 14 AND a.cell_phone REGEXP '^\\([0-9][0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					AND a.cell_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
						THEN INSERT(REPLACE(
										REPLACE(a.cell_phone, ') ', '')
											,'(', '')
									, 4, 0, '-')

			WHEN (length(a.cell_phone) = 14 AND a.cell_phone REGEXP '^\\([0-9][0-9][0-9]\\)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					AND a.cell_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
						THEN REPLACE(
								REPLACE(a.cell_phone, ')', '-')
									,'(', '')


			##### ssn NOT in aux_client and the home phone is fried, so there is nothing we can use to make this thing work 
			WHEN c.ss_number NOT IN (SELECT ss_number FROM aux_client)
				AND c.home_phone IN ( 	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" ,"N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`"
										, "N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone"
										, "NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411"
										, "11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", " X" , "000 0000","", "( 00)    -")
					OR (c.home_phone REGEXP '[a-z]' AND c.home_phone NOT REGEXP '[0-9]')
					OR (c.home_phone REGEXP '[a-z]')
					OR c.home_phone NOT REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' # leaving this out to salvage the #'s that are just preceded by a blank space
					OR c.home_phone IS NULL
							THEN ''
			

			#############///// ------>>>>>>> KEEP THIS CASHED FOR NOW -- seems to be doing double duty
			#WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				#AND (a.cell_phone IN ( 	"XXX", "OOO" , "000" , "00", "0", "(000)" , "(00 )", 
									#"(   )", "( )", "none", "same", "xxx xxx xxxx",
									#"NA", "N/A", " 000-0000", " 000-000", "(000) 000-0000", 
									#"(000) 000-000", "(000)    -", "(   )    -", "(00 )    -"
									#"XZ", "xx", "NA ", "") 
					#OR a.cell_phone IS NULL ) 
				#AND (c.home_phone IS NOT NULL OR c.home_phone != "")
				#AND length(	REPLACE(
								#REPLACE(c.home_phone, "CELL"
					#THEN IF(length(REPLACE(c.home_phone, "CELL", '')) = 12, IF( 	(c.city = "Wellington" OR c.city = "Loveland"
																					#OR	c.city = "FRUITA" OR c.city = "Loveland" OR c.city = "Wellington" 
																					#OR c.city = "Pierce" OR c.city = "Sterling" OR c.city = "Johnstown" 
																					#OR c.city = "Loveland " OR c.city = "Estes Park" OR c.city = "Estes Pk" 
																					#OR c.city = "Windsor" OR c.city = "Greeley" OR c.city = "Ft. Collins" 
																					#OR c.city = " Loveland" OR c.city = "FT.Collins" OR c.city = "Berthoud" 
																					#OR c.city = "Kersey" OR c.city = "X" ) 
																											#, concat("970-", REPLACE(c.home_phone, " cell" , '')), ''), '')
				###### --------------------------- NEW SECTION -------------------------
				###### --------------------------- NEW SECTION internal ----------------######
					##### IF the SSN is in client and aux client, but the cell phone is a bust for some reason, and the home phone has a tag to be removed
					##### SSN in client and aux_client
					##### CP is broken
					##### HP has tag to be removed before concatination 
				######------------- You know what? F**k that. If the CP doesn't exist but the HP does. Well, then, bully for the HP. No reason to bring it over to CP. That's just silly. 
							####--- ESPECIALLY if the SSN exists in aux_client, because then someone made a conscious decision NOT to include the CP
							####--- You'll have to look in an older version of this query in order to find the build out for the WHEN statement I'm talking about, because it's deleted below. 
					
					##THIS WHEN STATEMENT EJECTED ON 12/10/2019 by Dave 

					#### IF the SSN is in client and aux_client, but the cell phone is a bust for some reason and the home phone is perfect, but only 8 digits long
					###### ACTUALLY, f**k this WHEN statement too. Who f**king cares? If we took the time to say the cell phone was a bust, then f**k it! Why
					###### bother copying the home phone there? Just to piss me off and make me waste my time? Yes!

					## THIS WHEN STATEMENT EJECTED ON 12/10/2019 by Dave ##


			##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION ###############
			##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION ################
			##!!!!!!!!!!! --------------------->>>>>>>>>>> CONCAT SECTION CONCAT SECTION CONCAT SECTION CONCAT SECTION ###############
			#########------------->>>>>>>> concat() function for all cell phones that exist
			#### okay, so if the cell phone is missing the prefix, and the home phone is a bust, then we'll got the old fashioned route of finding the city and 
			#### tagging a prefix accordingly
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND c.home_phone IS NULL OR c.home_phone REGEXP '[a-z]' 
				AND length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN (	"Akron", "Almont", "Amherst", "Anton", "Arboles", "Aspen", "ASPEN", "Atwood", "Ault", "Austin", 
									"Avon", "AVON", "Basalt", "Battlement Mesa", "Bayfield", "Bedrock", "Bellvue", "Berthoud", "BERTHOUD",
									"Breckenridge", "BRECKENRIDGE", "Briggsdale", "Brush", "Burns", "Cahone", "Carbondale", "CARBONDALE", "Carr", 
									"Cedaredge", "Chimney Rock", "Chromo", "Cimarron", "Clark", "CLARK", "Clifton", "Coalmont", 
									"Collbran", "Cope", "Cortez", "Cory", "Cowdrey", "Craig", "Crawford", "Crested Butte", "CRESTED BUTTE",
									"Crook", "De Beque", "DEBEQUE", "Delta", "DELTA", "Dillon", "DILLON", "Dinosaur", "Dolores", "Dove Creek", "Drake", 
									"Durango", "DURANGO", "Eagle", "EAGLE", "Eaton", "Eckert", "Eckley", "Edwards", "Egnar", "Estes Park", "ESTES PARK", 
									"Evans", "EVANS",
									"Fleming", "Fort Collins", "FT COLLINS", "FC", "FORT COLLINS", "Ft Colllins",
									"Fort Morgan", "Fraser", 
									"Frisco", "FRISCO", "Fruita", "FRUITA", "Galeton", "Gateway", 
									"Gilcrest", "Gill", "Glade Park", "Glen Haven", "Glenwood Springs", "GLENWOOD SPGS", "Granby", "GRANBY",
									"Grand Junction", "GRAND JCT",
									"GRAND JUNCTION", "GJ",
									"Grand Lake", "Greeley", "GREELEY", "GLY", "Grover", "Gunnison", "Gypsum", "Hamilton", "Haxtun", "Hayden", 
									"Hesperus", "Hillrose", "Holyoke", "Hot Sulphur Springs", "Hotchkiss", "Idalia", "Ignacio", 
									"Iliff", "Joes", "Johnstown", "JOHNSTOWN", "Julesburg", "Kersey", "Kirk", "Kremmling", "La Salle", 
									"Lake City", "Laporte", "Lazear", "Lewis", "Lindon", "Livermore", "Log Lane Village", 
									"Loma", "LOMA", "Loveland", "LOVELAND", "Lucerne", "Mack", "Mancos", "Marvel", "Masonville", "Maybell", 
									"McCoy", "Mead", "MEAD", "Meeker", "Meredith", "Merino", "Mesa", "MESA", "Mesa Verde National Park", 
									"Milliken", "Minturn", "Molina", "Montrose", "MONTROSE", "Naturita", "New Castle", "New Raymer", 
									"Norwood", "Nucla", "Nunn", "Oak Creek", "Olathe", "Ophir", "Orchard", "Otis", "Ouray", 
									"Ovid", "Padroni", "Pagosa Springs", "Palisade", "Paoli", "Paonia", "Parachute", "Paradox", 
									"Parlin", "Parshall", "Peetz", "Phippsburg", "Pierce", "Pitkin", "Placerville", "Platteville", 
									"Pleasant View", "Powderhorn", "Rand", "Rangely", "Red Cliff", "Red Feather Lakes", "Redvale", 
									"Rico", "Ridgway", "Rifle", "RIFLE", "Sargents", "Severance", "Silt", "Silverthorne", "Silverton", 
									"Slater", "Snowmass", "Snowmass Village", "Snyder", "Somerset", "Steamboat Springs", 
									"Sterling", "Stoneham", "Stratton", "Tabernash", "Telluride", "TELLURIDE", "Timnath", "Toponas", 
									"Towaoc", "Vail", "VAIL", "Vernon", "Walden", "Weldona", "Wellington", "WELLINGTON", "Whitewater",
									"WHITEWATER", "Wiggins", "WIGGINS",
									"Windsor", "Winter Park", "WINTER PARK", "Wolcott", "Woodrow", "Woody Creek", "Wray", "Yampa", "YAMPA",
									"Yellow Jacket", "Yuma", "YUMA" )
															THEN concat("970-", a.cell_phone)

			WHEN length(a.cell_phone) = 9 AND (c.city = "Ft.collins") THEN concat("970" , a.cell_phone)

			####### REPLACE functions for cell phones that already exist in full #########################
			####### REPLACE REPLACE REPLACE REPLACE REPLACE ##########################################
			####### REPLACE REPLACE REPLACE REPLACE REPLACE REPLACE ###########################################
			WHEN a.cell_phone IS NOT NULL
				AND a.cell_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 	### without ^ and $ it makes sure to find the ones that have real phone 
																								### --> numbers tucked in between pure bullshit
				AND a.cell_phone != ""  ####!!!!!!!!!!!!!!!!!! good god, the LACK of this line really mucked things up. when it WASN'T here
										#### -----------------> then MySQL looked for even the blank entries and basically did nothing to them
										#### -----------------------> which just meant I had a shit-ton of blank entries. 
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
																																				REPLACE(a.cell_phone, '/', '-')
																																					, ' BAD', '')
																																				, ' DNC', '')
																																			, ' (DNC)', '')
																																		, ' (do not call)', '')
																																	, ' (dnc)', '')
																																, ' (work)', '')
																															, ' (husband)', '')
																														, ' (wife)', '')
																													, 'NC ', '')
																												, 'CC ', '')
																											, 'NIS ', '')
																										, 'NIS', '')
																									, '(00 )    -', '')
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
			
			#### for the cases when the cell phone exists, but was entered without the hyphens
			WHEN length(a.cell_phone) = 12
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$' THEN REPLACE(a.cell_phone, ' ', '-')

			#### for the cases when a cell phone does not exist because there is no data in aux_client BUT THERE IS a FULL (12 character) home phone number available in client table
			WHEN c.ss_number NOT IN (SELECT ss_number FROM aux_client) 
				AND a.cell_phone IS NULL
				AND length(c.home_phone) = 12
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 	### the beginning and ending characters make sure we're only pulling the 
																									### --> home phone that is exactly the same as a regular phone number
																									### --> although it occurs to me that this is kind of unnecessary since 
																									### --> I have already limited the length . . . oh well!
					THEN IF(	(	c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
									OR c.home_phone REGEXP '^ [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$') , trim(c.home_phone), '')
			####### okay, screw it. I already deleted the other two statements that kind of handled this, haha. I'll leave this one ^^^^^^^, since it is just super simple. 


			##### now the same thing, but if the aux_client DOES exist, just the cp is burned, but the HP is perfect to replace it (easily)
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client) 
				AND (
						a.cell_phone IS NULL
						OR a.cell_phone IN (	"303-" , "303 ","none" ,"303-none" , "0000" , "DISC" , "disc", "discon", "N/A/" ,"Disconnnected" ,"disconnected" ,"?" , "N" , "N/A" , "n/c" , "N/A`",
									"N/A-" , "n/a(cell)" , "Disconnected" , "O00" , "STORE#1006" , "NA", "No Phone", "same", "Same", "see application", "no home phone",
									"NO #", "nione", "New Phone", "STORE# 1005", "STORE# 1004", "STORE# 1003", "STORE# 1002" , "STORE# 1001", "UNLISTED 411",
									"11" ,"111" , "x" , "X" , "XZ", "NA" , "xx" ,"XX" , "XXX" , "xxx xxx xxxx" , "xx-" , "X" , "XZ" , "00", "0", "000", "0000", "00000", "000000", "0000000",
									"0000000", "00000000", "000000000"," X", "(000)    -", "*", "(00 )    -", "(   )    -", "( 00)    -", "719-", "(719)    -", "( 71) 9  -", "719", "720", "970", "303",
									"0", "xxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxx", "xxxxxxxxxx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", "xxxxxxxxx", 
									"DNC", "dnc", "DO NOT CALL", "000", "720-", "303-", "720", "303", "", "XXX-XXX-XXX", "XXX-XXX-XXXX", "xxx-xxx-xxxx", "( 00)    -"
									"NOT VALID", "NIS", "na", "NA", "nA", "Na", "(00 )    -", "(   )    -")
						OR (a.cell_phone REGEXP '[a-z]' AND a.cell_phone NOT REGEXP '[0-9]' )
				AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
					) ### the beginning and ending characters make sure we're only pulling the 
																									### --> home phone that is exactly the same as a regular phone number
																									### --> although it occurs to me that this is kind of unnecessary since 
																									### --> I have already limited the length . . . oh well!
					THEN IF(	(	c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
									OR c.home_phone REGEXP '^ [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$') , trim(c.home_phone), '')


			#### !!!!!!!!!!!!!!!!!!!!OKay, so here's the deal: if the cell phone has data in it (like "same" or "nc") then we will want to remove that and replace it with
										###### --> the home phone data. So long as the home phone data is already clean. Which means . . . something. 
			######### nope, bump that. I'm deleting this one too ####################
			################# DELETED BY DAVE ON 12/10/2019 #########################

			###### Concats the correct number when the CP is PERFECT but 8 digits long, and the HP is OKAY, but only 8 characters long |||| OG statement from October probably
			###### what the f did I mean by this? ^^^^^^^^ If the CP is perfect then why am I doing ANYTHING? maybe concat fromt he home phone if the 
			###### CP is just missing the first three? I guess? 
			###### no, this is using the driver licene if the home phone and city are fried. At least, that's how I edited it to make sense on 12/11/19. because well, Ihave no idea WTF I was
			###### going for here. so edited down, now the hp is a bust, and the city is a bust, but the cp is perfec minus the prefix. sweet mother. 
			WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				AND length(a.cell_phone) = 8 AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' # make sure we select only THESE cell phones
				AND (length(c.home_phone) <= 8 OR c.home_phone REGEXP '[a-z]' OR c.home_phone = '' OR c.home_phone IS NULL)  # to make sure that the home phone is a bust
				AND (c.city IS NULL OR c.city = '') 
				AND c.driver_license IS NOT NULL
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

			############## APPEND THAT MUHFUGGIN PREFIX, YA SHITHEAD!
			############## APPEND APPEND APPEND APPEND APPEND APPEND APPEND APPEND
			###########################################################################

			WHEN length(a.cell_phone) = 8 
				AND (
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"Akron", "Almont", "Amherst", "Anton", "Arboles", "Aspen", "ASPEN", "Atwood", "Ault", "Austin", 
									"Avon", "AVON", "Basalt", "Battlement Mesa", "Bayfield", "Bedrock", "Bellvue", "Berthoud", "BERTHOUD",
									"Breckenridge", "BRECKENRIDGE", "Briggsdale", "Brush", "Burns", "Cahone", "Carbondale", "CARBONDALE", "Carr", 
									"Cedaredge", "Chimney Rock", "Chromo", "Cimarron", "Clark", "CLARK", "Clifton", "Coalmont", 
									"Collbran", "Cope", "Cortez", "Cory", "Cowdrey", "Craig", "Crawford", "Crested Butte", "CRESTED BUTTE",
									"Crook", "De Beque", "Delta", "DELTA", "Dillon", "DILLON", "Dinosaur", "Dolores", "Dove Creek", "Drake", 
									"Durango", "DURANGO", "Eagle", "EAGLE", "Eaton", "Eckert", "Eckley", "Edwards", "Egnar", "Estes Park", "ESTES PARK", 
									"Evans", "EVANS",
									"Fleming", "Fort Collins", "FT COLLINS", "FC", "FORT COLLINS", "Fort Morgan", "Fraser", 
									"Frisco", "FRISCO", "Fruita", "FRUITA", "Galeton", "Gateway", 
									"Gilcrest", "Gill", "Glade Park", "Glen Haven", "Glenwood Springs", "GLENWOOD SPGS", "Granby", "GRANBY",
									"Grand Junction", "GRAND JCT",
									"GRAND JUNCTION", "GJ",
									"Grand Lake", "Greeley", "GREELEY", "GLY", "Grover", "Gunnison", "Gypsum", "Hamilton", "Haxtun", "Hayden", 
									"Hesperus", "Hillrose", "Holyoke", "Hot Sulphur Springs", "Hotchkiss", "Idalia", "Ignacio", 
									"Iliff", "Joes", "Johnstown", "JOHNSTOWN", "Julesburg", "Kersey", "Kirk", "Kremmling", "La Salle", 
									"Lake City", "Laporte", "Lazear", "Lewis", "Lindon", "Livermore", "Log Lane Village", 
									"Loma", "LOMA", "Loveland", "LOVELAND", "Lucerne", "Mack", "Mancos", "Marvel", "Masonville", "Maybell", 
									"McCoy", "Mead", "MEAD", "Meeker", "Meredith", "Merino", "Mesa", "MESA", "Mesa Verde National Park", 
									"Milliken", "Minturn", "Molina", "Montrose", "MONTROSE", "Naturita", "New Castle", "New Raymer", 
									"Norwood", "Nucla", "Nunn", "Oak Creek", "Olathe", "Ophir", "Orchard", "Otis", "Ouray", 
									"Ovid", "Padroni", "Pagosa Springs", "Palisade", "Paoli", "Paonia", "Parachute", "Paradox", 
									"Parlin", "Parshall", "Peetz", "Phippsburg", "Pierce", "Pitkin", "Placerville", "Platteville", 
									"Pleasant View", "Powderhorn", "Rand", "Rangely", "Red Cliff", "Red Feather Lakes", "Redvale", 
									"Rico", "Ridgway", "Rifle", "RIFLE", "Sargents", "Severance", "Silt", "Silverthorne", "Silverton", 
									"Slater", "Snowmass", "Snowmass Village", "Snyder", "Somerset", "Steamboat Springs", 
									"Sterling", "Stoneham", "Stratton", "Tabernash", "Telluride", "TELLURIDE", "Timnath", "Toponas", 
									"Towaoc", "Vail", "VAIL", "Vernon", "Walden", "Weldona", "Wellington", "WELLINGTON", "Whitewater",
									"WHITEWATER", "Wiggins", "WIGGINS",
									"Windsor", "Winter Park", "WINTER PARK", "Wolcott", "Woodrow", "Woody Creek", "Wray", "Yampa", "YAMPA",
									"Yellow Jacket", "Yuma", "YUMA" )
					)
																							THEN concat("970-", a.cell_phone) 
			###### -----> appending a prefix when the city is in the Denver / Metro area and could be 720 or 303 - check cell phone and home phone
			WHEN length(a.cell_phone) = 8 
				AND (
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"Allenspark", "Arvada", "ARVADA", "AEVADA", "Aurora", 
								"AURORA", "AURARA", "Bailey", "Bennett", "Black Hawk", "Bond",
								"Boulder", "Brighton", "BRIGHTON", "Broomfield", "BROOMFIELD", "Buffalo Creek", "Byers", "Castle Rock", 
								"Central City", 
								"Commerce City", "COMMERCE CITY", "Conifer", "Dacono", "Deer Trail", "Denver", 
								"DENVER", "Dumont", "Dupont", "Federal Heights",
								"Eastlake", "Elbert", "Eldorado Springs", "Elizabeth", "Empire", "Englewood", "Erie", "Evergreen", 
								"Fed Heights", "FED HIGHT'", "FED HIGHT`", "FEDERAL HTS", "FEDERAL HIGHTS", "FEDERAL HGTS",
								"FED. HTS",
								"Firestone", "Fort Lupton", "Franktown", "Frederick", "Georgetown", "Golden", "Grant", 
								"Henderson", "Hereford", "Highlands Ranch", "Hudson", "Hygiene", "Idaho Springs", "Idledale", 
								"Indian Hills", "Jamestown", "Keenesburg", "Kiowa", "Kittredge", "KITTREDGE", "Lafayette", "Lakewood", 
								"Larkspur", "Littleton", "Longmont", "Louisville", "Louiville", "Louviers", "Lyons", "Morrison", 
								"Nederland", "Niwot", "Northglenn", "NORTHGLENN", "NORTHGENN", "NORTHGLEN", "Parker", "Pine", "Pinecliffe",
								"Roggen", "Rollinsville", 
								"Sedalia", "Sedgwick", "Shawnee", "Silver Plume", "Strasburg", 
								"Thornton", "Thorton", "THORNTON", "THRNTON", "THRONTON", "THONTON", "Ward", 
								"Watkins", "Westminster", "Westminister", "WESTMINSTER", "WESTMINTSTER", "W.estminster"
								"Wheat Ridge", "WHEATRIDGE", "WHEAT RIDGE")
					)
																						THEN IF	(left(c.home_phone, 3) = "720", concat("720-", a.cell_phone), 
																								IF (left(c.home_phone, 3) = "303", concat("303-", a.cell_phone), concat("303-", a.cell_phone))
																									#IF 	(c.home_phone IS NULL AND a.cell_phone IS NOT NULL ,
																																#IF 	(left(a.cell_phone, 3) = "720", concat("333333333-", c.work_phone), 
																																	#IF	(left(a.cell_phone, 3) = "303", concat("44444444-", c.work_phone), concat("55555555-", c.work_phone) )
																																	#), c.work_phone
																										)
																									#)
																								#)
																									
																								
																		#IF	(left(a.cell_phone, 3) = 303, concat("bbb", c.work_phone),
																			#IF	(a.cell_phone IS NULL, work_phone, '')
																			#)
																		#)
																									#IF	(left(c.home_phone, 3) = 720, concat("720-", c.work_phone),
																										#IF	(left(c.home_phone, 3) = 303, concat("303-", c.work_phone), 
																											#IF	(c.home_phone IS NULL, c.work_phone, '')
																											#)
																										#)
																				#)
																#)

			WHEN length(a.cell_phone) = 8 
				AND (
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"Agate", "Aguilar", "Alamosa", "Alma", "Antonito", "Arapahoe", "Arlington", "Arriba", "Avondale", "Bethune",
								"Beulah", "Blanca", "Boncarbo", "Boone", "Branson", "Buena Vista", "Burlington", "Calhan", "Campo", "Canon City",
								"Capulin", "Cascade", "Center", "Chama", "Cheraw", "Cheyenne Wells", "Climax", "Coal Creek", "Coaldale", 
								"Colorado City", "Colorado Springs", "Como", "Conejos", "Cotopaxi", "Creede", "Crestone", "Cripple Creek", 
								"Crowley", "Del Norte", "Divide", "Eads", "Fairplay", "Flagler", "Florence", "Florissant", "Fort Garland", 
								"Fort Lyon", "Fountain", "Fowler", "Gardner", "Genoa", "Granada", "Granite", "Green Mountain Falls", "Guffey", 
								"Hartman", "Hartsel", "Hasty", "Haswell", "Hillside", "Hoehne", "Holly", "Homelake", "Hooper", "Howard", 
								"Hugo", "Jaroso", "Jefferson", "Karval", "Kim", "Kit Carson", "La Jara", "La Junta", "La Veta", "Lake George", 
								"Lamar", "Las Animas", "Leadville", "Limon", "Manassa", "Manitou Springs", "Manzanola", "Matheson", "Mc Clave", 
								"Model", "Moffat", "Monarch", "Monte Vista", "Monument", "Mosca", "Nathrop", "Ohio City", "Olney Springs", 
								"Ordway", "Palmer Lake", "Penrose", "Peyton", "Poncha Springs", "Pritchett", "Pueblo", "Ramah", "Rockvale", 
								"Rocky Ford", "Romeo", "Rush", "Rye", "Saguache", "Salida", "San Luis", "Sanford", "Seibert", "Sheridan Lake", 
								"Simla", "South Fork", "Springfield", "Sugar City", "Swink", "Trinchera", "Trinidad", "Twin Lakes", 
								"Two Buttes", "Usaf Academy", "Victor", "Vilas", "Villa Grove", "Vona", "Walsenburg", "Walsh", "Westcliffe", 
								"Weston", "Wetmore", "Wild Horse", "Wiley", "Woodland Park", "Yoder")
					)
										THEN concat("719-", a.cell_phone)

			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("WY", "Wy", "wY", "wy") 
					THEN concat("370-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("MT", "Mt", "mT", "mt") 
					THEN concat("306-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("ID", "Id", "iD", "id") 
					THEN concat("208-",a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND (
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"APPLE VALLEY", "HESPERIA", "A.V", "Adelanto", "Adelanto CA", "Altadena", "ANpple Valley", 
								"APPLE  VALLEY", "Apple alley", 
								"APPLE VAALEY", "Apple Vaklley", "APPLE VAL;LEY", "Apple valey", "Apple Vallet", 
								"APPLE VALLEWY", "Apple Valley", "Apple Valley Ca", "APPLE VALLWY", "Apple vally", 
								"Apple Vaslley", "Apple Vslley", "AppleValley", "Appley Valley", "APPLR VALLEY", "AV", 
								"AZUSA", "BARSTOW", "Bellflower", "BORON", "CALIF CITY", 
								"FORT IRWIN", 
								"Ft Irwin", "GRAND TERRACE", "Helendale", "Hesperia", "HESRPERIA", 
								"HXX", "JOHNSON  VALLEY", "JOSHUA TREE", "Lacern Valley", 
								"Landers", "Las Vegas", "Licerne valley", "Lomita", "Lucerbe Valley", 
								"Lucerene Valley", "Lucerne  valley", "Lucerne Valley", 
								"Lucerne Vly", "LUCERNEN  VLY", "LUCERNEVALLEY", "Lurcerne Valley", "LUUCERNE VLY VALLEY", 
								"Morongo Valley", "N. HOLLYWOOD", "Nampa", "Newberry Springs", "OAK HILLS", 
								"OKLAHOMA CITY", "ORO GRADE", "Oro Grande", "Perris", "Phelan", "PINON HILLS", 
								"Polson", "RIDGECREST", 
								"TEMPLE CITY", 
								"Victor Ville", "Victortvville", "VICTORVIILE", "Victorville", 
								"Victorville CA", "Victorville", "VICTORVILLEca", "Victoville", "WEST COVINA", 
								"WESTMINSTER", "WRIGHTWOOD", "YERMO") 
						)
									THEN concat("760-", a.cell_phone)

			WHEN length(a.cell_phone) = 8 
				AND ( 
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"Anaheim", "ANAHEIM HILLS", "ANAHIEM", "HUNTINGTON BCH", "Huntington Beach", "Yorba Linda", 
										"Yorbe Linda")	
					)
															THEN concat("714-", a.cell_phone)		
						
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ( "Los Angeles", "LOSANGELES", "Hollywood", "N. HOLLYWOOD", "Rosemead", "RISEMEAD" ) 
															THEN concat("213-", a.cell_phone)

			WHEN length(a.cell_phone) = 8 
				AND (
						a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						AND c.city IN (	"Angelus Oaks", "Big Bear City", "Big Bear Lake",  "Big bear city", "BIG BEAR LAKE", 
								"Bloomington", "Blue Jay", "Bryn Mawr", "Calimesa", "Cedar Glen", "Cedarpines Park", "Chino", 
								"CHINO", "Chino Hills", "Claremont", "Colton", 
								"Crest Park", "Crestline", "Diamond Bar", "Fawnskin", "Fontana", "Forest Falls", "Green Valley Lake", 
								"Guasti", "Highland", "La Verne", "Lake Arrowhead", "Loma Linda", "Lytle Creek", "Mentone", 
								"Montclair", "Mount Baldy", "Moreno Valley", "MORENO VALLEY", "Ontario", "ONTARIO", "Patton", "Pomona", "POMONA", "Rancho Cucamonga", "Redlands", 
								"Rialto", "Rimforest", "Running Springs", "San Bernardino", "SAN BERNRDNO", "San Dimas", "Skyforest",
								"Sugarloaf", 
								"Twin Peaks", "Upland", "Walnut", "WEST COVINA", "West Covina", "Yucaipa")
							)
								THEN concat("909-", a.cell_phone) 

			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Bellflower") THEN concat("562-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Trenton") THEN concat("609-",a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Van Nuys") THEN concat("818-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Clovis") THEN concat("559-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Coldwater", "COLDWATER") THEN concat("517-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("CA")
				AND c.city IN ("Fresno") THEN concat("559-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Hemet",  "HEMET", "Homeland", "Riverside") THEN concat("951-", a.cell_phone)	
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("West Camino") THEN concat("530-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Lancaster", "LANCASTER") THEN concat("661-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Napa") THEN concat("707-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("San Pedro") THEN concat("310-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Sierra Vista",  "SIERRA VISTA") THEN concat("520-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Spring Lake", "SPRING VALLEY LAKE", "Campo") THEN concat("619-", a.cell_phone)
			WHEN length(a.cell_phone) = 8 
				AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Temple City", "TEMPLE CITY") THEN concat("626-", a.cell_phone)

			####### okay, if the cell phone is just ddd-dddd, and the hp is perfect
			####### then concat the prefix from the home phone onto the cell phone, which I just realized is stupid because how many people have a home phone that was issued
			####### in the same city as the cell phone? very few, Dave, very few indeed. so nuts to this query too. accessible

			#WHEN c.ss_number IN (SELECT ss_number FROM aux_client)
				#AND length(a.cell_phone) = 8
				#AND length(c.home_phone) REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$	'	
					#THEN concat(left(c.home_phone, 4), a.cell_phone)

			########### EJECTED WHEN STATEMENT ##################
			####Nope. Trying to salvage a broken CP by using a partly broken HP. F. That.  ########
			########### EJECTED WHEN STATEMENT ##################

	
			############## ---> used when the SSN exists in aux_client and client, but the cell phone does NOT exist AND the home phone is less than 12
			##########DELETED ##### # Christ, this is overloaded with bullshit

			########## killed another WHEN statement 12/10/2019. Basically replaaced the CP with the HP. . AGAIN! Unnecessary! ####################

			##### THIS KILLS A LOT OF WHAT CAME BEFORE: in the interest of time. Meh. I think it just makes more sense. #### DEADCPCODE ######
			##### -----> fuuuuuck. Really, past Dave? REally!!!??——Dave 12/10/19
			WHEN c.ss_number NOT IN (SELECT ss_number FROM aux_client)
				AND c.home_phone REGEXP '[a-z]'
				AND a.cell_phone IS NULL
					THEN ''
			#______________________________________________________________________________________________________
			# !!!!!!!!!!!!!!!!!!!!!!! Hrm, not sure if I'm ready to kill everything just yet
			# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -----
			#WHEN c.ss_number NOT IN (SELECT ss_number FROM aux_client) AND a.cell_phone IS NULL THEN ''	### this one is the nail in the coffin. If the hope was to bring the HP over to the CP , it ain't gon' happen now. 
			##_______________________________________________________________________________________________________

			WHEN length(a.cell_phone) = 11 AND a.cell_phone REGEXP '[^a-z]' AND a.cell_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$' ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
				THEN INSERT(a.cell_phone, 8, 0, '-')
			
			ELSE trim(a.cell_phone)

		END) AS "Cell Phone" , 

		

		IF( (a.email = "none"
				OR a.email = "NA"
				OR a.email = "N/A"
				OR a.email = "noine"
				OR a.email IN ("x", "xx", "X", "XX")
				OR a.email IS NULL ) , '', a.email) AS 'Email' ,

		#IF( (c.payday_schedule IS NULL) , "BiWeekly", IF(c.payday_schedule = "Bi-Weekly", "BiWeekly", 
			#									IF	(c.payday_schedule = "Bi-Monthly", "SemiMonthly", c.payday_schedule)
			#									) 
			#) AS 'Pay Frequency', #### maybe the (if payday blablabla is null, then '')  is throwing me the "Nullable object error"? I changed it to fill "BiWeekly" instead. 

		IF(   ( a.net_from_paystubs IS NULL OR a.net_from_paystubs = '' 
				OR a.net_from_paystubs REGEXP '[a-z]' 
				OR a.net_from_paystubs REGEXP '^00'
				OR a.net_from_paystubs REGEXP '^0.00'), '0.00', trim(format(a.net_from_paystubs, 2))) AS 'Monthly Income', 


		
	#(    ####### FINDPD
		#CASE
			#WHEN c.payday IS NOT NULL THEN date_format(trim(c.payday), "%m-%d-%Y")
			#WHEN c.payday IS NULL OR c.payday REGEXP '[a-z]' THEN ""
			#ELSE ""  #### updated the dates here. used to be 1-1-1996. I was getting a "nullable object" error, so I tried this out. 
														#### THEN I updated the date_format thinking that maybe the CSV was somehow retaining that data type?
					#########CONFIRMED CONDFIRMED CONFIRMED --- this IS the NULLABLE object in question. And yet, it is required for some reason. Maybe if I delete
					######### --> the pay frequency too? dc 12/11/2019

	#END) AS 'First Payday',
		

	(	####### FINDEMP
		CASE
			WHEN c.employer IN ( 	"X", "N/A", "N/a", "NA", "na", "XXX", "None", "none", "A", "?", "Aaaaaa", "B", "Cc", "Cccccccc", 
									"unemployed", "no longer employed", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", 
									"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") THEN ''

			WHEN c.employer REGEXP '^xx|^-*-$' THEN ''
			ELSE REPLACE(
					REPLACE(c.employer, '"', '')
						, "'", '')

	END) AS 'Employer', 
	

	( 	############# FINDWP ####################################################
		#########################################################################################################
		CASE

	
			######### ----> DELETIONS DELETIONS DELETIONS, deleting all the empty, previously deleted, or bad # cases
			WHEN c.work_phone IS null
					OR c.work_phone IN (	"NA", "na", "Na", "nA", "N/A", "n/a", "N/a", "n/A", "none", "None", "NONE", "SSD", "SSDI", 
										"SSI", "VA", "x", "X", "000 ", "000-0000", "123-1234", 
										"xx", "XX", "XXX", "0", "00", "303-", "000", "---", "00", "0000", "00000", "0000000000", 
										"1", "11", "111", "000-0000", "(   )    -", "(000)    -", "(00 )    -", "000 0000", "(000)  00-00", "(719)    -",
										"(111)    -", "(720)    -", "(720)    -", "(970)    -", "(000)    -", "(307)    -", "(303)    -") 
					OR length(c.work_phone) <= 7
					OR c.work_phone REGEXP '[a-z]|[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]|^XX|^X|^x|[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
					OR c.work_phone REGEXP '^\\( [0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] #[0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^\\([0-9][0-9][0-9]\\) [0-9][0-9][0-9]-[0-9]$'
					OR c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^\\([0-9][0-9][0-9]\\)  [0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR (length(c.work_phone) = 13 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$')
					OR (length(c.work_phone) = 14 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]  [0-9][0-9][0-9][0-9]$')
					OR (length(c.work_phone) = 15 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] \\([0-9][0-9][0-9][0-9]\\)$')
					OR (length(c.work_phone) = 13 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]  [0-9][0-9][0-9]$')
					OR (length(c.work_phone) = 12 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] [0-9][0-9][0-9]')
					OR (length(c.work_phone) = 12 AND c.work_phone REGEXP '^\\( [0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9]$')
					OR (length(c.work_phone) = 14 AND c.work_phone REGEXP '^\\( [0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$') 
					OR length(c.work_phone) >= 16
					OR (length(c.work_phone) = 9 AND c.work_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
						THEN ''#### I decided just to delete 'em. More hassle than they're worth.
								##### use 7 so that we can rescue those that might only need a prefix and a hyphen if necessary




			######### ----> APPENDATION APPENDATION APPENDATION (I'm not sure if that's a word. I'm not going to look it up though, cuz f*ck that. I live on the edge, mang. 11/13/2019
			######### ----> appending the correct prefix when the work phone is exactly 8 characters long
			WHEN length(c.work_phone) = 8 
				AND (
						(c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$' 
						OR c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$')	###  Blergh. I didn't have these other possible phone iterations inside parentheses before which meant, the query was taking
																							### any phone number that just matched the regex. which means that,well, probably Fort Collins at least is dirty. Although, since
																							### 970 came first, then we might be okay. MAYBE littleton is dirty. I don't think I adjusted it then though. 
						AND c.city IN (	"Akron", "Almont", "Amherst", "Anton", "Arboles", "Aspen", "ASPEN", "Atwood", "Ault", "Austin", 
									"Avon", "AVON", "Basalt", "Battlement Mesa", "Bayfield", "Bedrock", "Bellvue", "Berthoud", "BERTHOUD",
									"Breckenridge", "BRECKENRIDGE", "Briggsdale", "Brush", "Burns", "Cahone", "Carbondale", "CARBONDALE", "Carr", 
									"Cedaredge", "Chimney Rock", "Chromo", "Cimarron", "Clark", "CLARK", "Clifton", "CLIFTON,", "Coalmont", 
									"Collbran", "Cope", "Cortez", "Cory", "Cowdrey", "Craig", "Crawford", "Crested Butte", "CRESTED BUTTE",
									"Crook", "De Beque", "DEBEQUE", "Debeque", "Delta", "DELTA", " DELTA", "Dillon", "DILLON", "Dinosaur", "Dolores", "Dove Creek", "Drake", 
									"Durango", "DURANGO", "Eagle", "EAGLE", "Eaton", "Eckert", "Eckley", "Edwards", "Egnar", "Estes Park", "ESTES PARK", 
									"Evans", "EVANS",
									"Fleming", "Fort Collins", "FT COLLINS", "Ft.collins", "FC", "FORT COLLINS", "Fort Morgan", "Fraser", 
									"Frisco", "FRISCO", "Fruita", "FRUITA", "Galeton", "Gateway", 
									"Gilcrest", "Gill", "Glade Park", "Glen Haven", "Glenwood Springs", "GLENWOOD SPGS", "Granby", "GRANBY",
									"Grand Junction", "GRAND JCT", "GRAND JCT.", "GRAN D JCT", "GRAND JCT.`",
									"GRAND JUNCTION", "GRAND  JUNCTION", "GJ", "GRND JCT", "GRAND JUNCTION,", "GRAND JUNCTION."
									"Grand Lake", "Greeley", "GREELEY", "GLY", "Grover", "Gunnison", "Gypsum", "Hamilton", "Haxtun", "Hayden", "HAYDEN",
									"Hesperus", "Hillrose", "Holyoke", "Hot Sulphur Springs", "Hotchkiss", "Idalia", "Ignacio", 
									"Iliff", "Joes", "Johnstown", "JOHNSTOWN", "Julesburg", "Kersey", "Kirk", "Kremmling", "La Salle", 
									"Lake City", "Laporte", "Lazear", "Lewis", "Lindon", "Livermore", "Log Lane Village", 
									"Loma", "LOMA", "Loveland", "LOVELAND", "Lucerne", "Mack", "Mancos", "Marvel", "Masonville", "Maybell", 
									"McCoy", "Mead", "MEAD", "Meeker", "Meredith", "Merino", "Mesa", "MESA", "Mesa Verde National Park", 
									"Milliken", "Minturn", "Molina", "Montrose", "MONTROSE", "Naturita", "New Castle", "New Raymer", 
									"Norwood", "Nucla", "Nunn", "Oak Creek", "Ogden", "Olathe", "Ophir", "Orchard", "Otis", "Ouray", 
									"Ovid", "Padroni", "Pagosa Springs", "Palisade", "Paoli", "Paonia", "Parachute", "Paradox", 
									"Parlin", "Parshall", "Peetz", "Phippsburg", "Pierce", "Pitkin", "Placerville", "Platteville", 
									"Pleasant View", "Powderhorn", "Rand", "Rangely", "Red Cliff", "Red Feather Lakes", "Redvale", 
									"Rico", "Ridgway", "Rifle", "RIFLE", "Sargents", "Severance", "Silt", "Silverthorne", "Silverton", 
									"Slater", "Snowmass", "Snowmass Village", "Snyder", "Somerset", "Steamboat Springs", 
									"Sterling", "Stoneham", "Stratton", "Tabernash", "Telluride", "TELLURIDE", "Timnath", "Toponas", 
									"Towaoc", "Vail", "VAIL", "Vernon", "Walden", "Weldona", "Wellington", "WELLINGTON", "Whitewater",
									"WHITEWATER", "Wiggins", "WIGGINS",
									"Windsor", "Winter Park", "WINTER PARK", "Wolcott", "Woodrow", "Woody Creek", "Wray", "Yampa", "YAMPA",
									"Yellow Jacket", "Yuma", "YUMA" )
							)
											THEN 	IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$', concat("970-", REPLACE(c.work_phone, '.', '-')), 
														IF	(c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$', concat("970-", REPLACE(c.work_phone, ' ', '-')), 
															IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$', concat("970-", REPLACE(c.work_phone, '/', '-')),
																IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', concat("970-", c.work_phone), '')
																)
															)
														)


			###### -----> appending a prefix when the city is in the Denver / Metro area and could be 720 or 303 - check cell phone and home phone
			WHEN length(c.work_phone) = 8 
				AND (
						( c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$')
						AND c.city IN (	"Allenspark", "Arvada", "ARVADA", "AEVADA", "Aurora", 
								"AURORA", "AURARA", "Bailey", "Bennett", "Black Hawk", "Bond",
								"Boulder", "Brighton", "BRIGHTON", "Broomfield", "BROOMFIELD", "Buffalo Creek", "Byers", "Castle Rock", 
								"Central City", 
								"Commerce City", "COMMERCE CITY", "Conifer", "Dacono", "Deer Trail", "Denver", 
								"DENVER", "Dumont", "Dupont", "Federal Heights",
								"Eastlake", "Elbert", "Eldorado Springs", "Elizabeth", "Empire", "Englewood", "Erie", "Evergreen", 
								"Fed Heights", "FED HIGHT'", "FED HIGHT`", "FEDERAL HTS", "FEDERAL HIGHTS", "FEDERAL HGTS",
								"FED. HTS",
								"Firestone", "Fort Lupton", "Franktown", "Frederick", "Georgetown", "Golden", "Grant", 
								"Henderson", "Hereford", "Highlands Ranch", "Hudson", "Hygiene", "Idaho Springs", "Idledale", 
								"Indian Hills", "Jamestown", "Keenesburg", "Kiowa", "Kittredge", "KITTREDGE", "Lafayette", "Lakewood", 
								"Larkspur", "Littleton", "Longmont", "Louisville", "Louiville", "Louviers", "Lyons", "Morrison", 
								"Nederland", "Niwot", "Northglenn", "NORTHGLENN", "NORTHGENN", "NORTHGLEN", "Parker", "Pine", "Pinecliffe",
								"Roggen", "Rollinsville", 
								"Sedalia", "Sedgwick", "Shawnee", "Silver Plume", "Strasburg", 
								"Thornton", "Thorton", "THORNTON", "THRNTON", "THRONTON", "THONTON", "Ward", 
								"Watkins", "Westminster", "Westminister", "WESTMINSTER", "WESTMINTSTER", "W.estminster"
								"Wheat Ridge", "WHEATRIDGE", "WHEAT RIDGE")
				)
																						THEN IF	(left(c.home_phone, 3) = "720", concat("720-", c.work_phone), 
																								IF (left(c.home_phone, 3) = "303", concat("303-", c.work_phone), concat("303-", c.work_phone))
																									#IF 	(c.home_phone IS NULL AND a.cell_phone IS NOT NULL ,
																																#IF 	(left(a.cell_phone, 3) = "720", concat("333333333-", c.work_phone), 
																																	#IF	(left(a.cell_phone, 3) = "303", concat("44444444-", c.work_phone), concat("55555555-", c.work_phone) )
																																	#), c.work_phone
																										)
																									#)
																								#)
																									
																								
																		#IF	(left(a.cell_phone, 3) = 303, concat("bbb", c.work_phone),
																			#IF	(a.cell_phone IS NULL, work_phone, '')
																			#)
																		#)
																									#IF	(left(c.home_phone, 3) = 720, concat("720-", c.work_phone),
																										#IF	(left(c.home_phone, 3) = 303, concat("303-", c.work_phone), 
																											#IF	(c.home_phone IS NULL, c.work_phone, '')
																											#)
																										#)
																				#)
																#)

			WHEN length(c.work_phone) = 8 
				AND( 
						(c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$')
						AND c.city IN (	"Agate", "Aguilar", "Alamosa", "Alma", "Antonito", "Arapahoe", "Arlington", "Arriba", "Avondale", "Bethune",
								"Beulah", "Blanca", "Boncarbo", "Boone", "Branson", "Buena Vista", "Burlington", "Calhan", "Campo", "Canon City",
								"Capulin", "Cascade", "Center", "Chama", "Cheraw", "Cheyenne Wells", "Climax", "Coal Creek", "Coaldale", 
								"Colorado City", "Colorado Springs", "Como", "Conejos", "Cotopaxi", "Creede", "Crestone", "Cripple Creek", 
								"Crowley", "Del Norte", "Divide", "Eads", "Fairplay", "Flagler", "Florence", "Florissant", "Fort Garland", 
								"Fort Lyon", "Fountain", "Fowler", "Gardner", "Genoa", "Granada", "Granite", "Green Mountain Falls", "Guffey", 
								"Hartman", "Hartsel", "Hasty", "Haswell", "Hillside", "Hoehne", "Holly", "Homelake", "Hooper", "Howard", 
								"Hugo", "Jaroso", "Jefferson", "Karval", "Kim", "Kit Carson", "La Jara", "La Junta", "La Veta", "Lake George", 
								"Lamar", "Las Animas", "Leadville", "Limon", "Manassa", "Manitou Springs", "Manzanola", "Matheson", "Mc Clave", 
								"Model", "Moffat", "Monarch", "Monte Vista", "Monument", "Mosca", "Nathrop", "Ohio City", "Olney Springs", 
								"Ordway", "Palmer Lake", "Penrose", "Peyton", "Poncha Springs", "Pritchett", "Pueblo", "Ramah", "Rockvale", 
								"Rocky Ford", "Romeo", "Rush", "Rye", "Saguache", "Salida", "San Luis", "Sanford", "Seibert", "Sheridan Lake", 
								"Simla", "South Fork", "Springfield", "Sugar City", "Swink", "Trinchera", "Trinidad", "Twin Lakes", 
								"Two Buttes", "Usaf Academy", "Victor", "Vilas", "Villa Grove", "Vona", "Walsenburg", "Walsh", "Westcliffe", 
								"Weston", "Wetmore", "Wild Horse", "Wiley", "Woodland Park", "Yoder")
					)
										THEN concat("719-", c.work_phone)
	
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("DECATURE") 
					THEN concat("404-", c.work_phone)

			WHEN length(c.work_phone) = 8
				AND ( 
						(c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
						OR (c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$' AND c.work_phone NOT REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$')
						OR c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$'
						OR c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$')	
						AND (c.state IN ("WY", "Wy", "wY", "wy")
							OR c.store IN ("CHY", "CAS", "LAR", "GIL", "RS"))
							OR c.city IN ("Laramie", "LARAMIE", "Cheyenne", "CHEYENNE", "Casper", "CASPER", "Rock Springs", "ROCK SPRINGS", "Gillette", "GILLETTE")
					)
					THEN 	IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]\\.[0-9][0-9][0-9][0-9]$', concat("307-", REPLACE(c.work_phone, '.', '-')), 
								IF	(c.work_phone REGEXP '^[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$', concat("307-", REPLACE(c.work_phone, ' ', '-')), 
									IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]\/[0-9][0-9][0-9][0-9]$', concat("307-", REPLACE(c.work_phone, '/', '-')),
										IF	(c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', concat("307-", c.work_phone), '')
										)
									)
								)


			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("MT", "Mt", "mT", "mt") 
					THEN concat("306-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.state IN ("ID", "Id", "iD", "id") 
					THEN concat("208-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN (	"APPLE VALLEY", "HESPERIA", "A.V", "Adelanto", "Adelanto CA", "Altadena", "ANpple Valley", 
								"APPLE  VALLEY", "Apple alley", 
								"APPLE VAALEY", "Apple Vaklley", "APPLE VAL;LEY", "Apple valey", "Apple Vallet", 
								"APPLE VALLEWY", "Apple Valley", "Apple Valley Ca", "APPLE VALLWY", "Apple vally", 
								"Apple Vaslley", "Apple Vslley", "AppleValley", "Appley Valley", "APPLR VALLEY", "AV", 
								"AZUSA", "BARSTOW", "Bellflower", "BORON", "CALIF CITY", 
								"FORT IRWIN", 
								"Ft Irwin", "GRAND TERRACE", "Helendale", "Hesperia", "HESRPERIA", 
								"HXX", "JOHNSON  VALLEY", "JOSHUA TREE", "Lacern Valley", 
								"Landers", "Las Vegas", "Licerne valley", "Lomita", "Lucerbe Valley", 
								"Lucerene Valley", "Lucerne  valley", "Lucerne Valley", 
								"Lucerne Vly", "LUCERNEN  VLY", "LUCERNEVALLEY", "Lurcerne Valley", "LUUCERNE VLY VALLEY", 
								"Morongo Valley", "N. HOLLYWOOD", "Nampa", "Newberry Springs", "OAK HILLS", 
								"OKLAHOMA CITY", "ORO GRADE", "Oro Grande", "Perris", "Phelan", "PINON HILLS", 
								"Polson", "RIDGECREST", 
								"TEMPLE CITY", 
								"Victor Ville", "Victortvville", "VICTORVIILE", "Victorville", 
								"Victorville CA", "Victorville", "VICTORVILLEca", "Victoville", "WEST COVINA", 
								"WESTMINSTER", "WRIGHTWOOD", "YERMO") 
									THEN concat("760-", c.work_phone)

			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN (	"Anaheim", "ANAHEIM HILLS", "ANAHIEM", "HUNTINGTON BCH", "Huntington Beach", "Yorba Linda", 
															"Yorbe Linda")	
															THEN concat("714-", c.work_phone)		
						
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ( "Los Angeles", "LOSANGELES", "Hollywood", "N. HOLLYWOOD", "Rosemead", "RISEMEAD" ) 
															THEN concat("213-", c.work_phone)

			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN (	"Angelus Oaks", "Big Bear City", "Big Bear Lake",  "Big bear city", "BIG BEAR LAKE", 
								"Bloomington", "Blue Jay", "Bryn Mawr", "Calimesa", "Cedar Glen", "Cedarpines Park", "Chino", 
								"CHINO", "Chino Hills", "Claremont", "Colton", 
								"Crest Park", "Crestline", "Diamond Bar", "Fawnskin", "Fontana", "Forest Falls", "Green Valley Lake", 
								"Guasti", "Highland", "La Verne", "Lake Arrowhead", "Loma Linda", "Lytle Creek", "Mentone", 
								"Montclair", "Mount Baldy", "Moreno Valley", "MORENO VALLEY", "Ontario", "ONTARIO", "Patton", "Pomona", "POMONA", "Rancho Cucamonga", "Redlands", 
								"Rialto", "Rimforest", "Running Springs", "San Bernardino", "SAN BERNRDNO", "San Dimas", "Skyforest",
								"Sugarloaf", 
								"Twin Peaks", "Upland", "Walnut", "WEST COVINA", "West Covina", "Yucaipa")
								THEN concat("909-", c.work_phone) 

			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Bellflower") THEN concat("562-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Trenton") THEN concat("609-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Van Nuys") THEN concat("818-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Clovis") THEN concat("559-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Coldwater", "COLDWATER") THEN concat("517-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Fresno") THEN concat("559-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Hemet",  "HEMET", "Homeland", "Riverside") THEN concat("951-", c.work_phone)	
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("West Camino") THEN concat("530-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Lancaster", "LANCASTER") THEN concat("661-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Napa") THEN concat("707-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("San Pedro") THEN concat("310-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Sierra Vista",  "SIERRA VISTA") THEN concat("520-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Spring Lake", "SPRING VALLEY LAKE", "Campo") THEN concat("619-", c.work_phone)
			WHEN length(c.work_phone) = 8 
				AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
				AND c.city IN ("Temple City", "TEMPLE CITY") THEN concat("626-", c.work_phone)

			##### --------> in cases where there is no home city, the wp is 8 characters long, and the home phone exists, but not the cell, then we'll 
			##### ------------> resort to the store ID and just pick a prefix. weeee! It occurs to me that we'll just have to ride or die either the home
			##### ----------------> phone or cell phone prefix, because we have so many f*cking cities to choose from that we don't have a choice. 
			##### --------------------> we COULD just put three 000s in the leading spot instead . . . that way we'll KNOW we need to look up the number. . . 
			##### ------------------------> actually, now that I think about it, that's probably the best way to go!
			WHEN length(c.work_phone) = 8 AND (c.city IS NULL OR c.city = '' OR c.city IN ("x", "xx", "X", "XX", "XXX", "xxx"))
				AND	(c.home_phone IS NULL OR c.home_phone = '' OR c.home_phone REGEXP '[a-z]' OR length(c.home_phone) < 12)
				AND (a.cell_phone IS NULL OR a.cell_phone = '' OR a.cell_phone REGEXP '[a-z]' OR length(a.cell_phone) < 12)
					THEN concat("000-", c.work_phone)
			

			########## WHY TF did I leave this in? It doesn't seem to do anything at all. SO the home phone is 12 digits log. . . so what? 
			########## Okay, I'll just redo it to actually be useful. I'll save the old version for posterity:
			#WHEN length(c.home_phone) = 12 AND length(c.work_phone) = 8 AND c.work_phone REGEXP '[^a-z]' AND c.work_phone REGEXP '\d\d\d-\d\d\d-\d\d\d\d'
				#AND (c.city IS NULL OR c.city = '' OR c.city IN ("x", "xx", "X", "XX", "XXX", "xxx")) 
					#THEN	IF	(length(c.home_phone) = 12, IF	(c.store IN ("AUR", "ARV", "LIT", "THN", "SD", "FH", "DEN", "FedH"), concat("303-", c.work_phone),
																#IF	(c.store IN ("FC", "GJ", "GLY", "LOV"), concat("970-", c.work_phone),
																	#IF	(c.store IN ("PBL"), concat("970-", c.work_phone ),
																		#IF	(c.store IN ("CAS", "CHY", "RS", "GIL", "LAR"), concat("307-", c.work_phone), 
																			#IF	(c.store IN ("BIL", "BUT", "MIS", "GF"), concat("406-", c.work_phone),
																				#IF	(c.store IN ("POC", "IDF"), concat("208-", c.work_phone), '')
																				#)
																			#)
																		#)
																	#)
																#), c.work_phone
								#)

			WHEN (length(c.home_phone) = 12 AND c.home_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					AND c.home_phone REGEXP '[^a-z]')
				AND (length(c.work_phone) = 8 AND c.work_phone REGEXP '^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					AND c.work_phone REGEXP '[^a-z]')
				AND (c.city IS NULL OR c.city = '' OR c.city IN ("x", "xx", "X", "XX", "XXX", "xxx")) 
					THEN concat( left(c.home_phone, 4), c.work_phone)

			WHEN length(c.work_phone) = 8	AND c.work_phone REGEXP '[^a-z]' 
				AND (length(c.home_phone) < 12 OR c.home_phone IS NULL OR c.home_phone = '')
				AND (c.city IS NULL OR c.city = '' OR c.city IN ("x", "xx", "X", "XX", "XXX", "xxx"))
				AND (length(a.cell_phone) < 12 OR a.cell_phone IS NULL OR a.cell_phone = '')
					THEN	IF	(c.store IN ("AUR", "ARV", "LIT", "LIT2", "THN", "SD", "SD_OLD", "FH", "DEN", "FedH"), concat("303-", c.work_phone),
								IF	(c.store IN ("FC", "GJ", "Grd Jct", "GLY", "GLY2", "LOV"), concat("970-", c.work_phone),
									IF	(c.store IN ("PBL"), concat("719-", c.work_phone ),
										IF	(c.store IN ("CAS", "CHY", "RS", "RS2", "Rock Spr.", "GIL", "GILL", "LAR", "Laramie", "CHY2", "Casper"), concat("307-", c.work_phone), 
											IF	(c.store IN ("BIL", "BUT", "MIS", "GF"), concat("406-", c.work_phone),
												IF	(c.store IN ("POC", "IDF"), concat("208-", c.work_phone),
													IF	(c.store IS NULL OR c.store IN ("ClosedStores", ""), '', c.work_phone)
													)
												)
											)
										)
									) 
								)
								
			WHEN length(c.work_phone) = 10 AND c.work_phone REGEXP '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$'
				###### FINDDBLINSERT ###### even COOLER INSERT(string, position, number of characters to replace, character to insert)
					THEN INSERT(INSERT(c.work_phone, 7, 0, '-'), 4, 0, '-') # my first insert was originally at 8, which was incorrect, because at a length of ten, it left 3 digits after the hyphen
		
			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP ' [0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
					THEN INSERT(REPLACE(c.work_phone, ' ', ''), 4, 0, '-')

			WHEN length(c.work_phone) = 12 AND c.work_phone REGEXP '[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
				###### FINDINSERT ###### pretty cool, INSERT(string, position, number of characters to replace, character to insert)
					THEN INSERT(c.work_phone, 4, 1, '-')

			WHEN length(c.work_phone) = 12 AND c.work_phone REGEXP ' [0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
					THEN INSERT(REPLACE(c.work_phone, ' ', ''), 4, 0, '-')

			WHEN length(c.work_phone) = 12 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]'
					THEN INSERT(c.work_phone, 8, 1, '-')

			WHEN length(c.work_phone) = 11 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
					THEN INSERT(REPLACE(c.work_phone, ' ', ''), 8, 0, '-')

			WHEN length(c.work_phone) = 11 AND c.work_phone REGEXP '[0-9][0-9][0-9] [0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				###### FINDDBLINSERT ###### even COOLER INSERT(string, position, number of characters to replace, character to insert)
					THEN INSERT(INSERT(c.work_phone, 8, 0, '-'), 4, 1, '-')

			WHEN length(c.work_phone) = 11 AND c.work_phone REGEXP '[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
				###### FINDINSERT ###### even COOLER INSERT(string, position, number of characters to replace, character to insert)
					THEN INSERT(c.work_phone, 4, 0, '-')

			WHEN length(c.work_phone) = 11 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				#AND c.work_phone REGEXP '^303 |^720 |^719 |^970 |^307 |^406 |^760 |^208 '###### FINDINSERT ###### pretty cool, INSERT(string, position, number of characters to replace, character to insert)
					THEN INSERT(c.work_phone, 8, 0, '-')

			WHEN length(c.work_phone) = 11 AND ( c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]|[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
				#AND c.work_phone REGEXP '^303 |^720 |^719 |^970 |^307 |^406 |^760 |^208 '###### FINDINSERT ###### pretty cool, INSERT(string, position, number of characters to replace, character to insert)
					THEN ''

			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP '[0-9][0-9][0-9] [0-9][0-9][0-9]\\*-[0-9][0-9][0-9][0-9]'
					THEN INSERT(REPLACE(c.work_phone, '*', ''), 4, 1, '-')

			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP '[0-9][0-9][0-9]  [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
					THEN REPLACE(c.work_phone, '  ', '-')

			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9] [0-9][0-9][0-9][0-9]'
					THEN INSERT(c.work_phone, 4, 1, '-')

			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-'
					THEN TRIM(trailing '-' from c.work_phone)
	
			WHEN length(c.work_phone) = 13 AND c.work_phone REGEXP '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
					THEN ''

			WHEN length(c.work_phone) BETWEEN 12 AND 16
				AND c.work_phone REGEXP '[a-z]|\\?|^[NC]|^[CEL]|\\/|\\*| -|- |$[a-z]|$`|\\.' THEN REPLACE(
																	REPLACE(
																		REPLACE(
																			REPLACE(
																				REPLACE(
																				#	REPLACE(
																					#	REPLACE(
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
																																	REPLACE(c.work_phone, 'CEL', '')
																																	, '.', '-')
																																, '`', '')
																															,IF ( (length(c.work_phone) = 14 AND right(c.work_phone, 2) = "-3"), right(c.work_phone , 2), c.work_phone), '')
																														, '- ', '-')
																													, ' -', '-')
																												, '*', '')
																											,'(', '')
																										, ') ', '-')
																									, '??', '')
																								, '/', '-')
																						#	, c.work_phone REGEXP '^1-', '')
																					#	, c.work_phone REGEXP '^1', '')
																					, 'NC', '')
																				,'CEL', '')
																			, 'CC', '')
																		, ' ?', '')
																	, ')', '-')
												

			WHEN c.work_phone REGEXP '^1-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '1-' from c.work_phone) 
			WHEN c.work_phone REGEXP '^1[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '1' from c.work_phone) 
			WHEN c.work_phone REGEXP '^1[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN trim(leading '1' from REPLACE(c.work_phone, ' ', '-'))
			WHEN c.work_phone REGEXP '^1[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' THEN INSERT(
																											trim(leading '1' from REPLACE(c.work_phone, ' ', '-'))
																										, 4, 0, '-')

			WHEN length(c.work_phone) = 13 
				AND c.work_phone REGEXP '^-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					THEN trim(leading '-' from c.work_phone)

			WHEN c.work_phone REGEXP '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' THEN ''
			WHEN c.work_phone REGEXP '1-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' THEN ''
			WHEN c.work_phone REGEXP '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' THEN ''

			WHEN (	c.work_phone REGEXP '^7\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' ## In this case, this is the EXACT text we're looking for, hence ^ and $
					OR c.work_phone REGEXP '^3\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^9\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' )
						THEN IF	(c.work_phone REGEXP	'^7\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE	(c.work_phone, '/', '20-'), 
								IF	(c.work_phone REGEXP '^3\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE (c.work_phone, '/', '03-'), 	
									IF	(c.work_phone REGEXP '^9\/[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', REPLACE (c.work_phone, '/', '70-'),	'')
									)
								)

			WHEN (	c.work_phone REGEXP '^7-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' ## In this case, this is the EXACT text we're looking for, hence ^ and $
					OR c.work_phone REGEXP '^3-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$'
					OR c.work_phone REGEXP '^9-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' )
						THEN IF	(c.work_phone REGEXP	'^7-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', INSERT(c.work_phone, 1, 2, '720-'), 
								IF	(c.work_phone REGEXP '^3-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', INSERT(c.work_phone, 1, 2,  '303-'), 	
									IF	(c.work_phone REGEXP '^9-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$', INSERT(c.work_phone, 1, 2, '970-'),	'')
									)
								)

			WHEN (length(c.work_phone) = 12 AND c.work_phone REGEXP '^[0-9][0-9][0-9]\\)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
				AND c.work_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
					THEN INSERT	(REPLACE(c.work_phone, ')', '')
								, 4, 0, '-') 

			WHEN (length(c.work_phone) = 13 AND c.work_phone REGEXP '^\\([0-9][0-9][0-9]\\)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
				AND c.work_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
					THEN 	REPLACE(
								REPLACE(c.work_phone, ')', '-')
									,'(', '')

			WHEN (length(c.work_phone) = 14 AND c.work_phone REGEXP '^\\([0-9][0-9][0-9]\\) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$' 
				AND c.work_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
					THEN INSERT	(REPLACE(
									REPLACE(c.work_phone, ') ', '')
										,'(', '')
								, 4, 0, '-') 

			WHEN (length(c.work_phone) = 14 AND c.work_phone REGEXP '^\\([0-9][0-9][0-9]\\) [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]$' 
				AND c.work_phone REGEXP '[^a-z]') ### the ^ inside the brackets [] means to bring back all the results that DON'T have letters inside. booya
					THEN INSERT(	INSERT	(	REPLACE(
													REPLACE(c.work_phone, ') ', '')
														,'(', '')
											, 4, 0, '-') 
								,8, 0, '-')

							### I had c.work_phone instead of '' previously. But it occurred to me that I could save myself some hassle if I just wiped out whatever I couldn't resolved
			ELSE c.work_phone
		END) AS "Work Phone", 


	( 	##############################################################
		##### FINDBANK ###################################################################################################################################
		##############################################################
		CASE
			WHEN c.bank_name IS NULL OR c.bank_name IN ("none", "None", "X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXX", "XXXXXXXX", "XXXXXXXXX",
														"N/A", "n/a", "x", "0", "NA", "/a", "na", "", "n",
														"CLOSED", "closed", "zz", "ZZ", "ZZZ", "unknown", "UNKNOWN", "ssss", "NO", 
														"no", "none", "NON", "jjjj", "jhss", "00", "517148", "21106437", "22222222", 
														" ", "105416655", "NOINE", "NONE", "none00",
														"CHECK CASH", "CHECK CASHING", "CHECK CASHING ONLY", "CASH CHECKS ONLY", "Cash Cks Only", "Cash Checks Only", "check cashing only", 
														"check cash only", "check cash", "cashing", "Cash Ck Only",
														"andersdon & keil", "APOLLO", "ANDERSON KEIL", "acct.closed",
														"anderson &keil", "anderson & keil", "andersdn & keil", "anderson  & keil", "anderson  Keil",
														"anderson &  keil", "A&K", "000000", "0000000", "Frozen", "Closed", "Stopped") 

				OR c.bank_name REGEXP '^\\*'
				OR c.bank_name REGEXP '^[A-Z][A-Z]$'
				OR c.bank_name REGEXP '^0*0$|0X'
				OR c.bank_name REGEXP '^x*x$'
				OR c.bank_name REGEXP '^X.*X$|^--$|^-$' #had to fix this - it ws finding any name with a '-' and blanking it out. Which is actually exactly what I told it to do. 
				OR c.bank_name REGEXP '^\\?'
				OR c.bank_name REGEXP '^xxx|^x'
				OR c.bank_name REGEXP '^closed$|^CLOSED$|^CLOSE$'
				OR c.bank_name REGEXP '^No Account$|^No Acct$|^No Authorization$|^non transaction$|^non-transaction$|^not auth$|^NONE`$'
				OR c.bank_name REGEXP '^PP'
				OR c.bank_name REGEXP '^bk'
				OR c.bank_name REGEXP '^[A-Z]$|^ [A-Z]$|^0X$|^[0-9]$|^ [0-9]$'
				OR c.bank_name REGEXP 'FRAUD'
				OR c.bank_name REGEXP '^FROZEN$|^frozen$|%frozen account$'
				OR c.bank_name REGEXP '^STOPPED$|^STOP$|^Stop Payment$|^stopped payment$|^StpPymtTCF$'
				OR c.bank_name REGEXP '\\.*closed$' 	### tried with matching the beginning and end of the string, but that proved cumbersome and wasn't successful
													### -- > specifically, I tried '/^\.*closed$\' --- I thought that the forward slashes would block out the characters
													### -- > but that wasn't the case. and it didn't clear in the regex tester. [] didn't solve it either, but the one above seems to work. 
					THEN ''
			WHEN c.bank_name REGEXP '\'|"' THEN REPLACE(
													REPLACE(c.bank_name, "'", '')
														, '"', '')
			
			ELSE trim(c.bank_name) ### when I hadn't included the "else" clause then the case statement just put NULL's in everywhere, which makes sense, because I hadn't told it how to handle items that weren't covered by the previous WHEN clauses
			
		END) AS 'Bank Name          ', 

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
		CASE   ####### FINDABA	


			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Yellowstone Federal Credit Union|Yellowstone F\\.C\\.U\\.|YELLOWSTONE F\\.C\\.U\\.|YEL\\. TEACHERS CREDIT UN\\.'
						OR c.bank_name REGEXP '^YELLOWSTONE TEACHERS FEDERAL CREDIT UNION|Yellowstone Teachers Credit Union|YELLOWSTONE TEACHERS|^YTCU|^YELLOWSTONE-|^YELLOWSTONE' ) THEN 302387023

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Yellowstone Bank|YELLOWSTONE BANK|yellowstone bank|YELLOWSTONE BK|^YELLOWSTONE$' ) THEN "092905142"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wyoming State Bank|Wyo State Bank|^state bsank$|^state bank$'
						OR c.bank_name REGEXP 'First State Bank of Wyoming' #### ALSO wyoming first! wyoming 1st
						OR c.bank_name REGEXP 'WYO 1ST FCU|WYOMING 1ST CUS|WYI C U|WYOMING 1ST CU') THEN "091911548"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'WYOMING CENTRAL FCU|WYOMING CENTRAL|^WYO CENTRAL$|WY0 CENTRAL FCU|WYO CENTRALFCU|WY CENTRAL FCU|WY  CENTRAL FCU'
						OR c.bank_name REGEXP 'WYCENTRAL FED CRED|WYO CENTRALFCU|WY0 CENTRAL FCU|WYO CENTRAL FCU|WYO CENTRAL|WYOCENTFEDCU'
						OR c.bank_name REGEXP 'WYO CEN FCU|WYO CFCU|WY FCU|WYCENTRALFCU|^CCU$|WYO FED CREDIT|^WY CENTRAL'
						OR c.bank_name REGEXP 'WYO CENTRALFCU|WY0 CENTRAL FCU|WYO CENTRALFCU|WY0 CENTRAL FCU'
						OR c.bank_name REGEXP 'WYO  CENTRALFCU|wyoming central fcu|wyo central fcu') THEN 302386587 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wyoming Bank and Trust|WYOMING BANK AND TRUST|Woming Bank & Trust|Wyoming Bank\/Trust'
						OR c.bank_name REGEXP 'Wyo Bank and Trust|wyo bank trust|Wyo Bank & Trust|Wy Bank&Trust|WY BANK&TRUST'
						OR c.bank_name REGEXP 'Wyoming Bank & Trust|wyo bank &trust|WY BANK\/TRUST|WY BANK\/ TRUST|WY BANK&&TRUST'
						OR c.bank_name REGEXP 'WY BANK&TRST|WY BNK&TRST|Wy Bank & Trust') THEN 102301636

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Wyochem|^WYOCHEM|WYO CHEM|wyo chem|whyo chem|WHYO CHEM') THEN 302386752

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'WyHy Credit Union|WyHy FCU|WYHY FCU|wyhy|wyhi|wy-hy|wy hy|WY\\.F\\.C\\.U|Wy  Hy FCU|Wh Hy|WY HIGH|WY HI'
						OR c.bank_name REGEXP 'WFCU|wfcu|W\\.F\\.C\\.U\\.|w\\.f\\.c\\.u\\.|wy fed\\.cred un|WYHT FCU|WY Employees FC|Wyoming Employees Credit Union'
						OR c.bank_name REGEXP 'wyom\\. fed cr\\. un|wyo\\.cr\\.fd\\.cr\\.un\\.|wyom\\. emp\\.fed\\.cr\\.un|wyo\\. fed\\. c\\.\\. u\\.'
						OR c.bank_name REGEXP 'WYO EMPLOY\\.FCU|WYEMP FCU|wy fed\\.cred un|WY FED C\\.U\\.|Wy Empl FCU|wy employees cu|WY EMPLOYEES CU'
						OR c.bank_name REGEXP 'wyo empl\\.fed cr un|wyo empl credit union|wyo emp\\. fcu|Wyo Emp Fed cr|wy\\.st\\.fed\\.cr\\.un|wy\\. employees'
						OR c.bank_name REGEXP 'wyo empl\\. fed cr un|wy ming empl\\. fcu|wy emp\\.\\.fed\\.cr\\.un|wy emply cr\\. union|WYOMING FCU') THEN 307086691 #### AKA wyoming federal creditunion //// wyhy

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wright Patt|WRIGHT PATT') THEN 242279408

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wray State Bank') THEN 102102932

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'World Savings|world saving|WORLD SAVING|WORLD SAVINGS|world savings' 
						OR c.bank_name IN ("WORLD SAVINGS")) THEN 102000076

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Woodland Bank|WOODLAND BANKS|woodland banks') THEN "091215163"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Woodforest National Bank|Woodforest Bank|WOODFOREST NATIONAL BANK|^WNB$') THEN 113008465

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Wingspan|Wing Span|WING SPAN|WINGSPAN|Wingspan|wingspan'
						OR c.bank_name REGEXP 'BANK ONE') THEN IF(c.state = "CO", 102000021, IF(c.state = "ID", 123103729, 102000021))

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'WILDFIRE'
						OR c.bank_name REGEXP '^WFB') THEN 272484713

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'White Crown'
						OR c.bank_name REGEXP 'White Crowm') THEN 302076295

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wheatland Bank|WHEATLAND BANK'
						OR c.bank_name REGEXP '^chugwater$') THEN 125107697 ### appears that wheatland bank IS the bank of chugwater WY

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'WestStar' 
						OR c.bank_name REGEXP 'West Star'
						OR c.bank_name REGEXP 'WESTAR') THEN 112017619

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Westmark Bank|^WESTMARK$|^WESTMARK CU$|^westmark cu$|^Westmark FCU$|westmark ECHEX|WESTMARK C\\.U\\.|WESTMARK C[ \/]U|WEST MARK|West Mark|west mark') THEN 324173079

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Westerra') THEN 302075319

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Western Vista|WSTRN VISTA|wstern bank|WST VIST FED|western vista|western Vista|westernvista|westren vista|westernvist'
						OR c.bank_name REGEXP 'WESTRN BANK|WETERN BANK|wetern vista|WESTERN VISTA|WEST\\. VISTA|west\\. vista|^WEST VISTA$'
						OR c.bank_name REGEXP 'WSTRN BANK|wstrn bank|W\\.  Vista CU|W\\. Vista CU|Western Visa|WESTERN VISA|western vist fcu'
						OR c.bank_name REGEXP '^Western$|^Western o') THEN 307086714

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Western State Bank|Western State|Western States|western states|WEST\\. BANK|westen bank|WESTEN BANK|Westen Bank') THEN 107007139

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Western Security|WESTERN SECURITY|WESTERNSECURITY|western security|WesternSecurity|WESTERN SECURITY BANK|western security UNION'
						OR c.bank_name REGEXP 'WESTERN SEC\\.|WESTERN SECURIT|Western Securit|WESTERN SECRUITY|Western Secruity|WESTERN SECORITY|Western Secority|WESTERN SECIRITY|Western Secirity'
						OR c.bank_name REGEXP 'WESTERN SECRUTY|WESTERN SEC BK|WESTER SEC|western sec|Western Sec\\.|Western Secruity|Western Secruty|West Sec\\.|WEST SEC'
						OR c.bank_name REGEXP 'WSTRN SEC|WSTRN SEC\\.') THEN 292970854

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' # ---------------->>> !!!!!!!!!!!!!!!!!!!!!!!!!
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Western Rockies Fed'
						OR c.bank_name REGEXP 'WRFCU|WRFCI'
						OR c.bank_name REGEXP 'WRF CREDIT'
						OR c.bank_name REGEXP 'WRCU'
						OR c.bank_name REGEXP 'WR FED CR'
						OR c.bank_name REGEXP 'WESTERN ROCKIS'
						OR c.bank_name REGEXP '^WESTERN ROCKIES|^ WESTERN ROCKIES|WESTERN  ROCKIES'
						OR c.bank_name REGEXP '^WEST ROCK|^WEST. ROCKIES|^WESTERN$'
						OR c.bank_name REGEXP '^W ROCKIES'
						OR c.bank_name REGEXP '^MSEA CTY TEACHERS FED'
						OR c.bank_name REGEXP '^mesa county teachers fed'
						OR c.bank_name REGEXP 'BURNING MTN CREDIT UNION|BMCU|burning mountain|burning mtn|BURNING MOUNTAIN') THEN 302176632

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Western Federal Credit Union|Wester Fed CU|WESTERN FEDERAL CREDIT UNION|WESTERN FED CU|WESTERN FCU|WFCU|West Fed\\.|West Fed|WEST FED|WEST FED\\.'
						OR c.bank_name REGEXP 'WEST FCU|WEST FED\\. CU|West Fed\\. CU|West Fed\\. C\\.U\\.') THEN 322079719

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP '^Western Bank|^WESTERN BANK$|WESTERN BNK|Western Bank') THEN 112203038

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP '^West Virginia Federal Credit Union|WVFCU') THEN 251584197

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP '^West Branch Valley') THEN 231380133

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Wescom|^WESCOM&|WESC FCU CASP|^Wesc\\. FCU$|WESCIM|Wescim|Wesc\\. FCU|WESC\\. FCU') THEN 322079353

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP '^WESC$|WESC CREDIT UNION|WESC FCU|WESCFCU') THEN 302386574 ##### IS GREATER WYOMING FCU NOW!!!!!

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND (  	c.bank_name REGEXP 'Wells Fargo|wellls fargo|WLSS FARGO|Wlss Fargo|Wells' 
						OR c.bank_name REGEXP 'WellsFargo|WELLS-FARGO'
						OR c.bank_name REGEXP 'Wells  Farg|WEELS FARGO|weels fargo|Weels Fargo|weels Fargol'
						OR c.bank_name REGEXP 'Wells Fargp|WELLFARGO|WellFargo|wellls fargo|WELLLS FARGO|wellfargo|^WELL$'
						OR c.bank_name REGEXP '^WELLSL FARGO'
						OR c.bank_name REGEXP 'WELLSFARGO|WELSL FARGO'
						OR c.bank_name REGEXP '^WELLSF|^WELLS$|^WELLS '
						OR c.bank_name REGEXP '^WELLS F|werlls fargo'
						OR c.bank_name REGEXP '^WELLS WELLS'
						OR c.bank_name REGEXP '^WELL FARGO'
						OR c.bank_name IN ("wels fargo" , "Well Fargo", "Wells Frgo", "Wells Fargo`")) THEN 102000076 #### confused why I made it so complicated before
					##### if the routing number is a bust for ANY reason, but "Wells Fargo" exists anywhere in the bank name, then we can adjust the routing nummber appropriately

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Weld Schools') THEN 307076724 # this will also get 'Weld Schools CU' or 'Weld Schools Credit Union'

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Washington Mutual|Wahington Mutual|Wa Mu|Wasington Mutual|WASINGTON MUTUAL|Wasington Mutual|wasington mutual|washington mutual'
						OR c.bank_name REGEXP 'Washington Mututal|Wahsington Mutual|washinton mutual|WASHINTON MUTUAL|Washinton Mutual|WASHINGTON MUT|WASHINTON MUT'
						OR c.bank_name REGEXP '^WASHINGTON$|^Wash\\.Mutual|^Wash\\. Mtl\\.|WASH\\. MTL\\.|WASHINGTOM MUTUAL|washingtom mutual|WASHING MUTUAL|Washing Mutual|Washing mut\\.'
						OR c.bank_name REGEXP 'Wash\\. Mutual|WASH\\. MUTUAL|WASH\\. MTL\\.|wash\\.mt\\pmts\\.|wash\\. mut\\.|Wash Mutua|Wash Mut|WASH MUT'
						OR c.bank_name REGEXP 'Chase'
						OR c.bank_name REGEXP '102001017'
						OR c.bank_name IN (	"Wash Mutual", "WAMU", "Wash Mutl", "Wash Mutua", "Chase", "Washington Mutaul")) THEN 102001017

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Warren Credit Union|Warren Federal CU|warren credit union|^Warren$|^WARREN$|^Warren FCU|^Warrren FCU'
						OR c.bank_name REGEXP 'warren fed\\.cr|WARREN F\\.C\\.U\\.|^WARREN|WARRENF\\.C\\.U\\.|FE WARREN CU|Wareen FCU|FE WARREN|fe warrn|fe warren'
						OR c.bank_name REGEXP 'warre|warrren fed cr union|waren fcu') THEN "071974372"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'Wal-Mart Money Network First Data|Walmart Money Network|Walmart Card') THEN 124303120

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Wachovia'
						OR c.bank_name REGEXP 'WACHOVIA|Wochovia|wochovia') THEN "071974372"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^VBC'
						OR c.bank_name REGEXP '^VIRGINIA COMMONWEALTH') THEN "051403850"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^V\\.A\\.C\\.U\\.|virginia credit union|VIRGINIA CREDIT UNION') THEN 251082615

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'VERIDIAN') THEN 273976369

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Velocity C\\.U\\.|Velocity CU|VELOCITY CU|Velocoity C\\.U\\.') THEN 314977133

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Vectra|ZION NAT BANK|ZIONS BANK|^ZIONS$|^ZIONS|^zions|ZION|zion'
						OR c.bank_name REGEXP '^VECTRA'
						OR c.bank_name REGEXP 'V ECTRA|V  ECTRA|ECTA|ECTRA BANK|ectra bank'
						OR c.bank_name REGEXP 'VECTA|^VETRA|^vc$')
							THEN 102003154

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Valley National Bank')
						THEN "021201383"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Valley Trust|^VALLEY$|^Valley$|VALLEY B &TRST|VALLEY B & TRUST'
						OR c.bank_name REGEXP 'Valley Bank and Trust|V\\.F\\.FED CR\\.|V\\.F\\.C\\.U\\.|V V Fed C U|V Fed CU|V FED CU'
						OR c.bank_name REGEXP 'Valley Bank') THEN 104101876

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^UTAH PWER CREDIT UNION|Utah Power Credit Union|utah power credit union|UPCU|UTAH POWER|UTAH TREASURER') THEN 324079539

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'US Bank'
						OR c.bank_name REGEXP 'USBank'
						OR c.bank_name REGEXP 'Us Bank|^U S BANK'
						OR c.bank_name REGEXP 'U.S. Bank'
						OR c.bank_name REGEXP 'U.S.Bank'
						OR c.bank_name REGEXP 'Blue Spruce'
						OR c.bank_name REGEXP 'USBANK'
						OR c.bank_name REGEXP '^USBK'
						OR c.bank_name REGEXP '^USB$|^USB '
						OR c.bank_name REGEXP 'US BAN|^US|^U S|^us'
						OR c.bank_name REGEXP '^FIRST NATIONAL BANK OF THE ROCKIES|^FNBR|^FIRST OF THE ROCKIES'
						OR c.bank_name IN ("US Bank", "US bank", "U.S. Bank", "U. S. Bank", "US") ) THEN 102000021

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'USAA') THEN 314074269

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Universtiy of Wyoming Federal Credit Union|Univ Wyo F\\.C\\.U\\.|uniwyo fcu|UNIWYO|UW FCU|Uni Wyo|uni wyo|UNI WYO|Uni-Wyo') THEN 307086882

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'University of Colorado|U of C Credition Union|U of C Credit Union|U OF C FED CU'
						OR c.bank_name REGEXP 'U of C FCU|U of C F\\. C\\. U\\.|U of C FCU|U of C F\\. C\\. U\\.'
						OR c.bank_name REGEXP 'U of C Federal CU|UOFC C\\.U\\.|CO U CU|UOFC FEDERAL C\\.U\\.|UOFC FCU|UOFCCU|UOFC C\\.U\\.|UOFC F\\.C\\.U\\.') THEN 253177793

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^United Business Bank|UNITED BUSINESS BANK'
						OR c.bank_name REGEXP '^UNITED'
						OR c.bank_name REGEXP '^PAONIA STATE BANK') THEN 121143781

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'UNITED BANK|^UNITED|United Bank|UNITED BANKS|') THEN "211170318"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'United Airlines Employee CU'
						OR c.bank_name REGEXP 'United Airlines FCU'
						OR c.bank_name REGEXP 'Alliant') THEN 271081528

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^United Airlines') THEN 211170318

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Union Bank of California|U\/B OF CA|UB OF CA$|Union Bank of CA|Union Bank of Ca') THEN 322271326

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^UNION BANK & TRUST|^UNION BANK AND TRUST|union bank and trust|union bank & trust|Union Bank & Trust|Union Bank') THEN "051403164"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Unify$') THEN 322079719

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^UNIFIED BANK|UNIFIED FCU|Unified peoples cu|Unified Peoples Federal Credit|Unified People FCU|unified peoples federal CU'
						OR c.bank_name REGEXP 'Unified Credit Union|unified people fcu|UNIFED FCU|UNIF FCU|^Unified People|unifed people cr\\.'
						OR c.bank_name REGEXP 'unif\\.peo\\.cr\\.un\\.|UNIF PEOP FCU|unifed peop\\.cr un|unifed peo\\.cr un|unified fed cu|UNIFIED FED CU'
						OR c.bank_name REGEXP 'unifed peoples federal cu|unifed peo\\. fed\\. cred\\.un|un\\.people fed\\.cr\\.un|unifed\\.\\.peo\\. fed\\.cr\\.un'
						OR c.bank_name REGEXP 'unifed peo\\. fed\\. cred\\.un|unt\\.people fd\\.cr\\.un\\.|unified pcu|unifed fd\\.cr\\.un\\.|unifed people fd\\.cr\\.'
						OR c.bank_name REGEXP 'unifed peoples cr\\.un|unified peopls fcu|uni people fcu|unifed peo\\. fed\\. cred\\.un|Unified Peopl|unifed peo\\. fed\\. crd\\.un') THEN 307086620 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'UMB'
						OR c.bank_name REGEXP 'U.M.B.') THEN 101000695

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Uinta Bank|UINTA BANK|UNITA BANK|unita bank|Unita Bank') THEN 102301717

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Tru Grocer FCU|^Truegrocer|^Tru Grocer CU|Tru Grocers Fed'
						OR c.bank_name REGEXP 'Albertsons FCU|ALBERT FCU|Alberts fcu') THEN 324172465

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Tri County Bank|Tri-County Bank|^Tri County$|tri county') THEN 101000695

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^TRONA VALLEY|Trona Valley FCU|^NATRONA FEDERAL$|TRONA FCU|Trona FCU|TRONA VALLY|^Trona$|Trona Vally|trona vally'
						OR c.bank_name REGEXP 'trona valloey|TronaValley|tronavalley|Trona Val Fed Cr Un') THEN 302386765

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Treasury'
						OR c.bank_name REGEXP 'US TREASUREY') THEN '000000000'

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^TONGASS FCU|TONGAS FCU|tongass fcu') THEN 325272306

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^TIMBERLINE|^timberline') THEN 102107063

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^THE JUNCTION BELL') THEN 302176629

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^THE BANK OF GRAND JUNCTION'
						OR c.bank_name REGEXP '^THE BANK OF GJ|^THE BANK OF G J|^THE BANK OF G.J.'
						OR c.bank_name REGEXP '^THE B[A|AA]NK OF GRAND JCT'
						OR c.bank_name REGEXP '^THE BANE OF GRAND JUNCTION'
						OR c.bank_name REGEXP '^THE BANK$') THEN 302176603

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^THE PALISADES NATIONAL'
						OR c.bank_name REGEXP '^COLO NAT\\.|^COLORADO NAT\\.|^COLORADO NATIONAL|colo national|colorado national|^COLO NATIONAL'
						OR c.bank_name REGEXP '^souther colorado national|^southern colorado natinal|^southern colo natl') THEN 102101441

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^TEACHERS CREDIT UNION|TEACHERS FED\\. CREDIT UNION') THEN 271291826

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'TCF'
						OR c.bank_name REGEXP 'tcf'
						OR c.bank_name IN ("TCS", "T.C.F.", "T C F") ) THEN 107006444

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^TBK$|^tbk$|^TBK Bank$') THEN 111909579

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^SWEETWATER|SWEET WATER|Sweet Water FCU|SWEETWATER FCU|SWEET WATER FEDERAL|Sweetwater Fedral|Sweetwater Federal|^SFCU'
						OR c.bank_name REGEXP 'Sfcu|sfcu') THEN 302386930

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Sunwest Education Credit Union|SW ED CU|SWEDCU|^SUNWEST'
						OR c.bank_name REGEXP 'SUNWEST|SUN WEST EDUCATIONAL|SUN WEST ED|^SunWest|^sunwest|^Sunwest|^SUN WEST|^Sun West') THEN 122228003

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^SUNTRUST|SUN TRUST|SunTrust FCU') THEN "061000104"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^SUNLIGHT FCU|^SUNLIGHT$') THEN 302386736

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^SUNFLOWER|^SUN FLOWER') THEN 101100621

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^SUFFOLK COUNTY NATIONAL|^SCNB|^scnb') THEN 021405464

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Stockgrowers State Bank|stockgrowers state') THEN 101104067

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'St. Vrain|St Vrain Valley|St.  VrainValley'
						OR c.bank_name IN ( "St Vrain", "St. Vrain", "ST Vrain")) THEN 307077053

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^ST VINCENT FCU|^SVAMC-CU$|St Vincent FCU|St Vincent') THEN 221173774

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^State Hospital FCU|State Department FCU|STATE HOSPITAL|ST HOSP CREDIT'
						OR c.bank_name REGEXP '^state hosp cred') THEN 2560-7534-2

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^State of Colorado|state bank la junta|^state bank') THEN 102101700

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'State Farm'
						OR c.bank_name REGEXP 'STATE FARM') THEN "071174431"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Star Tech') THEN 302075351

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'St Pius') THEN 222380579

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'St Joseph FCU|st\\.joseph fed\\.cr\\.un|ST JO FCU|ST JOES FCU|St Joseph|St. Jo FCU|st\\. josephs|st\\.joseph parish cr\\.un'
						OR c.bank_name REGEXP 'st\\.joseph parish cr\\.un|st josp\\.credit un|st\\.josephs parish fed\\.cr\\.un|st\\.joseph tri parissh|st\\.joseph fcu') THEN 241274569 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Spokane Teachers CU'
						OR c.bank_name REGEXP 'STCU') THEN 325182700

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Space Age') THEN 302076033

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Sovereign Bank'
						OR c.bank_name REGEXP 'Santander Bank') THEN IF(length(c.bank_account) = 11, "011075150", IF(length(c.bank_account) = 10, 231372691, '')) 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SOUTH WEST AIRLINES CU'
						OR c.bank_name REGEXP '^S W CREDIT') THEN 311090673

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Southwest Federal CU|Southwest FCU|^SWFCU$|^SWCFU$|SOUTH WEST BANK|^swf|^SWF') THEN 307083872

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SOUTH CAROLINA'
						OR c.bank_name REGEXP '^South Carolina Fed') THEN "053201872"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Sooper'
						OR c.bank_name REGEXP 'Scooper CU'
						OR c.bank_name REGEXP '^SOOPER|^SCU|^`MESA SOOPER') THEN 302076017

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'SkyOne'
						OR c.bank_name REGEXP 'Sky One') THEN 322077779

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Skagit Bank|Skagit State Bank') THEN 125105631

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Shyann Federal Credit Union|Shyann Bank|Shyann FCU|Shyann Fed CU|Shyann federal') THEN 307086662 ## holy shit, there is actually a Shyann FCU. WTF

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Service CU|Service CU|ServiceCU'
						OR c.bank_name REGEXP 'Service Credit Union') THEN 211489229

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'sentinel fedral|sentinel federal|SENTINEL FEDERAL|sentinel fed|sentinel fed\\.') THEN 291479291

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Security Service|^SSFCU|^ssfcu|SECURITY SERVICE|SECURITY SERV|SECURITY SER|SECURITY FED|Security Service|^SSFU$'
						OR c.bank_name REGEXP 'SECURIT;Y SERVICE|SECURITY SERVICES|Securty Service|SECIRITY SERVICE'
						OR c.bank_name REGEXP '^SECURITY$|SEC. SERVICE|Sec. Service|SEC SRVC|sec service|sec srvc|SEC SERV|sec serv|sec ser|SEC SER|SEC FED CRD'
						OR c.bank_name REGEXP 'SECURTIY SERVICES|SERURITY SERVICE|SECURITY SEVICES|SECURITY SEVICE|security credit union|SECURITY CREDIT UNION|security cu'
						OR c.bank_name REGEXP '^Norbel') THEN 314088637

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'SECURITY STATE BANK|SECURITY STATE' ) THEN "091408909"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Security First|SECURITY FIRST BANK|SECURITY 1ST|security first|SECURITY FIRST|sercuity first'
						OR c.bank_name REGEXP 'SERCUITY FIRST|Security 1st|Secuity 1st|Sercuity 1st|secuirty first|securtiy first|security firsr') THEN 307087661

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'SCHOOL DIST CREDIT UNION|^School District [0-9]|^S\\.D\\. [0-9][0-9]'
						OR c.bank_name REGEXP '^SD [0-9][0-9]|^SD[0-9][0-9] |^SCHOOL DIST|Sch\\. Dist|^SCH DIST|S\\.D\\.[0-9][0-9] F\\.C\\.U\\.' 
						OR c.bank_name REGEXP 'DIST\\. [0-9][0-9]F\\.C\\.U\\.|^District [0-9][0-9]') THEN 307077464 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Santa Barbara Bank and Trust|Santa Barbra Bank and Trust|Santa Barbara Ban K & Trust') THEN 122231304

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SAN LUIS VALLEY FEDERAL BANK|SAN LUIS VALLEY FEDERAL|san luis valley|^san luis valley fcu') THEN 302174728

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SAN JUAN MOUNTAIN'
						OR c.bank_name REGEXP '^SAN JUANMOUNTIANS|san juan mountains|san juan mountians') THEN 302177107

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SALT LAKE CREDIT') THEN 324079416

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Safeway Rocky Mountain |SAFEWY RCKY MTN CU'
						OR c.bank_name REGEXP 'Service Credit Union'
						OR c.bank_name REGEXP 'Safeway CU'
						OR c.bank_name REGEXP 'Safeway') THEN 325182577

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^SALT LAKE CREDIT') THEN 32407941

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^ROSEHILL FEDERAL'
						OR c.bank_name REGEXP '^ROSE HILL FEDERAL'
						OR c.bank_name REGEXP '^ROSE HILL FCU'
						OR c.bank_name REGEXP '^ROSE HILL CREDIT UNION'
						OR c.bank_name REGEXP '^ROSE HILL') THEN 271290681

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Rock Springs National Bank$|^RSNB$|^ROCK SPRINGS NATIONAL|ROCK SPRINGS NAT|^ROCK SPRINGS.*NAT|^rock springs|^ROCK SPRINGS|rocksprings national'
						OR c.bank_name REGEXP 'ROCK SPRINGS BANK|ROCKSPRINGS|^ROCK SPRINGS$|^Rock Springs$|Rock Spr\\. National|Rock spring|rock springs|rock spring|rs national'
						OR c.bank_name REGEXP 'rock sprgs|rock sprgs nat|Rock spring nat\\.|^Rock Nat$|ROCK S NATIONAL|rocksrings national|ROCK APRINGS NATIONAL|Rock SP Nat Bank'
						OR c.bank_name REGEXP 'ROCK SRPINGS NATIONAL|^ROCK NAL|ROCKSPRING NATIONAL|RS Nati Bank|ROCK S  NATIONAL') THEN 102300255

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Rocky Mtn Law'
						OR c.bank_name REGEXP 'Rocky Mountain Law'
						OR c.bank_name REGEXP 'Rocky Mountian Law|^Rocky Mt Law'
						OR c.bank_name REGEXP 'Rocky Mt. Law|Rocky Mt. Law Enf.'
						OR c.bank_name REGEXP 'Rocky Mountain Law Enforcement|^DPD FCU$'
						OR c.bank_name REGEXP 'Denver Bar Assoc|^ROCKY MTN$|^ROCKY M B'
						OR c.bank_name IN ("RMLECU", "RMLEFCU" ) ) THEN 325182577

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^ROCKY MOUNTAIN BANK|rocky mountain bank|Rocky Mountain Bank|Rocky Mtn Bank|^Rocky Mountain$|^RMB$|Rocky Mountain CU') THEN 102305098

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^ROBINS FCU|robins fed\\.cr\\.un') THEN 261171587

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^RIVER RAIL COMMUNITY FCU|^RIVER RAIL$|^RIVERRAIL$|RIVER RAIL FCU|RIVERRAIL FCU|RIVER-RAIL') THEN 302386477

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^RIVERMARK'
						OR c.bank_name REGEXP '^SUNSTRAND') THEN 292976845 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^RIO GRANDE|^ RIO GRANDE|^RIO GRAND|^RIO GANDE'
						OR c.bank_name REGEXP '^RGFCU') THEN 302176674

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Rimrock credit union') THEN 292976845 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Reliant FCU|RELIANT CU|RELIANT FCU|RELAINT FCU|^RELIANT$|^RELIANT|RELLIANT') THEN 302386529

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Regions Bank|REGIONS') THEN "062005690"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Redwood Credit Union|REDWOOD CREDIT UNION') THEN 321177586

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Red Rocks Federal CU'
						OR c.bank_name REGEXP 'Red Rocks FCU'
						OR c.bank_name REGEXP 'Red Rocks CU')  THEN 302088092

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'RAWLINS NAT BANK|RAWLINS BANK\RAWLINS NATL BANK|RAWLINS NATL BANK|Rawlins National Bank|The Rawlins National Bank|Rawlins National') THEN 102300297

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Randolph\\*Brooks|RANDOLPH BROOKS|Randolph-Brooks') THEN 314089681

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pyramid FCU|PYRAMID CU|PYRAMID FEDERAL CREDIT UNION') THEN 322174821

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Pueblo Horizons Federal Credit Union|PUEBLO HORIZONS FEDERAL|^PUEBLO HORIZONS'
						OR c.bank_name REGEXP 'PUEBLO HERIZON|PUEBLO HORIZAONS|PUEBLO HORIZANS|pueblo horizans|pbl horizons'
						OR c.bank_name REGEXP 'Pueblo Horizons|PUEBLO HORIZON|PUEBLO HORZONS') THEN 307077367

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Pueblo Government|PUEBLO GOVERNMENT|pueblo governement|Pueblo Govt|PUEBLO GOVT'
						OR c.bank_name REGEXP 'PUEBLO GOV|PUEBLO FEDERAL|PUEBLO CITY FED|PUEBLO CITY EMPLOYEES FED|pueblo ciy employees fcu'
						OR c.bank_name REGEXP 'GOVERNMENT AGENCIES|government agencies|government agencie|^GVMT FED CU|GOV. AGENY|GOVE. AGENCIES'
						OR c.bank_name REGEXP 'PUEBLO CITY EMP|PUEBLO CTEDIT UNION|GOVERMENT AGENCIES|PUE GOVT AGEC|^CITY OF PUEBLO$' 
						OR c.bank_name REGEXP 'PGFUC|PGAF|PGAFCU|P G A F C U|PUEB GOV AGENCIES|PUEBLO CITY E') THEN 307077309

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pueblo Bank|PUEBLO BANK AND TRUST|Pueblo Bank and Trus|PUEBLO BANK & TRUST|pueblo bank & trust|pueblo bank trust|Pueblo Bank Trust'
						OR c.bank_name REGEXP 'PUEBLO/TRUST|PUEBLO B&T|pueblo b& t|pueblo b&t|PUEBLO B\\$T|PUEBLO B \\ $T|PUEBLO B\\ $T|PEUBLO BANK AND TRUST|^PBT$|^pbt$|PBT O'
						OR c.bank_name REGEXP '^PB&T$|^pb&t$|^P BANK \\$ TRUST$|^p b&t$|^P B&T$|^P B\\$T$|^P B& T$|^P B T$|^P B AND T$|^P B @ T$|^P B & T$|^P B \\$ T'
						OR c.bank_name REGEXP 'PUEBLO B\\$ T|PUEBO BANK AND TRUST|^PBT$|^P B T [A-Z]|Pureblo Bank and Trust'
						OR c.bank_name REGEXP '^pb&t|^P  B\\$T|PB\\$T|^PB\\$ T|PUEBLO B & T|pb\\$t|PUEBO BANK &TRUST|PB@T|PB& T|P B \\$T') THEN 107000068

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Public Service'
						OR c.bank_name REGEXP 'Pub Serv'
						OR c.bank_name REGEXP 'Public Serv|^Public Srvc CU|GRAND JUNCTION P.S.C.|GJ PSCU|grand junction p.s.c.|gj pscu'
						OR c.bank_name REGEXP 'Public Ser|Public Svc|PUBLIC SERVICE|PUBLIC SVC|Public Svc. CU'
						OR c.bank_name REGEXP 'PS CU'
						OR c.bank_name REGEXP 'PSCU')  THEN 272079487

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Principal Bank')  THEN "073922623"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Premier Bank')  THEN "051000127"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'POWER FCU|Power CU|POWER CU|Power Credit Union|power credit union|POWER CREDIT UNION|^POWER CREDIT$'
						OR c.bank_name REGEXP '^POWER CR|^Power Credit$|^power credit$|Power trust')  THEN 307077202

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Porter FCU')  THEN 302075788

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Points West Bank|Points West Community Bank|PWCB|^Points West')  THEN 102101360 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Platte Valley|platte valley')  THEN 102306699

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Planters Bank|PLANTERS BANK')  THEN "083902633"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'PIONEER BANK|Pioneer Bank|pioneer bank')  THEN 312270463

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^PINNACLE BANK|^pinnacle$|pinical bank|pinnicale|pinnacol|pinncle bank|PINNCL\\. BANK|pinncl\\. bank|^pinnacle$'
						OR c.bank_name REGEXP '^Pinnacle Bamk$|pinaccle|pinnacle|^pinn$|pinnicle|^pinncale')  THEN "064008637"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pima FCU')  THEN 322174795

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'PHFCU|phfcu')  THEN 321371528

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'People\'s United Bank|Unified Peoples FCU|^PEOPLES FCU$|Unified P FCU|UNIFIED P FCU')  THEN 221172186

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'peoples national|PEOPLES NATIONAL BANK|^PEOPLES CU$|^People Bank$|^PEOPLES BANK$')  THEN "081206807"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pen Fed C\\.U\\.')  THEN 2560-7844-6

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^PCFCU$|^PCE FCU$|^PCE$|PEC Fed|^PCE  FCU$')  THEN 325182344

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'PATHFINDER CU' ##### BOUGHT OUT FAMILIES FIRST CU and NPRD FCU
						OR c.bank_name REGEXP 'FAMILIES FIRST|FAMILIES 1ST FCU|Familys First CU'
						OR c.bank_name REGEXP 'NPRD FCU|NPRD|NPRDFCU|N P R D C U') THEN 302386477 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^PALLISADES'
						OR c.bank_name REGEXP '^PALISADE'
						OR c.bank_name REGEXP '^PALASADE|^palisade')  THEN 221979101

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pacific Trust Bank|pacific trust|pacif trust')  THEN 322274527 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Pacific Marine CU')  THEN 322274925

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Oregon Trail Bank|OREGON TRAIL|oregan trail bank')  THEN 322274925

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^OLATHE STATE'
						OR c.bank_name REGEXP '^KS STATE'
						OR c.bank_name REGEXP 'Kansas State Bank')  THEN 101101536

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^NUVISTA|^nuvista')  THEN 302177110

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Northwest FCU'
						OR c.bank_name REGEXP '^NORWEST|NNORWEST'
						OR c.bank_name REGEXP '^ NORWEST')  THEN 243374218

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'North Vally|^North Valley|NORTH VALLEY|NORTH VALL\\.|^NORTH$|NORTH VALEY')  THEN 107007359

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'North Side Bank|NORTH SIDE ST BANK|north side state bank|^NSSB|^north side$|^NORTH SIDE$|^NORTHSIDE$|NORTH STATE BANK|^NSSB$|^north side|North side'
						OR c.bank_name REGEXP 'north side state|NORTHSIDE|northside state')  THEN 102300336

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Northern Bank|NORTHERN BANK|BURLINGTON NORTHERN|burlington northern|BURLINGTON COLORADO SOUTHERN|BURLINGTON FCU|BURLINGTON F CU|^BFCU$'
						OR c.bank_name REGEXP 'NATL CITY BANK|BC FED\\. CREDIT'
						OR c.bank_name REGEXP 'BURLINGTONCU|BURLINGTON CO-OP|BURLINGTON F CU|^BURLINGTON$|BN C0-0P FCU|B C0-0P FCU|BN CO-OP F CU|BURLINGTONFUC|BN CO-OP F C U')  THEN "011303097"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'New Horizons')  THEN 284283630

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Interstate Net'
						OR c.bank_name REGEXP 'Net Bank')  THEN "031207908"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'New Frontier')  THEN "081018956"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'New Cumberland FCU|^NCFCU$|^NCSFCU$|NCS FED CREDIT UNION')  THEN 231382555 ### NOT SURE WTF north cumberland is doing here, but I can't find any other bank that matches NCFCU


			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Navy Federal|Naval Federal'
						OR c.bank_name REGEXP 'Navy FederaCU'
						OR c.bank_name REGEXP 'NAVY FCU|navy federal|^navy fcu|^NAVY')  THEN 256074974

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^NATIONAL CITY BANK|NATL CITY BANK')  THEN "071000301"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Mountain West Federal Credit Union|MCWFCU|MC WEST FCU')  THEN 292976971

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Mountain States')  THEN 264279237

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Mountain River|MOUNTAIN RIVER CREDIT')  THEN 302177440 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Mountain America Credit Union|MOUNTAIN AMERICA CREDIT UNION|^Mountain America|mountain american Credit Union|Mtn\\. High FCU'
						OR c.bank_name REGEXP 'Mtn\\. High FCU|^Mountain America|^MOUNTAIN AMERICA|^mountain american Credit Union')  THEN 324079555

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^MONTROSE'
						OR c.bank_name REGEXP '^montrose')  THEN 107002448

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Missoula Federal Credit Union|MISSOULA FEDERAL')  THEN 292977899

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Minnequa Federal Credit Union|^MINNEQUA FCU|^NEPCO FCU$|^Nepco$|^nepco$|^nepco cu'
						OR c.bank_name REGEXP 'Minniqua Works FCU|Minniqua Works|Minnequa Works|MINNQUA WORKS|MINNUQUE|MINNIQUE FEDERAL CREDIT|MINNIQUA WORKS'
						OR c.bank_name REGEXP 'MINNIQUA C U|MINNIQUA BANK|^MINNIQUA$|^MINNEQUE FED|^MINNEQUE CRED|^MINNEQUE BANK|MINNEQUAL WORKS|MINNEQUA WRKS|^Minnequa Works'
						OR c.bank_name REGEXP 'Minnequa Works CU|MINNEQUA WORKS CU|MINNEQUA WORKS CREDIT|Minnequa Works Credit|^minnequa works$|MINNEQUA WORK|MINNEQUA CW'
						OR c.bank_name REGEXP 'MINNEQUA BANK|minnequa bank|^MINNEQUA$|^minnequa$|Minn Works FC|MINN WORKS FC|MINN WORKS CU|^minn works$|^MINN WORKS$'
						OR c.bank_name REGEXP 'Minnaqua Works fed CU|^MINNIQUA BNK|^MIN WORKS$|^MINNEQUE$|^MINNEQUE WORKS$|MINNEQUA  WORKS|MINNEQUA WORK|^MINNEQUEA$'
						OR c.bank_name REGEXP 'MINN CRED UNION|minnequa credit|minequa works|MINN WORKKS|MINNIQUA WORK|MINNEQUAL WRKS|minn work|^MINNEQUA ')  THEN 307077231 

 			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'MID AMERICA BANK|mid america bank|^MID AMERICA')  THEN "081514748"

 			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Metrum Community'
						OR c.bank_name REGEXP 'Metum community|metrum community|METRUM COMMUNITY|^METRUM$'
						OR c.bank_name REGEXP 'NORGREN FCU|Norgren Federal Credit Union|norgren federal credit union|^NORGREN$'
						OR c.bank_name REGEXP 'DEN POST FCU|DEVER POSTAL C\\.U\\.')  THEN 302075555

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^mesa national|MESA  NATIONAL|MESA NAT.| MESA NATIONAL'
						OR c.bank_name REGEXP '^MESA NATIONAL|MNB'
						OR c.bank_name REGEXP '^MESAA NATIONAL'
						OR c.bank_name REGEXP '^NESA NATIONAL|MES COUNTY|MESANATIONAL|mesanational|mesa natl')  THEN 102000021

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^MERRILL LYNCH|merril lynch|^MERRIL') THEN "084301767"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Meridian Trust|meridian trust federal credit union|meridian trus|meridan trust|meridan fcu|MERIDAN FCU|Meridan FCU'
						OR c.bank_name REGEXP 'WY EMP FED CU|Wyoming Employees Federal Credit Union|WY E F C U'
						OR c.bank_name REGEXP 'MERIDIAN \/ CHEYENNETRUST|MERIDIAN  FCU|Meriddan Trust fed|MeriddanTrust'
						OR c.bank_name REGEXP 'Wyoming Emp FCU|^MERIDIAN$|^Meridian$|Meridian  Trust|MERIDIAN TRUT|MERIDIAN FCU|MERIDIAN FCU')  THEN 307086701 ### AKA Wyoming Employees Federal Credit Union (bought 'em out)

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Members Federal CU')  THEN 264279237

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Members Advantage FCU|^Members Adv')  THEN 211690911

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'MEGABANK|MEGA BANK|Mega Bank|megabank|mega bank|MegaBank')  THEN 122244870

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^MCTFCU|^MC FEDERAL CREDIT|^MESA CTY|^MCTFED|^MCFCU|^MCTFU|^MCRFCU|^MCTCU'
						OR c.bank_name REGEXP '^MESA COUNTY|MESA COUNT F C U|MESA BANKING|mesa banking|MESA COUNTY TEACHERS|MESA CTFCU'
						OR c.bank_name REGEXP '^mesa couty|MESA COUTY|MESA COUSNTY TEACHERS|MESA CO FED TEACHERS|MESA CO TEACHERS')  THEN 221373422

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'MARSHALL AND ISLEY BANK|Marshall and Isley Bank|^M AND I$')  THEN 255083597

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Marriot'
						OR c.bank_name REGEXP 'Marriot employees')  THEN 255083597

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Main Stree Bank|First Mainstreet') THEN 211370752

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Long Peak Credit Union|Longs Peak Credit Union|Longs Peak CU'
						OR c.bank_name REGEXP 'Pikes Peak FCU|Pikes Peak Credit Union')  THEN 307074836

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Liberty Savings'
						OR c.bank_name REGEXP 'Liberty Bank') THEN 221276118

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Laramie Plains Community CU|LARAMIE PLAINS COMMUNITY CU|LAR PLAINS CU|^Laramie Plains$|LARAMIE PLAINS CU|laramie plains cu|lar\\. plains cu|lar\\. plains'
						OR c.bank_name REGEXP 'LPFCU|LPCU|Laramie PlainsFCU|Laramie Plains FCU|Laramie Plains CU|Larami PLains CFCU|LPCFCU|Lpcfcu|lpcfcu|PLCFCU|L\\:PFCU|Laramie PLains Federal'
						OR c.bank_name REGEXP 'Laramie Plains CFCU|Lariamie pr|^Bank plains') THEN 307086879

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Langley FCU|LANGLEY FCU|^LANGELY$') THEN 307086879

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Lake Michigan Credit Union|LAKE MICHIGAN CREDIT UNION') THEN 272480678

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Lafayette State Bank|^LAFAYETTE$|^LAFYETTE STATE BANK$') THEN 063105515

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Kirtland Bank|KIRTLAND BANK|Kirtland FCU|KIRTLAND FCU') THEN 307070050

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Key Bank'
						OR c.bank_name REGEXP 'KeyBank'
						OR c.bank_name REGEXP 'Key') THEN 307070267

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Jonah Bank|JONAH BANK|^JONAH$|JONA BANK|^JFCU') THEN 102307119

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Johns Manville'
						OR c.bank_name REGEXP 'JM Associates FCU'
						OR c.bank_name REGEXP 'Johns Mansville') THEN 263089800

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'JEFERSON BANK AND TRUST|jefferson bank and') THEN "081000566"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Jeffco Credit Union'
						OR c.bank_name REGEXP 'Jeffco FCU'
						OR c.bank_name REGEXP 'Jeffco CU'
						OR c.bank_name REGEXP 'Jeffco Schools CU'
						OR c.bank_name REGEXP '^Jeffco c.u.')  THEN 283079094

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'INTERIOR FCU') THEN 254074442

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'ING Direct Bank|ING Direct|^I N G$') THEN "031176110"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Independent Bank|INDEPENDENT BANK|independent bank|Ind\\. Bank|iDAHO INDENPENTENT|IDAHO INDEPENDENT|INDEPENDANT|Independant|independant') THEN 111916326

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'HSBC') THEN "022000020"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Horizons [a-z]|HORIZON FCU|^HORIZON$|^Horizon$|^HORIZONS FCU$'
						OR c.bank_name REGEXP 'Horizons Bank|^HORIZONS$|^Horizons$')  THEN 221373710

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Home State|^HOME LOAN STATE|^Home Loan State Bank|HomeState|Homestate'
						OR c.bank_name IN ( "Home State", " Home State"))  THEN 107004776

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Hilltop Bank|Hilltop Natioinal Bank|Hilltop National Bank|^HILLTOP|HILLTOP  NATIONAL|HILLTOP NATIONAL'
						OR c.bank_name REGEXP 'The Bank of Casper|Bank of Casper')  THEN 102301199

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Higher One'
						OR c.bank_name REGEXP 'BankMobile|^VIBE|^Bank Mobile')  THEN 113024588

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'High Plains Bank')  THEN 102102000

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Heritage Bank')  THEN 125108256

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Healthone CU'
						OR c.bank_name REGEXP 'First Medical CU'
						OR c.bank_name REGEXP 'Health One') THEN 272077984

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'harrington|harrington bank|HARRINGTON BANK|^HARRINGTON$|Harrington|Harrinton')  THEN "053174103"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Guaranty'
						OR c.bank_name REGEXP 'Guaranty Bank') THEN 107004611

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'G\\.R\\. U\\.P') THEN 241075658

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Green River|GREEN RIVER FCU|Green River CU|^GREEN RIVER|GR FCU|GR Basin FCU') THEN 302386778

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Greater Texas') THEN 314977337

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
						OR a.routing_number REGEXP '[a-z]' )
				AND ( c.bank_name REGEXP 'GREATER WYOMING FEDERAL CREDIT UNION|GREATER WYOMING FCU') THEN 302386574 ##### USED TO BE WESC credit union in Casper!!!!!

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Great Western Bank|GREAT WESTERN|Great Weastern Bank') THEN "091408734"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Great Lakes') THEN 271984832

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'GREAT ALLIANCE FEDERAL CREDIT UNION|GREATER ALLIANCE FED|GAFCU|greater alliance fed') THEN 221275876

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^great amercian christian credit union|GACCU|GREAT AMERICAN|GREAT ACCU|GR AM CREDIT'
						OR c.bank_name REGEXP '^GACCU|AMERICAN CHRISTIAN CREDIT UNION|^ACCU|^GAMCU') THEN 322283767

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'GREAT AMERICAN BANK|GREAT AMER.|GREAT AMEICAN|G AMERICAN|G  AMERICAN|GREAT AM') THEN 301179795

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Grand Valley|^GRAND VALLY'
						OR c.bank_name REGEXP '^GRAND VALLEY NATIONAL|grand valley national|GRAND VALLY NATL|grand vally natl|grand natl'
						OR c.bank_name REGEXP 'GVNB|gvnb') THEN 124303010

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Grand Mountain') THEN 102189612

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^GRAND JUNCTION FED|^GRAND JCT FEDERAL|GRAND JCT FCU|GRAND JCT. CREDIT|GJ FEDERAL CU|GJF CU|GJ F  CU|GJ FEDERAL|GJFEDERAL'
						OR c.bank_name REGEXP '^GJ FCU|^GJFCU|^GJ FED CU|GJF CU|GJ F  CU| GJF CU|GJ FED CR|gj fed cr|^GJ F CU|^JGFCU'
						OR c.bank_name REGEXP 'THE BAANK OF GRAND JCT'
						OR c.bank_name REGEXP 'THE BANK OF GRAND JUNCTION|GJ FEDERAL CREDIT UNION|GJ FED CU|grand junction federal credit union|grand junction fed|gj fedcu|GJ FEDCU'
						OR c.bank_name REGEXP 'The Bank of Grand Junction|^The Bank of GJ') THEN 102189612

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'GOLDENBANKS|GOLDEN BANK|GOLDENBANK|goldenbanks|golden banks|golden bank') THEN 113015500 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'GLACIER BANKS|Glacier Bank|^Glacier|BANK OF GLACIER|Bank of Pinedale|bank of pinedale') THEN 292970825 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Gesa Credit Union') THEN 325181248

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Gateway|GATEWAY BANK|^GATEWAY|^THE GATEWAY'
						OR c.bank_name REGEXP ' Gayeway'
						OR c.bank_name REGEXP 'Gateway CU'
						OR c.bank_name REGEXP 'Gayeway') THEN 264181671

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^GATE CU') THEN "092105337"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^GARFIELD COUNTY|^garfield county'
						OR c.bank_name REGEXP '^MT GARFIELD') THEN "092105337"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Frontier Bank|FRONTIER BANK|^FRONTIER$|^frontier$') THEN "073921420"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fremont Bank|FREMONT BANK|^FREMONT|FREEMONT') THEN 121107882

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fraud') THEN "000000000"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'FOWELER STATE BANK|^FOWLER STATE BANK$|Fowler State Bank') THEN 303184856

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fort Sill Fed Credit Union|FORT SILLS NAT') THEN 303184856

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fort Morgan State'
						OR c.bank_name REGEXP 'Fort Morgan FCU') THEN 107003942

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fort Campbell'
						OR c.bank_name REGEXP 'Ft Campbell'
						OR c.bank_name REGEXP 'Ft.Campbell') THEN 264182120

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fort Bragg FCU') THEN 253175737

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Foothills CreditUnion'
						OR c.bank_name REGEXP 'Foothills FCU|FOOT HILLS CREDIT UNION|FOOT HILLS CU'
						OR c.bank_name REGEXP 'Foothills CU'
						OR c.bank_name REGEXP '^FootHills'
						OR c.bank_name REGEXP 'Foothills Bank') THEN 302076266

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Fitzsimmons'
						OR c.bank_name REGEXP 'Fitzsimons'
						OR c.bank_name REGEXP 'Fitsmons'
						OR c.bank_name REGEXP 'Fitzsmons'
						OR c.bank_name REGEXP 'Fitz. CU'
						OR c.bank_name REGEXP 'bFitz.'
						OR c.bank_name REGEXP 'FITZ FED'
						OR c.bank_name REGEXP 'Fitz C.U.'
						OR c.bank_name REGEXP 'Fitz Simmons'
						OR c.bank_name REGEXP 'Fitz.C.U.'
						OR c.bank_name REGEXP 'Fitzimmons' 
						OR c.bank_name REGEXP 'Fitsimmons') THEN 302075458

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Fort Sill National'
						OR c.bank_name REGEXP '^FT SILL NATIONAL') THEN 103112675

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Western Bank|^FIRST WESTERN') THEN 102007011

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First United Bank'
						OR c.bank_name REGEXP '1 ST UNIT. BANK'
						OR c.bank_name REGEXP '1st United') THEN 291971320

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Union Bank|FIRSTUNION|firstunion|First Union') THEN 10200076 ### bought out by Wells Fargo

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Tier Bank|FIRSTTIER BANK|firsttier bank|FirstTier Bank|Firstier Bank') THEN 104113880

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Tennessee Bank|FIRST TENNESSE BANK|FIRST TENNESSE'
						OR c.bank_name REGEXP 'FIRST HORIZON BANK|First Horizon Bank') THEN "071924306" #### FIRST TENNESSEE BECAME FIRST HORIZON

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Tech'
						OR c.bank_name REGEXP 'Addison Ave'
						OR c.bank_name REGEXP 'First Tech FCU') THEN 321180379

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First State Bank|FIRSTSTATE'
						OR c.bank_name REGEXP '^FIRST STATE|FIRST ST BANK|1ST STATE BANK|FIRST STATE BANK|lst State Bank|Firstate Bank'
						OR c.bank_name REGEXP '^1st State$|FIRSTATEBANK|Firststate bank') THEN 111901467

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Security Bank'
						OR c.bank_name REGEXP '^FIRST SECURITY') THEN "082901538"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Pioneer Natl|First Pioneer National Bank') THEN 102101315

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Northern Bank|FIRST NORTHERN BANK|FIRST NORTH|first north|first northern bank|1ST North Bank') THEN 121105156

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'FIRST NATIONS BANK'
						OR c.bank_name REGEXP 'NATIONSBANK') THEN "071924306"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '1st National|FIRST NTL|first ntl|First NTL|Frist National Bank|Frist National|FirstNational Band'
						OR c.bank_name REGEXP 'First national|FIRST NATIONAL|FIRST MNATIONAL|F.N.B. OF ROCKIES|f.n.b. of rockies'
						OR c.bank_name REGEXP 'First Nat|FNBOR|1ST NATIONAT OF THE ROCKIES|1ST NATIONAL OF THE ROCKIES|1st National of the Rockies'
						OR c.bank_name REGEXP 'FNB PUEBLO|1ST NATNL BANK|^1ST NAT |^FNB$|lst Nat'
						OR c.bank_name IN ("1st National", "1st Natl", "1st Natl Bank", "1st National Bank", "1st Natl-Estes Pk", "!st Natl") ) THEN 107000262

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Interstate Bank|FIRST INTERSTATE BANK|^1st Interstate|first interstat|frist interstate|1st interstate|^First Interstate|^First  Interstate'
						OR c.bank_name REGEXP 'firsts interstate|1st\\. interstate|^first inter$|lst Interstate|1st intersate|fisrt\\.intstate|first inst\\. bank'
						OR c.bank_name REGEXP '1 interstate|fisrt interstate|1st inerstate|first innterstate|first inerstate|1st inerstate bank|first inerstate|First Int Laramie'
						OR c.bank_name REGEXP 'FIRST INT LARAMIE|FIRST INTERSTATE LARAMIE|YI federal credit un|FirstInterstate Bank|First Interstarte Bank|1st Interatate Bank'
						OR c.bank_name REGEXP '1st Ineterstae|^FIB$|FIRST INTRST|FIRST INTRSTE|1ST INTERSDTATE|^FIB|1STINTERSTATE|FIRST INT|FIRST INTERSTA|FIRST INTR|FIRST INTRST'
						OR c.bank_name REGEXP 'FIRST INTERS|FIRST INT\\.|FIRST INTERST\\.|FIRST INTESTATE|^F\\.I\\.B$|Ist Interstate|1st Interastate|First Insterstate|!st Interstate') THEN "092901683"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'FIRST HORIZON BANK|First Horizon Bank'
						OR c.bank_name REGEXP 'First Tennessee Bank|FIRST TENNESSE BANK') THEN "071924306" #### FIRST TENNESSEE BECAME FIRST HORIZON

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Hawaiian Bank|^FHB$|^First Hawaiian$') THEN 121301015

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Financial CU|FIRST FINANCIAL CU|First Financial fcu|first financial fcu') THEN 307083694

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Federal|first federal|First Federal|FIRST FEDERAL|1ST FED') THEN 307083694

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Education Federal Credit Union|First Education FCU|First education FCU|first Edu FCU|1st ED\\.F\\.C\\.U\\.'
						OR c.bank_name REGEXP '1ST EDUC FCU|1ST ED FCU|1ST EDUC\\. FCU|1st Education|1ST EDUCATION|1ST EDU FCU|^first ed|first Edu FCU|First Edu FCU|First Edu\\. FCU|1st Ed FCU'
						OR c.bank_name REGEXP 'FIRST ED\\.F\\.C\\.U\\.|first education|First Ed FCU|FIRST ED\\. FCU|First Ed\\. FCU|first ed\\.'
						OR c.bank_name REGEXP '1st Ed\\. FCU|lst ed|first\\.education|1st. education bank|fisrt ed\\. cred\\. un|FIRST\\.ED\\.FED\\.CR\\.UN'
						OR c.bank_name REGEXP 'first\\.educ\\. fd\\. cr\\. un|1st\\.educ\\.\\.fed\\.cr\\un|1st edcation fcu|first\\.ed\\.cr\\.fd\\.un\\.'
						OR c.bank_name REGEXP 'employees f\\.c\\.u|wy emp fe uniom|1st educfu|frist education fcu') THEN 307086617 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'First Colorado National Bank'
						OR c.bank_name REGEXP 'IST NAT OF PAONIA') THEN 102101292

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'FIRST CHEY CU|FIRST CHEY FCU|1ST CHEY FCU|First Chey\\. F\\.C\\.U\\.|First Cheyenne FCU|FIRST CHEYENNE|1st CHY FCU|1ST CHEYENNE'
						OR c.bank_name REGEXP 'First Cheyenne FC|^First Cheyenne FCU|1st Cheyenne FCU|CHEY FCU|1st Cheyenne FCU|1ST CHEYENNE|1ST CHY FCU|1st Chy FCU|1ST CHEY FCU'
						OR c.bank_name REGEXP 'first chey\\. fed\\.cr\\.un|first chey fd\\.cr\\.un|FIRST CHEYENNE|fiirst cheyenne|Chey  federal  credit union|^fed\\.credit union$'
						OR c.bank_name REGEXP 'first chey\\. cred\\. un|1st chey\\.fed cr\\.un|^FIRST FED$|first chey\\.fed\\.cr\\.un|fisrt\\.chey\\. fed cr un'
						OR c.bank_name REGEXP 'first\\.educ\\. fd\\.cr\\.un\\.|lst Cheyenne|1st\\.educ\\.\\.fed\\.cr\\.un|chey\\.first wyoming|w\\.f\\.c\\.u'
						OR c.bank_name REGEXP 'first chey fd\\. cr\\.un|frist cheyenne|first chey\\.fd\\.cr\\.un|first cheyenn cu|frist cheyenne|1st chey|First Chy FCU') THEN 307086633

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '1st Bank|^1stBank|1sr bank|BancFirst|1st\\. Bank Evanston'
						OR c.bank_name REGEXP 'First Bank|FRIST BANK|1 st Bank|1ST BNK N'
						OR c.bank_name REGEXP 'FIRSTBANK|^FBOR|^1STBOR'
						OR c.bank_name REGEXP 'FAA First FCU'
						OR c.bank_name REGEXP 'FAA First Fed|IST OF THE ROCKIES|1ST OF THE ROCKIES|FIRST BANK OF THE ROCKIES|1ST BANK OF THE ROCKIES'
						OR c.bank_name REGEXP 'Advantage Bank'
						OR c.bank_name IN ("!st Bank")) THEN 107005047

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'FIREFIGHTERS CREDIT UNION|FIREFIGHTERS FCU|firefighters fcu') THEN 303985961

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Financial Federal Bank|FINANCIAL FEDERAL BANK|FIN FED SAV &LN') THEN 264081179

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Fedral Credit Union') THEN "041202744"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Federal Bank|FDIC|FEDERAL CREDIT UNION|FED CRED UNION') THEN 302373118

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'National Farmers Union') THEN "041212145"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Fairwinds Cred.Union'
						OR c.bank_name REGEXP 'Fairwinds Credit') THEN 263181368

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'The Farmers State Bank|Farmers State Bank|^FARMERS BANK$|farmers state') THEN 102103562

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Farmers Insurance FCU'
						OR c.bank_name REGEXP 'Farmers Union FCU') THEN 322077795

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'FAMILIES FIRST'
						OR c.bank_name REGEXP 'PATHFINDER CU') THEN 302386477 ##### IS PATHFINDER NOW!

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'FAMILY FIRST|FAMILY FIRST CU') THEN 292977271 ### so there is, apparently a Family First CU. They probably meant FamilIES First, but who knows for sure? 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'FAA CU|FAA FCU') THEN 284084363

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Evergreen National Bank') THEN 107003861

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'E-Trade Bank|E Trade Bank|ETrade Bank|^E-Trade$') THEN 256072691

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Equitable Savings and Loan|Equitable Savings|^Equitable|equitable|Eqiutable Savings and loan') THEN 307087001

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Equality State|^EQUALITY$|EQULITY|EQUALITY BANK|equality bank|Equality Bank|Equailty State|equuitly state|equitly state'
						OR c.bank_name REGEXP '^EQUALITY ST|EQUALITYSTATE') THEN 107003052

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'ENT FCU'
						OR c.bank_name REGEXP 'ENT Federal Credit Union'
						OR c.bank_name REGEXP 'ENT Federal CU'
						OR c.bank_name REGEXP '^ENT |^ENT$') THEN 307070005

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ENERGY WEST FCU|ENERGY WEST|ENG W FCU|ENERGYWESTFC|ENERGY W FCU|ENERGYWEST') THEN 302075416

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Elevations FCU|Elevations CU'
						OR c.bank_name REGEXP '^Elevations$|^CSM FCU$'
						OR c.bank_name REGEXP '^Elevations Credit'
						OR c.bank_name REGEXP 'Boulder Muni') THEN 307074580

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Electrical FCU') THEN 302075416

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Eastern Colorado Bank'
						OR c.bank_name REGEXP 'Kit Carson State Bank') THEN 102104684

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'FCEASTERN FINANCIAL FCU'
						OR c.bank_name REGEXP '^EASTERN BANK|EFCU'
						OR c.bank_name REGEXP '^eastern financial'
						OR c.bank_name REGEXP 'Wy Emp FCU|WY EFCU|WY EMP FCU|wyo emp fcu|Wyo Emp FCU|WYO EMPLO FCU|WY EMPLOY.FCU|wyo employe|wyo.employ.fed.cr|wyom. emp.fed|wyom.fed cr'
						OR c.bank_name REGEXP 'wy\\.emp|wy\\.emply|wy emp fcu|WY EMP FCU|Wy Emp FCU|WY Emp FCU|Wyoming Emp FCU|wyoming emp fcu|Wyoming Em Fcu|WY EMPLOYEE FCU|wy employee fcu'
						OR c.bank_name REGEXP 'wy\\. emp\\. fcu|wy emp federal cu|WY Employees Fcu'
						OR c.bank_name REGEXP 'wyoming emplyees') THEN 11301798 #### AKA WY EMPLOYEES FEDERAL CREDITUNION

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Eagle Legacy'
						OR c.bank_name REGEXP 'Eagle Legancy'
						OR c.bank_name REGEXP '^Eagle') THEN 302075306

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'East Idao Bank|EAST IDAHO BANK') THEN 324173082

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^DOWNEY|^Downey|Downeysv\\.') THEN 102104927

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'dolores state|DOLORES STATE BANK|^dolores') THEN 102104927

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Digital FCU') THEN 211391825

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Desert Schools FCU') THEN 122187238

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'DESERET 1ST') THEN 324078909

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Denver Public Schools|DEN\\. PUBLIC SC\\. EMP\\. C\\.U\\.'
						OR c.bank_name REGEXP 'DEN PUB'
						OR c.bank_name REGEXP 'DPS'
						OR c.bank_name REGEXP 'Denver P.') THEN 302075319

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Denver Postal'
						OR c.bank_name REGEXP 'Partner'
						OR c.bank_name REGEXP 'Denver Credit Postal') THEN 302075306

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Denver Municipal CU|DENVERMUN\\. F\\. C\\. U\\.') THEN 302075694 ### bought out by Denver Commmunity

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Denver Community'
						OR c.bank_name REGEXP 'Denver Comm'
						OR c.bank_name REGEXP 'Den Comm'
						OR c.bank_name REGEXP 'DCFCU'
						OR c.bank_name REGEXP 'Denver Media'
						OR c.bank_name REGEXP 'DENVER MUNICIPAL|DENVER MUN\\. F\\.C\\.U\\.|DENVER MUN\\. C\\.U\\.|DENVER MUNI F\\.C\\.U\\.'
						OR c.bank_name REGEXP 'Colonial'
						OR c.bank_name REGEXP 'Denver Federal CU'
						OR c.bank_name REGEXP 'Denver Com.FCU') THEN 302075694

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Delta Community CU|DELTAFCU|DELTACFCU|Midtown Federal CU') THEN 261071315

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Decibel Credit|^DECIBEL CREDIT|^decibel$|^DECIBEL$|Decibel Community|DECIBEL COMMUNITY|DECIBEL C U|decibel c u'
						OR c.bank_name REGEXP 'DECIBEL COMM. CREDIT UNION|^DECIBAL CREDIT|^decible$|^DECIBLE$|^decible|^decibel '
						OR c.bank_name REGEXP '^DECIBEL CR|^DECIBEL CERIDET|^DECIBEL CRD|DECIBLE|DECIEBEL|decibel cu|^DECIBEL') THEN 307077202 ### SAME AS POWER CREDIT UNION (PUEBLO)

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'DC Credit Union') THEN 254074455

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'CSECU|CSE CREDIT UNION|CSEMCU'
						OR c.bank_name REGEXP 'Convenience Services') THEN 241274459

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Credit Union of the Rockies|^CU of the Rockies') THEN 307076232

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Credit Union of Denver|CU OF DEN| C U OF DEN|DENVER FCU'
						OR c.bank_name REGEXP 'CU of Denver|CO of Denver'
						OR c.bank_name REGEXP 'C\\.U\\. of Denver'
						OR c.bank_name REGEXP 'Denver F\\.C\\.U\\.|C\\.U\\.OF DENVER'
						OR c.bank_name REGEXP 'C\\.U\\. Denver'
						OR c.bank_name REGEXP 'aDenver C.U.'
						OR c.bank_name REGEXP '^CUof Denver|C U of Denver'
						OR c.bank_name REGEXP '^CREDIT UNION') THEN 307075259

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Coventry C U') THEN 211573326

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^County Savings|CO SAVINGS') THEN 231372329

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Corporate America Family') THEN 271987075

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Coors CU'
						OR c.bank_name REGEXP 'Coors'
						OR c.bank_name REGEXP '^On Tap') THEN IF 	(c.bank_name REGEXP '^Coors', 307076533, 
																IF	(c.bank_name REGEXP '^On Tap', 302075089, '')
																)

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'CONVERSE COUNTY BANK|^CCB$|^CONVERSE CTY$|^CONVERSE COUNTY$|CONVERSE COUNTY BK|CONVERSE CO B|CONVERSE CO BANK'
						OR c.bank_name REGEXP 'CONVERSE CTY|CONVERSE CO\\. B|CONVERSE CO|CONV\\. CO BANK|^CONVERSE$') THEN 102301542

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Continental FCU|CONTINENTAL FCU|continental fcu|CONTINENTAL F\\.C\\.U\\.') THEN 107005319

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Consumers Edge') THEN 271989950

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Compass'
						OR c.bank_name REGEXP '^BBVA') THEN 107005319

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'community national bank|COMMUNITY NATINAL BANK|^CNB') THEN 116312873

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'community first national bank|COMMUNITY FIRST NATIONAL BANK|^CFNB|COMMUNITY FIRTST|COMFB|COM') THEN 101114918

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Community First Bank|^CFB|^COM1ST|^COMM 1ST|CMNITY 1ST|CONUNITY 1ST|^CF B$|^CFB$'
						OR c.bank_name REGEXP '^COMMUNITY FIRST|COMMUNITY 1ST|community first|COMMUITY FIRST|COMMUNITYN FIRST') THEN "091208471"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Community Financial'
						OR c.bank_name REGEXP 'Comm. Fin.'
						OR c.bank_name REGEXP 'Community Fin.') THEN 221276545

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Community Banks of Colorado'
						OR c.bank_name REGEXP 'Community Banks|^Community Bank|^COLO COMM|^COMMMUNITY BANK') THEN 102102013

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Community Choice'
						OR c.bank_name REGEXP ' Comm Choice') THEN 307074276

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'CO State Bank and'
						OR c.bank_name REGEXP 'CO State Bank'
						OR c.bank_name REGEXP 'Colo State Bank &') THEN 102000607

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Commercial Bank'
						OR c.bank_name REGEXP 'Comercial Federal'
						OR c.bank_name REGEXP 'Commercial Fed|^Commmercial Fed|^COMMERCIAL  FED|^COMMERCIAL FED|COMMERICAL FED'
						OR c.bank_name REGEXP 'Comm Bank'
						OR c.bank_name REGEXP '^Com. Fin. Fed'
						OR c.bank_name REGEXP 'Comm. Fed.') THEN "064202983"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Commerce Federal'
						OR c.bank_name REGEXP 'Comm Federal Savings|COMMERCIAL FED.'
						OR c.bank_name REGEXP 'Comm Fedral'
						OR c.bank_name REGEXP 'Comm Fed') THEN 254074439

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Commerce') THEN 101000019

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^COLORAMO'
						OR c.bank_name REGEXP '^coloramo|^COLORAMA') THEN 302176580

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Credit Union of Colorado|COLORADO UNITED CREDIT UNION|colorado united credit union'
						OR c.bank_name REGEXP 'CO  ST ECU|CO S ECU|CO ST E CU|CO ST ECU|CO ST EMCU'
						OR c.bank_name REGEXP 'colorado federal credit union|COLORADO FEDERAL CREDIT|CO FED CU|co fed cu|CO FEDERAL CU|^CFF CU$|^CSM FCU$'
						OR c.bank_name REGEXP 'CU of CO'
						OR c.bank_name REGEXP 'Co St Employees C.U.'
						OR c.bank_name REGEXP 'CO State Employees CU'
						OR c.bank_name REGEXP 'Colorado State Emp|^COLORADO STATE$'
						OR c.bank_name REGEXP 'Colo State emp|^CO ST EMP CU|^CO STATE ECU|^CO STATE EMP|COLO STAT EMP CU|COLO STATE CREDIT UNION|EMP. CREDI UNIO'
						OR c.bank_name REGEXP 'Colo Central|EMP. CRED UNIO|CITY EMPLOYEE'
						OR c.bank_name REGEXP 'CO Central CU|^COLO ST CREDIT|^COLO SATE|^COLO FEDERAL CREDIT|COLORADO FEDERAL CREDIT UNION|COLORADO FCU|CO FEDERAL CU|co federal cu'
						OR c.bank_name REGEXP 'a C STATE EMPLOYEES CU'
						OR c.bank_name REGEXP 'Colorado Emp Cu|COLO ST EMP CR'
						OR c.bank_name REGEXP 'Colorado Emp'
						OR c.bank_name REGEXP 'Colorado St. Employees|COL STATE EMPL C\\.U\\.'
						OR c.bank_name REGEXP '^Colorado State O'
						OR c.bank_name REGEXP 'Co\\. St\\. Employee'
						OR c.bank_name REGEXP '^COLORADO CREDIT UNION|Colorado CU|CO CREDIT UNION'
						OR c.bank_name REGEXP 'Colorado State Bank'
						OR c.bank_name REGEXP '^CITY EMPLOYEES$|City Emp Crd Union'
						OR c.bank_name REGEXP 'colo\\. state employee|COLO STAT EMP CR|COLO EMPLOYEE|colo st employees|co st emp|CO.ST.EMPLOYEE|CO ST EMP CU|COL ST EMP CR U'
						OR c.bank_name REGEXP 'Colo St\\. Employ|^Colo\\. St\\. Emp'
						OR c.bank_name REGEXP 'STATE EMPLOYEES CREDIT UNION') THEN 302075128

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colorado State Bank and Trust|CO STATE & TRT|Colorado State Bank & Trust|co state bank and trust|co\\. state bank & trst') THEN 107002969

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colorado National Bank|^CO NATL$|Colorado Natl|Colo\\. National|Colorado Natnl Bank|Colo Natl|Colo Natl Bank|CO NAT|Colorado Natnl'
						OR c.bank_name REGEXP 'CO\\. NAT\\.|Colorado Natl Bank|Colorado Natl|colorado natl|Colo Natl|Colo Natl Bank|COLO\\. NAT\\. BANK|Colo\\. Natl'
						OR c.bank_name REGEXP 'Colorado Natl|colorado natl|Colo Natl Bank|Colorado Natl Bank|Colorado Natl|Colo Natl|Colo Natl Bank|COL\\. NATINAL|COL\\. NAT\\. BANK|Colorado Natl'
						OR c.bank_name REGEXP 'COL\\. NAT\\.|col nat bank|COL NAT  BANK|COL NAT BANK|Colorado Nat\'l Bank|Colo Nat\'*l|Colorado Nat\'*l|Colo\\. Nat\'*l'
						OR c.bank_name REGEXP 'col\\. national|COL\\.NATIONAL|COL\\.NAT\'*L|^COL NAT\\.$|^COL NAT|^COL\\. NAT|COL\\. NATIONAI BANK') THEN 102101441

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colorado East Bank & Trus|COLORADO EAST BK & TRUST|CO BANK & TRUST|CO B&T'
						OR c.bank_name REGEXP 'colorado east bank and trust|COLORADO EAST BANK AND TRUST'
						OR c.bank_name REGEXP '^COLORADO EAST|^Coloado East|^colorado east|^COLO EAST|Colordo East|colo east') THEN 102101577

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colorado Central CU|Colorado Central  C\\.U\\.|Colorado Cental C\\.U\\.|CO CCU'
						OR c.bank_name REGEXP 'Colorado Central Credit|Colorado Cental  C\\.U\\.|COL\\. CENT\\. C\\.U\\.|CO CENTRAL|CO CENTRAL CU|CO Central'
						OR c.bank_name REGEXP 'Colorado Central'
						OR c.bank_name REGEXP 'Colo. Central') THEN 307074690

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colorado Bank and Trust|COLORADO BANK AND TRUST') THEN 102100675

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Colonial Bank') THEN "041202744"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Collegiate Peaks Bank|COLLEGIATE PEAKS BANK|^Collegiate Peaks') THEN 102105997

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Coastal Bank of Florida|Coastal Bank & Trust of Florida|Sarasota Coastal CU') THEN "063208140"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CNB$|^CMB$|^CMB BANK$') THEN "022303659"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Citywide Bank'
						OR c.bank_name REGEXP 'City Wide'
						OR c.bank_name REGEXP 'Citywide') THEN 107005953

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'City and county'
						OR c.bank_name REGEXP 'CCCU') THEN 296075810

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Citizens Bank|CITIZENS BANK|CITIZENS BNK|citizens bank') THEN "011500120"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Citibank|^CITIBANK|^CITI BANK'
						OR c.bank_name REGEXP 'ALBERTSON CREDIT UNION'
						OR c.bank_name REGEXP '^Albertson') THEN 321171184

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Choice Bank|Bank of Choice') THEN 75918075

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Cheyenne State Bank|CHEYENNE STATE BANK|^Cheyenne State$|st\\. chey fed') THEN 107006923

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Cheyenne-Laramie County Employees Federal Credit Union|CLCEFCU|^Chey-Lara Cnty|Chey-Lar Co emp FCU|Chey-Lar FedCU'
						OR c.bank_name REGEXP 'CHE-LAR FCU|CHEY CO EMP CU|CHEY EMP FCU|CHY EMP CU|Cheyenne Employees CU|C\\.L\\.COU EMPLO|CHEY-LAR COU\\.EMP'
						OR c.bank_name REGEXP 'CHEY SCL FCU|CHEY COUNTY CU|CHEY-LARA FCU|Cheyenne-Larami County Emp FCU|cheyenne-lar county fcu'
						OR c.bank_name REGEXP 'Cheyenne-Laramie FCU|Cheyenne Employee FCU|Cheyenne-Laramie County Emp FCUz|Chy Laramie FCU|CheyenneFederal'
						OR c.bank_name REGEXP 'Cheyenne Laramie County Employee Federal Credit Un|chey\/lar\\.employ\\.cr\\.un|Chey-lar\\. emply fed cr un'
						OR c.bank_name REGEXP 'cheyenne employees federal|Chy Cty Emp|^COUNTY BANK$|Cheyenne-Laramie County Emp FCU|chey emply fd\\.cr\\.un'
						OR c.bank_name REGEXP 'chey-larcounty em\\.fcu|^employees fed cu$|CLC federal union|chey-county employees fed|Laramie county FCU'
						OR c.bank_name REGEXP 'emp\\. fed\\. credit|Cheyenne Laramie County Employees|employes fed credit union|CHY LC FCU|chy lc fcu'
						OR c.bank_name REGEXP 'chey lar county fcu|Cheyenne Laramie County FCU|chey lar cty fcu|chey lar fcu|^FEFCR$|Cheyenne Laramie County FCU|Cheyenne Laramie County  FCU'
						OR c.bank_name REGEXP 'ChyLarCntyFCU|Chey Laramie Cnty Employee FCU|Chey Laramie Cnty Employee  FCU') THEN 307086604

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Charter One') THEN "011500120" # Acquired by Citizens Bank

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Charles Schwab'
						OR c.bank_name REGEXP '^Schwab') THEN 121202211

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CHASE BANK'
						OR c.bank_name REGEXP '^STATE OF CALIF'
						OR c.bank_name REGEXP '^STATE OF CA'
						OR c.bank_name REGEXP '^CHASE') THEN 102001017

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CFCU') THEN 221381540

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CF&I CREDIT UNION|CF BANK|CF&I CREDIT|^CO SPGS$') THEN 241272118

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Central Bank') THEN 113001077

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^central national bank|CENTRAL NATIONAL BANK') THEN 221381540

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Centennial Bank|Cenntennial Bank'
						OR c.bank_name REGEXP 'CENTENNIAL SAVINGS|CENTINNIAL'
						OR c.bank_name REGEXP '^CENTENNIAL$|^centennial$|^CENTEN BANK|^CENTENIAL BANK') THEN "082902757"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Catholic Federal Credit Union|Cath\\. Fed\\. Credit Union|^CATH\\. UFCU') THEN 221381540

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CAPITAL ONE|Capital One'
						OR c.bank_name REGEXP '^NORTH FORK|^north fork bank') THEN 302075830

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Canvas Bank'
						OR c.bank_name REGEXP 'Canvas CU'
						OR c.bank_name REGEXP 'Provenant'
						OR c.bank_name REGEXP 'NORLARCO|norlarco|noralco|Norlaco') THEN 302075830

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'CANON NATL BANK|Canon Natl|Canon Ntl|^Canon National|^CANON NATIONAL|^canon national|CANON NAT BK|Canon Nat Bank|Canon Nat'
						OR c.bank_name REGEXP 'Canon Bank|^canon$|^CANON$|^CANNON NATIONAL') THEN 107002516 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^CAMPCO FCU|^CAMPO FEDERAL$') THEN 302386749

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Cache Bank & Trust|Cache Bank') THEN 107006389 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Burke & Herbert|BURKE & HERBERT') THEN "056001066"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Buffalo Federal|BUFFALO FCU') THEN 222079424

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Buckley') THEN "071111957"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Brighton Cooperative F\\.C\\.U\\.|Brighton FCU|The Cooperative Bank') THEN 211372404

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Boulder Valley Credit Union|Boulder Valley') THEN 307074535 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Boulder Muni Emp|Boulder Municipal Emp|BOULDER MUN\\.EMP') THEN 107002448

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'BMO Harris Bank') THEN "071025661"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Blue Federal Credit Union|BLUE FEDERAL CUR|Two Blues Fed CU|^BLUE FCU$|^Blue FCU$') THEN 307070034

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Big Thompson FCU|Big Thompson') THEN 307077079

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bell') THEN 107005953

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$' 
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bellco'
						OR c.bank_name REGEXP 'Bello'
						OR c.bank_name REGEXP '^BELLCO|^BELCO') THEN 107005953

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'BECU|^becu') THEN 325081403

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'barksdale bank|BARKSDALE BANK|Barksdale|BARKSDALE|barksdale fcu') THEN 311175093

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of the West|Bank of th West|Bank West|^BANK OF  WEST|^BANK OF WEST|^BANK OF THE WEST'
						OR c.bank_name REGEXP 'Bank of West|^Bank West|^BANIK OF THE WEST|^BANK OF  WEST|^ BANK OF  WEST'
						OR c.bank_name REGEXP 'Commercial Federal'
						OR c.bank_name REGEXP 'Commerical Federal'
						OR c.bank_name REGEXP 'Commercial Fed'
						OR c.bank_name REGEXP 'Bank of Cherry Creek'
						OR c.bank_name REGEXP '^BOTW|^BOT WEST|Bank of The W est|^B\\.O\\.T\\.W\\.$'
						OR c.bank_name IN ("Bank of the Werst")) THEN 121100782

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank One' 
						OR c.bank_name REGEXP 'Bankone|BANK1ONE') THEN IF(c.state = "CO", 102000021, IF(c.state = "ID", 123103729, 102000021))

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Bank of San Juan'
						OR c.bank_name REGEXP 'Bank of the San Juans'
						OR c.bank_name REGEXP 'BANK OF SAN JUANS'
						OR c.bank_name REGEXP '^BANK OF THE SAN JUANS') THEN 102106569

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of New York') THEN "021000018"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of Laramie') THEN 121100782

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of Jackson Hole|bank of jackson hole|BANK OF JACKSON HOLE') THEN 102304099

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of Grand Junction'
						OR c.bank_name REGEXP '^BANK OF GRAND JCT'
						OR c.bank_name REGEXP '^BANK  OF GRAND JUNCTION'
						OR c.bank_name REGEXP '^BANK OF GJ|^BANK OF G\\.J\\.') THEN 102000924

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of Denver|Denver Media|DENVER MEDIA|Dnvr Media CU') THEN 102000924


			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of Colorado|^BANK O CO'
						OR c.bank_name REGEXP '^Bank of Co|^B OF CO'
						OR c.bank_name REGEXP 'SURFACE CREEK BANK'
						OR c.bank_name REGEXP '^BANK OF CO') THEN 107002448

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of China|BOC') THEN 111308442

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Bank of America|BANK OF AMER|B OF A|^BOA$|^BofA$'
						OR c.bank_name REGEXP '^BANK OF AMERICA|Bank America|BofA'
						OR c.bank_name REGEXP '^NO BANK OF USA') THEN 123103716

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'The Bancorp Bank|Bankcorp|BANK CORP|bank corp|Bank Corp') THEN "031101169"

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Badlands Federal Credit Union|BNFCU') THEN 292977200

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Aurora Federal CU'
						OR c.bank_name REGEXP 'Aurora Fed'
						OR c.bank_name REGEXP 'Members Federal CU'
						OR c.bank_name REGEXP 'Members FCU'
						OR c.bank_name REGEXP 'Aurora FCU'
						OR c.bank_name REGEXP 'Aurora ') THEN 307074454

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Aurora Schools FCU'
						OR c.bank_name REGEXP 'ASFCU'
						OR c.bank_name REGEXP 'Aurora FCU'
						OR c.bank_name REGEXP 'Aurora Catholic'
						OR c.bank_name REGEXP 'Aurora Schols'
						OR c.bank_name REGEXP 'Aurora Schools') THEN 307074467

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ATLANTIC CITY FCU|ATLANTIC CITY') THEN 302386817

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Armed Forces'
						OR c.bank_name REGEXP 'arm forces'
						OR c.bank_name REGEXP '^ARMED FORCE'
						OR c.bank_name REGEXP '^ASDF|^AS'
						OR c.bank_name REGEXP 'Fort Riley National') THEN 101108319 ### Fort Riley branch of Armed Forces bank

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Arizona Federal|ARIZONA FEDERAL|arizona federal') THEN 322172797

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Arapahoe') THEN 307076342

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Apex Community FCU') THEN 231385167

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ANIMAS CU') THEN 302284058

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Anheuser-Busch') THEN 281082915

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Andrews FCU') THEN 255074111

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^AMERICAN NATIONAL|Amercan National Bank'
						OR c.bank_name REGEXP '^AM NAT|Am\\. Nat|amer\\.nat\\.'
						OR c.bank_name REGEXP '^American National|AM NTLBANK'
						OR c.bank_name REGEXP '^AMER NATL|AM NTL BANK|AM NTL BNK|Am\\.'
						OR c.bank_name REGEXP '^AMERICAN'
						OR c.bank_name REGEXP '^american|amer\\.nat bank|amer\\.nat|americam natl'
						OR c.bank_name REGEXP '^AMERCIAN NAT'
						OR c.bank_name REGEXP '^AMNB|^AMB|^AM NATL|AMERICAN NATIONAL BANK|American National Bank|Amer\\. Nat\\.|Amer\\. Nat|Amrcn Natl'
						OR c.bank_name REGEXP 'AMER\\. NATIONAL|AMER NATION|AMER\\. NAT|AMER NAT|AM\\. NAT|AM\\. NATIONAL'
						OR c.bank_name REGEXP '^AND') THEN 103102960

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^ANCHOR BANK|Anchor Bank|anchor bank|^Anchor$')  THEN 067015656


			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^ANB'
						OR c.bank_name REGEXP '^ANB BANK')  THEN 107000233 ### us this one for ANB ONLY!!! Although I think it technically STANDS for American National Bank. . .there actually IS
																			## an American National Bank. So .. . . leave ANB for ANB BAnk alone. 

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'American Fed\\.|american federal|AMERICAN FEDERAL|^AM FED$|^am fed$|American Federal|American Fed\\.|AMERICAN FED\\.|^AM\\. FED\\.$') THEN 103102960

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'America First Credit Union|America First CU|Amer\\.  1st FCU|Amer\\. 1st FCU|Amer\\.   1st FCU|AMERICA FIRST|America First|^AMERICA$') THEN 324377516

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ALTURA CREDIT UNION|Altura Credit Union|altura credit union|ALTURA CU|Altura CU|altura cu') THEN 322281235

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ALTA|alta|alta one fcu'
						OR c.bank_name REGEXP 'Trane FCU|Trane Federal Credit Union|^TRANE') THEN 291881216

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^ALPI NE'
						OR c.bank_name REGEXP '^Alpine|^ALPINE|^ ALPINE'
						OR c.bank_name REGEXP '^APLINE'
						OR c.bank_name REGEXP '^f COUNTY'
						OR c.bank_name REGEXP '^MESA CNT'
						OR c.bank_name REGEXP '^MESA CTY') THEN 102103407

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Ally Bank') THEN 124003116

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Allstate Bank|^ALLSTATE$') THEN 71974424

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^Alliant$|^ALLLIANT$') THEN 271081528

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Alliance') THEN 111901975

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ALBERTSON') THEN 111901975

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP '^ALASKA$|^alaska$|^Alaska$|Alaska USA|Alaska FCU|Alaska CU|alaska f c u|alaska fcu|alaska cu|ALASKA FCU|ALASKA CU') THEN 325272021

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'AIR ACADEMY|^air academy federal cu|^AIR ACADEMY FCU|^AIR  ACADEMY$') THEN 307070021

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Agriculture Federal Credit Union|AGRICULTURE FEDERAL CREDIT UNION|AGRICULTURE FCU|Agriculture FCU'
						OR c.bank_name REGEXP 'FARMLAND CREDIT UNION|FARMLAND CU|FARMLAND FCU|Farmland FCU|Farmland Credit Union') THEN 254074057

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Advantage Plus|ADVANTAGE PLUS|ADVATAGE PLUST|ADAVANTAGE PLUS|^ADVANTAGE$|^ADVANTAGE \\+$|^ADVANTAGE PLUS$|^ADVANTAGE PLUS FCU'
						OR c.bank_name REGEXP '^ADVANTAGE PLUS CU|ADVANTAGE F\\.C\\.U\\.|advantage plus|Advantage Plus|^AFCU$') THEN 324173587

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Addison|Addison Ave|Addison CU') THEN 321180379

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'Adams Bnk & Trust|Adams Trust|Adams Bank & Trust') THEN 104113958

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ACPE FCU|A\\.C\\.P\\.E\\.|acpe fcu|ACPE Fed Credit Un|ACPE') THEN 307086837

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND ( 	c.bank_name REGEXP 'ACCESS FCU|^ACAS') THEN 311376902

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP '^Academy|^ ACADEMY|acadamy|academy|ACADAMY'
						OR c.bank_name REGEXP 'academy bank'
						OR c.bank_name REGEXP '^acdemy|^Acsdemy'
						OR c.bank_name REGEXP '^acedamy'
						OR c.bank_name REGEXP '^acedemy'
						OR c.bank_name REGEXP '^Acamemy'
						OR c.bank_name REGEXP '^ ACADAMY'
						OR c.bank_name REGEXP '^AB|^ACB|^ACADAMY|^ACADEMEY|^ACADEMY|^ACADMY|^Acadeny|^ADADEMY|^ACAD|^ACA '
						OR c.bank_name IN ( "Academy", "Acadamy") ) THEN 107001481

			WHEN (	a.routing_number IS NULL OR a.routing_number = '' OR a.routing_number IN ("X", "0", "0X", "00", "000", "0000", "closed", "CLOSED", "XX", "xx", "x", "None", "NA", "na", "none") OR a.routing_number REGEXP '[a-z]' OR a.routing_number REGEXP '^0*$'
					OR a.routing_number REGEXP '[a-z]' )
				AND (	c.bank_name REGEXP 'Anderson|ANDERSON AND KEIL|ANDERS0N KEIL|andderson & keil|anderson& keil|andersonh & keil'
						OR c.bank_name REGEXP '^apollo [0-9][0-9]-[0-9][0-9]-[0-9][0-9] xx$|^apollo [0-9]-[0-9][0-9]-[0-9][0-9] xx$|apollo [0-9][0-9]-[0-9][0-9]-[0-9][0-9]xx$'
						OR c.bank_name REGEXP '^APOLLO [0-9][0-9]-[0-9][0-9]-[0-9][0-9] xx$|^APOLLO [0-9]-[0-9][0-9]-[0-9][0-9] xx$|APOLLO [0-9][0-9]-[0-9][0-9]-[0-9][0-9]xx$'
						OR c.bank_name REGEXP '^apollo xx$|^APOLLO XX$'
						OR c.bank_name REGEXP '^ANDERSWON|^[A-Z][A-Z]$'
						OR c.bank_name REGEXP '^BANK$|^Bank of Trust$'
						OR c.bank_name REGEXP '^DMEA$'
						OR c.bank_name REGEXP '^Frozen$|^FROZEN ACCOUNT$'
						OR c.bank_name REGEXP '^NO ACCOUNT$'
						OR c.bank_name REGEXP '^none00$|^NONE$|^NONE$|^NONE`$|N O NE|nonbe'
						OR c.bank_name REGEXP '^non transaction$|^non-transaction acct$|^no authorization$|^not auth$|^n o$|^no$'
						OR c.bank_name REGEXP '^Revoked$|^Auth Revoked$'
						OR c.bank_name REGEXP '^SAFECO INSURANCE|^safeco'
						OR c.bank_name REGEXP '^SBBT'
						OR c.bank_name REGEXP '^Stop Payment$|^STOP$'
						OR c.bank_name REGEXP '^STOPPED$|^STOP$|^Stop Payment$|^stopped payment$|^StpPymtTCF$'
						OR c.bank_name REGEXP '^UPDATE$'
						OR c.bank_name REGEXP '^FROZEN$'
						OR c.bank_name REGEXP '^Close$|^CLOSED$|^CLSOED$|^Close...$|^Closed Account|cash cashing|^CC Only$|^CC ONLY$'
						OR c.bank_name REGEXP '^X\\/F|^X\\/0|^X\\/O'
						OR c.bank_name REGEXP '^--$|^-$'
						OR c.bank_name REGEXP '^xxx$|^XXX$|^x|^x*x$|^X*X$|^x*x .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^X*X .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^Western Union|WESTERN UNION|^NO BANK$|^zzz$'
						OR c.bank_name REGEXP '^[A-Z]$|^ [A-Z]$|^0X$|^;LASKDF$'
						OR c.bank_name REGEXP '^[a-z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9]-[0-9][0-9]-[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]\/[0-9]-[0-9]-[0-9][0-9]$|^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[0-9]\/[A-Z]\/[0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]-[0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[A-Z]-[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name IN ("anderson & keil", "anderson", "A&K", "ANDERSON KEIL", "APOLLO", "NOT AVAILABLE", "O", "OO", "OOO", "OOOO", "104648886", "Money Orders", "MONEY ORDERS",
											"Money Order Only", "Check Cashing Only", "MONEY ORDER AND BILL PAY", "QWEST PAYMENTS", "MONEY ORDERS ONLY" , "cashchecks only", "QWEST ONLY", 
											"Money Gram")) THEN '000000000'


			###### --- DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS DELETIONS
			WHEN (a.routing_number REGEXP '[a-z]' 	### will not include REGEXP [a-z] or REGEXp closed or frozen or stop pay, etc., in the BANK NAME section because those USUALLY have the actual bank name too
													### if I REGEXP for those, then I'll end up blanking out those accounts that COULD have an actual routing number. 
													### get it? GET IT?
					OR a.routing_number IS NULL)
					AND (	c.bank_name IS NULL
							OR c.bank_name IN (	"X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXXX", "XXXXXXXX", "XXXXXXXXX", "XXXXXXXXXX", 
												"XXXXXXXXXXX", "XXXXXXXXXXXX", "x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
												"xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", " x", 
												" xx", " xxx", " XXX", "closed", "CLOSED", "Closed", "Closed Account", "closed acct", "closed account", 
												"check cashing only", "CHECK CASHING", "CHECK CASHING ONLY", "Check Cashing Only", "CHECK CASH", "cashchecks only",
												"na", "NA", " na", " na", " NA", "Na", "nA", "NO BANK", "No Bank", "no bank", "nada", "Nada",  "QWEST ONLY", "Money Gram",
												"Money Order Only", "Check Cashing Only", "MONEY ORDER AND BILL PAY", "QWEST PAYMENTS", "MONEY ORDERS ONLY", "MONEY ORDERS",
												"N/A", "n/a", "N/a", "n/A", "c", "00", "000", "0000", "00000", "000000", "0000000", "00000000", "000000000",
												"0000000000", "00000000000", "000000000000", "0000000000000", "00000000000000", "000000000000000", 
												"0000000000000000", "00000000000000000", "x000000000000", "x.", "x-PP", "?", "0", " 0", "1", "", 
												"Bankruptcy", "check cashing only", "x-cccs", "*", "NNA", "DAD", "MOM", "n/.a", "n/a", "N/A")
							OR c.bank_name REGEXP '^bk-'
							OR c.bank_name REGEXP '^bk'
							OR c.bank_name REGEXP '^check cashing|CHECK CASHING ONLY|ONLY CHECK CASHING|ONLY CASH CHECKS|CHECK CASHER|Cash Checks only|cash checks only|Cash Checks Only'
							OR c.bank_name REGEXP 'Cash Ck Only|cash cks only|Cash Checks|Cash Cecks Only|CK CSH ONLY|ck cashing only|CheckCashing Only|Ck Cash Only|Ck Cashing Only'
							OR c.bank_name REGEXP 'Ck Cshg Only|CK Cash Only|CkCashing Only|Cash  Checks Only|^CC Only$|^CC ONLY$'
							OR c.bank_name REGEXP '^\\*'
							OR c.bank_name REGEXP '^[A-Z][A-Z]$'
							OR c.bank_name REGEXP '^0*0$|0X'
							OR c.bank_name REGEXP '^x*x$'
							OR c.bank_name REGEXP '^X.*X$|^--$|^-$' #had to fix this - it ws finding any name with a '-' and blanking it out. Which is actually exactly what I told it to do. 
							OR c.bank_name REGEXP '^\\?|^zzz$'
							OR c.bank_name REGEXP '^xxx$|^XXX$|^x|^x*x$|^X*X$|^x*x .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^X*X .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
							OR c.bank_name REGEXP '^closed$|^CLOSED$|^CLOSE$|cash cashing'
							OR c.bank_name REGEXP '^No Account$|^No Acct$|^No Authorization$|^non transaction$|^non-transaction$|^not auth$|^NONE`$|nonbe|^n o$|^no$'
							OR c.bank_name REGEXP '^PP'
							OR c.bank_name REGEXP '^bk'
							OR c.bank_name REGEXP '^[A-Z]$|^ [A-Z]$|^0X$|^[0-9]$|^ [0-9]$'
							OR c.bank_name REGEXP 'FRAUD'
							OR c.bank_name REGEXP '^FROZEN$|^frozen$|%frozen account$'
							OR c.bank_name REGEXP '^STOPPED$|^STOP$|^Stop Payment$|^stopped payment$|^StpPymtTCF$'
							OR c.bank_name REGEXP '\\.*closed$'
							OR c.bank_name REGEXP '^Western Union|WESTERN UNION|^NO BANK$'
							OR c.bank_name REGEXP '^[0-9]\/[A-Z]\/[0-9]\/[0-9][0-9]\/[0-9][0-9]$'
							OR c.bank_name REGEXP '^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
							OR c.bank_name REGEXP '^[a-z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9]-[0-9][0-9]-[0-9][0-9]$'
							OR c.bank_name REGEXP '^[A-Z]\/[0-9]-[0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
							OR c.bank_name REGEXP '^[A-Z]-[0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[A-Z]-[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$')
								THEN ''
			
			WHEN 	c.ss_number NOT IN (SELECT ss_number FROM aux_client) AND 
					( 	c.bank_name IN (	"X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXXX", "XXXXXXXX", "XXXXXXXXX", "XXXXXXXXXX", 
										"XXXXXXXXXXX", "XXXXXXXXXXXX", "x", "-x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
										"xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", " x", 
										" xx", " xxx", " XXX", "closed", "CLOSED", "Closed", "na", "NA", " na", " na", " NA", "Na", "nA", 
										"check cashing only", "CHECK CASHING", "CHECK CASHING ONLY", "Check Cashing Only", "CHECK CASH", "cashchecks only",
										"Money Order Only", "Check Cashing Only", "MONEY ORDER AND BILL PAY", "QWEST PAYMENTS", "MONEY ORDERS ONLY","MONEY ORDERS",
										"N/A", "n/a", "N/a", "n/A", "None", "Noine", "NOINE", "NONE", "nada", "Nada", "QWEST ONLY", "Money Gram",
										"c", "00", "000", "0000", "00000", "000000", 
										"0000000", "00000000", "000000000", "none00","NO BANK", "No Bank", "no bank",
										"0000000000", "00000000000", "000000000000", "0000000000000", "00000000000000", "000000000000000", 
										"0000000000000000", "00000000000000000", "x000000000000", "xxxxxxxxxxxxxxxxxxxxxxx" , "x.", "x-", "x-PP", "?", "0",
										" 0", "1", "", 
										"Bankruptcy", "check cashing only", "000", "ANDERSON KEIL", "andersdn & keil", "anderson  & keil", 
										"andersdon & keil", "acct.closed", "closed", "x-cccs", "NNA", "DAD", "MOM", "n/.a", "n/a", "N/A" )
						OR c.bank_name REGEXP '^PP'
						OR c.bank_name REGEXP '^PP'
						OR c.bank_name REGEXP '^x-'
						OR c.bank_name REGEXP '^x '
						OR c.bank_name REGEXP '^xF|^XxF|^Xx |^XxLst|^X O|^\\?what|^zzz$'
						OR c.bank_name REGEXP 'xO'
						OR c.bank_name REGEXP 'X-F'
						OR c.bank_name REGEXP '^x  O-[0-9]'
						OR c.bank_name REGEXP '^x PP-[0-9]'
						OR c.bank_name REGEXP 'PP-[0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP 'x O-[0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x  O-[0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x O-[0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x  O-[0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x O-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x PP-[0-9][0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x PP-[0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x PP-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x-PP-[0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP 'O-[0-9]-[0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP 'x-O[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP 'x-O-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP '^\\*'
						OR c.bank_name REGEXP '^[A-Z][A-Z]$'
						OR c.bank_name REGEXP '^0*0$|0X'
						OR c.bank_name REGEXP '^x*x$'
						OR c.bank_name REGEXP '^X.*X$|^--$|^-$' #had to fix this - it ws finding any name with a '-' and blanking it out. Which is actually exactly what I told it to do. 
						OR c.bank_name REGEXP '^\\?'
						OR c.bank_name REGEXP '^xxx$|^XXX$|^x|^x*x$|^X*X$|^x*x .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^X*X .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^closed$|^CLOSED$|^CLOSE$|cash cashing|^CC Only$|^CC ONLY$'
						OR c.bank_name REGEXP '^No Account$|^No Acct$|^No Authorization$|^non transaction$|^non-transaction$|^not auth$|^NONE`$|nonbe|^n o$|^no$'
						OR c.bank_name REGEXP '^PP'
						OR c.bank_name REGEXP '^bk'
						OR c.bank_name REGEXP '^[A-Z]$|^ [A-Z]$|^0X$|^[0-9]$|^ [0-9]$'
						OR c.bank_name REGEXP 'FRAUD'
						OR c.bank_name REGEXP '^FROZEN$|^frozen$|%frozen account$'
						OR c.bank_name REGEXP '^STOPPED$|^STOP$|^Stop Payment$|^stopped payment$|^StpPymtTCF$'
						OR c.bank_name REGEXP '\\.*closed$'
						OR c.bank_name REGEXP '^Western Union|WESTERN UNION|^NO BANK$'
						OR c.bank_name REGEXP '^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[a-z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9]-[0-9][0-9]-[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]\/[0-9]-[0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[0-9]\/[A-Z]\/[0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]-[0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[A-Z]-[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$') THEN "1111111111"

			WHEN 	c.ss_number IN (SELECT ss_number FROM aux_client) AND 
					( 	c.bank_name IN (	"X", "XX", "XXX", "XXXX", "XXXXX", "XXXXXX", "XXXXXXXX", "XXXXXXXX", "XXXXXXXXX", "XXXXXXXXXX", 
										"XXXXXXXXXXX", "XXXXXXXXXXXX", "x", "-x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
										"xxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", " x", 
										" xx", " xxx", " XXX", "closed", "CLOSED", "Closed", "na", "NA", " na", " na", " NA", "Na", "nA",
										"check cashing only", "CHECK CASHING", "CHECK CASHING ONLY", "Check Cashing Only", "CHECK CASH", "cashchecks only", 
										"N/A", "n/a", "N/a", "n/A", "None", "c", "NO BANK", "No Bank", "no bank", "nada", "Nada",  "QWEST ONLY", "Money Gram",
										"00", "000", "0000", "00000", "000000", "0000000", "00000000", "000000000",
										"0000000000", "00000000000", "000000000000", "0000000000000", "00000000000000", "000000000000000", 
										"0000000000000000", "00000000000000000", "x000000000000", "x.", "x-PP", "?", "0", " 0", "1", "", 
										"Bankruptcy", "check cashing only", "000", "ANDERSON KEIL", "andersdn & keil", "anderson  & keil", 
										"Money Order Only", "Check Cashing Only", "MONEY ORDER AND BILL PAY", "QWEST PAYMENTS", "MONEY ORDERS ONLY", "MONEY ORDERS",
										"andersdon & keil", "acct.closed", "closed", "APOLLO",  "NNA", "DAD", "MOM", "n/.a", "n/a", "N/A" )
						OR c.bank_name REGEXP 'x O-[0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x O-[0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x O-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'x PP-[0-9][0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_name REGEXP 'O-[0-9]-[0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_name REGEXP '^bk'
						OR c.bank_name REGEXP '^\\*'
						OR c.bank_name REGEXP '^[A-Z][A-Z]$'
						OR c.bank_name REGEXP '^0*0$|0X|^zzz$'
						OR c.bank_name REGEXP '^x*x$'
						OR c.bank_name REGEXP '^X.*X$|^--$|^-$' #had to fix this - it ws finding any name with a '-' and blanking it out. Which is actually exactly what I told it to do. 
						OR c.bank_name REGEXP '^\\?'
						OR c.bank_name REGEXP '^xxx$|^XXX$|^x|^x*x$|^X*X$|^x*x .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^X*X .*[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^closed$|^CLOSED$|^CLOSE$|check cashing|Check Cashing|CHECK CASHING|cash cashing|^CC Only$|^CC ONLY$'
						OR c.bank_name REGEXP '^No Account$|^No Acct$|^No Authorization$|^non transaction$|^non-transaction$|^not auth$|^NONE`$|nonbe|^n o$|^no$'
						OR c.bank_name REGEXP '^PP'
						OR c.bank_name REGEXP '^bk'
						OR c.bank_name REGEXP '^[A-Z]$|^ [A-Z]$|^0X$|^[0-9]$|^ [0-9]$'
						OR c.bank_name REGEXP 'FRAUD'
						OR c.bank_name REGEXP '^FROZEN$|^frozen$|%frozen account$'
						OR c.bank_name REGEXP '^STOPPED$|^STOP$|^Stop Payment$|^stopped payment$|^StpPymtTCF$'
						OR c.bank_name REGEXP '\\.*closed$|Had Multiple Accounts|Has Multiple Accounts|MULTIPLE ACCOUNTS|MULTIPLE ACCTS'
						OR c.bank_name REGEXP '^Western Union|WESTERN UNION|^NO BANK$'
						OR c.bank_name REGEXP '^[0-9]\/[A-Z]\/[0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[a-z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$|^[A-Z]\/[0-9]-[0-9][0-9]-[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]\/[0-9]-[0-9]-[0-9][0-9]$|^[A-Z]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[0-9]\/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$'
						OR c.bank_name REGEXP '^[A-Z]-[0-9]\/[0-9][0-9]\/[0-9][0-9]$|^[A-Z]-[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]$') THEN "222222222"

		ELSE trim(a.routing_number)
	END) AS 'ABA Number',

	( ############################### FINDACCT ######################
		CASE	
			WHEN c.bank_account REGEXP '[a-z]' THEN '000'
			WHEN c.bank_account IN (1, 0) OR c.bank_account IS NULL THEN '000'
			WHEN c.bank_account REGEXP '/' THEN '000'
			WHEN c.bank_account IS NOT NULL
				AND (	c.bank_account REGEXP '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_account REGEXP '[0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_account REGEXP '[0-9]-[0-9][0-9]-[0-9][0-9]'
						OR c.bank_account REGEXP '[0-9]-[0-9]-[0-9][0-9]'
						OR c.bank_account REGEXP '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
						OR c.bank_account REGEXP '[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' ) THEN '000'
			WHEN c.bank_account REGEXP '`$' THEN REPLACE(c.bank_account, '`', '')

			ELSE cast(trim(c.bank_account) as CHAR) ### put cast() here? ELSE cast(trim(c.bank_account) as CHAR)
	END) AS 'Account Number', 

	(
		CASE
			WHEN ( c.employer REGEXP 'military' OR c.employer REGEXP 'army' OR c.employer REGEXP 'air force' OR c.employer REGEXP 'navy') THEN "y"
			ELSE "n"
	END) AS 'Military', 

	# c.store AS 'test id',
	

	(
		CASE 
			WHEN (SELECT 1 IS TRUE) THEN concat( "Imported December 20 2019 ||", "\n",	IF	(c.ss_number NOT REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$', "SSN WAS INCORRECT! CHECK PAPERWORK! CHECK OG SSN LISTED BELOW! ", ''),
													IF	(c.status = 0, concat("Loan Star Status = Good ||", "\n") ,  ###### FINDTRUEBOOL ######### ----> MySQL evaluates any integer as true - so this WHEN statement runs automatically
														IF	(c.status = 1, concat("Loan Star Status = Denied ||", "\n") ,
															IF	(c.status = 2, concat("Loan Star Status = Pre-legal ||", "\n") ,
																IF	(c.status = 3, concat("Loan Star Status = Outsourced ||", "\n") ,
																	IF	(c.status = 4, concat("Loan Star Status = Bankruptcy or Dead ||", "\n") , 
																		IF	(c.status = 5, concat("Loan Star Status = In In-House collections ||", "\n") , 
																			IF	(c.status = 6, concat("Loan Star Status = With BBS, ACSI, RMSB, APOLLO, or another collection agency ||", "\n") ,  
																				IF	(c.status = 7, concat("Loan Star Status = in Legal - whatever that means (check notes) ||", "\n") ,  
																					IF	(c.status = 8, concat("Loan Star Status = Purged ||", "\n") ,  
																						IF	(c.status = 9, concat("Loan Star Status = with Anderson ||", "\n") ,
																							IF	(c.status IS NULL, concat("Loan Star Status = ? (was null) check notes ||", "\n"), '')
																							)
																						)	
																					)
																				)
																			)
																		)
																	)
																)
															)
														), ##### second parameter for concat()
																IF	( (c.store = "av" OR c.driver_license IN ("Apple Valley Acct")), concat(" Apple Valley account ||", "\n"),
																	IF	( (c.store = "BIL" OR c.driver_license IN ("Billings Acct")), concat(" Bilings account ||", "\n"), 
																		IF	( (c.store = "BUT" OR c.driver_license IN ("Butte Office")), concat(" Butte account ||", "\n"),
																			IF	( (c.store = "DEN" OR c.driver_license IN ("Denver Acct")), concat(" old Denver - before South Denver - account ||", "\n"),
																				IF	( (c.store = "FedH" OR c.driver_license IN ("Fed Heights Acct")), concat(" Federal Heights account ||", "\n"),
																					IF	( (c.store = "FH" OR c.driver_license IN ("Fed Heights Acct")), concat(" Federal Heights account ||", "\n"),
																						IF	( (c.store = "GF" OR c.driver_license IN ("Great Falls Acct")), concat(" Great Falls account ||", "\n"),
																							IF	( (c.store = "IDF" OR c.driver_license IN ("IdahoFalls Acct")), concat(" Idaho Falls account ||", "\n"),
																								IF	( (c.store = "LOV" OR c.driver_license IN ("Loveland Acct")), concat(" Loveland account ||", "\n"), 
																									IF	( (c.store = "MIS" OR c.driver_license IN ("Missoula Acct")), concat(" Missoula account ||", "\n"),
																										IF	( (c.store = "POC" OR c.driver_license IN ("Pocatello Acct")), concat( " Pocatello account ||", "\n"),
																											IF	(c.store = "AUR" , concat(" Aurora account ||", "\n"),
																												IF	(c.store = "ARV", concat( " Arvada account ||",  "\n"),
																													IF	(c.store = "CAS", concat( " Casper account ||", "\n"),
																														IF	(c.store IN ("CHY", "CHY2"), concat(" Cheyenne account ||", "\n"),
																															IF	(c.store = "FC", concat(" Fort Collins account ||", "\n"), 
																																IF	(c.store = "GIL", concat(" Gillette account ||", "\n"),
																																	IF	(c.store = "GJ", concat(" Grand Junction account ||",  "\n"),
																																		IF	(c.store = "GLY", concat(" Greeley account ||", "\n"),
																																			IF	(c.store = "LAR", concat(" Laramie account ||", "\n"),
																																				IF	(c.store = "PBL", concat(" Pueblo account ||", "\n"),
																																					IF	(c.store = "RS", concat(" Rock Springs account ||", "\n"),
																																						IF	(c.store = "SD", concat(" South Denver account ||", "\n"),
																																							IF	(c.store = "THN", concat(" Thornton account ||", "\n"),
																																								IF	( c.store IS NULL OR c.store =  " ", concat( " NULL - check client city ||", "\n"), '')
																																								)
																																							)
																																						)
																																					)
																																				)
																																			)
																																		)
																																	)
																																)
																															)
																														)
																													)
																												)
																											)
																										)
																									)
																								)
																							)
																						)
																					)
																				)
																			)
																		)
																	), 	"OG DOB = ", 
																			IF( (a.dob IS NULL OR a.dob = '' OR a.dob REGEXP '[a-z]'), 'NULL', a.dob) ,
																		" || OG HP = ", 
																			IF( (c.home_phone IS NULL OR c.home_phone = '' OR c.home_phone REGEXP '[a-z]'), 'NULL', c.home_phone), 
																		" || OG CP = ", 
																			IF( (c.ss_number NOT IN (SELECT ss_number FROM aux_client) OR a.cell_phone IS NULL OR a.cell_phone = ''), 'NULL', a.cell_phone), 
																		" || OG WP = ", # "\n", ### deleted the new line in case that is what is causing the import problems
																			IF(	(c.work_phone IS NULL OR c.work_phone = '' OR c.work_phone REGEXP '[a-z]'), 'NULL', c.work_phone),
																		" || OG SSN = ", 
																			IF( (c.ss_number NOT REGEXP '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]$'), concat(" OG SSN was incorrect.", "\n", "it was changed only to complete the import, nonetheless, here it is: ", c.ss_number), c.ss_number),
																		" || Account notes (NOT Collections) follow: ",
						#### current job - given up as of 12/8/19
						#### trying to add the count of transactions ------------>	# IF(	(c.ss_number IN (SELECT ss_number FROM transactions)), ''),
																			# attepmt 4 :::::: (SELECT @var1 IN ( SELECT count(*) FROM transactions t JOIN client c on t.ss_number = c.ss_number GROUP BY c.ss_number)), ''),
																			# attempt 3 :::::: ( SELECT count(*) FROM transactions t WHERE t.ss_number = @var1), ''), 
																			# attempt 2 :::::: (SELECT count(*) as count FROM transactions GROUP BY ss_number), 'NULL') ,
																			# attempt 1 :::::: t1 LEFT JOIN (SELECT ss_number as ssn, count(*) as count FROM transactions t2 GROUP BY ss_number) pull ON pull.ssn = t1.ss_number AND pull.count = count GROUP BY pull.ssn, count ), ''), 
																			IF	(our_notes.note IS NULL OR our_notes.note = " " OR our_notes.note NOT REGEXP '[a-z]|\/|-', "empty notes - this note added for FINAL import", 
																				IF 	(our_notes.note IS NOT NULL OR our_notes.note REGEXP '\n|\r', 	TRIM(trailing '\n' from
																																						TRIM(trailing '\r' from 
																																							TRIM(trailing ' ' from REPLACE(
																																														REPLACE(
																																															REPLACE(
																																																REPLACE(our_notes.note, '"','') 
																																																	, ';', '')										
																																																, ',', '')
																																															, "'", '')
																																								)
																																							)
																																						)
																																									
																																																									, our_notes.note) 
																				) 
																			)# this is the last part of the concatination, and the final ')'
		END) as 'Note                                                                                                                        ', # the extra space is, well, extra space. Because I'm too lazy to pull the damn spacer over to the right. What is this? A third-world country? Resize it FOR me, dammit!


	0 as 'Credit Limit'
																																	
			
	

FROM
	client c
    LEFT JOIN aux_client a ON c.ss_number = a.ss_number 	### left join makes sure that no accounts are left in the dust. JOIN (right join) only returns accounts that are in BOTH databases
	LEFT JOIN 
		(SELECT note, ss_number, id FROM notes GROUP BY ss_number) AS our_notes ON our_notes.ss_number = c.ss_number #this actually doesn't need to contain a subquery, I don't think, but it seems to be doing the trick
																					# when I simply left-join'ed the Notes table using the ss_number, then I had unwittingly added to to the total
																					#-----> aggregate returned rows. The amount returned is 2216, as it should be with a Loveland Acct DL in the WHERE clause 12/16/2019

#WHERE 
#	c.lastname = "WALCK"	
#	OR c.driver_license = "Loveland Acct"
#	OR c.driver_license = "Fed Heights Acct"
#		AND c.lastname = "Taylor"
#		AND right( c.ss_number, 4) LIKE '%4576%'

LIMIT 40000;