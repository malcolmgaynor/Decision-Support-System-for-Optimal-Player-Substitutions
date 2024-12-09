#https://www.kaggle.com/datasets/secareanualin/football-events?select=events.csv 
#specifically, events
dfsoc<-read.csv(file=file.choose())

colnames(dfsoc)
summary(as.factor(dfsoc$event_team))
dfmanu<-dfsoc[dfsoc$event_team=="Manchester Utd",]
nrow(dfsoc[dfsoc$event_type==7,]) # 51,715 substitutions total in dataset
nrow(dfmanu[dfmanu$event_type==7,]) # 373 for ManU substitutions total in dataset 

justsubs<-dfsoc[dfsoc$event_type==7,]
View(justsubs)

# We would need to calculate goals before and after sub using this dataset...
# goals conceded do not go under "event team", so we would need to merge with dfoppmanu on id_odsp, ordering on id_event

dfoppmanu<-dfsoc[dfsoc$opponent=="Manchester Utd",]

View(dfoppmanu)
View(dfmanu)
View(dfmanu[dfmanu$event_type==7,])

summary(as.factor(dfsoc[dfsoc$event_type==7,]$event_team)) #list of teams who we have the most subs for... 
# also, we could just do entire dataset, or just one league too



dfmanuall<-rbind(dfmanu,dfoppmanu)
dfmanuall <- dfmanuall[order(dfmanuall$id_odsp, dfmanuall$sort_order), ]
View(dfmanuall)

nrow(dfmanuall[dfmanuall$event_type==7 & dfmanuall$event_team=="Manchester Utd",]) # still 373 ManU subs

totalgoals <- dfmanu %>%
  group_by(id_odsp, event_team) %>%
  summarise(total_goals = sum(is_goal))
totalgoals

# need to go over OPT slides to better understand...
#### NOTES: cluster substitution decision (player in position (and stats), player out position (and stats), time (maybe do separetely) 45-60, 60-75, 75-90)
# then, add sub treatment clusters to original dataset
# Use OPT

dfsocsorted <- dfsoc[order(dfsoc$id_odsp, dfsoc$sort_order), ]
View(dfsocsorted)

dfsocsorted$goals_pre_sub=0
dfsocsorted$opp_goals_pre_sub=0

dfsocsorted$attempts_pre_sub=0
dfsocsorted$opp_attempts_pre_sub=0
dfsocsorted$corners_pre_sub = 0
dfsocsorted$opp_corners_pre_sub = 0
dfsocsorted$fouls_pre_sub = 0
dfsocsorted$opp_fouls_pre_sub = 0
dfsocsorted$pks_pre_sub = 0
dfsocsorted$opp_pks_pre_sub = 0



prevgame=1

homegoalcounter = 0 #event 7
awaygoalcounter = 0

homeattempts=0 # event 1
awayattempts=0
homecorners=0 # event 2
awaycorners=0
homefouls=0 # event 3
awayfouls=0
homepks=0 # event 11 
awaypks=0

for (i in 1:nrow(dfsocsorted)){
  
  print(i/nrow(dfsocsorted))
  
  #first, reset counters if we are in a new game 
  
  if(dfsocsorted$id_odsp[i]!=dfsocsorted$id_odsp[prevgame]){
    homegoalcounter=0
    awaygoalcounter=0
    
    homeattempts=0 # event 1
    awayattempts=0
    homecorners=0 # event 2
    awaycorners=0
    homefouls=0 # event 3
    awayfouls=0
    homepks=0 # event 11 
    awaypks=0
    
    prevgame=i
  }
  
  #if the event is a goal, update our counters
  
  if(dfsocsorted$is_goal[i]==1){
    if (dfsocsorted$side[i]==1){
      homegoalcounter=homegoalcounter+1
    } else if (dfsocsorted$side[i]==2){
      awaygoalcounter=awaygoalcounter+1
    }
  }
  #attempts (1) 
  
  if(dfsocsorted$event_type[i]==1){
    if (dfsocsorted$side[i]==1){
      homeattempts=homeattempts+1
    } else if (dfsocsorted$side[i]==2){
      awayattempts=awayattempts+1
    }
  }
  
  #corners (2) 
  
  if(dfsocsorted$event_type[i]==2){
    if (dfsocsorted$side[i]==1){
      homecorners=homecorners+1
    } else if (dfsocsorted$side[i]==2){
      awaycorners=awaycorners+1
    }
  }
  
  #fouls (3) 
  
  if(dfsocsorted$event_type[i]==3){
    if (dfsocsorted$side[i]==1){
      homefouls=homefouls+1
    } else if (dfsocsorted$side[i]==2){
      awayfouls=awayfouls+1
    }
  }
  
  #pks (11) 
  
  if(dfsocsorted$event_type[i]==11){
    if (dfsocsorted$side[i]==1){
      homepks=homepks+1
    } else if (dfsocsorted$side[i]==2){
      awaypks=awaypks+1
    }
  }
  
  #update pre-substitution counter if the event is a sub 
  
  if(dfsocsorted$event_type[i]==7){
    if(dfsocsorted$side[i]==1){
      dfsocsorted$goals_pre_sub[i]=homegoalcounter
      dfsocsorted$opp_goals_pre_sub[i]=awaygoalcounter
      
      dfsocsorted$attempts_pre_sub[i]=homeattempts
      dfsocsorted$opp_attempts_pre_sub[i]=awayattempts
      dfsocsorted$corners_pre_sub[i] = homecorners
      dfsocsorted$opp_corners_pre_sub[i] = awaycorners
      dfsocsorted$fouls_pre_sub[i] = homefouls
      dfsocsorted$opp_fouls_pre_sub[i] = awayfouls
      dfsocsorted$pks_pre_sub[i] = homepks
      dfsocsorted$opp_pks_pre_sub[i] = awaypks
      
    } else if (dfsocsorted$side[i]==2){
      dfsocsorted$goals_pre_sub[i]=awaygoalcounter
      dfsocsorted$opp_goals_pre_sub[i]=homegoalcounter
      
      dfsocsorted$attempts_pre_sub[i]=awayattempts
      dfsocsorted$opp_attempts_pre_sub[i]=homeattempts
      dfsocsorted$corners_pre_sub[i] = awaycorners
      dfsocsorted$opp_corners_pre_sub[i] = homecorners
      dfsocsorted$fouls_pre_sub[i] = awayfouls
      dfsocsorted$opp_fouls_pre_sub[i] = homefouls
      dfsocsorted$pks_pre_sub[i] = awaypks
      dfsocsorted$opp_pks_pre_sub[i] = homepks
      
    }
  }
}


View(dfsocsorted[dfsocsorted$event_type==7 | dfsocsorted$is_goal==1,])




###NOW, FLIP IT, AND DO IT AGAIN FOR POST SUB



dfsocsorted2 <- dfsocsorted[order(dfsocsorted$id_odsp, -dfsocsorted$sort_order), ]
View(dfsocsorted2)

dfsocsorted2$goals_post_sub=0
dfsocsorted2$opp_goals_post_sub=0

dfsocsorted2$attempts_post_sub=0
dfsocsorted2$opp_attempts_post_sub=0
dfsocsorted2$corners_post_sub = 0
dfsocsorted2$opp_corners_post_sub = 0
dfsocsorted2$fouls_post_sub = 0
dfsocsorted2$opp_fouls_post_sub = 0
dfsocsorted2$pks_post_sub = 0
dfsocsorted2$opp_pks_post_sub = 0



prevgame=1

homegoalcounter = 0 #event 7
awaygoalcounter = 0

homeattempts=0 # event 1
awayattempts=0
homecorners=0 # event 2
awaycorners=0
homefouls=0 # event 3
awayfouls=0
homepks=0 # event 11 
awaypks=0

for (i in 1:nrow(dfsocsorted2)){
  
  print(i/nrow(dfsocsorted2))
  
  #first, reset counters if we are in a new game 
  
  if(dfsocsorted2$id_odsp[i]!=dfsocsorted2$id_odsp[prevgame]){
    homegoalcounter=0
    awaygoalcounter=0
    
    homeattempts=0 # event 1
    awayattempts=0
    homecorners=0 # event 2
    awaycorners=0
    homefouls=0 # event 3
    awayfouls=0
    homepks=0 # event 11 
    awaypks=0
    
    prevgame=i
  }
  
  #if the event is a goal, update our counters
  
  if(dfsocsorted2$is_goal[i]==1){
    if (dfsocsorted2$side[i]==1){
      homegoalcounter=homegoalcounter+1
    } else if (dfsocsorted2$side[i]==2){
      awaygoalcounter=awaygoalcounter+1
    }
  }
  #attempts (1) 
  
  if(dfsocsorted2$event_type[i]==1){
    if (dfsocsorted2$side[i]==1){
      homeattempts=homeattempts+1
    } else if (dfsocsorted2$side[i]==2){
      awayattempts=awayattempts+1
    }
  }
  
  #corners (2) 
  
  if(dfsocsorted2$event_type[i]==2){
    if (dfsocsorted2$side[i]==1){
      homecorners=homecorners+1
    } else if (dfsocsorted2$side[i]==2){
      awaycorners=awaycorners+1
    }
  }
  
  #fouls (3) 
  
  if(dfsocsorted2$event_type[i]==3){
    if (dfsocsorted2$side[i]==1){
      homefouls=homefouls+1
    } else if (dfsocsorted2$side[i]==2){
      awayfouls=awayfouls+1
    }
  }
  
  #pks (11) 
  
  if(dfsocsorted2$event_type[i]==11){
    if (dfsocsorted2$side[i]==1){
      homepks=homepks+1
    } else if (dfsocsorted2$side[i]==2){
      awaypks=awaypks+1
    }
  }
  
  #update pre-substitution counter if the event is a sub 
  
  if(dfsocsorted2$event_type[i]==7){
    if(dfsocsorted2$side[i]==1){
      dfsocsorted2$goals_post_sub[i]=homegoalcounter
      dfsocsorted2$opp_goals_post_sub[i]=awaygoalcounter
      
      dfsocsorted2$attempts_post_sub[i]=homeattempts
      dfsocsorted2$opp_attempts_post_sub[i]=awayattempts
      dfsocsorted2$corners_post_sub[i] = homecorners
      dfsocsorted2$opp_corners_post_sub[i] = awaycorners
      dfsocsorted2$fouls_post_sub[i] = homefouls
      dfsocsorted2$opp_fouls_post_sub[i] = awayfouls
      dfsocsorted2$pks_post_sub[i] = homepks
      dfsocsorted2$opp_pks_post_sub[i] = awaypks
      
    } else if (dfsocsorted2$side[i]==2){
      dfsocsorted2$goals_post_sub[i]=awaygoalcounter
      dfsocsorted2$opp_goals_post_sub[i]=homegoalcounter
      
      dfsocsorted2$attempts_post_sub[i]=awayattempts
      dfsocsorted2$opp_attempts_post_sub[i]=homeattempts
      dfsocsorted2$corners_post_sub[i] = awaycorners
      dfsocsorted2$opp_corners_post_sub[i] = homecorners
      dfsocsorted2$fouls_post_sub[i] = awayfouls
      dfsocsorted2$opp_fouls_post_sub[i] = homefouls
      dfsocsorted2$pks_post_sub[i] = awaypks
      dfsocsorted2$opp_pks_post_sub[i] = homepks
      
    }
  }
}


View(dfsocsorted2[dfsocsorted2$event_type==7 | dfsocsorted2$is_goal==1,])

dfsocsubs<-dfsocsorted2[dfsocsorted2$event_type==7,]
dfsocsubsorted <- dfsocsubs[order(dfsocsubs$id_odsp, dfsocsubs$sort_order), ]


#write.csv(dfsocsubsorted, "YOUR LOCATION HERE")

View(dfsocsubsorted)

#https://www.kaggle.com/datasets/antoinekrajnc/soccer-players-statistics/data 
players <- read.csv(file=file.choose())
head(players)
dfp<-players[,c(1,6,10,13,18:53)]
head(dfp)
nrow(dfsocsubsorted) # 51738
View(dfp)

summary(as.factor(players$Club_Position))







View(dfmerged)


library(dplyr)
library(stringr)
library(stringi)

# Function to normalize text (lowercase, remove punctuation, remove accents)
normalize_text <- function(text) {
  text %>%
    str_to_lower() %>%                   # Convert to lowercase
    str_remove_all("[[:punct:]]") %>%    # Remove punctuation
    stri_trans_general("Latin-ASCII")   # Remove accents/special characters
}

# Normalize columns and perform the join
dfmerged <- dfsocsubsorted %>%
  mutate(player_in_normalized = normalize_text(player_in)) %>%
  left_join(
    dfp %>%
      mutate(Name_normalized = normalize_text(Name)),
    by = c("player_in_normalized" = "Name_normalized")
  ) %>%
  select(-player_in_normalized)  # Remove the temporary normalized column


dfpout <- dfp

colnames(dfpout) <- paste0("out", colnames(dfpout))


dfmerged2 <- dfmerged %>%
  mutate(player_in_normalized = normalize_text(player_out)) %>%
  left_join(
    dfpout %>%
      mutate(Name_normalized = normalize_text(outName)),
    by = c("player_in_normalized" = "Name_normalized")
  ) %>%
  select(-player_in_normalized)  # Remove the temporary normalized column

View(dfmerged2)

nrow(dfmerged2)-nrow(dfmerged2[is.na(dfmerged2$Rating)|is.na(dfmerged2$outRating),])

dfmergednona<-dfmerged2[!is.na(dfmerged2$Rating)&!is.na(dfmerged2$outRating),]

View(dfmergednona)

nrow(dfmergednona)


#write.csv(dfmergednona, "YOUR LOCATION HERE")






