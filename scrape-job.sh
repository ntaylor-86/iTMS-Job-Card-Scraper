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
ROTO_LST_READY_TO_NEST="/mnt/Network-Drives/T-Drive/7000 TUBE JOBS READY TO NEST"

###############################################
# Defining where the customer drawings are

BUSTECH="/mnt/Network-Drives/U-Drive/BUSTECH/PDF DRAWINGS"
EXPRESS_COACH_BUILDERS="/mnt/Network-Drives/U-Drive/EXPRESSCOACHES/ALL OFFICIAL PARTS DRAWINGS"
JJ_RICHARDS="/mnt/Network-Drives/U-Drive/JJRICHARDSENG"
OFFROAD_RUSH="/mnt/Network-Drives/U-Drive/OFFROADRUSH"
PACEINNOVATION="/mnt/Network-Drives/U-Drive/PACEINNOVATION"
STEELROD="/mnt/Network-Drives/U-Drive/STEELROD"
SUN_ENGINEERING="/mnt/Network-Drives/U-Drive/SUNENG"
VARLEY_BNE="/mnt/Network-Drives/U-Drive/VARLEYBNE"
VARLEY_TOMAGO="/mnt/Network-Drives/U-Drive/VARLEYTGO"
WEBER="/mnt/Network-Drives/U-Drive/WEBERSOUTHPACIFIC"


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
customerName=$(sed -n '2p' "$fileName")

###############################################################################################
PRINT_CUSTOMER_PDFS="FALSE"
PRINT_ROTO_PROGRAMS="FALSE"
TEST_MODE="FALSE"
GRAB_ROTO_LSTs="FALSE"
GRAB_GEOS="FALSE"
CREATE_LABELS="FALSE"
CREATE_MATERIAL_ARRAY="FALSE"

echo "  ╔═════════════════════════════════════════╗"
echo "  ║     1) Print the Customers PDF's        ║"
echo "  ║     2) Print the existing ROTO PDF's    ║"
echo "  ║     3) Grab all the ROTO LST's          ║"
echo "  ║     4) Grab all the GEO's               ║"
echo "  ║     5) Create Labels                    ║"
echo "  ║     6) Test Mode                        ║"
echo "  ╚═════════════════════════════════════════╝"
echo
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
  echo "Grab all the GEO's selected!"
  GRAB_GEOS="TRUE"
  CREATE_MATERIAL_ARRAY="TRUE"
  sleep 1
elif [[ $OPTION == "5" ]]; then
  echo "Create Labels selected!"
  CREATE_LABELS="TRUE"
  sleep 1
elif [[ $OPTION == "6" ]]; then
  echo "Test Mode selected!"
  TEST_MODE="TRUE"
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
jobNumber=$(sed -n '3p' "$fileName")
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
            gciPartNumber+=($(sed -n "$tempValue p" "$fileName" | cut -f 1))
            revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
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
            revisionArray+=("$(sed -n "$tempValue p" "$fileName" | cut -f 2)")
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
      materialCodeLine=$(( ${jobTickLineNumber[$i]} + 20 ))

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

      else
          # if the part is neither a LASER or ROTO part
          echo "This part is neither a LASER or ROTO part"

          processArray+=("NOT LASER OR ROTO")
          materialCodeArray+=("N/A")

      fi
  done
fi



########################################################
############  Echo Test of all the Arrays  #############
########################################################

echo

for (( i=0; i<${arrayLength}; i++ ));
do
  echo "Ticket Number" $jobNumber"-"${ticketNumberArray[$i]}
  echo "GCI Part Number:" ${gciPartNumber[$i]}
  echo "Client Part Code:" ${clientPartNumber[$i]}
  echo "Revision:" ${revisionArray[$i]}
  echo "Qty:" ${qtyArray[$i]}
  echo "Process:" ${processArray[$i]}
  echo "Material:" ${materialCodeArray[$i]}
  echo
done


########################################################
############  Printing the client drawings  ############
########################################################

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
          # added double quotes around the find command, this solves the problem of spaces in the name/path of the pdf
          for j in "$(find -type f -iname "${clientPartNumber[$i]}*.pdf"  -not -path "./ARCHIVE/*")"; do
            echo "PRINTY is going to print" $j
            lp -o fit-to-page "$j"
            sleep 0.5
          done
        done
      fi

      if [[ $customerName == "BUSTECH" ]]; then
        cd "$BUSTECH"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
            echo "PRINTY is going to print" $j
            lp -o fit-to-page "$j"
            sleep 0.5
          done
        done
      fi

      if [[ $customerName == "JJ RICHARDS ENGINEERING PTY LTD" ]]; then
        cd "$JJ_RICHARDS"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
            # for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
            #   echo "PRINTY is going to print" $j
            #   lp -o fit-to-page -o page-right=25 "$j"
            #   sleep 0.5
            # done
            while IFS= read -rd '' file <&3; do
              echo "PRINTY going to print" $file
              lp -o fit-to-page "$file"
              sleep 0.5
            done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)
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
          #   echo "PRINTY is going to print" ${clientPartNumber[$i]}
          #   lp -o fit-to-page -o page-right=25 ${clientPartNumber[$i]}*.pdf
          #   sleep 2
          # done
            while IFS= read -rd '' file <&3; do
              echo "PRINTY going to print" $file
              lp -o fit-to-page "$file"
              sleep 0.5
            done 3< <(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*" -print0)

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

      if [[ $customerName == "WEBER SOUTH PACIFIC PTY LTD" ]]; then
          cd "$WEBER"
          pwd
          sleep 1

          for (( i=0; i<${arrayLength}; i++ ));
          do
              while IFS= read -rd '' file <&3; do
                echo "PRINTY going to print" $file
                lp -o fit-to-page "$file"
                sleep 0.5
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
              if [[ ${processArray[$i]} == "ROTO 3030" ]]; then
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
              if [[ ${processArray[$i]} == "ROTO 3030" ]]; then
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

#################################################################
#############  Grabbing the GEO's ready for Nest  ###############
#################################################################

if [[ $GRAB_GEOS == "TRUE" ]]; then
    echo
    echo "Going to copy all the GEO's that are ready to nest for this job to,"
    echo $GEO_READY_TO_NEST"/"$jobNumber"/"
    mkdir "$GEO_READY_TO_NEST/$jobNumber"
    sleep 0.5

    if [[ $customerName == "BUSTECH" ]]; then

        cd "$BUSTECH_GEOS"
        sleep 0.5
        pwd

        echo "The customer is BUSTECH, have to replce '-' with an underscore '_' for each part..."
        for (( i=0; i<${arrayLength}; i++ ));
        do
            if [[ ${processArray[$i]} == "3030 LASER 2" ]]; then
                echo ${clientPartNumber[$i]} "is a 3030 LASER 2 part"
                echo "Have to turn the '-' in the client part code into an '_'"
                clientPartNumber[$i]=$(echo ${clientPartNumber[$i]//-/_})

                if [[ ${revisionArray[$i]} == "ORIG" ]]; then
                    test -e "${clientPartNumber[$i]}.GEO"
                    if [[ $? == '0' ]]; then
                      # the formatting of the cpoied part is currently as follows: 1 - 0026_01 - 12mm 250 GR - x6.GEO
                        cp "${clientPartNumber[$i]}.GEO" "$GEO_READY_TO_NEST/$jobNumber/${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.GEO"
                    else
                        echo "File does not exist!!!"
                        echo "Error, could not find a .GEO for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.ERROR.log"
                    fi

                # testing if the revision string is empty
                elif [[ -z "${revisionArray[$i]}" ]]; then
                    # revision array variable is empty

                    test -e "${clientPartNumber[$i]}.GEO"
                    if [[ $? == '0' ]]; then
                        cp "${clientPartNumber[$i]}.GEO" "$GEO_READY_TO_NEST/$jobNumber/${ticketNumberArray[$i]} - ${clientPartNumber[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.GEO"
                    else
                        echo "File does not exist!!!"
                        echo "Error, could not find a .GEO for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.ERROR.log"
                    fi

                # if the revision string is not empty
                else
                    test -e "${clientPartNumber[$i]}_${revisionArray[$i]}.GEO"
                    if [[ $? == '0' ]]; then
                        cp "${clientPartNumber[$i]}_${revisionArray[$i]}.GEO" "$GEO_READY_TO_NEST/$jobNumber/${ticketNumberArray[$i]} - ${clientPartNumber[$i]}_${revisionArray[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.GEO"
                    else
                        echo "File does not exist!!!"
                        echo "Error, could not find a .GEO for: $jobNumber-${ticketNumberArray[$i]} - ${clientPartNumber[$i]} Revision ${revisionArray[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.ERROR.log"
                    fi

                fi

            fi
        done
    fi

    if [[ $customerName == "LAI SWITCHBOARDS AUSTRALIA" ]]; then

       cd "$LAI_SWITCHBAORDS_GEOS"
       sleep 0.5
       pwd

       for (( i=0; i<${arrayLength}; i++ ));
       do
          if [[ ${processArray[$i]} == "3030 LASER 2" ]]; then
              echo ${gciPartNumber[$i]} "is a 3030 LASER 2 part"

              if [[ -z "${revisionArray[$i]}" ]]; then
                  # revision array variable is empty

                  test -e "${gciPartNumber[$i]}.GEO"
                  if [[ $? == '0' ]]; then
                      # '0' if file does exist
                      cp "${gciPartNumber[$i]}.GEO" "$GEO_READY_TO_NEST/$jobNumber/${ticketNumberArray[$i]} - ${gciPartNumber[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.GEO"
                  else
                      echo "File does not exist!!!"
                      echo "Error, could not find a .GEO for: $jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.ERROR.log"
                  fi
              else
                  # revision array variable is not empty

                  test -e "${gciPartNumber[$i]}_${revisionArray[$i]}.GEO"
                  if [[ $? == '0' ]]; then
                      # '0' if files does exist
                      cp "${gciPartNumber[$i]}_${revisionArray[$i]}.GEO" "$GEO_READY_TO_NEST/$jobNumber/${ticketNumberArray[$i]} - ${gciPartNumber[$i]}_${revisionArray[$i]} - ${materialCodeArray[$i]} - x${qtyArray[$i]}.GEO"
                  else
                      echo "File does not exist!!!"
                      echo "Error, could not find a .GEO for: $jobNumber-${ticketNumberArray[$i]} - ${gciPartNumber[$i]}" >> "$ORIGINAL_FOLDER/$jobNumber.ERROR.log"
                  fi
              fi
          fi
       done

    fi

fi

#################################################################
###############   Creating the sticker labels   #################
#################################################################

if [[ $CREATE_LABELS == "TRUE" ]]; then
    echo
    echo "Creating the labels .CSV now..."
    echo
    echo "Ticket Number, Part Number, Qty" >> "$ORIGINAL_FOLDER/Labels/$jobNumber.csv"
    for (( i=0; i<${arrayLength}; i++ ));
    do
        if [[ ${clientPartNumber[$i]} != "CUSTOMER-LABELS" ]]; then
              echo "${ticketNumberArray[$i]}, ${clientPartNumber[$i]}, ${qtyArray[$i]}" >> "$ORIGINAL_FOLDER/Labels/$jobNumber.csv"
        fi
    done
    echo "Creating the Labels .CSV is complete!"
    echo "Open the 'Labels' folder to find $jobNumber.csv"
fi

echo
