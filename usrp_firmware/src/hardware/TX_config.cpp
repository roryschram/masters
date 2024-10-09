#include "hardware/TX_config.hpp"
#include <uhd/usrp/multi_usrp.hpp>
#include "utilities/config_reader.hpp"
#include "utilities/utilities.hpp"
#include "utilities/config_constants.hpp"

namespace TX{
    bool confirmTxOscillatorsLocked(uhd::usrp::multi_usrp::sptr usrp_object, std::string ref_source){
        std::string clock_source = ref_source;
        std::vector<std::string> tx_sensor_names;
        tx_sensor_names = usrp_object->get_tx_sensor_names();

        // checking LO
        if (std::find(tx_sensor_names.begin(), tx_sensor_names.end(), "lo_locked")!= tx_sensor_names.end()){
            uhd::sensor_value_t lo_locked = usrp_object->get_tx_sensor("lo_locked");
            std::cout << boost::format("Checking TX.... %s ...") % lo_locked.to_pp_string()  << std::endl;
            if(!lo_locked.to_bool()){
                return false;
            }
        }
        
        tx_sensor_names = usrp_object->get_mboard_sensor_names();
        if ((clock_source == "mimo") and (std::find(tx_sensor_names.begin(), tx_sensor_names.end(), "mimo_locked")!= tx_sensor_names.end())) {
            uhd::sensor_value_t mimo_locked = usrp_object->get_mboard_sensor("mimo_locked");
            std::cout << boost::format("Checking TX .... %s ...") % mimo_locked.to_pp_string()<< std::endl;
            if(!mimo_locked.to_bool()){
                return false;
            }
        }
        if ((clock_source == "external") and (std::find(tx_sensor_names.begin(), tx_sensor_names.end(), "ref_locked")!= tx_sensor_names.end())) {
            uhd::sensor_value_t ref_locked = usrp_object->get_mboard_sensor("ref_locked");
            std::cout << boost::format("Checking TX .... : %s ...") % ref_locked.to_pp_string() << std::endl;
            if(!ref_locked.to_bool()){
                return false;
            }
        }
        return true;
    }

    int setupTransmitter(uhd::usrp::multi_usrp::sptr tx_usrp){
        //ref clock already set up
        tx_usrp->set_tx_subdev_spec(CONFIG::TX_SUBDEV);
        tx_usrp->set_tx_antenna(CONFIG::TX_ANTENNA);


        // sample rate
        double tx_rate=CONFIG::TX_RATE;
        std::cout << "Setting TX Rate (MHz):  "<< (tx_rate / 1e6)<< std::endl;
        tx_usrp->set_tx_rate(tx_rate);
        std::cout << "Actual TX Rate (MHz) : "<< (tx_usrp->get_tx_rate() / 1e6)<< std::endl;
        // bandwidth
        tx_usrp->set_tx_bandwidth(CONFIG::TX_BW);
        // center freq
        double tx_center_freq= CONFIG::TX_FREQ;
        TX::setTxFreqHz(tx_usrp,tx_center_freq);
        // gain
        double tx_gain = CONFIG::TX_GAIN;
        std::cout << "Setting TX Gain (dB) : " << tx_gain<< std::endl;
        tx_usrp->set_tx_gain(tx_gain,0);
        std::cout << "Actual TX Gain (dB) : " << tx_usrp->get_tx_gain() <<". Out of a possible range:"<< tx_usrp->get_tx_gain_range().to_pp_string()<< std::endl;
        // make sure LO locked (give it a few attempts)
        size_t numlockAttempts=0;
        while( numlockAttempts<5&&!confirmTxOscillatorsLocked(tx_usrp,CONFIG::REF_CLOCK)){
            numlockAttempts++;
        }
        // 
        return 0;


    }

    bool setTxFreqHz(uhd::usrp::multi_usrp::sptr tx_usrp, double newTxFreqHz){

        tx_usrp->set_tx_freq(newTxFreqHz);

        if(!(std::abs(tx_usrp->get_tx_freq()-newTxFreqHz)<5e3)){ // if more than 5kHz off 
            std::cerr<<"setting of center freq unsuccessful. Requested: "<< (double)newTxFreqHz/1e6<<" Actually set: "<<(double)tx_usrp->get_tx_freq()/1e6<<"\n";    
            return false;
        }
        else{
            return true;
        }


    }

    bool incrementTxFreqHz(uhd::usrp::multi_usrp::sptr tx_usrp, double freqIncHz){
        double newFreq = tx_usrp->get_tx_freq()+freqIncHz;
        if(newFreq<CONFIG::MIN_FREQ){
            std::cerr<<"Requested Frequency Lower than SBX board capable of. If not using SBX, edit config_constants.hpp\n";
            return false;
        }
        if(newFreq>CONFIG::MAX_FREQ){
            std::cerr<<"Requested Frequency higher than SBX board capable of. If not using SBX, edit config_constants.hpp\n";
            return false;
        }

        return setTxFreqHz(tx_usrp, newFreq);

    }

}//namespace TX