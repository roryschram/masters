#ifndef CONFIG_CONSTANTS_HPP
#define CONFIG_CONSTANTS_HPP

#include <unordered_set>
#include <string>

/// @brief namespace used for config file related matters. 
namespace CONFIG{

    // For the broad categories of tests using the USRP
    enum USRP_MODE{
        TX_ONLY_MODE=0,
        RX_ONLY_MODE=1,
        TX_AND_RX_MODE=2,
        RUN_MAIN=3,
        INVALID_MODE=-1
    };

    // For different test types
    enum TEST_TYPES{
        INVALID=-1,
        TRANSMIT_SINGLE_FREQ=0,
        RECEIVE_SINGLE_FREQ=1,
        LOOPBACK=2,
        MAIN=3,
        LOOPBACK_SINGLE_DOWNMIX=4,
        SFCW=5,
    };

    // allowed values for config variables
    const std::unordered_set<std::string> SDR_IP_ALLOWED = {"192.168.10.2"};
    const std::unordered_set<std::string> TX_SUBDEV_ALLOWED={"A:0"};
    const std::unordered_set<std::string> RX_SUBDEV_ALLOWED={"A:0"};
    const std::unordered_set<std::string> REF_CLOCK_ALLOWED={"internal","external"};
    const std::unordered_set<std::string> TX_ANTENNA_ALLOWED={"TX/RX",""};
    const std::unordered_set<std::string> RX_ANTENNA_ALLOWED={"TX/RX","RX2",""};
    const std::unordered_set<std::string> TEST_TYPE_STR_ALLOWED={"TRANSMIT_SINGLE_FREQ","LOOPBACK","RECEIVE_SINGLE_FREQ"};


    // SBX Daughterboard constants
    const double MIN_FREQ=400e6; // restricted by USRP
    const double MAX_FREQ=3e9;   // restricted by RF hardware, not USRP
}

#endif
