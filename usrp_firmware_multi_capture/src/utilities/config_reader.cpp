// read_config.cpp
#include "utilities/config_constants.hpp"
#include "utilities/config_reader.hpp"
#include <fstream>
#include "nhlomann/json.hpp"
#include <iostream>

namespace CONFIG{
    std::string SDR_IP_TX;
    std::string SDR_IP_RX;
    std::string TX_SUBDEV;
    std::string RX_SUBDEV;
    std::string REF_CLOCK;
    std::string RX_CLOCK;
    std::string TX_ANTENNA;
    std::string RX_ANTENNA;
    std::string test_type_string;
    TEST_TYPES TEST_TYPE;
    std::string OUTPUT_FILE;
    bool VERBOSE;
    ////////////// single frequency parameters (currently only associated with transmit_single_frequency() function
    double TX_FREQ;
    double TX_RATE;
    double TX_BW;
    double TX_GAIN;
    size_t NUM_SAMPS;
    ////////////// 
    double RX_FREQ;
    double RX_RATE;
    double RX_BW;
    double RX_GAIN;
    /////////////
    double SFCW_START_FREQ;
    double SFCW_MIN_RESOLUTION;
    double SFCW_MAX_RANGE;
    double SFCW_IF;
    int SFCW_NUM_SWEEPS; 

    //local
    bool configRead=false;
    bool configValid=false;
    USRP_MODE device_mode=INVALID_MODE;


    int readConfigFile(const std::string& filename) {
        //access file
        std::ifstream file(filename);
        if (!file.is_open()) {
            std::cerr<<"Cannot Open File with path:"<<filename<<std::endl;
            return -1;
        }

        //read in json file
        nlohmann::json config;
        file >> config;

        ///////////////////////// Assign values to variables based on the JSON structure
        ////////////// For all configs
        SDR_IP_TX = config["SDR_IP_TX"];
        SDR_IP_RX = config["SDR_IP_RX"];
        TX_SUBDEV = config["TX_SUBDEV"];
        RX_SUBDEV = config["RX_SUBDEV"];
        REF_CLOCK = config["REF_CLOCK"];
        RX_CLOCK = config["RX_CLOCK"];
        TX_ANTENNA = config["TX_ANTENNA"];
        RX_ANTENNA = config["RX_ANTENNA"];
        test_type_string  = config["TEST_TYPE"];
        TEST_TYPE=cast_test_type_str_to_enum(test_type_string);
        OUTPUT_FILE=config["OUTPUT_FILE"];
        VERBOSE=config["VERBOSE"];
        ////////////// TX single frequency parameters (currently only associated with transmit_single_frequency() function
        TX_FREQ=config["TX_FREQ"];
        TX_RATE=config["TX_RATE"];
        TX_BW=config["TX_BW"];
        TX_GAIN=config["TX_GAIN"];
        NUM_SAMPS=std::size_t(config["NUM_SAMPS"]);
        ////////////// RX single frequency parameters 
        RX_FREQ=config["RX_FREQ"];
        RX_RATE=config["RX_RATE"];
        RX_BW=config["RX_BW"];
        RX_GAIN=config["RX_GAIN"];

        if(VERBOSE){
            std::cout<<"SDR_IP_TX="<<SDR_IP_TX<<"\n";
            std::cout<<"SDR_IP_RX="<<SDR_IP_RX<<"\n";
            std::cout<<"TX_SUBDEV="<<TX_SUBDEV<<"\n";            
            std::cout<<"RX_SUBDEV="<<RX_SUBDEV<<"\n";            
            std::cout<<"REF_CLOCK="<<REF_CLOCK<<"\n";       
            std::cout<<"RX_CLOCK="<<RX_CLOCK<<"\n";     
            std::cout<<"TX_ANTENNA="<<TX_ANTENNA<<"\n";            
            std::cout<<"RX_ANTENNA="<<RX_ANTENNA<<"\n";            
            std::cout<<"TEST_TYPE="<<test_type_string<<"\n";            
            std::cout<<"output to be written to OUTPUT_FILE="<<OUTPUT_FILE<<"\n";            
            std::cout<<"PROG RUNNING IN VERBOSE MODE:="<<VERBOSE<<"\n";
            /////            
            std::cout<<"TX_FREQ="<<TX_FREQ<<"\n";            
            std::cout<<"TX_RATE="<<TX_RATE<<"\n";            
            std::cout<<"TX_BW="<<TX_BW<<"\n";
            std::cout<<"TX_GAIN="<<TX_GAIN<<"\n";            
            std::cout<<"NUM_SAMPS="<<NUM_SAMPS<<"\n";
            ////            
            std::cout<<"RX_FREQ="<<RX_FREQ<<"\n";            
            std::cout<<"TX_RATE="<<RX_RATE<<"\n";            
            std::cout<<"RX_BW="<<RX_BW<<"\n";
            std::cout<<"RX_GAIN="<<RX_GAIN<<"\n";
        }
        

        // Check that all values are allowed
        bool allValuesAllowed=true;
        allValuesAllowed&=(SDR_IP_ALLOWED.find(SDR_IP_TX)!=SDR_IP_ALLOWED.end());
        allValuesAllowed&=(TX_SUBDEV_ALLOWED.find(TX_SUBDEV)!=TX_SUBDEV_ALLOWED.end());
        allValuesAllowed&=(RX_SUBDEV_ALLOWED.find(RX_SUBDEV)!=RX_SUBDEV_ALLOWED.end());
        allValuesAllowed&=(REF_CLOCK_ALLOWED.find(REF_CLOCK)!=REF_CLOCK_ALLOWED.end());
        allValuesAllowed&=(TX_ANTENNA_ALLOWED.find(TX_ANTENNA)!=TX_ANTENNA_ALLOWED.end());
        allValuesAllowed&=(RX_ANTENNA_ALLOWED.find(RX_ANTENNA)!=RX_ANTENNA_ALLOWED.end());
        // could implement checks above to let user know where something is not 

        if (!allValuesAllowed){
            std::cerr<<"One of the config parameters is not right (but I am not telling you which)"<<std::endl;
            return- -1;
        }
        else{
            configRead=true;
            return 0;
        }
    }


    bool checkAllConfigsValid() {
    // method assumes that all values are already in allowed set

        // making sure antenna configuration is valid
        if(TX_ANTENNA==RX_ANTENNA){
            //std::cerr<<"Config is attempting to TX and RX on same channel:"<<std::endl;
            // std::cerr<<TX_ANTENNA<<"&"<<RX_ANTENNA<<std::endl;
            // configValid=false;
            // device_mode=INVALID_MODE;
            // return false;    
        }
        if(TX_ANTENNA==""&&RX_ANTENNA==""){ //at least one antenna is defined
            std::cerr<<"No antennas specified"<<std::endl;
            configValid=false;
            device_mode=INVALID_MODE;
            return false;
        }
        if(TX_ANTENNA==""&&RX_ANTENNA!=""){ // RX only mode
            std::cout<<"Device configured as RX only"<<std::endl;
            configValid=true;
            device_mode=RX_ONLY_MODE;
        }
        if(TX_ANTENNA!=""&&RX_ANTENNA==""){ // RX only mode
            std::cout<<"Device configured as TX only"<<std::endl;
            configValid=true;
            device_mode=TX_AND_RX_MODE;
        }
        if(TX_ANTENNA!=""&&RX_ANTENNA!=""){ // RX only mode
            std::cout<<"Device configured as TX and RX"<<std::endl;
            configValid=true;
            device_mode=TX_AND_RX_MODE;
        }
        if(TEST_TYPE == 3) {
            device_mode = RUN_MAIN;
        }
        /*
        //checking valid test type
        if(TEST_TYPE==TEST_TYPES::INVALID){
            configValid=false;
            std::cerr<<"Invalid test type found"<<std::endl;
            return configValid;
        }
        */
        return configValid;
    }

    TEST_TYPES cast_test_type_str_to_enum(std::string test_type_str)
    {
        static const std::map<std::string,TEST_TYPES> test_types_map={
            {"TRANSMIT_SINGLE_FREQ",TEST_TYPES::TRANSMIT_SINGLE_FREQ},
            {"RECEIVE_SINGLE_FREQ",TEST_TYPES::RECEIVE_SINGLE_FREQ},
            {"LOOPBACK",TEST_TYPES::LOOPBACK},
            {"MAIN",TEST_TYPES::MAIN},
            {"LOOPBACK_SINGLE_DOWNMIX",TEST_TYPES::LOOPBACK_SINGLE_DOWNMIX},
            {"SFCW",TEST_TYPES::SFCW},
        };

        auto it = test_types_map.find(test_type_str);
        if(it!=test_types_map.end()){
            return it->second;
        }
        else{
            return TEST_TYPES::INVALID;
        }
    }


    
} // namespace CONFIG