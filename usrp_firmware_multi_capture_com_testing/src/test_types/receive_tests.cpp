#include "test_types/receive_tests.hpp"
#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/config_reader.hpp"
#include <iostream>
#include "hardware/RX_Funcs.hpp"

namespace tests{
    
    int captureSingleFreqToFile(uhd::usrp::multi_usrp::sptr rx_usrp, std::string precision, size_t numSamples, std::string outputFile, double settling_time){

        return 0;
    }

} // namespace test_types