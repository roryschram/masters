#include "storage/storing.hpp"
#include <iostream>
#include <string>
#include <ctime>
#include <chrono>
#include <complex>
#include <vector>
#include <highfive/highfive.hpp>
#include <highfive/H5File.hpp>
#include <highfive/H5DataSet.hpp>
#include <highfive/H5Easy.hpp>
#include "processing/SFCW.hpp"
#include <boost/multi_array.hpp>
#include "utilities/utilities.hpp"
#include "processing/SFCW.hpp"
#include "processing/DSP.hpp"
#include "utilities/config_reader.hpp"

namespace storage{

    HighFive::File createEmptyH5CommitDataTypes(std::string fileNameNoExt){
        HighFive::File expFile(fileNameNoExt+".h5",HighFive::File::Create);
        expFile.flush();
        return expFile;
    
    }

    bool appendIQMatrixToDatasetSeparated(std::string fileName, std::string datasetPath,const IQ_2D& IQ_mat){
        bool success;
        appendDoubleMatrixToDataset(fileName,datasetPath+"/I",DSP::extractChannelFromIQMat(IQ_mat,0));
        appendDoubleMatrixToDataset(fileName,datasetPath+"/Q",DSP::extractChannelFromIQMat(IQ_mat,1));
        return success;
    }

    bool appendDoubleMatrixToDataset(std::string fileName, std::string datasetPath,const std::vector<std::vector<double>> sweepMat){
        HighFive::File file(fileName+".h5",HighFive::File::ReadWrite);
        HighFive::DataSet dataset;
        
        //getting dataset
        if (file.exist(datasetPath)){
            dataset=file.getDataSet(datasetPath);
        }else{
            HighFive::DataSpace dataSpace({0,sweepMat.size(),sweepMat[0].size()},{HighFive::DataSpace::UNLIMITED,sweepMat.size(),sweepMat[0].size()});
        
            HighFive::DataSetCreateProps creationProperties;
            creationProperties.add(HighFive::Chunking(std::vector<hsize_t>{1,sweepMat.size(),sweepMat[0].size()}));
            
            dataset= file.createDataSet(datasetPath,dataSpace,HighFive::create_datatype<double>(),creationProperties);
        }

        std::vector<size_t> collectedDimensions = dataset.getSpace().getDimensions();
        size_t dim0 = collectedDimensions[0];
        size_t dim1 = collectedDimensions[1];
        size_t dim2 = collectedDimensions[2];
        
        // make sure new data has same number of columns
        if (sweepMat.size()!=dim1||sweepMat[0].size()!=dim2){
            std::cerr<<"Dimensions of new IQ data dont match current stored dimensions\n";
            std::cerr<<"dim0="<<dim0<<"\n";
            std::cerr<<"IQ_mat.size()="<<sweepMat.size()<<"  dim1="<<dim1<<"\n";
            std::cerr<<"IQ_mat[0].size()="<<sweepMat[0].size()<<"  dim2="<<dim2<<"\n";
            return false; 
        }

        //resize 
        dataset.resize({dim0+1,dim1,dim2});
        std::vector<size_t> resizedDimensions = dataset.getSpace().getDimensions();
        
        // get offsets and counts
        std::vector<size_t> offsets={dim0,0,0};
        std::vector<size_t> counts={1,dim1,dim2};
        
        std::vector<std::vector<std::vector<double>>> mat3D;
        mat3D.push_back(sweepMat);

        HighFive::Selection slice =  dataset.select(offsets,counts);        
        slice.write(mat3D);
        return true;
    }

    bool appendIQMatrixToDataset(std::string fileName, std::string datasetPath,const IQ_2D sweepMat){
        HighFive::File file(fileName+".h5",HighFive::File::ReadWrite);
        HighFive::DataSet dataset;
        
        //getting dataset
        if (file.exist(datasetPath)){
            //std::cout<<"Found Dataset\n";
            dataset=file.getDataSet(datasetPath);
        }else{
            //std::cout<<"making Dataset: "<<datasetPath<<"\n";
            HighFive::DataSpace dataSpace({0,sweepMat.size(),sweepMat[0].size()},{HighFive::DataSpace::UNLIMITED,sweepMat.size(),sweepMat[0].size()});
        
            HighFive::DataSetCreateProps creationProperties;
            creationProperties.add(HighFive::Chunking(std::vector<hsize_t>{1,sweepMat.size(),sweepMat[0].size()}));
            
            dataset= file.createDataSet(datasetPath,dataSpace,HighFive::create_datatype<std::complex<double>>(),creationProperties);
            //std::cout<<"Dataset data type: "<<dataset.getDataType().string()<<"\n";
        }

        //getting dataset dimensions
        std::vector<size_t> collectedDimensions = dataset.getSpace().getDimensions();
        size_t dim0 = collectedDimensions[0];
        size_t dim1 = collectedDimensions[1];
        size_t dim2 = collectedDimensions[2];
        //std::cout<<"Collected Dimensions: ";
        //UTIL::printVecSize_t(collectedDimensions);

        // make sure new data has same number of columns
        if (sweepMat.size()!=dim1||sweepMat[0].size()!=dim2){
            std::cerr<<"Dimensions of new IQ data dont match current stored dimensions\n";
            std::cerr<<"dim0="<<dim0<<"\n";
            std::cerr<<"IQ_mat.size()="<<sweepMat.size()<<"  dim1="<<dim1<<"\n";
            std::cerr<<"IQ_mat[0].size()="<<sweepMat[0].size()<<"  dim2="<<dim2<<"\n";
            return false; 
        }

        //resize 
        dataset.resize({dim0+1,dim1,dim2});
        std::vector<size_t> resizedDimensions = dataset.getSpace().getDimensions();

        // get offsets and counts
        std::vector<size_t> offsets={dim0,0,0};
        std::vector<size_t> counts={1,dim1,dim2};
        // annoyingly have to make a 3D matrix to store
        std::vector<std::vector<std::vector<std::complex<double>>>> mat3D;
        mat3D.push_back(sweepMat);

        HighFive::Selection slice =  dataset.select(offsets,counts);        
        slice.write(mat3D);
        return true;
    }

    bool appendIQVecToDataset(std::string fileName, std::string datasetPath,const IQ_1D sweepVec){
        HighFive::File file(fileName+".h5",HighFive::File::ReadWrite);
        HighFive::DataSet dataset;
        
        //getting dataset
        if (file.exist(datasetPath)){
            //std::cout<<"Found Dataset\n";
            dataset=file.getDataSet(datasetPath);
        }else{
            //std::cout<<"making Dataset: "<<datasetPath<<"\n";
            HighFive::DataSpace dataSpace({0,sweepVec.size()},{HighFive::DataSpace::UNLIMITED,sweepVec.size()});
        
            HighFive::DataSetCreateProps creationProperties;
            creationProperties.add(HighFive::Chunking(std::vector<hsize_t>{1,sweepVec.size()}));
            
            dataset= file.createDataSet(datasetPath,dataSpace,HighFive::create_datatype<std::complex<double>>(),creationProperties);
            //std::cout<<"Dataset data type: "<<dataset.getDataType().string()<<"\n";
        }

        //getting dataset dimensions
        std::vector<size_t> collectedDimensions = dataset.getSpace().getDimensions();
        size_t dim0 = collectedDimensions[0];
        size_t dim1 = collectedDimensions[1];
        

        // make sure new data has same number of columns
        if (sweepVec.size()!=dim1){
            std::cerr<<"Length of new IQ Vector doesnt match that of currently stored vectors dimensions\n";
            return false; 
        }

        //resize 
        dataset.resize({dim0+1,dim1});
        std::vector<size_t> resizedDimensions = dataset.getSpace().getDimensions();

        // get offsets and counts
        std::vector<size_t> offsets={dim0,0};
        std::vector<size_t> counts={1,dim1};
        // annoyingly have to make a 3D matrix to store
        std::vector<std::vector<std::complex<double>>> mat2D;
        mat2D.push_back(sweepVec);

        HighFive::Selection slice =  dataset.select(offsets,counts);        
        slice.write(mat2D);
        return true;
    }

    IQ_2D read2DIQMatFrom3DDataset(std::string fileName, std::string datasetName, int sliceNum){

        HighFive::File file(fileName+".h5",HighFive::File::ReadOnly);
        if (!file.exist(datasetName)){
            std::cerr<<"Dataset does not exist\n";
            return IQ_2D();
        }

        HighFive::DataSet dataset = file.getDataSet(datasetName);
        std::vector<size_t> dimensions = dataset.getDimensions();
        
        // check dimensions
        if (dimensions.size()!=3){
            std::cerr<<"Dataset dimensions not what expected for this function\n";
            return IQ_2D();
        }
        if(sliceNum+1>dimensions[0]||sliceNum<0){
            std::cerr<<"Slice requested is beyond extent of dataset";
            return IQ_2D();
        }


        // fetch slice
        std::vector<size_t> indices = {(size_t)sliceNum, 0,0};
        std::vector<size_t> counts = {1, dimensions[1],dimensions[2]};
        HighFive::Selection slice = dataset.select(indices,counts);

        // read into 3D mat and return first element
        IQ_3D mat3D;
        slice.read(mat3D);
        return mat3D[0];
    }

    void testWritingAndReadingMatWithDummyData(){
        std::vector<std::vector<std::complex<double>>> dummyA ={
            {{1,0},{1,0},{1,0},{1,0}},
            {{2,0},{2,0},{2,0},{2,0}},
            {{3,0},{3,0},{3,0},{3,0}}
        };
        std::vector<std::vector<std::complex<double>>> dummyB ={
            {{0,1},{0,1},{0,1},{0,1}},
            {{0,2},{0,2},{0,2},{0,2}},
            {{0,3},{0,3},{0,3},{0,3}}
        };
        std::vector<std::vector<std::complex<double>>> dummyC ={
            {{1,1},{1,1},{1,1},{1,1}},
            {{1,1},{1,1},{1,1},{1,1}},
            {{1,1},{1,1},{1,1},{1,1}}
        };
        
        appendIQMatrixToDataset("testfile","MATComp",dummyA);
        appendIQMatrixToDataset("testfile","MATComp",dummyB);
        appendIQMatrixToDataset("testfile","MATComp",dummyC);

        storage::attachAttributeToDataset("testfile","MATComp","sampsPerStep",dummyA.size());
        storage::attachAttributeToDataset("testfile","MATComp","stepsPerSweep",dummyA[0].size());

        IQ_2D dummyARead = read2DIQMatFrom3DDataset("testfile","MATComp",0);
        IQ_2D dummyBRead = read2DIQMatFrom3DDataset("testfile","MATComp",1);
        IQ_2D dummyCRead = read2DIQMatFrom3DDataset("testfile","MATComp",2);
        IQ_2D dummyDRead = read2DIQMatFrom3DDataset("testfile","MATComp",3);
        
        
        std::cout<<"Written A: \n";
        UTIL::printIQMatrix(dummyA);
        std::cout<<"Read A: \n";
        UTIL::printIQMatrix(dummyARead);
        

        std::cout<<"Written B: \n";
        UTIL::printIQMatrix(dummyB);
        std::cout<<"Read B: \n";
        UTIL::printIQMatrix(dummyBRead);

        std::cout<<"Written C: \n";
        UTIL::printIQMatrix(dummyC);
        std::cout<<"Read C: \n";
        UTIL::printIQMatrix(dummyCRead);

        std::cout<<"Read D: \n";
        UTIL::printIQMatrix(dummyDRead);

    }


    std::string generateExperimentTitle(){
        auto now = std::chrono::system_clock::now();
        time_t now_c = std::chrono::system_clock::to_time_t(now);
        struct tm local_tm;
        localtime_r(&now_c, &local_tm);

        std::string year    = std::to_string(local_tm.tm_year + 1900);  // tm_year is years since 1900
        std::string month   = std::to_string(local_tm.tm_mon + 1);     // tm_mon is months since January (0-11)
        std::string day     = std::to_string(local_tm.tm_mday);          // tm_mday is day of the month (1-31)
        std::string hour    = std::to_string(local_tm.tm_hour);         // tm_hour is hours since midnight (0-23)
        std::string minute  = std::to_string(local_tm.tm_min);        // tm_min is minutes after the hour (0-59)
        std::string second  = std::to_string(local_tm.tm_sec);        // tm_sec is seconds after the minute (0-60)

        return year+"_"+month+"_"+day+"_"+hour+"h"+minute;

    }
    
    template <typename attributeDataType>
    void attachAttributeToDataset(std::string fileNameNoExt, std::string datasetPath, std::string attributeTitle, attributeDataType attributeValue){
        HighFive::File file(fileNameNoExt+".h5",HighFive::File::ReadWrite);
        HighFive::DataSet dataset;
        
        //getting dataset
        if (file.exist(datasetPath)){
            dataset=file.getDataSet(datasetPath);
        }else{
            std::cerr<<"Dataset "<<datasetPath<< " does not exist\n";
            return;
        }

        dataset.createAttribute(attributeTitle,attributeValue);
    }
    template void attachAttributeToDataset<double>(std::string, std::string, std::string, double);
    template void attachAttributeToDataset<int>(std::string, std::string, std::string, int);
    template void attachAttributeToDataset<float>(std::string, std::string, std::string, float);

    void dumpComplexMatrixtoHDF(std::vector<std::vector<std::complex<double>>> dataVector, std::string fileNameNoExt, std::string dataSetName){
        H5Easy::File dumpingFile(fileNameNoExt+".h5",H5Easy::File::ReadWrite);
        H5Easy::dump(dumpingFile,dataSetName,dataVector,H5Easy::DumpMode::Overwrite);
    }
    
    template<typename precision>
    void dumpComplexVectortoHDF(std::vector<std::complex<precision>> dataVector, std::string fileNameNoExt, std::string dataSetName){
        H5Easy::File dumpingFile(fileNameNoExt+".h5",H5Easy::File::ReadWrite);
        H5Easy::dump(dumpingFile,dataSetName,dataVector,H5Easy::DumpMode::Overwrite);
    }
    template void dumpComplexVectortoHDF<double>(std::vector<std::complex<double>>, std::string, std::string);
    template void dumpComplexVectortoHDF<float>(std::vector<std::complex<float>>, std::string, std::string);

    template<typename precision>
    void dumpVectortoHDF(std::vector<precision> dataVector, std::string fileNameNoExt, std::string dataSetName){
        H5Easy::File dumpingFile(fileNameNoExt+".h5",H5Easy::File::ReadWrite);
        H5Easy::dump(dumpingFile,dataSetName,dataVector,H5Easy::DumpMode::Overwrite);
    }
    template void dumpVectortoHDF<double>(std::vector<double>, std::string, std::string);
    template void dumpVectortoHDF<float>(std::vector<float>, std::string, std::string);
    


}// namespace storage



