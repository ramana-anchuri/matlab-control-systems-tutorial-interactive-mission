% Restore tasks 1-4 before resuming task 5.
reset_t04;
lqrGain = lqr(cruisePlant, 1000, 0.1);
cruiseClosedLoop = ss(cruisePlant.A-cruisePlant.B*lqrGain, ...
    cruisePlant.B, cruisePlant.C, cruisePlant.D);
cruiseClosedLoop = cruiseClosedLoop/dcgain(cruiseClosedLoop);
