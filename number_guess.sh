#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME 

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else

  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER=$((1 + RANDOM % 1000))
ATTEMPTS=0


echo "Guess the secret number between 1 and 1000:"

while true
do
  ((ATTEMPTS++))
  read GUESS


  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
 
    if [[ $GUESS -gt $NUMBER ]]; then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]; then
      echo "It's higher than that, guess again:"
    else
      echo -e "\nYou guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
      
      INSERT_GAME=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $ATTEMPTS)")
      break
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
