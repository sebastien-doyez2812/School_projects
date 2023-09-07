function obstacles = obs()
%je définis les bordures
obstacles(1).A = [5 45]; obstacles(1).B = [5 5];
obstacles(2).A = [45 5]; obstacles(2).B = [45 45];
obstacles(3).A = [5 45]; obstacles(3).B = [45 45];
obstacles(4).A = [5 5]; obstacles(4).B = [45 5];

%Je définis les obstacles:
obstacles(5).A = [8 20]; obstacles(5).B = [15 30];
obstacles(6).A = [8 20]; obstacles(6).B = [30 15];
obstacles(7).A = [25 25]; obstacles(7).B = [15 5];
obstacles(8).A = [40 30]; obstacles(8).B = [30 30];
obstacles(9).A = [40 40]; obstacles(9).B = [40 15];
obstacles(10).A = [10 35]; obstacles(10).B = [20 40];


%tracage des obstacles ( allant de 1 à 10)
for i=1:10
    line ([obstacles(i).A(1) obstacles(i).B(1)],[obstacles(i).A(2) obstacles(i).B(2)],'color','b','LineWidth',3);
end
end