mv $1 orig
sed  -e "s/^*}//" orig | sed  -e "s/^*{//" - > $1 

