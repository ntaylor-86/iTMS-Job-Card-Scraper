#!/usr/bin/env bash
# notes: system requires dos2unix to be installed
# source txt file will have new line characters from windows
# and that will break things real good

###############################################
# Defining the Original Start point for the program
ORIGINAL_FOLDER="/home/$USER/Network-Drives/T-Drive/temp.bmt/Scripts/scrape txt file"

###############################################
# Defining the 7000 TUBE PDF folder
ROTO_PDF_FOLDER="/home/$USER/Network-Drives/T-Drive/7000 TUBE PDF/"

###############################################
# Defining the 7000 TUBE lst folder
ROTO_LST_FOLDER="/home/$USER/Network-Drives/T-Drive/7000 ROTO LST"
ROTO_LST_READY_TO_NEST="/home/$USER/Network-Drives/T-Drive/7000 TUBE JOBS READY TO NEST"

###############################################
# Defining where the customer drawings are

BUSTECH="/home/$USER/Network-Drives/U-Drive/BUSTECH/PDF DRAWINGS"
EXPRESS_COACH_BUILDERS="/home/$USER/Network-Drives/U-Drive/EXPRESSCOACHES/ALL OFFICIAL PARTS DRAWINGS"
JJ_RICHARDS="/home/$USER/Network-Drives/U-Drive/JJ RICHARDS"
VARLEY_TOMAGO="/home/$USER/Network-Drives/U-Drive/VARLEYTGO"

###############################################
# Defining the thile to work on, $1 is the first argument passed when loading this script
fileName=$1

###############################################
# dos2unix has to be the first command to execute before the script can start working on $fileName
# removes all windows new line format so linux can work on it, -q = quiet mode

dos2unix -q "$fileName"

###############################################################################################
# Getting the customer name, this assumes that the customer name is on line 2 of the txt file
customerName=$(sed -n '2p' "$fileName")

###############################################################################################

echo
echo "             pN▒g▒p▒g▒▒g▒ge"
echo "            ▒▒▒▒▒▒▒░░▒░▒░▒"
echo "          _0▒░▒░▒░░▒▒▒▒▒▒!"
echo "          4▒▒▒▒▒░░░▒░░▒▒▒▒▒Y"
echo "          |\` ~~#00░░0▒MMM\"M|"
echo "                \`gM░M7"
echo "         |       00Q0       |"
echo "         #▒____g▒0░░P______0"
echo "         #▒0g_p#░░04▒▒&,__M#"
echo "         0▒▒▒▒▒00   ]0▒▒▒▒00"
echo "          |\j▒▒0'   '0▒▒▒4M'"
echo "           |\#▒▒&▒▒gg▒▒0& |"
echo "          \" ▒▒00▒▒▒▒00▒▒'d"
echo "          %  ¼▒  ~P▒¼▒▒|¼¼|"
echo "          M▒9▒,▒▒ ]▒] *▒j,g"
echo "          l▒g▒▒] @▒9"
echo "           ~▒0▒▒▒p ▒g▒"
echo "             @░▒▒▒▒▒   ▒▒░"
echo "              M0░░   ░░░^"
echo "                \`"
echo
echo "   Nathan's PR1N7Y th3 pr1n7 b07 SCR1P7_"
echo

###############################################################################################
PRINT_CUSTOMER_PDFS="FALSE"
PRINT_ROTO_PROGRAMS="FALSE"
TEST_MODE="FALSE"
GRAB_ROTO_LSTs="FALSE"

echo "  ╔═════════════════════════════════════════╗"
echo "  ║     1) Print the Customers PDF's        ║"
echo "  ║     2) Print the existing ROTO PDF's    ║"
echo "  ║     3) Grab all the ROTO LST's          ║"
echo "  ║     4) Test Mode                        ║"
echo "  ╚═════════════════════════════════════════╝"
echo
read -p "   Enter an option Number: " OPTION

if [[ $OPTION == "1" ]]; then
  echo "Print the customers PDF's selected!"
  PRINT_CUSTOMER_PDFS="TRUE"
  sleep 1
elif [[ $OPTION == "2" ]]; then
  echo "Print the existing ROTO PDF's selected!"
  PRINT_ROTO_PROGRAMS="TRUE"
  sleep 1
elif [[ $OPTION == "3" ]]; then
   echo "Grab all the ROTO LST's selected!"
   GRAB_ROTO_LSTs="TRUE"
  sleep 1
elif [[ $OPTION == "4" ]]; then
  echo "Test Mode selected!"
  TEST_MODE="TRUE"
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

isThereRotoParts='FALSE'

processArray=()
materialCodeArray=()

for (( i=0; i<${arrayLength}; i++ ));
do
    linesAhead=$(( ${jobTickLineNumber[$i]} + 35 ))
    materialCodeLine=$(( ${jobTickLineNumber[$i]} + 25 ))

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

        isThereRotoParts='TRUE'

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

  sleep 1

  echo "Starting to print the customer drawings for" $customerName "Job Number" $jobNumber | lp -o fit-to-page

      # tempFrontPage="./temp-files/$jobNumber-front-page-temp.txt"
      # touch $tempFrontPage
      # echo "Starting to print the drawings for customer:" $customerName "Job Number:" $jobNumber > $tempFrontPage
      # lp -o fit-to-page "$tempFrontPage"

      if [[ $customerName == "EXPRESS COACH BUILDERS" ]]; then
        cd "$EXPRESS_COACH_BUILDERS"
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf"  -not -path "./ARCHIVE/*"); do
            lp -o fit-to-page "$j"
            sleep 5
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
            sleep 5
          done
        done
      fi

      if [[ $customerName == "JJ RICHARDS ENGINEERING PTY LTD" ]]; then
        cd "$JJ_RICHARDS"
        pwd
        sleep 1
        for (( i=0; i<${arrayLength}; i++ ));
        do
          for j in $(find -type f -iname "${clientPartNumber[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
            echo "PRINTY is going to print" $j
            lp -o fit-to-page -o page-right=25 "$j"
            sleep 5
          done
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
          sleep 5
        done
      fi
fi



########################################################
##########  Printing the existing roto pdf's  ##########
########################################################

if [[ $PRINT_ROTO_PROGRAMS == "TRUE" ]]; then

  sleep 1

  rotoPartArrayLength=${#rotoPartArray[@]}

  echo "Starting to print the ROTO programs for" $customerName "Job Number" $jobNumber | lp -o fit-to-page

  if [[ $isThereRotoParts == 'TRUE' ]]; then
    echo "I have detected a disturbance in the force... And also ROTO programs in this job"
    cd "$ROTO_PDF_FOLDER"
    sleep 1

    #########################################################################################
    # if the customer is bustech, we have to replace the '-' in the client part code to '_'
    #########################################################################################
    if [[ $customerName == "BUSTECH" ]]; then
        echo "The customer is BUSTECH, have to replace the '-' with an underscore '_' for each part..."
        for (( i=0; i<${rotoPartArrayLength}; i++ ));
        do
            echo "Replacing the '-' in" ${rotoPartArray[$i]}
            rotoPartArray[$i]=$(echo ${rotoPartArray[$i]//-/_})
            echo "The '-' should now be replaced with an '_' " ${rotoPartArray[$i]}
        done
    fi

    echo $rotoPartArrayLength
    pwd
    for (( i=0; i<${#rotoPartArray[@]}; i++ ));
    do
      for j in $(find -type f -iname "${rotoPartArray[$i]}*.pdf" -not -path "./ARCHIVE/*"); do
        lp -o fit-to-page "$j"
        sleep 5
      done
    done
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

  cd "$ROTO_LST_FOLDER"
  sleep 0.5

  rotoPartArrayLength=${#rotoPartArray[@]}

  echo $customerName

  if [[ $customerName == "BUSTECH" ]]; then
      echo "The customer is BUSTECH, have to replace the '-' with an underscore '_' for each part..."
      for (( i=0; i<${rotoPartArrayLength}; i++ ));
      do
          echo "Replacing the '-' in" ${rotoPartArray[$i]}
          rotoPartArray[$i]=$(echo ${rotoPartArray[$i]//-/_})
          echo "The '-' should now be replaced with an '_' " ${rotoPartArray[$i]}
      done
  fi

  for (( i=0; i<${rotoPartArrayLength}; i++ ));
  do
    if [[ -z "${rotoPartRevision[$i]}" ]]; then
      echo "The revision for this part is Empty"
      cp "${rotoPartArray[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/${rotoPartTicketNumberArray[$i]} - ${rotoPartArray[$i]}.LST"
      sleep 0.5
    elif [[ ${rotoPartRevision[$i]} == "ORIG" ]]; then
      echo "The revision for the part is ORIG"
      echo "Ignoring the revision for this part"
      cp "${rotoPartArray[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/${rotoPartTicketNumberArray[$i]} - ${rotoPartArray[$i]}.LST"
      sleep 0.5
    else
      echo "Copying" ${rotoPartArray[$i]}"_"${rotoPartRevision[$i]}".LST"
      cp "${rotoPartArray[$i]}_${rotoPartRevision[$i]}.LST" "$ROTO_LST_READY_TO_NEST/$jobNumber/${rotoPartTicketNumberArray[$i]} - ${rotoPartArray[$i]}_${rotoPartRevision[$i]}.LST"
      sleep 0.5
    fi
  done
fi

# ###################################################################
# ###########  Moving the .txt file after working on it  ############
# echo
# echo "Moving" $fileName "into the ./Already-Processed/ folder"
# cd "$ORIGINAL_FOLDER"
# sleep 0.5
# mv "./$fileName" ./Already-Processed/
#
# ##################################################################
# #########################  Cleaning up  ##########################
# echo
# echo "Removing the TEMP files..."
# rm "./temp-files/$tempFrontPage"
