#!/usr/bin/env bash
# notes: system requires dos2unix to be installed
# source txt file will have new line characters from windows
# and that will break things real good


echo
echo "              .__        __             "
echo " _____________|__| _____/  |_ ___.__.   "
echo " \____ \_  __ \  |/    \   __<   |  |   "
echo " |  |_> >  | \/  |   |  \  |  \___  |   "
echo " |   __/|__|  |__|___|  /__|  / ____|   "
echo " |__|                 \/      \/        "
echo "      Nathan's PR1N7Y th3 pr1n7 b07 SCR1P7  "
echo

###################################################
#######    Defining the file to work on   #########
###################################################

# 'read' will read in what the user inputs | the '-p' flag will prompt | it saves the input into a variable called job_number
read -p "  Please enter the Job Number: " job_number
# the extension of the file exported from itms is '.txt'
extension=".txt"
# we add both variables together to make the fileName variable
fileName=$job_number$extension

# This is a test to see if the .txt file actaully exists before we continue
if [[ ! -f $fileName ]]; then
  echo
  echo "What?!?!"
  echo "I cannot find the Job Number you entered..."
  echo "Did you export it from iTMS?"
  echo
  sleep 1
  exit 0
fi

echo

###############################################
# Defining the Original Start point for the program
ORIGINAL_FOLDER="/mnt/Network-Drives/T-Drive/iTMS-Job-Card-Scraper"

###############################################
# Defining the 7000 TUBE PDF folder
ROTO_PDF_FOLDER="/mnt/Network-Drives/T-Drive/7000 TUBE PDF/"

###############################################
# Defining the 7000 TUBE lst folder
ROTO_LST_FOLDER="/mnt/Network-Drives/T-Drive/7000 ROTO LST"
ROTO_LST_READY_TO_NEST="/mnt/Network-Drives/T-Drive/7000 ROTO LST/7000 TUBE JOBS READY TO NEST"

###############################################
# Defining where the customer drawings are
ABSOLUTE_PACE="/mnt/Network-Drives/U-Drive/ABSOLUTEPACE"
BUSTECH="/mnt/Network-Drives/U-Drive/BUSTECH/PDF"
BRYAN_BODIES="/mnt/Network-Drives/U-Drive/BRYANINDUSTRIES"
CONDAMINE_CAMPERS="/mnt/Network-Drives/U-Drive/CONDAMINECAMPERS"
CEDAR_CREEK="/mnt/Network-Drives/U-Drive/CEDARCREEKCOMPANY"
DAVCO="/mnt/Network-Drives/U-Drive/DAVCO"
EKEBOL="/mnt/Network-Drives/U-Drive/EKEBOL"
EXPRESS_COACH_BUILDERS="/mnt/Network-Drives/U-Drive/EXPRESSCOACHES/ALL OFFICIAL PARTS DRAWINGS"
GEMCUTS="/mnt/Network-Drives/U-Drive/GEMCUTS"
HOLMWOOD="/mnt/Network-Drives/U-Drive/HOLMWOOD"
JJ_RICHARDS="/mnt/Network-Drives/U-Drive/JJRICHARDSENG"
KIMBERLEY="/mnt/Network-Drives/U-Drive/KIMBERLYKAMPERS"
LIFESTYLE="/mnt/Network-Drives/U-Drive/LIFESTYLE"
LIQUIP="/mnt/Network-Drives/U-Drive/LIQUIP"
MONSTER="/mnt/Network-Drives/U-Drive/MONSTER"
OFFROAD_RUSH="/mnt/Network-Drives/U-Drive/OFFROADRUSH"
PACEINNOVATION="/mnt/Network-Drives/U-Drive/PACEINNOVATION"
PROACTIVE_MAINTENANCE='/mnt/Network-Drives/U-Drive/PROACTIVE'
PROJECT_MODULAR='/mnt/Network-Drives/U-Drive/PROJECTMODULAR'
PTAUTOMATIONSOLUTIONS='/mnt/Network-Drives/U-Drive/PTAUTOMATION'
RIPTIDE="/mnt/Network-Drives/U-Drive/RIPTIDE"
SEVA="/mnt/Network-Drives/U-Drive/SEVA"
SPEEDSAFE="/mnt/Network-Drives/U-Drive/SPEEDSAFE"
STEELROD="/mnt/Network-Drives/U-Drive/STEELROD"
SUN_ENGINEERING="/mnt/Network-Drives/U-Drive/SUNENG"
TEST_CLIENT="/mnt/Network-Drives/U-Drive/TEST CLIENT"
TRITIUM="/mnt/Network-Drives/U-Drive/TRITIUM/PDFs CURRENT"
VARLEY_BNE="/mnt/Network-Drives/U-Drive/VARLEYBNE"
VARLEY_TOMAGO="/mnt/Network-Drives/U-Drive/VARLEYTGO"
WEBER="/mnt/Network-Drives/U-Drive/WEBERSOUTHPACIFIC"

###############################################
# Defining the coloured console text, used for 'echo' commands
# to use these colours you will need the command 'echo -e'
BLACK_WITH_GREEN="\e[30m\e[42m"
RED_WITH_WHITE="\e[41m"
DEFAULT="\e[39m\e[49m"  # you always have to use the default at the end of your echo

###############################################
# Defining where the customer GEO's are
BUSTECH_GEOS="/mnt/Network-Drives/U-Drive/BUSTECH/ITMS DXF"
LAI_SWITCHBAORDS_GEOS="/mnt/Network-Drives/U-Drive/LAISWITCHBOARDS/ITMS DXF"

###############################################
# Defining where to copy the GEO's that are ready to nest
GEO_READY_TO_NEST="/mnt/Network-Drives/U-Drive/Jobs-Ready-To-Nest"

###############################################
# dos2unix has to be the first command to execute before the script can start working on $fileName
# removes all windows new line format so linux can work on it, -q = quiet mode

dos2unix -q "$fileName"

###############################################################################################
# Getting the customer name, this assumes that the customer name is on line 2 of the txt file
# SEVA breaks the whole Customer Name on line 2 thing
if [[ $(sed -n '2p' "$fileName") == "SEVA - SPECIALISED & EMERGENCY VEHICLES" ]]; then
  customerName="SEVA"
else
  customerName=$(sed -n '2p' "$fileName")
fi

###############################################################################################
PRINT_CUSTOMER_PDFS="FALSE"
PRINT_ROTO_PROGRAMS="FALSE"
PRINT_CUSTOMER_PDFS_AND_ROTO_PROGRAMS="FALSE"
TEST_MODE="FALSE"
GRAB_ROTO_LSTs="FALSE"
GRAB_GEOS="FALSE"
CREATE_LABELS="FALSE"
CREATE_MATERIAL_ARRAY="FALSE"

echo "  ╔═══════════════════════════════════════════════════════════════════════╗"
echo "  ║     1) Print the Customers PDF's                                      ║"
echo "  ║     2) Print the existing ROTO PDF's                                  ║"
echo "  ║     3) Grab all the ROTO LST's                                        ║"
echo "  ║     4) Test Mode                                                      ║"
echo "  ║     5) Print DWG and ROTO pdf at once...                              ║"
echo "  ║         >> (BUSTECH, EXPRESS, JJ RICHARDS and PROJECT MODULAR ONLY!)  ║"
echo "  ╚═══════════════════════════════════════════════════════════════════════╝"
echo

###############################################################################################
# testing if there are roto parts in the jobN
roto_count=$(cat $fileName | grep ROTO | wc -l)
if [[ $roto_count > 0 ]]; then
  echo
  echo -e $BLACK_WITH_GREEN"I'VE FOUND SOME ROTO PARTS IN THIS JOB"$DEFAULT
  echo -e $BLACK_WITH_GREEN"YOU SHOULD USE OPTION 5 BRO!"$DEFAULT
  echo
fi

read -p "   Please enter an option Number: " OPTION

if [[ $OPTION == "1" ]]; then
  echo "Print the customers PDF's selected!"
  PRINT_CUSTOMER_PDFS="TRUE"
  sleep 1
elif [[ $OPTION == "2" ]]; then
  echo "Print the existing ROTO PDF's selected!"
  PRINT_ROTO_PROGRAMS="TRUE"
  CREATE_MATERIAL_ARRAY="TRUE"
  sleep 1
elif [[ $OPTION == "3" ]]; then
  echo "Grab all the ROTO LST's selected!"
  GRAB_ROTO_LSTs="TRUE"
  CREATE_MATERIAL_ARRAY="TRUE"
  sleep 1
elif [[ $OPTION == "4" ]]; then
  echo "Test Mode selected!"
  TEST_MODE="TRUE"
  CREATE_MATERIAL_ARRAY="TRUE"
  sleep 1
elif [[ $OPTION == "5" ]]; then
  echo "Print DWG and ROTO at once selected!"
  PRINT_CUSTOMER_PDFS_AND_ROTO_PROGRAMS="TRUE"
  CREATE_MATERIAL_ARRAY="TRUE"
  sleep 1
else
  echo "That is not an option!"
  sleep 1
  exit
fi

############################################################################################
echo "The customer name is:" $customerName

# getting the job, this assumes that the job number is on line 3 of the txt file
# Seva breaks this again, it will move to line 4
if [[ $customerName == "SEVA" ]]; then
  jobNumber=$(sed -n '4p' "$fileName")
else
  jobNumber=$(sed -n '3p' "$fileName")
fi

jobNumber=${jobNumber%%-*}
jobNumber=${jobNumber#\*}

echo "The Job number is:" $jobNumber

# looking for the line number of each job ticket
# grep is searching for each line number that contains
# the pattern starting with "*" and ending with "-", and number from 0 to 9 then another "*"
ticketLineNumber=($(grep -rne "^\*.*-[0-9]*\*" "$fileName"))

echo "Number of job tickets for this job is:" ${#ticketLineNumber[@]}

arrayLength=${#ticketLineNumber[@]}
echo "The new variable \"arrayLength\" has been assigned the value of:" $arrayLength

echo

jobTickLineNumber=()
for (( i=0; i<${arrayLength}; i++ ));
do
  tempValue=${ticketLineNumber[$i]}
  jobTickLineNumber+=(${tempValue%:*})
  ticketNumberArray+=($(( $i + 1 )))
done


###############################################################################################
# EXPRESS COACH BUILDERS, has some bad client part number entries in itms
# if the below is not removed from the .txt file before processing it, it breaks a few things in bash

  if [[ $customerName == "EXPRESS COACH BUILDERS" ]]; then
      echo "Since the customer is 'EXPRESS COACH BUILDERS', I'll have to remove '[SPACE]***'"
      echo "from all the Client Part Code fields in this job, otherwise shit breaks real good..."
      sed -i 's/\s\*\*\*//g' "$fileName"
      echo "'[SPACE]***' has been removed from this job"
  fi
##############################################################################################


##################################################################
############  Creating the Client Part Number Array  #############
##################################################################

clientPartNumber=()
for (( i=0; i<${arrayLength}; i++ ));
do
    # new customer SUN ENGINEERING, they have been entered into iTMS a bit weird
    # instead of using the client part number field, the only reference to the part number
    # is in the 'Part Description' field. The very first string of text is the client part number
    # the rest of the text is cut away
    if [[ $customerName == "SUN ENGINEERING" ]]; then

        tempTicketNumber=${jobTickLineNumber[$i]}
        # the part description is 4 lines down from the jobTickLineNumber variable
        # this might have to change, depending if they are not multi line descriptions
        partDescription=$(($tempTicketNumber + 4))

        clientPartNumber+=($(sed -n "$partDescription p" "$fileName" | cut -f1 -d" "))

    else
        # multi line Part Desciptions break where it looks for the Client Part Code
        # to fix this, test if "Issue Date" is on a certain line
        # if it's not a multi line part description, "Issue Date" should be (+5 lines) from $jobTickLineNumber
        tempTicketNumber=${jobTickLineNumber[$i]}
        issueDate=$(($tempTicketNumber + 5))
        ticketNumber=$(( $i + 1 ))

        sed -n "$issueDate p" "$fileName" | grep "Issue Date" -q
        if [[ $? == '1' ]]; then
          oneLineAhead=$issueDate
          counter=0

          sed -n "$issueDate p" "$fileName" | grep "Issue Date" -q
          while [[ $? == '1' ]]
          do
            ((oneLineAhead++))
            ((counter++))
            sed -n "$oneLineAhead p" "$fileName" | grep "Issue Date" -q
          done
          # echo "Job ticket line number =" $tempTicketNumber
          tempValue=$(( $oneLineAhead - 2 ))
          # echo "line number with the client part code is =" $tempValue
          # sed -n "$tempValue p" "$fileName" | cut -f 2
          clientPartNumber+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
        else
          # if Issue Date is on the right line it will act normally
          tempTicketNumber=${jobTickLineNumber[$i]}
          # echo "Job ticket line number =" $tempTicketNumber
          tempValue=$(( $issueDate - 1 ))
          # echo "line number with the client part code is =" $tempValue
          # sed -n "$tempValue p" "$fileName" | cut -f 2
          clientPartNumber+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
        fi
        echo "Loop number" $i
    fi

done


###########################################################################
#########  Creating the GCI Part Number, Revision and Qty Array  ##########
###########################################################################

# the GCI part number and revision are on the same line
# combining them into the same for loop
gciPartNumber=()
revisionArray=()
qtyArray=()
for (( i=0; i<${arrayLength}; i++ ));
do
    tempTicketNumber=${jobTickLineNumber[$i]}
    # 'Issue Date' should be 5 lines down from $tempTicketNumber
    issueDate=$(( $tempTicketNumber + 5 ))

    # testing if 'Issue Date' is 5 lines down from $jobTickLineNumber
    sed -n "$issueDate p" "$fileName" | grep "Issue Date" -q
    if [[ $? == '1' ]]; then
        echo "'Issue Date' was not on the expected line, going to search the next line..."
        oneLineAhead=$issueDate

        sed -n "$issueDate p" "$fileName" | grep "Issue Date" -q
        while [[ $? == '1' ]]; do
            ((oneLineAhead++))
            echo "Jumping to line" $oneLineAhead "to look for 'Issue Date'"
            sed -n "$oneLineAhead p" "$fileName" | grep "Issue Date" -q
        done

        echo "Success! found 'Issue Date' on line" $oneLineAhead
        echo "Now to check if 'Order Qty' is 2 lines down..."

        orderQty=$(( $oneLineAhead + 2 ))

        sed -n "$orderQty p" "$fileName" | grep "Order Qty" -q
        # if 'Order Qty' is not two lines down from 'Issue Date' the gciPartNumber will not be on the right line
        # this is usually caused by a multi-line purchase order entry
        if [[ $? == '1' ]]; then
            echo "'Order Qty' was not on the expected line... Stupid thing!"
            oneLineAhead=$orderQty

            sed -n "$orderQty p" "$fileName" | grep "Order Qty" -q
            while [[ $? == '1' ]]; do
                ((oneLineAhead++))
                echo "Jumping to line" $oneLineAhead "to look for 'Order Qty'"
                sed -n "$oneLineAhead p" "$fileName" | grep "Order Qty" -q
            done

            echo "Success! found 'Order Qty' on line" $oneLineAhead
            echo "Since 'Order Qty' was not two lines down from 'Issue Date' I have to approach this differently..."
            # Usually if 'Order Qty' is not two lines down form 'Issue Date' the gciPartNumber and Revision is two lines up from 'Order Qty'
            tempValue=$(( $oneLineAhead - 2 ))
            # removing forward slashes from the part number if there are any
            temp_gci_part_number=$(sed -n "$tempValue p" "$fileName" | cut -f 1)
            temp_gci_part_number=$(echo ${temp_gci_part_number////-})
            # adding the part number to the array
            gciPartNumber+=($temp_gci_part_number)
            # gciPartNumber+=($(sed -n "$tempValue p" "$fileName" | cut -f 1))

            # testing the number of tabs on the current line number, OFFR was pulling in the GCI part code for the rev
            # testing if the line in the txt file is greater than one to see if this stops this behaviour
            string=$(sed -n "$tempValue p" "$fileName")
            number_of_tabs=$(echo "$string" | awk '{print gsub(/\t/,"")}')
            number_of_tabs=$(($number_of_tabs + 1))
            if [[ $number_of_tabs -gt 1 ]]; then  # if number of tabs is greater than 1
              temp_revision=$(sed -n "$tempValue p" "$fileName" | cut -f 2)
              echo "Adding $temp_revision to the revision array"
              revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
            else
              echo "adding a blank entry into the revision array"
              revisionArray+=("")
            fi

            manufactureQtyLine=$(( $oneLineAhead + 1 ))
            qtyArray+=($(sed -n "$manufactureQtyLine p" "$fileName" | cut -f 5))

        else
            echo "'Order Qty' was on the expected line, we can continue as normal"
            tempValue=$(( $orderQty - 1 ))
            gciPartNumber+=($(sed -n "$tempValue p" "$fileName" | cut -f 4))
            revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 5)")
            manufactureQtyLine=$(( $orderQty + 1 ))
            qtyArray+=($(sed -n "$manufactureQtyLine p" "$fileName" | cut -f 5))
        fi
    else
        echo "Sweet! 'Issue Date was on the expected line'"
        echo "Now to check if 'Order Qty' is 2 lines down..."

        orderQty=$(( $issueDate + 2 ))

        sed -n "$orderQty p" "$fileName" | grep "Order Qty" -q
        # if 'Order Qty' is not two lines down from 'Issue Date' the gciPartNumber will not be on the right line
        # this is usually caused by a multi-line purchase order entry
        if [[ $? == '1' ]]; then
            echo "'Order Qty' was not on the expected line... Stupid thing!"
            oneLineAhead=$orderQty

            sed -n "$orderQty p" "$fileName" | grep "Order Qty" -q
            while [[ $? == '1' ]]; do
                ((oneLineAhead++))
                echo "Jumping to line" $oneLineAhead "to look for 'Order Qty'"
                sed -n "$oneLineAhead p" "$fileName" | grep "Order Qty" -q
            done

            echo "Success! found 'Order Qty' on line" $oneLineAhead
            echo "Since 'Order Qty' was not two lines down from 'Issue Date' I have to approach this differently..."
            # Usually if 'Order Qty' is not two lines down form 'Issue Date' the gciPartNumber and Revision is two lines up from 'Order Qty'
            tempValue=$(( $oneLineAhead - 2 ))
            gciPartNumber+=($(sed -n "$tempValue p" "$fileName" | cut -f 1))

            ## testing the number of tabs on the current line, PROJECT MODULAR and others were pulling in the part number as the revision
            ## this test should stop this behaviour, will see how it goes.
            string=$(sed -n "$tempValue p" "$fileName")
            number_of_tabs=$(echo "$string" | awk '{print gsub(/\t/,"")}')
            number_of_tabs=$(($number_of_tabs + 1))
            if [[ $number_of_tabs -gt 1 ]]; then # if number of tabs is greater than 1
              temp_revision=$(sed -n "$tempValue p" "$fileName" | cut -f 2)
              echo "Adding $temp_revision to the revision array"
              revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
            else
              echo "adding a blank entry into the revision array"
              revisionArray+=("")
            fi
            # revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)") # the above test seems to be working so far, more testing needed.

            manufactureQtyLine=$(( $oneLineAhead + 1 ))
            qtyArray+=($(sed -n "$manufactureQtyLine p" "$fileName" | cut -f 5))

        else
            echo "'Order Qty' was on the expected line, we can continue as normal"
            tempValue=$(( $orderQty - 1 ))
            gciPartNumber+=($(sed -n "$tempValue p" "$fileName" | cut -f 4))
            revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 5)")
            manufactureQtyLine=$(( $orderQty + 1 ))
            qtyArray+=($(sed -n "$manufactureQtyLine p" "$fileName" | cut -f 5))

        fi
    fi

done


################################################################################
###############  Creating the Processs and Material Code Array  ################
################################################################################

isThereRotoParts="FALSE"

processArray=()
materialCodeArray=()

if [[ $CREATE_MATERIAL_ARRAY == "TRUE" ]]; then
  for (( i=0; i<${arrayLength}; i++ ));
  do
      linesAhead=$(( ${jobTickLineNumber[$i]} + 35 ))
      materialCodeLine=$(( ${jobTickLineNumber[$i]} + 16 ))

      # testing from the jobTickLineNumber to $linesAhead if the part is a '3030 LASER' part
      if (sed -n "${jobTickLineNumber[$i]},$linesAhead p" "$fileName" | grep '3030 LASER 2' -q); then
          echo "This part has 3030 LASER 2"
          processArray+=("3030 LASER 2")

          # getting the material code for the 3030 LASER 2 part
          sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
          if [[ $? == '1' ]]; then
              oneLineAhead=$materialCodeLine
              echo "'Material Code' was not on the expected line, going to search the next line..."
              sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
              while [[ $? == '1' ]]; do
                  ((oneLineAhead++))
                  echo "Jumping to line" $oneLineAhead "to look for 'Material Code'"
                  sed -n "$oneLineAhead p" "$fileName" | grep "Material Code" -q
              done
              echo "Success! found 'Material Code' on line" $oneLineAhead
              tempValue=$(( $oneLineAhead + 1 ))
              sed -n "$tempValue p" "$fileName" | cut -f 1
              materialCodeArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 1)")
          fi

      # testing from the jobTickLineNumber to $linesAhead if the part is a 'ROTO 3030' part
      elif (sed -n "${jobTickLineNumber[$i]},$linesAhead p" "$fileName" | grep 'ROTO 3030' -q); then
          echo "This part has ROTO 3030"
          processArray+=("ROTO 3030")

          isThereRotoParts="TRUE"

          # getting the material code for the 'ROTO 3030' part
          sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
          if [[ $? == '1' ]]; then
              oneLineAhead=$materialCodeLine
              echo "'Material Code' was not on the expected line, going to search the next line..."
              sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
              while [[ $? == '1' ]]; do
                  ((oneLineAhead++))
                  echo "Jumping to line" $oneLineAhead "to look for 'Material Code'"
                  sed -n "$oneLineAhead p" "$fileName" | grep "Material Code" -q
              done
              echo "Success! found 'Material Code' on line" $oneLineAhead
              tempValue=$(( $oneLineAhead + 1 ))
              sed -n "$tempValue p" "$fileName" | cut -f 1
              materialCodeArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 1)")
          fi

        # testing from the jobTickLineNumber to $linesAhead if the part is a 'BANDSAW' part
        elif (sed -n "${jobTickLineNumber[$i]},$linesAhead p" "$fileName" | grep 'BANDSAW' -q); then
            echo "This part has BANDSAW"
            processArray+=("BANDSAW")

            isThereRotoParts="TRUE"

            # getting the material code for the 'ROTO 3030' part
            sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
            if [[ $? == '1' ]]; then
                oneLineAhead=$materialCodeLine
                echo "'Material Code' was not on the expected line, going to search the next line..."
                sed -n "$materialCodeLine p" "$fileName" | grep "Material Code" -q
                while [[ $? == '1' ]]; do
                    ((oneLineAhead++))
                    echo "Jumping to line" $oneLineAhead "to look for 'Material Code'"
                    sed -n "$oneLineAhead p" "$fileName" | grep "Material Code" -q
                done
                echo "Success! found 'Material Code' on line" $oneLineAhead
                tempValue=$(( $oneLineAhead + 1 ))
                sed -n "$tempValue p" "$fileName" | cut -f 1
                materialCodeArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 1)")
            fi

      else
          # if the part is neither a LASER or ROTO part
          echo "This part is neither a LASER or ROTO part"
          processArray+=("NOT LASER OR ROTO")
          materialCodeArray+=("N/A")

      fi
  done
fi



########################################################
############  echo Test of all the Arrays  #############
########################################################

echo

for (( i=0; i<${arrayLength}; i++ ));
do
  echo "Ticket Number" $jobNumber"-"${ticketNumberArray[$i]}
  echo "GCI Part Number:" ${gciPartNumber[$i]}
  echo "Client Part Code:" ${clientPartNumber[$i]}

  # testing the string length
  string="${clientPartNumber[$i]}"
  string_length=${#string}
  if [[ $string_length -le 7 ]]; then
    echo -e $RED_WITH_WHITE"string_length is less than 7"$DEFAULT
  else
    echo "string_length is greater than 7"
  fi

  echo "String Length:" $string_length

  echo "Revision:" ${revisionArray[$i]}
  echo "Qty:" ${qtyArray[$i]}
  echo "Process:" ${processArray[$i]}
  echo "Material:" ${materialCodeArray[$i]}
  echo
done


#########################################################################
##########  Printing client drawings and ROTO progams at once  ##########
#########################################################################

if [[ $PRINT_CUSTOMER_PDFS_AND_ROTO_PROGRAMS == "TRUE" ]]; then

  echo "PRINT_CUSTOMER_PDFS_AND_ROTO_PROGRAMS variable is TRUE"
  echo
  echo "variable customerName: $customerName"
  echo "variable isThereRotoParts: $isThereRotoParts"
  echo

  sleep 1

  echo "Starting to print the drawings and ROTO programs for" $customerName "Job Number" $jobNumber | lp -o fit-to-page

  if [[ $customerName == "BUSTECH" && $isThereRotoParts == "TRUE" ]]; then

      sleep 1

      for (( i=0; i<${arrayLength}; i++ ));
      do

        cd "$BUSTECH"
        sleep 0.5

        echo
        echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

        # testing the character length of the part
        string="${clientPartNumber[$i]}"
        if [[ "${#string}" -le 7 ]]; then  # testing if the string is less than 8 characters long
          echo -e $RED_WITH_WHITE"$string is less than 7 characters long!"$DEFAULT
          continue  # this forces the loop to jump to the next iteration
        fi

        # testing if there is a pdf with the client part number
        if [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the Customer Part Number"
            echo ${clientPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
              # converting the pdf file to a post script file, so comments will get printed out
              pdftops -paper A4 "$file"

              # removing the pdf extension
              # checking if the extension (.pdf) is UPPER CASE or lower case
              if [[ "$file" == *PDF  ]]; then
                  no_extension=${file%.PDF}
              else
                  no_extension=${file%.pdf}
              fi

              post_script_file="$no_extension.ps"
              lp -o fit-to-page "$post_script_file"
              sleep 2
              rm "$post_script_file"
            done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
          else
            echo -e $RED_WITH_WHITE"Could not find a pdf at all."$DEFAULT
            missed_a_pdf="TRUE"
            missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
        fi

        # going to try and print the ROTO program PDF
        if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
            cd "$ROTO_PDF_FOLDER"
            sleep 0.5
            echo ${clientPartNumber[$i]} "is a ROTO 3030 part"
            echo "$jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
            echo "Have to turn the '-' in the client part code into an '_'"
            clientPartNumber[$i]=$(echo ${clientPartNumber[$i]//-/_})
            for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                echo -e $BLACK_WITH_GREEN"Sending" "$j" "to PR7N7y"$DEFAULT
                lp -o fit-to-page "$j"
                sleep 1
            done
        fi

      done
  fi

  if [[ $customerName == "EXPRESS COACH BUILDERS" && $isThereRotoParts == "TRUE" ]] || [[ $customerName == "BUSFURB PTY LTD" && $isThereRotoParts == "TRUE" ]]; then

      sleep 1

      echo "Entered the 'if' statement, if customer=express && isthereroto=true"

      for (( i=0; i<${arrayLength}; i++ ));
      do

          cd "$EXPRESS_COACH_BUILDERS"
          sleep 0.5

          echo
          echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

          # testing if there is a pdf with the client part number
          if [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                # converting the pdf file to a post script file, so comments will get printed out
                pdftops -paper A4 "$file"

                # removing the pdf extension
                # checking if the extension (.pdf) is UPPER CASE or lower case
                if [[ "$file" == *PDF  ]]; then
                    no_extension=${file%.PDF}
                else
                    no_extension=${file%.pdf}
                fi

                post_script_file="$no_extension.ps"
                lp -o fit-to-page "$post_script_file"
                sleep 2
                rm "$post_script_file"
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all."$DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
          fi

          # going to try and print the ROTO pdf program
          if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
              cd "$ROTO_PDF_FOLDER"
              sleep 0.5
              echo ${gciPartNumber[$i]} "is a ROTO 3030 part"
              echo "$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
              for j in $(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                  echo -e $BLACK_WITH_GREEN"Sending" "$j" "to PR1N7Y"$DEFAULT
                  lp -o fit-to-page "$j"
                  sleep 5
              done
          fi

      done

  fi

  if [[ $customerName == "JJ RICHARDS ENGINEERING PTY LTD" && $isThereRotoParts == "TRUE" ]]; then

      sleep 1

      echo "Entered the 'if' statement, if customer=JJ RICHARDS && isthereroto=true"

      for (( i=0; i<${arrayLength}; i++ ));
      do

          cd "$JJ_RICHARDS"
          sleep 0.5

          echo
          echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

          # testing if there is a pdf with the client part number
          if [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all."$DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
          fi

          # going to try and print the ROTO pdf program
          if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
              cd "$ROTO_PDF_FOLDER"
              sleep 0.5
              echo ${gciPartNumber[$i]} "is a ROTO 3030 part"
              echo "$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
              for j in $(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                  echo -e $BLACK_WITH_GREEN"Sending" "$j" "to PR1N7Y"$DEFAULT
                  lp -o fit-to-page "$j"
                  sleep 5
              done
          fi

      done

  fi

  if [[ $customerName == "PROJECT MODULAR PTY LTD" && $isThereRotoParts == "TRUE" ]]; then

      sleep 1

      for (( i=0; i<${arrayLength}; i++ ));
      do

        cd "$PROJECT_MODULAR"
        sleep 0.5

        echo
        echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

        # testing if there is a pdf with the GCI part number
        if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the GCI Part Number"
            echo ${gciPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
              # converting the pdf file to a post script file, so comments will get printed out
              pdftops -paper A4 "$file"

              # removing the pdf extension
              # checking if the extension (.pdf) is UPPER CASE or lower case
              if [[ "$file" == *PDF  ]]; then
                  no_extension=${file%.PDF}
              else
                  no_extension=${file%.pdf}
              fi

              post_script_file="$no_extension.ps"
              lp -o fit-to-page "$post_script_file"
              sleep 2
              rm "$post_script_file"
            done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
          else
            echo -e $RED_WITH_WHITE"Could not find a pdf at all."$DEFAULT
            missed_a_pdf="TRUE"
            missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
        fi

        # going to try and print the ROTO program PDF
        if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
            cd "$ROTO_PDF_FOLDER"
            sleep 0.5
            echo ${gciPartNumber[$i]} "is a ROTO 3030 part"
            echo "$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
            echo "Have to turn the '-' in the client part code into an '_'"
            clientPartNumber[$i]=$(echo ${clientPartNumber[$i]//-/_})
            for j in $(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                echo -e $BLACK_WITH_GREEN"Sending" "$j" "to PR7N7y"$DEFAULT
                lp -o fit-to-page "$j"
                sleep 1
            done
        fi

      done
  fi

fi


########################################################
############  Printing the client drawings  ############
########################################################

missed_a_pdf="FALSE"
missed_a_pdf_array=()

if [[ $PRINT_CUSTOMER_PDFS == "TRUE" ]]; then

  echo "PRINT_CUSTOMER_PDFS variable is TRUE"
  echo
  echo $customerName
  echo

  sleep 1

  echo "Starting to print the customer drawings for" $customerName "Job Number" $jobNumber | lp -o fit-to-page

      if [[ $customerName == "EXPRESS COACH BUILDERS" ]]; then
        cd "$EXPRESS_COACH_BUILDERS"
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          # # added double quotes around the find command, this solves the problem of spaces in the name/path of the pdf
          # for j in "$(find -type f -iname "${clientPartNumber[$i]}*.pdf"  -not -path "./ARCHIVE/*")"; do
          #   echo "PRINTY is going to print" $j
          #   lp -o fit-to-page "$j"
          #   sleep 0.5
          # done
          while IFS= read -rd '' file <&3; do
            echo "PRINTY is going to print" $file
            lp -o fit-to-page "$file"
            sleep 0.5
          done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
        done
      fi

      if [[ $customerName == "HOLMWOOD HIGHGATE (AUST) P/L" ]]; then
        cd "$HOLMWOOD"
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          echo
          echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

          # testing if there is a pdf with the GCI part number
          if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the GCI Part Number"
            echo ${gciPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
              lp -o fit-to-page "$file"
              sleep 2
            done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          # testing if there is a pdf with the client part number
          elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the Customer Part Number"
            echo ${clientPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
              lp -o fit-to-page "$file"
              sleep 2
            done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
          else
            echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
            missed_a_pdf="TRUE"
            missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
          fi
          
        done
      fi

      if [[ $customerName == "ABSOLUTE PACE" ]]; then
        echo "Entered into the ABSOLUTE PACE if statement"
        cd "$ABSOLUTE_PACE"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "BUSTECH" ]]; then
        cd "$BUSTECH"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing the character length of the part
            string="${clientPartNumber[$i]}"
            string_length=${#string}
            if [[ $string_length -le 7 ]]; then  # testing if the string is less than 8 characters long
              echo -e $RED_WITH_WHITE"$string is less than 7 characters long!"$DEFAULT
              continue  # this forces the loop to jump to the next iteration
            fi

            # testing if there is a pdf with the client part number
            if [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file$DEFAULT
                # converting the pdf file to a post script file, so comments will get printed out
                pdftops -paper A4 "$file"
                # removing the '.pdf' extension
                no_extension=${file%.pdf}
                post_script_file="$no_extension.ps"
                lp -o fit-to-page "$post_script_file"
                sleep 2
                rm "$post_script_file"
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all."$DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "BUSFURB PTY LTD" ]]; then
          echo "The Customer is BUSFURB!!"
          echo "Going to change into their directory..."
          cd "$EXPRESS_COACH_BUILDERS"
          echo
          pwd
          echo
          sleep 1
          for (( i=0; i<${arrayLength}; i++ ));
          do

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

          done
      fi

      if [[ $customerName == "BRYAN BODIES AUSTRALIA PTY LTD" ]]; then
        echo "Entered into the BRYAN BODIES if statement"
        cd "$BRYAN_BODIES"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "CEDAR CREEK COMPANY PTY LTD" ]]; then
        echo "Entered into the CEDAR CREEK if statement"
        cd "$CEDAR_CREEK"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "EKEBOL PTY LTD" ]]; then
        echo "Entered into the EKEBOL if statement"
        cd "$EKEBOL"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "CONDAMINE CAMPERS" ]]; then
        cd "$CONDAMINE_CAMPERS"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            while IFS= read -rd '' file <&3; do
              echo "PRINTY going to print" $file
              lp -o fit-to-page "$file"
              sleep 2
            done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
        done
      fi

      if [[ $customerName == "DAVCO WINCH SYSTEMS" ]]; then
        cd "$DAVCO"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "GEMCUTS" ]]; then
        echo "Entered into the GCEMCUTS if statement"
        cd "$GEMCUTS"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "JJ RICHARDS ENGINEERING PTY LTD" ]]; then
        cd "$JJ_RICHARDS"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi
        done
      fi

      if [[ $customerName == "KIMBERLEY KAMPERS" ]]; then
        cd "$KIMBERLEY"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            ## Kimberley Kampers has such a short part number that it returns a lot of unwanted results
            ## e.g. KK175, will return KK1750, KK1751, KK1752 etc etc
            ## going to try and fix this with ($part_number + [space_character]) & ($part_number + [underscore_character])
            client_part_number="${clientPartNumber[$i]}"
            # client_part_number_plus_space="$client_part_number "
            client_part_number_plus_underscore=$client_part_number"_"
            client_part_number_plus_hyphen=$client_part_number"-"

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the (client part number + [space_character])
            elif [[ $(find -type f -iname "$client_part_number *.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "$client_part_number *.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the ($client_part_number + [underscore_character])
            elif [[ $(find -type f -iname "$client_part_number_plus_underscore*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "$client_part_number_plus_underscore*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the ($client_part_number + [hyphen_character])
          elif [[ $(find -type f -iname "$client_part_number_plus_hyphen*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "$client_part_number_plus_hyphen*.pdf" -not -path "./ARCHIVE/*" -print0)


            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "LIFESTYLE CAMPER TRAILERS" ]]; then
        echo "Entered into the LIFESTYLE CAMPER TRAILERS if statement"
        cd "$LIFESTYLE"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            # if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            ## NEW TEST TO STOP IT FROM FINGIND 'EXTRA' DRAWGINS | LIKE LIFE2201_2.pdf AND LIFE2201_OPP_HAND_2.pdf
            if [[ $(find . -regextype posix-extended -regex ".*${gciPartNumber[$i]}.{2,4}\.pdf|.*${gciPartNumber[$i]}.{2,4}\.PDF" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              # done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
            done 3< <(find -regextype posix-extended -regex ".*${gciPartNumber[$i]}.{2,4}\.pdf|.*${gciPartNumber[$i]}.{2,4}\.PDF" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "LIQUIP SALES QLD" ]]; then
        cd "$LIQUIP"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            # while IFS= read -rd '' file <&3; do
            #   echo "PRINTY is going to print" $file
            #   lp -o fit-to-page "$file"
            #   sleep 2
            # done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "MONSTER RIDES" ]]; then
        cd "$MONSTER"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi
        done
      fi

      if [[ $customerName == "G H VARLEY - BNE" ]]; then
          echo "The Customer is VARLEY BNE!!"
          echo "Going to change into their directory..."
          cd "$VARLEY_BNE"
          echo
          pwd
          echo
          sleep 1
          for (( i=0; i<${arrayLength}; i++ ));
          do

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

          done
      fi

      if [[ $customerName == "G H VARLEY - TOMAGO DEFENCE" || $customerName == "G H VARLEY - YENNORA" ]]; then
          echo "The Customer is VARLEY - TOMAGO DEFENCE!!"
          echo "Going to change into their directory..."
          cd "$VARLEY_TOMAGO"
          echo
          pwd
          echo
          sleep 1
          for (( i=0; i<${arrayLength}; i++ ));
          do

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

          done
      fi

      if [[ $customerName == "G H VARLEY - TOMAGO (SCHOOL DRIVE)" ]]; then
        cd "$VARLEY_TOMAGO"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          echo "PRINTY is going to print" ${clientPartNumber[$i]}
          lp -o fit-to-page -o page-right=25 ${clientPartNumber[$i]}*.pdf
          sleep 0.5
        done
      fi

      if [[ $customerName == "OFFROAD RUSH" ]]; then
          cd "$OFFROAD_RUSH"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 1
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

      if [[ $customerName == "PACE INNOVATIONS PTY LTD" ]]; then
          cd "$PACEINNOVATION"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
            #   for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
            #     echo "PRINTY is going to print" $j
            #     lp -o fit-to-page "$j"
            #     sleep 5
            #   done
              while IFS= read -rd '' file <&3; do
              	echo "PRINTY going to print" $file
              	lp -o fit-to-page "$file"
                sleep 0.5
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

      if [[ $customerName == "PROACTIVE MAINTENANCE & ENGINEERING" ]]; then
        cd "$PROACTIVE_MAINTENANCE"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

        done
      fi

      if [[ $customerName == "P.T. AUTOMATION SOLUTIONS PTY LTD" ]]; then
          echo "The Customer is P.T. AUTOMATION SOLUTIONS!!"
          echo "Going to change into their directory..."
          cd "$PTAUTOMATIONSOLUTIONS"
          echo
          pwd
          echo
          sleep 1
          for (( i=0; i<${arrayLength}; i++ ));
          do

            # testing if there is a pdf with the GCI part number
            if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the GCI Part Number"
              echo ${gciPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # testing if there is a pdf with the client part number
            elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              echo "Found a pdf using the Customer Part Number"
              echo ${clientPartNumber[$i]}
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

            # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
            else
              echo "Could not find a pdf at all."
              missed_a_pdf="TRUE"
              missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
            fi

          done
      fi

      if [[ $customerName == "RIPTIDE CAMPERS" ]]; then
          cd "$RIPTIDE"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              echo
              echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}
              if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
                echo "Found a pdf using the GCI Part Number"
                echo ${gciPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo "PRINTY going to print" $file
                  lp -o fit-to-page "$file"
                  sleep 2
                done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
              elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
                echo "Found a pdf using the Customer Part Number"
                echo ${clientPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo "PRINTY going to print" $file
                  lp -o fit-to-page "$file"
                  sleep 2
                done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
              else
                echo "Could not find a pdf at all."
                missed_a_pdf="TRUE"
                missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
              fi

          done

      fi

      if [[ $customerName == "SEVA" ]]; then
        echo "Entered into the SEVA if statement"
        cd "$SEVA"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            echo
            part_string_length=${#gciPartNumber[$i]}
            echo "Part string length =" $part_string_length "for ticket number: "

            if [[ $part_string_length -ge 8 ]]; then
              echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

              # testing if there is a pdf with the GCI part number
              # if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
              ## NEW TEST TO STOP IT FROM FINGIND 'EXTRA' DRAWGINS | LIKE LIFE2201_2.pdf AND LIFE2201_OPP_HAND_2.pdf
              if [[ $(find . -regextype posix-extended -regex ".*${gciPartNumber[$i]}.{2,4}\.pdf|.*${gciPartNumber[$i]}.{2,4}\.PDF" | wc -l) > 0 ]]; then
                echo "Found a pdf using the GCI Part Number"
                echo ${gciPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                  lp -o fit-to-page "$file"
                  sleep 2
                # done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
              done 3< <(find -regextype posix-extended -regex ".*${gciPartNumber[$i]}.{2,4}\.pdf|.*${gciPartNumber[$i]}.{2,4}\.PDF" -not -path "./ARCHIVE/*" -print0)

              # testing if there is a pdf with the client part number
              elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
                echo "Found a pdf using the Customer Part Number"
                echo ${clientPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo -e $BLACK_WITH_GREEN"PRINTY going to print" $file $DEFAULT
                  lp -o fit-to-page "$file"
                  sleep 2
                done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

              # if no pdf could be found at all, this will get stored into the 'missed_a_pdf_array' and the user will get notified of the jobNumber-ticketNumber and partNumber that is missing
              else
                echo -e $RED_WITH_WHITE"Could not find a pdf at all." $DEFAULT
                missed_a_pdf="TRUE"
                missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
              fi
            fi



        done
      fi

      if [[ $customerName == "WEBER SOUTH PACIFIC PTY LTD" ]]; then
          cd "$WEBER"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              # while IFS= read -rd '' file <&3; do
              #   echo "PRINTY going to print" $file
              #   lp -o fit-to-page "$file"
              #   sleep 0.5
              # done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

              echo
              echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}
              if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
                echo "Found a pdf using the GCI Part Number"
                echo ${gciPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo "PRINTY going to print" $file
                  lp -o fit-to-page "$file"
                  sleep 2
                done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
              elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
                echo "Found a pdf using the Customer Part Number"
                echo ${clientPartNumber[$i]}
                while IFS= read -rd '' file <&3; do
                  echo "PRINTY going to print" $file
                  lp -o fit-to-page "$file"
                  sleep 2
                done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
              else
                echo "Could not find a pdf at all."
                missed_a_pdf="TRUE"
                missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
              fi

          done

      fi

      if [[ $customerName == "SPEEDSAFE" ]]; then
          cd "$SPEEDSAFE"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

      if [[ $customerName == "STEELROD PTY LTD" ]]; then
          cd "$STEELROD"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

      if [[ $customerName == "TEST CLIENT" ]]; then
        cd "$TEST_CLIENT"
        sleep 1

        for (( i = 0; i < ${arrayLength}; i++ )); do
          echo
          echo "Testing ticket number" $jobNumber"-"${ticketNumberArray[$i]}

          # testing if there is a pdf with the client part number
          if [[ $(find -type f -iname "${gciPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the GCI Part Number"
            echo ${gciPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo "PRINTY going to print" $file
              lp -o fit-to-page "$file"
              sleep 2
            done 3< <(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
          elif [[ $(find -type f -iname "${clientPartNumber[$i]}*.pdf" | wc -l) > 0 ]]; then
            echo "Found a pdf using the Customer Part Number"
            echo ${clientPartNumber[$i]}
            while IFS= read -rd '' file <&3; do
              echo "PRINTY going to print" $file
              lp -o fit-to-page "$file"
              sleep 2
            done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
          else
            echo "Could not find a pdf at all."
            missed_a_pdf="TRUE"
            missed_a_pdf_array+=($jobNumber"-"${ticketNumberArray[$i]}", "${gciPartNumber[$i]})
          fi

        done

      fi

      if [[ $customerName == "SUN ENGINEERING" ]]; then
          cd "$SUN_ENGINEERING"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

      if [[ $customerName == "TRITIUM PTY LTD" ]]; then
          cd "$TRITIUM"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 2
              done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

          done

      fi

fi

if [[ $missed_a_pdf == "TRUE" ]]; then
  echo
  echo
  echo -e "\e[91mThere has been an...\e[0m"
  echo -e "\e[91m _____ ____  ____   ___  ____  \e[0m"
  echo -e "\e[91m| ____|  _ \|  _ \ / _ \|  _ \ \e[0m"
  echo -e "\e[91m|  _| | |_) | |_) | | | | |_) |\e[0m"
  echo -e "\e[91m| |___|  _ <|  _ <| |_| |  _ < \e[0m"
  echo -e "\e[91m|_____|_| \_|_| \_|\___/|_| \_\ \e[0m"
  echo

  for (( i = 0; i < ${#missed_a_pdf_array[@]}; i++ )); do
    echo -e "\e[91mCould not find a pdf for\e[0m" "\e[91m${missed_a_pdf_array[$i]}\e[0m"
  done

fi



########################################################
##########  Printing the existing roto pdf's  ##########
########################################################

if [[ $PRINT_ROTO_PROGRAMS == "TRUE" ]]; then

  sleep 1

  if [[ $isThereRotoParts == "TRUE" ]]; then
      # printing the cover page
      echo "Starting to print the ROTO programs for" $customerName "Job Number" $jobNumber | lp -o fit-to-page

      echo "I have detected a disturbance in the force... And also ROTO programs in this job"
      cd "$ROTO_PDF_FOLDER"
      sleep 1

      #########################################################################################
      # if the customer is bustech, we have to replace the '-' in the client part code to '_'
      #########################################################################################
      if [[ $customerName == "BUSTECH" ]]; then
          echo "The customer is BUSTECH, have to replace the hyphen '-' with an underscore '_' for each part..."
          for (( i=0; i<${arrayLength}; i++ ));
          do
              # added BANDSAW to the if statement as most BANDSAW are now cut on the ROTO
              if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
                  echo ${clientPartNumber[$i]} "is a ROTO 3030 part"
                  echo "$jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
                  echo "Have to turn the '-' in the client part code into an '_'"
                  clientPartNumber[$i]=$(echo ${clientPartNumber[$i]//-/_})
                  for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                      echo "Sending" "$j" "to PR1N7Y"
                      lp -o fit-to-page "$j"
                      sleep 5
                  done
              fi
          done
      else
          # most of the customers ROTO programs are made using the GCI part number
          echo "The customer is not BUSTECH, going to search for the ROTO pdf's using the GCI Part Number"
          for (( i=0; i<${arrayLength}; i++ ));
          do
              # added BANDSAW to the if statement as most BANDSAW are now cut on the ROTO
              if [[ ${processArray[$i]} == "ROTO 3030" || ${processArray[$i]} == "BANDSAW" ]]; then
                  echo ${gciPartNumber[$i]} "is a ROTO 3030 part"
                  echo "$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - is a ROTO 3030 part" >>  "$ORIGINAL_FOLDER/$jobNumber.ROTO.log"
                  for j in $(find -type f -iname "${gciPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
                      echo "Sending" "$j" "to PR1N7Y"
                      lp -o fit-to-page "$j"
                      sleep 5
                  done
              fi

          done
        fi

  else
      echo "ERROR! There are no ROTO parts in this Job"
      sleep 2
  fi
fi

######################################################################
###########  Grabbing the ROTO lst's ready for Tube Nest  ############
######################################################################

if [[ $GRAB_ROTO_LSTs == "TRUE" ]]; then
  echo
  echo "Going to copy all the ROTO lst's for this job to,"
  echo $ROTO_LST_READY_TO_NEST"/"$jobNumber"/"
  mkdir "$ROTO_LST_READY_TO_NEST/$jobNumber"

  hasThereBeenAnError="FALSE"

  cd "$ROTO_LST_FOLDER"
  sleep 0.5

  if [[ $customerName == "BUSTECH" ]]; then

      echo "The customer is BUSTECH, have to replace the '-' with an underscore '_' for each part..."
      for (( i=0; i<${arrayLength}; i++ ));
      do
          if [[ ${processArray[$i]} == "ROTO 3030" ]]; then
              echo ${clientPartNumber[$i]} "is a ROTO 3030 part"
              echo "Have to turn the '-' in the client part code into an '_'"
              clientPartNumber[$i]=$(echo ${clientPartNumber[$i]//-/_})

                  if [[ -z "${revisionArray[$i]}" ]]; then
                      # revision array variable is empty
                      echo "The revision for this part is Empty"
                      test -e "${clientPartNumber[$i]}.LST"
                      if [[ $? == '0' ]]; then
                          cp "${clientPartNumber[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/$jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.LST"
                          sleep 0.5
                      else
                          echo "File does not exist!!!"
                          echo "Error, could not find a .LST for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR.log"
                          hasThereBeenAnError="TRUE"
                      fi

                  elif [[ ${revisionArray[$i]} == "ORIG" ]]; then
                      echo "The revision for the part is ORIG"
                      echo "Ignoring the revision for this part"
                      test -e "${clientPartNumber[$i]}.LST"
                      if [[ $? == '0' ]]; then
                          cp "${clientPartNumber[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/$jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.LST"
                          sleep 0.5
                      else
                        echo "File does not exist!!!"
                        echo "Error, could not find a .LST for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR.log"
                        hasThereBeenAnError="TRUE"
                      fi

                  else
                      test -e "${clientPartNumber[$i]}_${revisionArray[$i]}.LST"
                      if [[ $? == '0' ]]; then
                          cp "${clientPartNumber[$i]}_${revisionArray[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/$jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]}_${revisionArray[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.LST"
                          sleep 0.5
                      else
                          echo "File does not exist!!!"
                          echo "Error, could not find a .LST for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} Revision ${revisionArray[$i]} - ${materialCodeArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR.log"
                          hasThereBeenAnError="TRUE"
                      fi

                  fi

          fi
      done
  else
      # most customers use the GCI part number as the ROTO program
      for (( i=0; i<${arrayLength}; i++ ));
      do
          if [[ ${processArray[$i]} == "ROTO 3030" ]]; then
              echo ${gciPartNumber[$i]} "is a ROTO 3030 part"

              # There is some material in itms with a forward slash in it '/'
              # bash really doesn't like it when this happens, so we have to remove them
              echo "Checking if this Parts Material Code has a '/' in it"
              if [[ ${materialCodeArray[$i]} = *"/"* ]]; then
                echo "This Part Meterial Code does have a '/' in it"
                echo "Chaning it now to a '_'"
                materialCodeArray[$i]=$(echo ${materialCodeArray[$i]//\//_})
              fi


              if [[ -z "${revisionArray[$i]}" ]]; then
                  # revision array variable is empty
                  echo "The revision for this part is empty"
                  test -e "${gciPartNumber[$i]}.LST"
                  if [[ $? == '0' ]]; then
                      cp "${gciPartNumber[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - "${materialCodeArray[$i]}" - x${qtyArray[$i]}.LST"
                      sleep 0.5
                  else
                      echo "File does not exist!!!"
                      echo "Error, could not find a .LST for: $jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - ${materialCodeArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR"
                      hasThereBeenAnError="TRUE"
                  fi
              else
                  test -e "${gciPartNumber[$i]}_${revisionArray[$i]}.LST"
                  if [[ $? == '0' ]]; then
                      cp "${gciPartNumber[$i]}_${revisionArray[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/$jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - "${materialCodeArray[$i]}" - x${qtyArray[$i]}.LST"
                      sleep 0.5
                  else
                      echo "File does not exist!!!"
                      echo "Error, could not find a .LST for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} Revision ${revisionArray[$i]} - ${materialCodeArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR.log"
                      hasThereBeenAnError="TRUE"
                  fi
              fi
          fi
      done
  fi

  if [[ $hasThereBeenAnError == "TRUE" ]]; then
    echo
    echo "There has been an..."
    echo " _____ ____  ____   ___  ____  "
    echo "| ____|  _ \|  _ \ / _ \|  _ \ "
    echo "|  _| | |_) | |_) | | | | |_) |"
    echo "| |___|  _ <|  _ <| |_| |  _ < "
    echo "|_____|_| \_|_| \_\\\\___/|_| \_\ "
    echo
    cat "$ORIGINAL_FOLDER/$jobNumber.copyRotoLST.ERROR.log"
    echo
  fi

fi


echo
