#Pobieramy dane o chorobie 
brca <- read.table("dane_BRCA.csv", h=T, sep=";", dec=",")

#Sumujemy warto�ci dla ka�dego Stage/etapu

library(dplyr)

brca %>% 
  
  group_by(ICD10, GENDER, AGE_GROUP, TERYT4, region, subregion, year) %>%
  
  summarise(Stage1 = sum(Stage1), 
            
            Stage2 = sum(Stage2), 
            
            Stage3 = sum(Stage3), 
            
            Stage4 = sum(Stage4)) -> sum1

#Tworzymy kolumn� z sum� dla wszystkich stage/etap�w

sum1$patient<-rowSums(sum1[,c(8:11)])

#Tylko kobiety

sum6<-sum1[sum1$GENDER=="K",]

#Tutaj mo�emy doda� jeszcze podzia� na grupy wiekowe

sum6 %>%
  group_by( region ) %>%
  summarize( suma=sum(patient)) -> sum5


load(file="ludnosc_k.RData")

m<-merge(x = sum5, y = ludnosc1, by = "region", all.x = TRUE)

m$norm<-m$suma/m$kobiety

m1<-m[,c(1,4)]
m1<-m1[order(m1$norm),]
m1$reg<-1:16


s<-unique(sum1[,c(4,5)])
m_plot<-merge(x = s, y = m1, by = "region", all.x = TRUE)
colnames(m_plot)[2]<-"TERYT"
mm_plot<-m_plot
mm_plot$TERYT<-sprintf("%04d", mm_plot$TERYT)

#tract.RData - plik utworzy�am do wykre�lania map
#zrobi�am go na podstawie plik�w z https://github.com/pbiecek/teryt
#oraz na podstawie opisu z http://www.kevjohnson.org/making-maps-in-r/

load(file="tract.RData")

tract2<-tract[,c(1,2,6,7)]
colnames(tract2)<-c("long","lat","TERYT","group")

ksztalt<-merge(y = mm_plot, x = tract2, by = "TERYT", all.x = TRUE)


library(ggmap)
library(scales)

#Dane

p1 <- ggplot() +
  geom_polygon(data = ksztalt, aes(x = long, y = lat, group = group,
                                   fill = norm), color = "black", size = 0.25) +
  scale_fill_distiller(palette = "Greens", labels = percent,
                       breaks = pretty_breaks(n = 10), values = c(1,0)) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_nothing(legend = TRUE) +
  labs(title = "Odsetek chorych kobiet w podziale na wojew�dztwa",
       fill = "")
p1

