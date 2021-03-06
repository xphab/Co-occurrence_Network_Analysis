###@author Feng Ju
###@email richieju520@gmail.com
###@cite Ju F, Xia Y, Guo F, Wang ZP, Zhang T. 2014. 
###@Taxonomic relatedness shapes bacterial assembly in activated sludge of globally distributed wastewater treatment plants.
###@Environmental Microbiology. 16(8):2421-2432

################## Correlation-based network analysis ###############################
#install.packages("vegan")
#install.packages("igraph")
#install.packages("Hmisc")

library(vegan)
library(igraph)
library(Hmisc)

co_occurrence_network<-function(matrix,cor.cutoff,p.cutoff){
  
  matrix1<-matrix
  matrix1[matrix1>0]<-1
  
  #correlation analysis based on spearman's co-efficient
  matrix.dist<-rcorr(t(matrix),type="spearman")
  ###matrix.dist<-rcorr(t(matrix),type="pearson")
  matrix.cor<-matrix.dist$r
  matrix.cor.p<-matrix.dist$P
  
  #Multiple testing correction using Benjamini-Hochberg standard false discovery rate correction ("FDR-BH")
  matrix.cor.p <- p.adjust(matrix.cor.p, method="BH")
  
  #1.Consider positive cooccurence at given coefficient (cor.cutoff) and p-value cutoffs
  matrix.cor1<-matrix.cor
  matrix.cor1.p<-matrix.cor.p
  matrix.cor1[which(matrix.cor1 <= cor.cutoff)]=0
  matrix.cor1[which(matrix.cor1.p>p.cutoff)]=0
  # delete those rows and columns with sum = 0
  matrix.cor1<-matrix.cor1[which(rowSums(matrix.cor1)!=1),]
  matrix.cor1<-matrix.cor1[,which(colSums(matrix.cor1)!=0)]
  
  #2.Consider netagive cooccurence at given coefficient (-cor.cutoff) and p-value cutoffs
  ###matrix.cor2<-matrix.cor
  ###matrix.cor2.p<-matrix.cor.p
  ###matrix.cor2[which(matrix.cor2 > (-cor.cutoff))]=0
  ###matrix.cor2[which(matrix.cor2.p>p.cutoff)]=0
  # delete those rows and columns with sum = 0
  ###matrix.cor2<-matrix.cor2[which(rowSums(matrix.cor2)!=0),]
  ###matrix.cor2<-matrix.cor2[,which(colSums(matrix.cor2)!=0)]
  
  #3.Consider both positive and netagive cooccurence at given coefficient (cor.cutoff) and p-value cutoffs
  matrix.cor3<-matrix.cor
  matrix.cor3.p<-matrix.cor.p
  matrix.cor3[which(matrix.cor3>=(-cor.cutoff) & matrix.cor3 <= cor.cutoff)]=0
  matrix.cor3[which(matrix.cor3.p>p.cutoff)]=0
  
  # delete those rows and columns with sum = 0
  matrix.cor3<-matrix.cor3[which(rowSums(matrix.cor3)!=1),]
  matrix.cor3<-matrix.cor3[,which(colSums(matrix.cor3)!=0)]
  
  # generate graph using igraph
  g1<-graph.adjacency(matrix.cor1,weight=T,mode="undirected")
  g1<-simplify(g1)
  V(g1)$label <- V(g1)$name
  V(g1)$degree <- degree(g1)
  
  ###g2<-graph.adjacency(matrix.cor2,weight=T,mode="undirected")
  ###g2<-simplify(g2)
  ###V(g2)$label <- V(g2)$name
  ###V(g2)$degree <- degree(g2)
  
  g3<-graph.adjacency(matrix.cor3,weight=T,mode="undirected")
  g3<-simplify(g3)
  V(g3)$label <- V(g3)$name
  V(g3)$degree <- degree(g3)
  
  # append the output into results
  result<-list()
  result$matrix.cor<-matrix.cor
  result$matrix.cor.p<-matrix.cor.p
  
  result$matrix.cor1<-matrix.cor1
  result$graph1<-g1
  
  ###result$matrix.cor2<-matrix.cor2
  ###result$graph2<-g2
  
  result$matrix.cor3<-matrix.cor3
  result$graph3<-g3
  return(result)
}
