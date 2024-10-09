#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/utilities.hpp"

namespace tests{
    /// @brief NOTE: Should rather use transmitAndReceiveToH5. Loopback function which will will transmit a given vector and receive a synchronised signal to a file. 
    /// @param usrp  USRP with all center frequencies, sample rates, bandwidths, ETC already configured 
    /// @param TransmitSignal Vector of complex doubles (not templated for other precisions) to be transmitted. 
    /// @param fileName filename to be received to (will be a .bin). This file should not exist yet. 
    /// @param storeMetaData Flag to store metadata in a txt file. Currently this is not operational 
    /// @param settling_time Time to wait before tx and rx. 
    void transmitAndReceiveToFile(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, bool storeMetaData,double settling_time);
    
    /// @brief Loopback function which will will transmit a given vector and receive a synchronised signal to a file.
    /// @param usrp USRP with all center frequencies, sample rates, bandwidths, ETC already configured 
    /// @param TransmitSignal Vector of complex doubles (not templated for other precisions) to be transmitted
    /// @param fileName filename of the .h5 file. Should exist but be empty. 
    /// @param dataSetName name of the vector dataset 
    /// @param storeMetaData Currently doesnt do anything
    /// @param settling_time Time to wait before tx and rx.
    void transmitAndReceiveToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, std::string dataSetName, bool storeMetaData, double settling_time);


    /// @brief Barebones test of downmixing a Oversampled IF frequency. Stores the following vectors: (complex)Received, downmixSig, singleChannel, mixedSignal 
    /// @param usrp 
    /// @param TransmitSignal 
    /// @param fileName 
    /// @param settling_time 
    void transmitReceiveDownmixToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, std::string fileName, double settling_time);


    void steppedFreqDumpToH5(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, int numsteps, double stepSizeHz,std::string fileName);

}// namespace tests