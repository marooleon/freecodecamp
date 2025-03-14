#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME_IN

USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME_IN'")

if [[ -z $USER ]]
then
    # print welcome
    echo "Welcome, $USERNAME_IN! It looks like this is your first time here."
    # set up user in the database
    INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_IN')")
    if [[ $INSERT_RESULT == "INSERT 0 1" ]]
    then
        echo "Successfully have you registered into our database, '$USERNAME_IN'!"
        USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME_IN'")
        IFS='|' read USER_ID USERNAME GAMES BEST <<< "$USER"
    else
        echo "Sorry, failed to have you registered into our database, '$USERNAME_IN'."
        exit 0
    fi
else
    # get user entry from database
    IFS='|' read USER_ID USERNAME GAMES BEST <<< "$USER"
    echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi
# play guess game
# generate a random number between 1 and 1000
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
GUESS_CNT=0

echo "Guess the secret number between 1 and 1000:"

while true
do
    read GUESS_IN
    GUESS_CNT=$((GUESS_CNT + 1))
    if [[ ! $GUESS_IN =~ ^[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
        continue
    elif [[ $GUESS_IN -gt $RANDOM_NUMBER ]]
    then
        echo "It's lower than that, guess again:"
    elif [[ $GUESS_IN -lt $RANDOM_NUMBER ]]
    then
        echo "It's higher than that, guess again:"
    else    # hit
        echo "You guessed it in $GUESS_CNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
        break
    fi
done

# update database
NEW_GAMES=$((GAMES + 1))
$PSQL "UPDATE users SET games_played = $NEW_GAMES WHERE username='$USERNAME'" >/dev/null 2>&1
if [[ "$BEST" -eq 0 || "$BEST" -gt "$GUESS_CNT" ]]
then
    $PSQL "UPDATE users SET best_score = $GUESS_CNT WHERE username='$USERNAME'" >/dev/null 2>&1
fi
