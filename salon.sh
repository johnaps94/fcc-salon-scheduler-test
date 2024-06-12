#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
CUSTOMER_PHONE=''
SERVICE_ID_SELECTED=0

CHECK_SERVICE_CHOICE() {
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE  
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  # Query the database to check if the entered service choice exists
  SERVICE_CHOICE_CHECK=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # Check if the query result is empty
  if [[ -z $SERVICE_CHOICE_CHECK ]]
  then  
    echo -e "\nI could not find that service. What would you like today?"
    CHECK_SERVICE_CHOICE
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
  fi
}
CHECK_SERVICE_CHOICE

if [[ ! -z $CUSTOMER_PHONE ]]
then
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    ADD_CUSTOMER_INFO_TODB=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  ADD_APPOINTMENT_INFO_TODB=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")

  echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
fi