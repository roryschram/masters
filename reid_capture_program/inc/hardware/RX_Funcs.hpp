#ifndef RX_FUNCS_HPP
#define RX_FUNCS_HPP
#include <uhd/usrp/multi_usrp.hpp>

namespace RX{

    std::vector<std::complex<double>> captureDoubles(uhd::usrp::multi_usrp::sptr rx_usrp,size_t numSamples,double settling_time);
    
    void recv_to_file_doubles(uhd::usrp::multi_usrp::sptr usrp,
    const std::string& file,
    int num_requested_samples,
    double settling_time,
    bool storeMD);


} // namesapce RX


#endif