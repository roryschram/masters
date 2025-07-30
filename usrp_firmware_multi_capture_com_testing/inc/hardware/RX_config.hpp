#ifndef RX_CONFIG_HPP
#define RX_CONFIG_HPP

#include <uhd/usrp/multi_usrp.hpp>

namespace RX{

    bool setRXFreqHz(uhd::usrp::multi_usrp::sptr rx_usrp, double newRXFreqHz);

    bool confirmRxOscillatorsLocked(uhd::usrp::multi_usrp::sptr usrp_object, std::string ref_source);


    int setupReceiever(uhd::usrp::multi_usrp::sptr tx_usrp);

    bool incrementRxFreq(uhd::usrp::multi_usrp::sptr rx_usrp, double incrementFreqHz);

}//namespace RX


#endif