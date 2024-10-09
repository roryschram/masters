#include "test_types/loopback.hpp"
#include <uhd/usrp/multi_usrp.hpp>
#include "hardware/TX_config.hpp"
#include "hardware/TX_Funcs.hpp"
#include "hardware/RX_config.hpp"
#include "hardware/RX_Funcs.hpp"
#include "utilities/config_reader.hpp"
#include "utilities/utilities.hpp"
#include <thread>
#include "test_types/transmit_tests.hpp"
#include "test_types/receive_tests.hpp"
#include "processing/DSP.hpp"
#include "storage/storing.hpp"

namespace tests{
    void transmitAndReceiveToFile(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, bool storeMetaData, double settling_time){
        usrp->set_time_now(uhd::time_spec_t(0.0));

        std::thread transmit_thread([&]() {
            TX::transmitDoublesAtTime(usrp,TransmitSignal,settling_time);
        });

        captureSingleFreqToFile(usrp,"double",TransmitSignal.size(),fileName,settling_time);
        transmit_thread.join();
    }

    void transmitAndReceiveToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, std::string dataSetName, bool storeMetaData, double settling_time){
        usrp->set_time_now(uhd::time_spec_t(0.0));

        std::thread transmit_thread([&]() {
            TX::transmitDoublesAtTime(usrp,TransmitSignal,2.00);
        });

        //size_t receive_length = 40000;
        std::vector<std::complex<double>> receieved= RX::captureDoubles(usrp,CONFIG::NUM_SAMPS,2.00);
        transmit_thread.join();

        storage::dumpComplexVectortoHDF(receieved,fileName,dataSetName);

        double TX_freq = usrp->get_tx_freq();
        std::cout<<"\nTransmit Frequency: " << TX_freq << "\n";
        double RX_freq = usrp->get_rx_freq();
        std::cout<<"\nReceive Frequency: " << RX_freq << "\n";
    }

    void transmitReceiveDownmixToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, double settling_time){
        // actually get signals
        usrp->set_time_now(uhd::time_spec_t(0.0));
        std::thread transmit_thread([&]() {
            TX::transmitDoublesAtTime(usrp,TransmitSignal,settling_time);
        });
        std::vector<std::complex<double>> receieved= RX::captureDoubles(usrp,TransmitSignal.size(),settling_time);
        transmit_thread.join();

        // get parameters for mixing signal
        double TX_freq = usrp->get_tx_freq();
        double RX_freq = usrp->get_rx_freq();
        double mixFreq=abs(TX_freq-RX_freq);
        double TX_sampleRate=usrp->get_tx_rate();
        double RX_sampleRate=usrp->get_rx_rate();
        

        // downmix        
        std::vector<double> singleChannel = DSP::extractChannelFromIQ_d(receieved,0);
        std::vector<std::vector<double>> IQ = DSP::digitalDemodulateToIQ(singleChannel,mixFreq,TX_sampleRate,0.0);

        

        // store
        storage::dumpComplexVectortoHDF(TransmitSignal,fileName,"transmit");
        storage::dumpComplexVectortoHDF(receieved,fileName,"received");
        storage::dumpVectortoHDF(singleChannel,fileName,"singleChannel");
        storage::dumpVectortoHDF(IQ[0],fileName,"mixedSignalI");
        storage::dumpVectortoHDF(IQ[1],fileName,"mixedSignalQ");

        return;

    }

    std::vector<std::vector<std::complex<double>>> steppedFreqToIQMatrix(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, int numsteps, double stepSizeHz){
        usrp->set_time_now(uhd::time_spec_t(0.0));
        double incrementTime=0.009; //! should probably not be done this way. I think better to schedule the start of the transmits. 
        std::vector<std::vector<std::complex<double>>> allSamples;

        for (int i=0;i<numsteps;i++){
            std::thread transmit_thread([&]() {
                TX::transmitDoublesAtTime(usrp,TransmitSignal,usrp->get_time_now().get_real_secs()+incrementTime);
            });
            allSamples.push_back(RX::captureDoubles(usrp,TransmitSignal.size(),usrp->get_time_now().get_real_secs()+incrementTime));  
            transmit_thread.join();
            TX::incrementTxFreqHz(usrp,stepSizeHz);
            RX::incrementRxFreq(usrp, stepSizeHz);
        }

        return allSamples;
    }

    void steppedFreqDumpToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, int numsteps, double stepSizeHz,std::string fileName){
        std::cout<<"Performing stepped freq test with "<<numsteps<<" steps\n";
        std::vector<std::vector<std::complex<double>>> IQ_mat = steppedFreqToIQMatrix(usrp,TransmitSignal,numsteps,stepSizeHz);
        std::vector<std::complex<double>> IQ_vec = DSP::processHomodyneSweepMat(IQ_mat);
        storage::dumpComplexVectortoHDF(IQ_vec,fileName,"sweep");
        return;
    }

}// namespace tests