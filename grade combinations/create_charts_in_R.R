rm(list=ls())
setwd("C:\\Users\\hs17922\\Dropbox\\Work\\Research\\Projects\\3 The effect of grading on study effort\\archive\\Data and Analysis\\Combinations")

library("tidyverse")

# load data
df<-read_csv("dataforR.csv")

#wide
w<-gather(df,gradesgiven,count, seq(2,17,by=2))%>%
  select(-c(2:9))%>%
  separate(gradesgiven,sep=5,into=c("delete","gradesgiven"))%>%
  select(-"delete")%>%
  filter(gradesgiven>1,gradesgiven<6)%>%
  filter(!is.na(count))

# plots
ggplot(w)+geom_step(aes(x=gpa,y=count,colour=gradesgiven), size=1)+
   theme( panel.border = element_rect(colour = "black", fill=NA, size=1), panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),panel.background = element_blank(),legend.key=element_blank(),
          legend.position="bottom")+
        labs(y="Grade Combinations",x="GPA pre transformation")+
        scale_colour_manual(name = " ",values = c("#a6a6a6", "#808080", "#5c5b5b", "#000000"), 
    labels = c("2 grades transformed", "3 grades transformed", "4 grades transformed", "5 grades transformed"))+
    guides(colour=guide_legend(nrow=2,byrow=TRUE))
ggsave("fig_combinations.png")
ggsave("fig_combinations.pdf")



#wide
w<-gather(df,gradesgiven,count, seq(3,17,by=2))%>%
  select(-c(2:9))%>%
  separate(gradesgiven,sep=3,into=c("delete","gradesgiven"))%>%
  select(-"delete")%>%
  filter(gradesgiven>1,gradesgiven<6)%>%
  filter(!is.na(count))

# plots
ggplot(w)+geom_step(aes(x=gpa,y=count,colour=gradesgiven), size=1)+
  theme( panel.border = element_rect(colour = "black", fill=NA, size=1), panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),panel.background = element_blank(),legend.key=element_blank(),
         legend.position="bottom")+
  labs(y="Max potential difference post transf.",x="GPA pre transformation")+
  scale_colour_manual(name = " ",values = c("#a6a6a6", "#808080", "#5c5b5b", "#000000"), 
                      labels = c("2 grades transformed", "3 grades transformed", "4 grades transformed", "5 grades transformed"))+
  guides(colour=guide_legend(nrow=2,byrow=TRUE))
ggsave("fig_dif.png")
ggsave("fig_dif.pdf")