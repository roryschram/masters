#include <iostream>
#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/config_constants.hpp"
#include "utilities/config_reader.hpp"
#include "utilities/utilities.hpp"
#include <boost/format.hpp>
#include <regex>
#include <thread>
#include <fstream>
#include <filesystem>
#include <vector>
#include <cmath>
#include <boost/filesystem.hpp>
#include <highfive/highfive.hpp>
#include <highfive/H5Easy.hpp>


namespace UTIL{
    
    
    bool fileAlreadyExists(std::string *pfilename, std::string extensionNoDot)
    {
        std::string fullpath=*pfilename+"."+extensionNoDot;
        if (std::filesystem::exists(fullpath)) {
            std::cout << "File already exists, renaming...\n";
            *pfilename=*pfilename+"_1";
            fileAlreadyExists(pfilename,extensionNoDot);
            return false;
        } else {
            return true;
        } 
    }

    std::vector<std::complex<double>> generateLinearSweep(double sampleRate, int signalLength, double startFrequency, double endFrequency){

        std::vector<std::complex<double>> result;
        result.reserve(signalLength);

        for (int i = 0; i < signalLength; ++i) {
            double t = static_cast<double>(i) / sampleRate;
            double frequency = startFrequency + (endFrequency - startFrequency) * i / signalLength;
            double phase = 2.0 * M_PI * frequency * t;
            std::complex<double> sample(0.8*std::cos(phase), 0);
            result.push_back(sample);
        }

        return result;
    }
    
    std::vector<double> linspace(double start, double end, int num) {
        std::vector<double> result;

        if (num <= 0) {
            return result;
        }

        if (num == 1) {
            result.push_back(start);
            return result;
        }

        double step = (end - start) / (num - 1);

        for (int i = 0; i < num; ++i) {
            result.push_back(start + i * step);
        }

        return result;
    }

    void printVecSize_t(std::vector<size_t> vec){
        for(int i=0;i<vec.size();i++){
            std::cout<<vec[i]<<", ";
        }
        std::cout<<std::endl;
        return;
    }

    void printIQMatrix(std::vector<std::vector<std::complex<double>>> mat){
        for (int row=0;row<mat.size();row++){
            for (int col=0;col<mat[0].size();col++){
                std::cout<<"{"<<mat[row][col].real()<<","<<mat[row][col].imag()<<"}, ";
            }
            std::cout<<"\n";
        }
    }


}//namespace UTIL
