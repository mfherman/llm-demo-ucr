# Data source

**The table name is `ca_data`. This is the only table you have access to. In you SQL queries, only use `ca_data` in the FROM clause.**

The data comes from the FBI's Uniform Crime Reporting Program. Specifically, this file contains annual aggregate counts of reported crime by law enforcement agency. The source dataset is called "Offenses Known and Clearances by Arrest" and is released annualy by the FBI. The version we are using here is made available by Jacob Kaplan, a crime researcher, who has cleaned up the FBI version of the data. It can be downloaded here: <https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/OESSD1>. For more information about this dataset, users can view Chapter 3 of Jacob Kaplan's book, Decoding FBI Crime Data
, which is all about UCR crime data: <https://ucrbook.com/offensesKnown.html>.

The FBI’s Uniform Crime Reporting (UCR) Program collects the number of offenses that come to the attention of law enforcement for violent crime and property crime, as well as data regarding clearances of these offenses.

## Violent Crime

Violent crime is composed of four offenses: murder and nonnegligent manslaughter, rape, robbery, and aggravated assault. Violent crimes are defined in the UCR Program as those offenses that involve force or threat of force.

## Property Crime

Property crime includes the offenses of burglary, larceny-theft, motor vehicle theft, and arson. The object of the theft-type offenses is the taking of money or property, but there is no force or threat of force against the victims.

## Clearances

Within the UCR Program, law enforcement agencies can solve, clear, or “close,” offenses in one of two ways: by arrest or by exceptional means. Although agencies may administratively close a case, this does not necessarily mean that the agency can clear the offense for UCR purposes.

For this application, we've inlcuded only data from 2010 to 2023 for law enforcement agencies in California that have reported data to the FBI for every month in a given year. Agencies that did not report for all 12 months are excluded.

## Column descriptions

- year: Year crime was reported to law enforcement agency
- agency_name: Name of law enforcement agency
- agency_type: Type of law enforcement agency
- pop_group: Size of agency jurisidiction based on popluation
- pop_jurisdiction: Number of people living in the jurisdiction of the agency. See note below for more information about jurisidictions.
- offense: Offense of reported crime. See note below for more information about offenses
- n_reported: Number of crimes reported
- reported_per100k: Number of crimes reported per 100,000 residents
- n_solved: Number of crimes solved/cleared by arrest or exceptional means
- n_unsolved: Number of crimes not solved/cleared by arrest or exceptional means
- solve_rate: Rate or percentage of crimes reported that were solved/cleared

## Offense descriptions

The only offenses that are included in this dataset are known as "Part I offenses." These are considered the most serious crimes and have been tracked the longest by the FBI, but it does not include all crimes for which people are arrested. It is also important to note that many crimes are not reported to police. So this only includes a subset of all criminal activity.

Criminal homicide―a.) Murder and nonnegligent manslaughter: the willful (nonnegligent) killing of one human being by another. Deaths caused by negligence, attempts to kill, assaults to kill, suicides, and accidental deaths are excluded. The program classifies justifiable homicides separately and limits the definition to: (1) the killing of a felon by a law enforcement officer in the line of duty; or (2) the killing of a felon, during the commission of a felony, by a private citizen. b.) Manslaughter by negligence: the killing of another person through gross negligence. Deaths of persons due to their own negligence, accidental deaths not resulting from gross negligence, and traffic fatalities are not included in the category manslaughter by negligence.

Rape―The penetration, no matter how slight, of the vagina or anus with any body part or object, or oral penetration by a sex organ of another person, without the consent of the victim.

Robbery―The taking or attempting to take anything of value from the care, custody, or control of a person or persons by force or threat of force or violence and/or by putting the victim in fear.

Aggravated assault―An unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault usually is accompanied by the use of a weapon or by means likely to produce death or great bodily harm. Simple assaults are excluded.

Burglary (breaking or entering)―The unlawful entry of a structure to commit a felony or a theft. Attempted forcible entry is included.

Larceny-theft (except motor vehicle theft)―The unlawful taking, carrying, leading, or riding away of property from the possession or constructive possession of another. Examples are thefts of bicycles, motor vehicle parts and accessories, shoplifting, pocket-picking, or the stealing of any property or article that is not taken by force and violence or by fraud. Attempted larcenies are included. Embezzlement, confidence games, forgery, check fraud, etc., are excluded.

Motor vehicle theft―The theft or attempted theft of a motor vehicle. A motor vehicle is self-propelled and runs on land surface and not on rails. Motorboats, construction equipment, airplanes, and farming equipment are specifically excluded from this category.

## Population

Each of the SRS data sets include a population variable that has the estimated population under the jurisdiction of that agency. This variable is often used to create crime rates that control for population. In cases where jurisdiction overlaps, such as when a city has university police agencies or county sheriffs in counties where the cities in that county have their own police, SRS data assigns the population covered to the most local agency and zero population to the overlapping agency. So an agency’s population is the number of people in that jurisdiction that is not already covered by a different agency.

For example, the city of Los Angeles in California has nearly four million residents according to the US Census. There are multiple police agencies in the city, including the Los Angeles Police Department, the Los Angeles County Sheriff’s Office, the California Highway Patrol that operates in the area, airport and port police, and university police departments. If each agency reported the number of people in their jurisdiction - which all overlap with each other - we would end up with a population far higher than LA’s four million people. To prevent double-counting population when agency’s jurisdictions overlap, the non-primary agency will report a population of 0, even though they still report crime data like normal. As an example, in 2018 the police department for California State University - Los Angeles reported 92 thefts and a population of 0. Those 92 thefts are not counted in the Los Angeles Police Department data, even though the department counts the population. To get complete crime counts in Los Angeles, you would need to add up all police agencies within in the city; since the population value is 0 for non-LAPD agencies, both the population and the crime sum will be correct.

The SRS uses this method even when only parts of a jurisdiction overlaps. Los Angeles County Sheriff has a population of about one million people, far less than the actual county population (the number of residents, according to the Census) of about 10 million people. This is because the other nine million people are accounted for by other agencies, mainly the local police agencies in the cities that make up Los Angeles County.

The population value is the population who reside in that jurisdiction and does not count people who are in the area but do not live there, such as tourists or people who commute there for work. This means that using the population value to determine a rate can be misleading as some places have much higher numbers of non-residents in the area (e.g. Las Vegas, Washington D.C.) than others.
