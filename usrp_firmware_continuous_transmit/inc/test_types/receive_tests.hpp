#include <uhd/usrp/multi_usrp.hpp>

namespace tests{

    

    int captureSingleFreqToFile(uhd::usrp::multi_usrp::sptr rx_usrp, std::string precision, size_t numSamples, std::string outputFile,double settling_time);


}//namespace tests