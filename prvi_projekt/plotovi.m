figure(1);
plot(1:16, squeeze(postoci(1,1,:))', '-o', 1:16, squeeze(postoci(1,2,:))', '-*', 1:16, squeeze(postoci(1,3,:))', '-d');
xlabel('broj baznih vektora'); ylabel('postotak uspjesnosti');
legend('32x32', '32x48', '32x64');

figure(2);
plot(1:16, squeeze(postoci(2,1,:))','-o', 1:16, squeeze(postoci(2,2,:))','-*', 1:16, squeeze(postoci(2,3,:))', '-d');
legend('48x32', '48x48', '48x64');
xlabel('broj baznih vektora'); ylabel('postotak uspjesnosti');


figure(3);
plot(1:16, squeeze(postoci(3,1,:))', '-o',1:16, squeeze(postoci(3,2,:))','-*', 1:16, squeeze(postoci(3,3,:))','-d');
legend('64x32', '64x48', '64x64');
xlabel('broj baznih vektora'); ylabel('postotak uspjesnosti');