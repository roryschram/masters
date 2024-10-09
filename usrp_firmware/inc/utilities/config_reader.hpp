#ifndef CONFIG_READER_HPP
#define CONFIG_READER_HPP
#include <string>
#include "utilities/config_constants.hpp"
#include "processing/SFCW.hpp"

/// @brief CONFIG Namespace used for retrieving and saving config parameters
namespace CONFIG{

    extern std::string SDR_IP_TX;
    extern std::string SDR_IP_RX;
    extern std::string TX_SUBDEV;
    extern std::string RX_SUBDEV;
    extern std::string REF_CLOCK;
    extern std::string RX_CLOCK;
    extern std::string TX_ANTENNA;
    extern std::string RX_ANTENNA;
    extern std::string test_type_string;
    extern TEST_TYPES TEST_TYPE;
    extern std::string OUTPUT_FILE;
    extern bool VERBOSE; 
    ////////////// single frequency parameters (currently only associated with transmit_single_frequency() function
    extern double TX_FREQ;
    extern double TX_RATE;
    extern double TX_BW;
    extern double TX_GAIN;
    extern size_t NUM_SAMPS;
    ////////////// 
    extern double RX_FREQ;
    extern double RX_RATE;
    extern double RX_BW;
    extern double RX_GAIN;

    /// @brief parameters extracted for the waveform based on the config 
    namespace waveform{
        extern DSP::SFCW::DEMODULATION_TYPE demod_type; 
        extern double deltaF;
        extern double deltaT;
        extern double sampsPerF;
        extern int Num_steps;
        extern int N_delay; // the number of samples before we can start using that data for processing
        extern std::string experimentFileName;
    } 
    

    ////////////////// Vars
    extern bool configRead;
    extern bool configValid;
    extern USRP_MODE device_mode;

    /// @brief Sets constants as defined by config file
    /// @param filename path to config file. Must be a json file. 
    /// @return 0 if successful, -1 if unsuccessful
    int readConfigFile(const std::string& filename);

    /// @brief checks if loaded configuration is valid, also sets CONFIG::configValid with result
    /// @return True if valid config, false if not
    bool checkAllConfigsValid();

    /// @brief Somewhat superfluous method to cast a string for the test type into its CONFIG::TEST_TYPES enum equivalent
    /// @param  test_type_str string representing the test type, should come directly from a config file and be one of the options in CONFIG::TEST_TYPE_STR_ALLOWED
    /// @return CONFIG::TEST_TYPES equivalent
    TEST_TYPES cast_test_type_str_to_enum(std::string test_type_str);
}

#endif //CONFIG_READER_HPP
