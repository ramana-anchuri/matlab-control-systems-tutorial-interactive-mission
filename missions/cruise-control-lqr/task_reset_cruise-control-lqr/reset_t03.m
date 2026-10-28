% Restore tasks 1-2 before resuming task 3.
reset_t02;
cruiseTime = (0:0.01:12)';
openVelocity = step(500*cruisePlant, cruiseTime);
figure('Name', 'Original cruise-control response');
plot(cruiseTime, openVelocity);
xlabel('Time (s)');
ylabel('Speed (m/s)');
