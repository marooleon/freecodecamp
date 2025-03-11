#!/bin/bash

# Script to insert data from courses.csv and students.csv into students database

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams;");

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPO WINNER_GOALS OPPO_GOALS
do
  if [[ $YEAR != "year" ]]  # skip the title row
  then

    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # get new team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get oppo_id
    OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPO'")
    # if not found
    if [[ -z $OPPO_ID ]]
    then
      # insert team
      INSERT_OPPO_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPO')")
      if [[ $INSERT_OPPO_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPO
      fi
      # get new major_id
      OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPO'")
    fi

    # insert into games
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPO_ID', '$WINNER_GOALS', '$OPPO_GOALS');")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER_ID $OPPO_ID $WINNER_GOALS $OPPO_GOALS
    fi
  fi
done
