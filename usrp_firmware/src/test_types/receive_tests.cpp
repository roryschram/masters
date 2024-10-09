#include "test_types/receive_tests.hpp"
#include "utilities/utilities.hpp"
#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/config_reader.hpp"
#include <iostream>
#include "hardware/RX_Funcs.hpp"

namespace tests{
    
    int captureSingleFreqToFile(uhd::usrp::multi_usrp::sptr rx_usrp, std::string precision, size_t numSamples, std::string outputFile, double settling_time){

        //check if file exists
        UTIL::fileAlreadyExists(&outputFile,"bin");

        // the need for separate recv functions can (and should) be solved with a templated receive function
        double TX_freq = rx_usrp->get_tx_freq();
        std::cout<<"\nTransmit Frequency: " << TX_freq << "\n";
        double RX_freq = rx_usrp->get_rx_freq();
        std::cout<<"\nReceive Frequency: " << RX_freq << "\n";

        // recv to file
        if (precision == "double"){
            RX::recv_to_file_doubles(rx_usrp,outputFile,numSamples,settling_time,true); //TODO: set up metadata dept config parameter
            return 0;
            //
        }/*else if (type == "float"){
            UTIL::recv_to_file<std::complex<float>>(rx_usrp, "fc32", "sc16", CONFIG::OUTPUT_FILE, 0, total_num_samps, 1, 0,pstop_signal);
        }else if (type == "short"){
            UTIL::recv_to_file<std::complex<short>>(rx_usrp, "sc16", "sc16", CONFIG::OUTPUT_FILE, 0, total_num_samps, 1, 0,pstop_signal);
        }*/else {
            // clean up transmit worker
            throw std::runtime_error("Unknown type " + precision);
        }
        return 0;
    }

} // namespace test_types