#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ ! $1 ]]
then
    echo -e "Please provide an element as an argument."
    exit 0
fi
# get all info from elements table
ALL_ELEMENTS=$($PSQL "SELECT * FROM elements")

#echo $ALL_ELEMENTS

# iterate through atomic_number, symbol and name
while IFS='|' read ATOMIC_NUMBER SYMBOL NAME
do
    #echo $ATOMIC_NUMBER $SYMBOL $NAME
        #if [[ "$1" == "$ATOMIC_NUMBER" ]] || [[ "$1" == "$SYMBOL" ]] || [[ "$1" == "$NAME" ]]
        if [[ "$1" == "$ATOMIC_NUMBER" || "$1" == "$SYMBOL" || "$1" == "$NAME" ]]
    then
                PROPERTY=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
                #echo "$PROPERTY" | while IFS="|" read ATOMIC_MASS MELT BOIL TYPE_ID
                IFS='|' read ATOMIC_MASS MELT BOIL TYPE_ID <<< "$PROPERTY"
                #echo $TYPE_ID
                TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
                #echo $TYPE
                echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
                exit 0
    fi
done <<< "$ALL_ELEMENTS"

# if not found
echo "I could not find that element in the database."
