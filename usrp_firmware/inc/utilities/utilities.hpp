#ifndef UTILITIES_HPP
#define UTILITIES_HPP

#include <iostream>
#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/config_constants.hpp"
#include <boost/format.hpp>
#include <regex>
#include <thread>
#include <boost/filesystem.hpp>
#include <filesystem>


/// @brief 
namespace UTIL{    
    
    bool fileAlreadyExists(std::string *pfilename, std::string extensionNoDot);

    std::vector<std::complex<double>> generateLinearSweep(double sampleRate, int signalLength, double startFrequency, double endFrequency);

    std::vector<double> linspace(double start, double end, int num);

    void printVecSize_t(std::vector<size_t> vec);

    void printIQMatrix(std::vector<std::vector<std::complex<double>>> mat);

}//UTIL

#endif