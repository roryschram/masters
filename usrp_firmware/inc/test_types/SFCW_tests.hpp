#ifndef SFCW_TESTS_HPP
#define SFCW_TESTS_HPP
#include <uhd/usrp/multi_usrp.hpp>
#include "processing/SFCW.hpp"
namespace tests{
    namespace SFCW{
        
        /// @brief Runs a SFCW sweep based on the parameters given and returns a 2D matrix [stepsPerFreq,numFreqSteps] of IQ values 
        /// @param usrp 
        /// @param TransmitSignal This will be the signal transmitted for every step
        /// @param numsteps number of steps to use in the sweep
        /// @param stepSizeHz increment to be added to each step
        /// @param stepTimes vector of times at which each step should start
        /// @return 
        std::vector<std::vector<std::complex<double>>> performSweep(uhd::usrp::multi_usrp::sptr usrp, std::vector<std::complex<double>> TransmitSignal, int numsteps, double stepSizeHz, std::vector<double> stepTimes);

        /// @brief The main function for actually running an SFCW experiment. 
        /// @param usrp 
        /// @param numSweeps 
        /// @return 
        bool performNSweepsAndStore(uhd::usrp::multi_usrp::sptr usrp ,int numSweeps);

    }// namespace SFCW

}// namespace tests


#endif