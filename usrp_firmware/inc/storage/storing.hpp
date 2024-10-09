#ifndef STORING_HPP
#define STORING_HPP

#include <iostream>
#include <vector>
#include <complex>
#include <highfive/highfive.hpp>
#include <highfive/H5Easy.hpp>
#include "processing/SFCW.hpp"

////! Following example from here: https://github.com/BlueBrain/HighFive/blob/master/src/examples/create_datatype.cpp
//HighFive::CompoundType create_compound_SFCW_SWEEP(){
//    return{
//        {"sweepID",HighFive::create_datatype<int>()},
//        {"sweepStartTime",HighFive::create_datatype<double>()}
//    };
//}
//
//HIGHFIVE_REGISTER_TYPE(DSP::SFCW::SFCW_SWEEP,create_compound_SFCW_SWEEP)
namespace storage{

    HighFive::File createEmptyH5CommitDataTypes(std::string fileNameNoExt);

    /// @brief Generates a string representing the experiment based off the current dateTime as well as the modulation scheme for the SFCW experiment
    /// @return 
    std::string generateExperimentTitle();

    bool appendIQMatrixToDatasetSeparated(std::string fileName, std::string datasetPath,const IQ_2D& IQ_mat);

    /// @brief Will append 2D matrices of IQ data to a 3D matrix of IQ data. The first call will set up the dataset and subsequent calls will append. The dimensions of subsequent matrices must match that of the original
    /// @param fileName path to already created H5 file (no extension) 
    /// @param datasetPath path to dataset within H5 file
    /// @param sweepMat a 2D vector of complex<double> values
    /// @return bool representing success or not
    bool appendIQMatrixToDataset(std::string fileName, std::string datasetPath,const IQ_2D sweepMat);

    /// @brief Will append 1D matrices of IQ data to a 2D vector of IQ data. The first call will set up the dataset and subsequent calls will append. The dimensions of subsequent matrices must match that of the original
    /// @param fileName path to already created H5 file (no extension) 
    /// @param datasetPath path to dataset within H5 file
    /// @param sweepMat a 1D vector of complex<double> values
    /// @return bool representing success or not
    bool appendIQVecToDataset(std::string fileName, std::string datasetPath,const IQ_1D sweepVec);

    template <typename attributeDataType>
    void attachAttributeToDataset(std::string fileNameNoExt, std::string datasetPath, std::string attributeTitle, attributeDataType attributeValue);

    /// @brief Creates a (non-extensible) dataset in an h5 file from the data given to it
    /// @param dataVector 2D matrix of complex data
    /// @param fileNameNoExt 
    /// @param dataSetName 
    void dumpComplexMatrixtoHDF(std::vector<std::vector<std::complex<double>>> dataVector, std::string fileNameNoExt, std::string dataSetName);

    template<typename precision>
    void dumpComplexVectortoHDF(std::vector<std::complex<precision>> dataVector, std::string fileNameNoExt, std::string dataSetName);

    template<typename precision>
    void dumpVectortoHDF(std::vector<precision> dataVector, std::string fileNameNoExt, std::string dataSetName);

    /// @brief Fetches a 2D complex matrix (slice) from a 3D complex<double> dataset in an H5 file. 
    /// @param fileName path to already created H5 file (no extension) 
    /// @param datasetName path to dataset within H5 file
    /// @param sliceNum 
    /// @return a 2D vector of complex<double> from the dataset
    IQ_2D read2DIQMatFrom3DDataset(std::string fileName, std::string datasetName, int sliceNum);

    /// @brief Test function for testing H5 storage
    void testWritingAndReadingMatWithDummyData();

    /// @brief same as appendIQMatrixToDataset except using doubles instead of complex<double>
    /// @param fileName path to already created H5 file (no extension) 
    /// @param datasetPath path to dataset within H5 file
    /// @param sweepMat a 2D vector of double values
    /// @return bool representing success or not
    bool appendDoubleMatrixToDataset(std::string fileName, std::string datasetPath,const std::vector<std::vector<double>> sweepMat);

}// namespace storage



#endif