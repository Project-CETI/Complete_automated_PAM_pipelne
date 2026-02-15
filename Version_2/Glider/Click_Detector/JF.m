function I=JF(V)

I=((sum(V,2)).^2)./(size(V,2)*sum(V.^2,2));

end