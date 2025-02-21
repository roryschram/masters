#ifndef TX_CONFIG_HPP
#define TX_CONFIG_HPP

#include <uhd/usrp/multi_usrp.hpp>

namespace TX{
    bool confirmTxOscillatorsLocked(uhd::usrp::multi_usrp::sptr usrp_object, std::string ref_source);

    int setupTransmitter(uhd::usrp::multi_usrp::sptr tx_usrp);

    bool setTxFreqHz(uhd::usrp::multi_usrp::sptr tx_usrp, double newTxFreqHz);

    bool incrementTxFreqHz(uhd::usrp::multi_usrp::sptr tx_usrp, double freqIncHz);
    
}// namespace TX
    


#endif
