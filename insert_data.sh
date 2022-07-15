#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #inserting teams
  if [[ $WINNER != "winner" ]] && [[ $OPPONENT != "opponent" ]]
  then
    #get team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' OR name='$OPPONENT")

    #if not found
    if [[ -z $TEAM_ID ]]
    then
      #insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ INSERT_TEAM=="INSERT 0 1" ]]
      then
        echo Inserted team: $WINNER.
      fi
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ INSERT_TEAM=="INSERT 0 1" ]]
      then
        echo Inserted team: $OPPONENT.
      fi
    #get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' OR name='$OPPONENT'")
    fi
  fi


  #inserting games
  if [[ $YEAR != "year" ]] && [[ $ROUND != "round" ]] && [[ $WINNER_GOALS != "winner_goals" ]] && [[ $OPPONENT_GOALS != "opponent_goals" ]]
  then
    #get team_id
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WIN_ID, $OPP_ID)")
    if [[ $INSERT_GAMES=="INSERT 0 1" ]]
    then
      echo Inserted game: $WINNER vs $OPPONENT from $ROUND in $YEAR.
    fi
  fi
done