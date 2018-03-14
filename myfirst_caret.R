library(recipes)
library(tidyverse)
library(corrr)
library(doMC)
library(stringr)

set.seed(42)
df<-read_csv('pol_clust_trump_forml.csv')

#remove features that are not actively being used for machine learning

df2<-df %>%
  select(-parsed_media_url,-parsed_media_type,-lat,-lon,-place_lat,-place_lon,-full_name,
         -timestamp_ms,-expanded_url,-rt_screen_id,-rt_screen_name,-source,-profile_desc,
         -profile_url,-profile_name,-id,-mentioned_users,-mentioned_id,-created_at,-user_id_str,
         -country,-in_reply_to_user_id,-in_reply_to_screen_name,-modularity_class,
         -strongcompnum,-att1,-hashes) %>%
  select(class_label,everything())

df2<-df2[,c(1:15,19:43)]
names(df2)[12]<-"mod_created_at"

library(stringr)
#sent_out <- str_replace_all(df2$text,"[\n\r]",'')
#write.csv(sent_out,'senti_text.txt',row.names=F)


#This file contains the sentiment scores for the tweets
sent<-read_tsv('senti_text4_out.txt')
#df2=df2[,1:37]
df2=bind_cols(df2,sent[,1:2])

df2<- df2 %>% mutate(
  csent = Positive + Negative,
  asent = Positive - Negative
)

screen_name<-df2$screen_name
df2<-df2 %>%
  select(-tweet_id,-screen_name,-text)

which_nd<-function(x){n_distinct(x)>1}
# give the column names that are univariate, so we can drop them
names(df2)[unlist(map(df2, ~!which_nd(.)))]

#number of hashes based on Ryan's feature discussed 02-16-18
hashes=strsplit(df$hashes,';')
nhashes=sapply(hashes,function(x) ifelse(is.na(x[[1]]), 0,length(x[[1]])))
df2=cbind(df2,nhashes=nhashes)
df3 <- df2 %>%
  mutate(
    used_web=used_web %>% as.numeric(),
    used_iphone = used_iphone %>% as.numeric(),
    used_android= used_android %>% as.numeric(),
    prof_inlist = prof_inlist %>% as.numeric(),
    prof_hasdesc = prof_hasdesc %>% as.numeric(),
    rt90 = rt90 %>% as.numeric(),
    links90 = links90 %>% as.numeric(),
    has_ment = has_ment %>% as.numeric(),
    has_ht = has_ht %>% as.numeric(),
    fol2_gt_friends = fol2_gt_friends %>% as.numeric(),
    api = api %>% as.factor() %>% as.numeric()
    
  )


df3 <- select(df3,-datetime)



df3=df2 %>%
  mutate(
    followers_count=followers_count +1,
    friends_count= friends_count +1,
    listed_count=listed_count+1,
    statuses_count=statuses_count+1,
    fol_rate=fol_rate+1
  )

#df3=df3 %>%
#  arrange(datetime)


#Split sample into train and test group

library(rsample)
train_test_split <- initial_split(df3, prop = 0.75)


# Retrieve train and test sets
train_tbl <- training(train_test_split)
test_tbl  <- testing(train_test_split) 



#This recipe (using package "recipes")
#log normalizes several variables that vary over magnitudes
#and one-hot encodes (makes into dummy variables) the categorical variables
# also centers and scales the data


rec_obj=recipe(class_label~.,data=train_tbl) %>%
  step_log(followers_count,friends_count,listed_count,statuses_count,fol_rate) %>%
  #step_date(datetime,features='decimal') %>%
  step_rm(datetime) %>%
  step_sqrt(degree,indegree,outdegree) %>%
  step_dummy(all_nominal(),-all_outcomes()) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep(data=train_tbl)



# These are the datasets actually used for ML training and testing, after transformed
# by the previous "recipe"

x_train_tbl <- bake(rec_obj, newdata = train_tbl)
x_test_tbl  <- bake(rec_obj, newdata = test_tbl)





library(doMC)
#either allocate automatically all available, or set if you know
registerDoMC(cores=getDoParWorkers())
#registerDoMC(cores=4)


library(caret)
fitControl <- trainControl(method = "CV",
                           number = 5,
                           verboseIter = TRUE,
                           summaryFunction = multiClassSummary,
                           allowParallel=TRUE,
                           classProbs=TRUE
                           
)



#glmmod <- train(x_train_tbl[,names(x_train_tbl)!="class_label"], x_train_tbl$class_label, method='glmnet',metric='accuracy', trControl=fitControl)

glmmod2 <- train(x_train_tbl[,names(x_train_tbl)!="class_label"], x_train_tbl$class_label, method='glmnet',metric='Mean_F1', trControl=fitControl)


glm_pred <- predict(glmmod2, newdata = x_test_tbl)
confusionMatrix(glm_pred,x_test_tbl$class_label)
res<-confusionMatrix(glm_pred,x_test_tbl$class_label)
out_res <- data.frame(t(res$overall),t(res$byClass))
write_csv(out_res,"myfirst_glm.csv")