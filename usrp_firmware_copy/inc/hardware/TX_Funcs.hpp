#ifndef TX_FUNCS_HPP
#define TX_FUNCS_HPP
#include <vector>
#include <uhd/usrp/multi_usrp.hpp>

namespace TX{

    void transmitDoublesAtTime(uhd::usrp::multi_usrp::sptr tx_usrp, std::vector<std::complex<double>> buffers, double secondsInFuture);

    void transmitShortsAtTime(uhd::usrp::multi_usrp::sptr tx_usrp, std::vector<std::complex<short>> buffers, double secondsInFuture);

    void endBurst(uhd::usrp::multi_usrp::sptr tx_usrp,uhd::tx_streamer::sptr tx_stream);

} // namespace TX


#endif