#include <uhd/usrp/multi_usrp.hpp>
#include <vector>

namespace tests{

    int transmitSingleFreq(uhd::usrp::multi_usrp::sptr tx_usrp);
 
    void timeFreqSwitch(uhd::usrp::multi_usrp::sptr tx_usrp,int signalLength, int freqIncHz, int numIncrements);

}//namespace tests