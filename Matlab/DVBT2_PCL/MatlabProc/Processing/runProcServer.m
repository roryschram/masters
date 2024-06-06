%% Copy ARDs over
function runProcServer()
addpath('./OutputRCF/TwoTargets3')
fprintf('\nCANCELLED_SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged: ');
unix('ssh stephen@procserv.ee.uct.ac.za ~./Simulations/DVBT/CudaProcServer_orig UCTconstantia.conf CANCELLED_SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.rcf; mv ARDs/1970-01-01T02.00.00.000000.ard ARDs/CANCELLED_SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.ard', '-echo');
fprintf('\nSimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged: ');
unix('ssh stephen@procserv.ee.uct.ac.za ~./Simulations/DVBT/CudaProcServer_orig UCTconstantia.conf SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.rcf; mv ARDs/1970-01-01T02.00.00.000000.ard ARDs/SimulatedTarget_test20_CPI2_GuardUnchanged_PilotsUnchanged.ard', '-echo');
fprintf('\nSimulatedTarget_test20_refNormalised_survTarget_survCancelled: ');
unix('ssh stephen@procserv.ee.uct.ac.za ~./Simulations/DVBT/CudaProcServer_orig UCTconstantia.conf SimulatedTarget_test20_refNormalised_survTarget_survCancelled.rcf; mv ARDs/1970-01-01T02.00.00.000000.ard ARDs/SimulatedTarget_test20_refNormalised_survTarget_survCancelled.ard', '-echo');
fprintf('\nCopying to: ');
unix('pwd');
fprintf('\n');
unix('scp -r stephen@procserv.ee.uct.ac.za:~/Simulations/ ARDs/', '-echo');
unix('ssh stephen@procserv.ee.uct.ac.za:~/Simulations/ rm -R ARDs/', '-echo');
