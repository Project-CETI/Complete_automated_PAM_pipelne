function M_criterion=Slice_sum(All_clusters,AllCombs,Nc)
   
   M=All_clusters(AllCombs(:,1),:);
   
   for i=2:Nc
       M=M+All_clusters(AllCombs(:,i),:);      
   end
   
  M_criterion= max(M,[],2);
   
   
end