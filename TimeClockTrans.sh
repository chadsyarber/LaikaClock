#!/bin/bash
#Time Clock Translation from C into bash
#Originally written in C this is an exercise in translation.
#This currently uses simple text files for reading and storage
#It can easily be changed to a database
#Written by: Chad Yarber
until [ "$LoopEnd" = "1" ]; do
	#date for writing to file
	Date_Time=$(date +%D,%R)
	#Var to hold date to check if clocked in already
	Date_only=$(date +%D)
	EmpNum=
	In_Out=
	Tips=
	Passcode=
	EmpNumMGR=
	LoopEnd=
	echo "Enter your Employee Number"
	read EmpNum
	#get the number of characters from the user
	NumCheck=$(echo "${EmpNum}" | wc -m)
	#verify a valid number of characters, this can be set to any value
	if [ "$NumCheck" != "5" ]; then
		echo "Invalid Number"
	else
		#check the number against the stored values to determine validity
		EmpScan=$(grep -o "$EmpNum" EmpNum.txt)
		if [ -z "$EmpScan"  ]; then
			echo "Invalid Number!"
		else
			#This can be set to any range of values that the Admin does not want to use
			if [ "$EmpScan" -lt "999" ]; then
				echo "Incorrect Entry!"
			#The range chosen for this script for normal hourly employees was 1000-1999
			#If we have a valid number and it is within this range then we will ask to clock in or out
			elif [ "$EmpScan" -gt "1000" ] && [ "$EmpScan" -lt "1999" ]; then
				until [ "$In_Out" = "1" ] || [ "$In_Out" = "2" ]; do
					echo "Press 1 to clock in and 2 to clock out"
					read In_Out
					#Determine if the user is clocked in or not
					case $In_Out in
						1 ) CheckIn=$(grep -o "In,$EmpNum,$Date_only" TimeSheet.txt)
							if [ -n "$CheckIn" ]; then
								echo "Already clocked In"
							else
								echo "In,${EmpNum},${Date_Time}"$'\r' >> TimeSheet.txt
								echo "Thank You"
							fi;;
					#Determine if the user if clocked out or not
						2 ) CheckIn=$(grep -o "Out,$EmpNum,$Date_only" TimeSheet.txt)
							if [ -n "$CheckIn" ]; then
								echo "Already clocked Out"
							else
								echo "Out,${EmpNum},${Date_Time}"$'\r' >> TimeSheet.txt
								echo "Have a Nice Day!"
							fi;;
						* ) echo "Press 1 or 2";;
					esac
				done
			#This range assumed Tipped employees 2000-2999
			#If a valid tipped employee we will ask for the total amount of tips for the shift on clock out
			elif [ "$EmpScan" -gt "2000" ] && [ "$EmpScan" -lt "2999" ]; then
				until [ "$In_Out" = "1" ] || [ "$In_Out" = "2" ]; do
					echo "Press 1 to clock in and 2 to clock out"
					read In_Out
					case $In_Out in
						1 ) CheckIn=$(grep -o "In,$EmpNum,$Date_only" TimeSheet.txt)
							if [ -n "$CheckIn" ]; then
								echo "Already clocked In"
							else
								echo "In,${EmpNum},${Date_Time}"$'\r' >> TimeSheet.txt
								echo "Thank You"
							fi;;
						2 ) CheckIn=$(grep -o "Out,$EmpNum,$Date_only" TimeSheet.txt)
							if [ -n "$CheckIn" ]; then
								echo "Already clocked Out"
							else
								echo "Enter your Tips as Ex, 25.00"
								read Tips
								echo "Out,${EmpNum},${Date_Time},${Tips}"$'\r' >> TimeSheet.txt
								echo "Have a Nice Day!"
							fi;;
						* ) echo "Press 1 or 2";;
					esac
				done
			#3000 was resereved for admin privledges protected by a password. 
			#For the purposes of this exercise I used plain text
			elif [ "$EmpScan" -gt "3000" ]; then
				echo "Enter Passcode"
				read Passcode
				CheckCode=$(grep -o "$Passcode" Passcode.txt)
				#Check for a valid code. If successful then begin the editing process
				if [ -n "$CheckCode" ]; then
					echo "Which employee did you want to change?"
					read EmpNumMGR
					#gets all the records for the employee number
					ShowAllEmpNum=$(grep "$EmpNumMGR" TimeSheet.txt)
					echo "${ShowAllEmpNum}"
					#allow the admin to enter all of the changes needed for the employee
					until [ "$MGRIO" = "1" ] || [ "$MGRIO" = "2" ]; do
						echo "Enter 1 for time In and 2 for time Out"
						MGRIO=
						read MGRIO
						if [ "$MGRIO" = "1" ]; then
							MGRIn_Out="In"
						elif [ "$MGRIO" = "2" ]; then
							MGRIn_Out="Out"
						else
							echo "Please press 1 or 2"
						fi
					done
					echo "Enter the Date as mm/dd/yy"
					MGRDate=
					read MGRDate
					echo "Enter the Time using 24 hour clock"
					MGRTime=
					read MGRTime
					echo "Enter the Tips (if any) as Ex, 25.00"
					MGRTips=
					read MGRTips
					echo "Writing input to Manager File, Please update records"
					#output the changes to the manager override file. Futher scripting could be written to update the TimeSheet file
					echo "${MGRIn_Out},${EmpNumMGR},${MGRDate},${MGRTime},${MGRTips},${EmpNum}"$'\r' >> MgrOver.txt
				else
					echo "Incorrect Entry!"
				fi
			fi
		fi
	fi
	echo "Press 1 to sign out"
	read LoopEnd
done
