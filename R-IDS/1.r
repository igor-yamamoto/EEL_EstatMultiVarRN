##TITANIC

## Dados (Kraggle)
train <- read.csv("../Data/train-titanic.csv", header = TRUE)
test <- read.csv("../Data/test-titanic.csv", header = TRUE)

## Diferença entre treino e teste
ncol(train) #-> 12
ncol(test)  #-> 11 (vamos predizer sobreviver/falecer)

## Adicionar uma coluna varia em "test"
test.survived <- data.frame(Survived = rep(NA, nrow(test)), test[,])
ncol(test.survived) #-> 12

## Combinar data sets
data.combined <- rbind(train,test.survived)

## Tipos de dados
str(data.combined)

## fatores que queremos considerar na análise (preliminarmente)
## Ticket, Cabin, Embarked, Pclass, Name, Sex,
data.combined$Survived <- as.factor(data.combined$Survived)
data.combined$Pclass <- as.factor(data.combined$Pclass)
data.combined$Name <- as.factor(data.combined$Name)
data.combined$Sex <- as.factor(data.combined$Sex)
data.combined$Age <- as.factor(data.combined$Age)
data.combined$Ticket <- as.factor(data.combined$Ticket)
data.combined$Cabin <- as.factor(data.combined$Cabin)
data.combined$Embarked <- as.factor(data.combined$Embarked)

## Tabela com numero de pessoas que sobreviveu/faleceu
table(data.combined$Survived)

table(data.combined$Pclass)

##Usaremos a biblioteca ggplot, para visualizar análises
library(ggplot2)

##Testaremos uma hipotese: pessoas ricas tiveram uma chance maior de
##sobrevivencia


ggplot(train, aes(x = Pclass, fill = factor(Survived)))+
    geom_bar(width = 0.5) +
    xlab("Pclass") +
    ylab("Conta total") +
    labs(fill="Survived")

## De fato, visualmente, observamos que ser da primeira classe importa
## na sua chance de sobreviver.



#head(as.character(train$Name))
length(unique(as.character(data.combined$Name))) #-> 1307 (Quantos nomes únicos)
nrow(data.combined)                      #-> 1309 (2 duplicatas, ou
                                        #quatro nomes iguais)



## Como houveram nomes duplicados, podemos utilizar os seguintes
## comandos e checar se, de fato, eram entradas distintas ou não.


duplicados.Name <- as.character(data.combined[which(duplicated(as.character(data.combined$Name))), "Name"])

data.combined[which(data.combined$Name %in% duplicados.Name),]


## Analisaremos se ha relacao entre titulos, como "Miss", e sobrevivencia.

library(stringr)

misses <- data.combined[which(str_detect(data.combined$Name, "Miss.")),]
misses[1:5,]

## Miss. eh um titulo que era dado a mulheres solteiras.

mrses <- data.combined[which(str_detect(data.combined$Name, "Mrs.")),]
mrses[1:5,]

## Mrs. mulheres mais velhas e provavelmente já casadas

## Ver padrão com (qualquer) homem [H: homens morrem com maior frequência]
males <- data.combined[which(train$Sex == "male"),]
males[1:5,]



## Como parece ter algum tipo de relação com esses nomes, vamos
## analisá-los, inicialmente, visualmente.


extractTitle <- function(name){
    ## Nome, no dataset, é um Factor. Retornamos para Character
    name <- as.character(name)
    ## Planejamos fazer uma coluna, com os títulos
    if (length (grep ("Miss.", name)) > 0) {
        return("Miss.")
    } else if (length (grep ("Master.", name)) > 0) {
        return("Master.")
    } else if (length (grep ("Mrs.", name)) > 0) {
        return("Mrs.")
    } else if (length (grep ("Mr.", name)) > 0) {
        return("Mr.")
    } else {
        return("Other.")
    }
}


## Criando uma nova coluna na nossa tabela,

titles <- NULL # objeto vazio
for(i in 1:nrow(data.combined)){
    titles <- c(titles, extractTitle(data.combined[i,"Name"]))
} # vetor ( c() ), com os titulos exatraidos

## Criando uma nova coluna com o vetor de titulos, com tipo Factor,
## invés de Character

data.combined$Title <- as.factor(titles)


#### Visualizando relação de sobrevivencia e titulo
ggplot(data.combined[1:nrow(train),], aes(x = Title, fill = Survived))+
    geom_bar(width = 0.5)+
    facet_wrap(~Pclass)+
    ggtitle("Classe Ticket/Social, Titulo(Sexo-Status) vs Sobrevivencia")+
    xlab("Titulos")+
    ylab("Contagem total")+
    labs(fill="Sobreviveram")

table(data.combined$Sex)

ggplot(data.combined[1:891,], aes(x=Sex, fill=Survived))+
    geom_bar(width = 0.5)+
    facet_wrap (~Pclass)+
    ggtitle("Classe Social")+
    xlab("Sexo")+
    ylab("Contagem Total")+
    labs(fill="Sobreviveram")

data.combined$Age <- as.numeric(data.combined$Age)
summary(data.combined$Age)
summary(data.combined[1:nrow(train),"Age"])

ggplot(data.combined[1:nrow(train),], aes(x=Age, fill=Survived))+
    facet_wrap(~Sex + Pclass)+
    geom_bar(width = 10)+
    xlab("Idade")+
    ylab("Quantidade")+
    labs(fill="Sobreviveram")


## Validar que "Master." é um título de homens jovens
boys <- data.combined[which(data.combined$Title=="Master."),]
summary(boys$Age)

## Avaliar a idade de "Miss."
misses <- data.combined[which(data.combined$Title=="Miss."),]
summary(misses$Age)


ggplot(misses[which(misses$Survived != "NA"),], aes(x=Age, fill=Survived))+
    facet_wrap(~Pclass)+
    geom_histogram(binwidth = 5)+
    ggtitle("Idade para 'Miss.', por Classe")+
    xlab("Age")+
    ylab("Total Count")


## 1 criança mulher viajando sozinha (bem diferente de "Masters")
misses.alone <- misses[which(misses$SibSp == 0 & misses$Parch==0),]
summary(misses.alone$Age)
length(which(misses.alone$Age <= 14.5)) #=>1


summary(data.combined$SibSp)
## -> podemos transformar em um Factor?
length(unique(data.combined$SibSp)) # => 7
## Ok, podemos,
data.combined$SibSp <- as.factor(data.combined$SibSp)

ggplot(data.combined[1:891,], aes(x=SibSp, fill=Survived))+
    geom_bar(width = 1)+
    facet_wrap(~Pclass + Title)+
    xlab("SibSp")+
    ylab("Total")+
    labs(fill="Sobreviveu")

## Muitos levels, sem significancia -> transformar em str(ing).
data.combined$Ticket <- as.character(data.combined$Ticket)
data.combined$Ticket[1:20]

## Procurando um padrao; coletaremos apenas o primeiro caracter do Ticket.
ticket.prim.carac <- ifelse(data.combined$Ticket == "", NA, substr(data.combined$Ticket, 1, 1)) ## => ?substr || substr(x,start,stop)
## Temos 16 entradas ao todo, unicas
unique(ticket.prim.carac)
length(unique(ticket.prim.carac)) # => 16

## Agora, podemos utilizar esses dados para observar padroes com as
## classes de Tickets
data.combined$Ticket.first.char <- as.factor(ticket.prim.carac)

ggplot(data.combined[1:nrow(train),], aes(x= Ticket.first.char, fill=Survived))+
    facet_wrap(~ Title)+ #Variar com Pclass
    geom_bar()+
    xlab("Ticket")+
    ylab("Quantidade")+
    ylim(0,350)+
    labs(fill="Sobreviveram")

## Parece que o que o Ticket pode nos fornecer de informacao ja eh
## contido em outros fatores.

## Pelo princípio de parcimonia (Occam's razor), nao utilizaremos esse
## fator em nossa analise


### Analisaremos o factor Fare, agora (valor pago no ticket)
summary(data.combined$Fare) #=> distribuição skew alto
length(unique(data.combined$Fare))

## Plot de Valor vs Frequencia

ggplot(data.combined[1:nrow(train),], aes(x=Fare))+
    geom_histogram(binwidth = 5)+
    ## facet_wrap(~Pclass)+
    ggtitle("Distribuição conjunta de valores pagos no Ticket")+
    xlab("Valor do Ticket")+
    ylab("Frequência")+
    ylim(0,200)



ggplot(data.combined[1:nrow(train),], aes(x=Fare, fill=Survived))+
    geom_histogram(binwidth = 5)+
    facet_wrap(~Pclass)+
    ggtitle("Distribuição conjunta de valores pagos no Ticket")+
    xlab("Valor do Ticket")+
    ylab("Frequência")+
    ylim(0,200)

## Não parece linear, nem simples de se analisar.
## Podemos fazer modelos com, e sem, esse fator e ver a capacidade de
## predicao. Principalmente, porque os numeros eram arbitrarios a
## algum tipo de logica organizativa do Titanic


## Vamos dar uma olhada em Cabin
str(data.combined$Cabin)
data.combined$Cabin[1:100] #=> muitos valores sem dados sobre Cabin |
                                        #provavelmente tem a ver com
                                        #3ra classe.

data.combined$Cabin <- as.character(data.combined$Cabin)
## Afunilando os dados, como em Ticket
data.combined[which(data.combined$Cabin == ""), "Cabin"] <- "U" #=>undefined
data.combined$Cabin[1:100]

cabin.prim.caracter <- as.factor(substr(data.combined$Cabin,1,1))
str(cabin.prim.caracter)

## filtrando o primeiro caracter
data.combined$Cabin.first.char <- cabin.prim.caracter

## Plot Cabine vs Sobrevivencia
ggplot(data.combined[1:nrow(train),], aes(x=Cabin.first.char, fill=Survived))+
    geom_bar()+
    ggtitle("Cabine vs Sobrevivencia")+
    xlab("Inicial da Cabine")+
    ylab("Frequência")+
    labs(fill="Sobreviveram")

## Descriminar, conjutamente, por classes
## Plot Cabine, Classe vs Sobrevivencia
ggplot(data.combined[1:nrow(train),], aes(x=Cabin.first.char, fill=Survived))+
    facet_wrap(~Pclass)+
    geom_bar()+
    ggtitle("Cabine vs Sobrevivencia")+
    xlab("Inicial da Cabine")+
    ylab("Frequência")+
    labs(fill="Sobreviveram")

## Parece explicar o que outras variáveis ja fazem


## Consequencia de estar numa cabine multipla
data.combined$Cabin.multiple <- as.factor(ifelse(str_detect(data.combined$Cabin, " "), "Y","N"))


ggplot(data.combined[1:nrow(train),], aes(x=Cabin.multiple, fill=Survived))+
    facet_wrap(~Pclass + Title)+
    geom_bar()+
    ggtitle("Cabine multipla, Pclasse, Titulo vs Sobrevivencia")+
    xlab("Cabine mutilpla")+
    ylab("Frequencia")+
    labs(fill="Sobreviveram")

### => não parece promissor, quanto ao poder explicativo


## Analise do Fator Ponto de embarcacao

##
str(data.combined$Embarked)
levels(data.combined$Embarked)
data.combined$Title

## Visual
ggplot(data.combined[1:nrow(train),], aes(x=Embarked, fill=Survived))+
    facet_wrap(~Pclass + Title)+
    geom_bar()+
    ggtitle("Local Embarcacao, Pclasse, Titulo vs Sobrevivencia")+
    xlab("Local Embarcacao")+
    ylab("Frequencia")+
    labs(fill="Sobreviveram")


## Aparentemente nao muito explicativo
############ TITANIC
######## ------------------------- ############
## Anterior: filtragem de Fatores; Tratamento de dados

###############################################
##                                            #
## RANDOM FOREST                              #
##                                            #
###############################################
###### BIBLIOTECA(S): randomForest
library(randomForest)

#################
## Treinar modelos com V.a. Pclass, Title; SibSp e Parch, ou
## Family.size ||| Dados continham 11 variaveis ao todo
#################

## Comecamos usando apenas Pclass e Title
rf.treino.1 <- data.combined[1:nrow(train),c("Pclass", "Title")]
rf.label <- as.factor(train$Survived)

set.seed(1234)
rf.1 <- randomForest(x = rf.treino.1, y = rf.label, importance = TRUE, ntree=1000)

##importance=TRUE -> informacoes extras (verbosa) sobre o como o
## processo do treinamento se deu.

rf.1

varImpPlot(rf.1)
## Title mais importante que Pclass, em predicao

## Nomeclatura OOB = Out-of-bag => erro medio cometido nas subamostragens semi-aleatorias

## OOB estimate of  error rate: 20.99%
## Confusion matrix:
##     0   1 class.error
## 0 536  13  0.02367942 => erro associado ah classificacao de mortos
## 1 174 168  0.50877193 => erro associado ah classificacao de sobreviventes


##
## Treinar uma Random Forest, usando Pclass, Title e SibSp
rf.treino.2 <- data.combined[1:891, c("Pclass", "Title", "SibSp")]

set.seed(1234)
rf.2 <- randomForest(x = rf.treino.2, y = rf.label, importance = TRUE, ntree=1000)
rf.2
varImpPlot(rf.2)

## OOB estimate of  error rate: 19.53%
## Confusion matrix:
##     0   1 class.error
## 0 487  62   0.1129326
## 1 112 230   0.3274854

## Aumento de predicao de quem sobrevive, (pequena) perca de precisao
## de quem morre

##
## Treinar uma Random Forest, usando Pclass, Title e Parch
rf.treino.3 <- data.combined[1:891, c("Pclass", "Title", "Parch")]

set.seed(1234)
rf.3 <- randomForest(x = rf.treino.3, y = rf.label, importance = TRUE, ntree=1000)
rf.3
varImpPlot(rf.3)


## OOB estimate of  error rate: 20.09%
## Confusion matrix:
##     0   1 class.error
## 0 501  48  0.08743169
## 1 131 211  0.38304094


## Treinar uma Random Forest, usando Pclass, Title e Parch, SibSp
rf.treino.4 <- data.combined[1:891, c("Pclass", "Title", "Parch", "SibSp")]

set.seed(1234)
rf.4 <- randomForest(x = rf.treino.4, y = rf.label, importance = TRUE, ntree=1000)
rf.4
varImpPlot(rf.4)

## OOB estimate of  error rate: 18.86%
## Confusion matrix:
##     0   1 class.error
## 0 489  60   0.1092896
## 1 108 234   0.3157895


## Vamos criar um novo Factor que junta Parch e SibSp, o qual mede
## qual é o tamanho da familia a bordo.

temp.sibsp <- c(train$SibSp, test$SibSp) ## combinando os dados do
## treino e teste
temp.parch <- c(train$Parch, test$Parch) ##idem
## Variavel tamanho-da-familia
data.combined$Family.size <- as.factor(temp.sibsp + temp.parch + 1)

## Treinar uma Random Forest, usando Pclass, family.size
rf.treino.5 <- data.combined[1:891, c("Pclass", "Title", "Family.size")]

set.seed(1234)
rf.5 <- randomForest(x = rf.treino.5, y = rf.label, importance = TRUE, ntree=1000)
rf.5
varImpPlot(rf.5)


## OOB estimate of  error rate: 18.18%
## Confusion matrix:
##     0   1 class.error
## 0 486  63   0.1147541
## 1  99 243   0.2894737


## => menor erro que obtemos ateh o momento
## => acuracia de 81.82%!
## Top 350 Kraggle (~19.000 times) <=> top 5%

## ---------- Se colocarmos conjuntamente tamanho da familia, com
## SibSp e Parch, obtemos um pior resultado---- ###
## (Principio da parcimonia)


## Modelo 1, Classe e Titulo

## OOB estimate of  error rate: 20.99%
## Confusion matrix:
##     0   1 class.error
## 0 536  13  0.02367942 => erro associado ah classificacao de mortos
## 1 174 168  0.50877193 => erro associado ah classificacao de sobreviventes

## Modelo 2, Classe, Titulo e irmaos-primos-filhos-netos-etc (SibSp)

## OOB estimate of  error rate: 19.53%
## Confusion matrix:
##     0   1 class.error
## 0 487  62   0.1129326
## 1 112 230   0.3274854

## Modelo 3, Classe, Titulo, pais-tios-avos-etc (Parch)

## OOB estimate of  error rate: 20.09%
## Confusion matrix:
##     0   1 class.error
## 0 501  48  0.08743169
## 1 131 211  0.38304094

## Modelo 4, Classe, Titulo, SibSp, Parch

## OOB estimate of  error rate: 18.86%
## Confusion matrix:
##     0   1 class.error
## 0 489  60   0.1092896
## 1 108 234   0.3157895 => muito melhor predicao

## Definimos a variavel "tamanho de familia" SibSp+Parch+1
## Modelo 5, Classe, Titulo, Family.size

## OOB estimate of  error rate: 18.18% => melhor erro!
## Confusion matrix:
##     0   1 class.error
## 0 486  63   0.1147541
## 1  99 243   0.2894737

## Obs: modelos com SibSp, Parch e Family.size fizem o modelo predizer
## menos. => Principio da parcimonia.




####################
####### Preparando os dados para o Kaggle
###################

## Subset dos dados para predicao
test.submit.df <- data.combined[892:nrow(data.combined), c("Pclass", "Title", "Family.size")]

## Fazendo as predicoes, usando o modelo 5 de Random Forest
rf.5.preds <- predict(rf.5, test.submit.df)
table(rf.5.preds)

## Deixar em formato CSV, com duas colunas
submit.df <- data.frame(PassengerId = rep(892:nrow(data.combined)), Survived = rf.5.preds)

write.csv(submit.df, file = "./RF_02122020_1.csv", row.names = FALSE)
nrow(submit.df)


######### 77.99% obtido, em relacao aos 81.82% esperados. Ainda sim, um otimo resultado.

############################
###### Cross-Validacao #####
############################

## BIBLIOTECAS
library(caret) ## => Classification And REgression Training
## library(doSNOW) #=> Multithread Mac e Windows
library(doParallel) #=> Multithread Linux
library(parallel) #=> pacote generico do R, para comandar multithread


###### Book: Applied Predictive Modeling -> autores do pacote caret ######

########################## CROSS-VALIDATION #################
####### 10 subamostragens, 10 vezes
set.seed(1000)
cv.10.folds <- createMultiFolds(rf.label, k=10, times=10) ##  particao dos dados

## table(rf.label)
## 0   1
## 549 342

## table( rf.label[ cv.10.folds[[33]] ] )
## 0   1
## 494 308


ctrl.1 <- trainControl(method="repeatedcv", number=10, repeats=10, index = cv.10.folds)

##### Utilizar computacao paralela do computador
#### Mac/windows
## cl <- makeCluster(6, type = "SOCK") #Escolher dependendo do valor detectCores()
## registerDoSNOW(cl)

#### Linux
cl <- makeCluster((2*detectCores()/3), type="SOCK")
registerDoParallel(cl)

set.seed(999)
## Primeiro codigo de cross validacao (cv)
rf.5.cv.1 <- train(x = rf.treino.5, y= rf.label, method = "rf", tuneLength=3, ntree=1000, trControl = ctrl.1)

rf.5.cv.1 #=>

## mtry  Accuracy   Kappa
## 2     0.8104346  0.5888406
## 3     0.8076279  0.5816135


stopCluster(cl)
## =>

## Ainda muito otimista




############# --------- ### ------------  ###############
########## CV, 5-fold (menos dados de treino, mais de teste) #####

set.seed(1000)
cv.5.folds <- createMultiFolds(rf.label, k=5, times=12)

ctrl.2 <- trainControl(method="repeatedcv", number=5, repeats=10, index = cv.5.folds)

cl <- makeCluster(6, type="SOCK")
registerDoParallel(cl)
                                        #<<machine learning code goes in here>>

set.seed(999)
## Primeiro codigo de cross validacao (cv)
rf.5.cv.2 <- train(x = rf.treino.5, y= rf.label, method = "rf", tuneLength=3, ntree=1000, trControl = ctrl.2)

#=>
## mtry  Accuracy   Kappa
## 2     0.8140474  0.5982693
## 3     0.8103058  0.5895262


## A cross-validacao ficou ainda mais otimista, com samples para testes maiores, e treinos menores.

stopCluster(cl)
