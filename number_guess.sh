#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
N=$(( (RANDOM%1000)+1 ))
T=0
user_guess=0
echo $N
echo 'Enter your username:'
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

if [[ -z $USER_ID ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$USERNAME', 0, 999999);")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  GAMES=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID';")
  BEST=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID';")
  BEST=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID';")
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi


until [[ $USER_GUESS -eq $N ]]
do
  echo 'Guess the secret number between 1 and 1000:'
  read USER_GUESS
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    (( T++ ))
    if [[ $USER_GUESS -lt $N ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS -gt $N ]]
    then
      echo "It's lower than that, guess again:"
    fi
  else
    echo 'That is not an integer, guess again:'
  fi
done
if [[ $T -lt $BEST ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $T WHERE username='$USERNAME';")
fi

NEW_GAMES=$(($GAMES+1))
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = $NEW_GAMES WHERE username='$USERNAME';")

echo "You guessed it in $T tries. The secret number was $N. Nice job!"


#ALTER SEQUENCE <table>_<column>_seq RESTART;