#include <uhd/utils/thread.hpp>
#include <uhd/utils/safe_main.hpp>
#include <uhd/usrp/multi_usrp.hpp>
#include <uhd/exception.hpp>
#include <uhd/types/stream_cmd.hpp>
#include <uhd/types/metadata.hpp>
#include <iostream>
#include "utilities/config_constants.hpp"
#include "utilities/config_reader.hpp"
#include "hardware/TX_config.hpp"
#include "hardware/RX_config.hpp"
#include "test_types/transmit_tests.hpp"
#include "test_types/receive_tests.hpp"
#include <iomanip>
#include <fstream>
#include <fstream>
#include <chrono>


std::atomic<bool> isSetupComplete(false);

std::vector<std::complex<double>> readComplexDataFromFile(const std::string& filename) {
    std::vector<std::complex<double>> complexData;
    std::ifstream file(filename, std::ios::binary);

    if (!file) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return complexData;
    }

    while (!file.eof()) {
        double i, q;

        // Read 64-bit double I (real part)
        file.read(reinterpret_cast<char*>(&i), sizeof(double));

        // Read 64-bit double Q (imaginary part)
        file.read(reinterpret_cast<char*>(&q), sizeof(double));

        // Ensure that both I and Q were read successfully
        if (file.gcount() == sizeof(double)) {
            complexData.emplace_back(i, q);  // Add to vector as std::complex<float>
        }
    }

    file.close();
    return complexData;
}

void saveComplexDataToFile(const std::string& filename, const std::vector<std::complex<double>>& complexData) {
    auto now = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch());
    long long timestamp = duration.count();

    // Save timestamp to file
    std::ofstream tfile("../../../masters_large_data/received_data/latest_capture_timestamp.txt");
    if (tfile.is_open()) {
        tfile << timestamp << std::endl;
        tfile.close();
        std::cout << "Timestamp saved: " << timestamp << std::endl;
    } else {
        std::cerr << "Failed to open file for timestamp" << std::endl;
    }    
    
    
    
    
    
    std::ofstream file(filename, std::ios::binary);



    if (!file) {
        std::cerr << "Error opening file for writing: " << filename << std::endl;
        return;
    }

    for (const auto& sample : complexData) {
        double real_part = sample.real();  // Extract real part (I)
        double imag_part = sample.imag();  // Extract imaginary part (Q)

        // Write real part (I) as 64-bit double
        file.write(reinterpret_cast<const char*>(&real_part), sizeof(double));

        // Write imaginary part (Q) as 64-bit double
        file.write(reinterpret_cast<const char*>(&imag_part), sizeof(double));
    }

    file.close();
}


/////////////////////////////////////////////////////////////////////
////////////////////// TRANSMIT SECTION /////////////////////////////
/////////////////////////////////////////////////////////////////////





void transmit_vector(uhd::usrp::multi_usrp::sptr tx_usrp, std::vector<std::complex<double>> buffers, uhd::time_spec_t time_now, double secondsInFuture){
    //set up transmit streamer
    uhd::stream_args_t stream_args("fc64","sc16");
    // stream_args.args["underflow_policy"] = "next_burst";
    uhd::tx_streamer::sptr tx_stream = tx_usrp->get_tx_stream(stream_args);
        
    uhd::tx_metadata_t md;
    md.has_time_spec = true;
    md.end_of_burst = false;
    md.time_spec = uhd::time_spec_t(secondsInFuture);
    md.start_of_burst = false;

    size_t maxTransmitSize=tx_stream->get_max_num_samps(); //not entirely sure where this comes from
    //std::cout<<"Max Transmit Buffer Size: "<<maxTransmitSize<<"\n";
    size_t fullBufferLength=buffers.size();

    //std::cout<<"full buffer length "<<fullBufferLength<<"\n";

    if(fullBufferLength<=maxTransmitSize){
        std::cout<<"OUT OF WHILE LOOP: "<<maxTransmitSize<<"\n";
        std::vector<std::complex<double>*> pBuffs(1,&buffers.front());
        tx_stream->send(pBuffs,buffers.size(),md,0.1);
        //md.end_of_burst=true;
        //tx_stream->send("",0,md,0.1);
        return;
    }else{
        //std::cout<<"IN WHILE LOOP: "<<maxTransmitSize<<"\n";
        size_t numSent=0;
        while (numSent<fullBufferLength)
        {
            size_t smallBufferSize=fullBufferLength-numSent;
            if(smallBufferSize>maxTransmitSize){
                smallBufferSize=maxTransmitSize;
            }
            std::vector<std::complex<double>> smallbuffer(buffers.begin()+numSent,buffers.begin()+numSent+smallBufferSize);
            std::vector<std::complex<double>*> pBuffs(1,&smallbuffer.front());
            tx_stream->send(pBuffs,smallbuffer.size(),md,0.1);
            numSent+=smallBufferSize;
            md.has_time_spec=false; //dont want subsequent packets to wait
            md.start_of_burst=false;
            //std::cout<<"Samps Tramsitted: "<<numSent<<"\n";
        }
        md.end_of_burst=true;
        tx_stream->send("",0,md,0.1);
        // std::cout<<"Time of first transmitted sample: "<<md.time_spec.get_full_secs() + md.time_spec.get_frac_secs()<<"\n";
        return;
    }
}



/////////////////////////////////////////////////////////////////////
////////////////////// TRANSMIT SECTION /////////////////////////////
/////////////////////////////////////////////////////////////////////









/////////////////////////////////////////////////////////////////////
////////////////////// RECEIVE SECTION //////////////////////////////
/////////////////////////////////////////////////////////////////////




std::vector<std::complex<double>> receive_vector(uhd::usrp::multi_usrp::sptr rx_usrp,size_t numSamples,uhd::time_spec_t time_now, double secondsInFuture){
    //set up receive streamer
    uhd::stream_args_t stream_args("fc64","sc16");
    // stream_args.args["underflow_policy"] = "next_burst";
    uhd::rx_streamer::sptr rx_stream = rx_usrp->get_rx_stream(stream_args);

    uhd::rx_metadata_t rxMetaData;
    rxMetaData.has_time_spec = true;
    rxMetaData.end_of_burst = false;
    rxMetaData.time_spec = uhd::time_spec_t(secondsInFuture);
    rxMetaData.start_of_burst = false;


    size_t samps_per_buff=rx_stream->get_max_num_samps();

    // create totalVector
    std::vector<std::complex<double>> entireSample;
    entireSample.reserve(numSamples);

    // allocate buffers to receive with samples (one buffer per channel)
    std::vector<std::complex<double>> sampleBuffer;
    sampleBuffer.reserve(samps_per_buff);

    // creating a pointer to sample buffer
    std::complex<double>* psampleBuffer = &sampleBuffer[0];


    uhd::stream_cmd_t stream_cmd=uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS;
    // // stream_cmd.num_samps  = numSamples;
    // stream_cmd.stream_now = false;
    // stream_cmd.time_spec  = uhd::time_spec_t(time_now + secondsInFuture - 0.03);
    rx_stream->issue_stream_cmd(stream_cmd);


    // 
    size_t numSamplesReceived=0;
    
        

    while (numSamplesReceived<numSamples){
        double samplesForThisBlock=numSamples-numSamplesReceived;
        if (samplesForThisBlock>samps_per_buff){
            samplesForThisBlock=samps_per_buff;
        }
            
        size_t numNewSamples=rx_stream->recv(psampleBuffer,samplesForThisBlock,rxMetaData,0.1);

        //append received data to rest of buffer
        entireSample.insert(entireSample.begin()+numSamplesReceived, sampleBuffer.begin(), sampleBuffer.begin()+numNewSamples);
        //increment num samples receieved
        numSamplesReceived+=numNewSamples;
        rxMetaData.has_time_spec=false; //dont want subsequent packets to wait
        // rxMetaData.start_of_burst=false;
        // std::cout<<"Samps received: "<<numSamplesReceived<<"\n";
    }

    // stream_cmd.stream_now = false;
    // rx_usrp->issue_stream_cmd(stream_cmd);
    //std::cout<<"Time of last received sample: "<<rxMetaData.time_spec.get_full_secs() + rxMetaData.time_spec.get_frac_secs()<<"\n";
    std::cout<<rxMetaData.to_pp_string()<<"\n";
    return entireSample;
}


/////////////////////////////////////////////////////////////////////
////////////////////// RECEIVE SECTION //////////////////////////////
/////////////////////////////////////////////////////////////////////


int setup(int argc, char *argv[]){
    // for floating point printing
    std::cout << std::fixed << std::setprecision(4);


    //check to see if user gave config file
    std::string filepath;
    if (argc != 2) {
        std::cout << "Usage: " << argv[0] << " <filename>" << std::endl;
        return -1; // return error code
    }
    else{
        filepath=argv[1];
        std::cout<<"Config file path:"<<filepath<<std::endl;
    }

    // read config
    if(CONFIG::readConfigFile(filepath)==0){
        std::cout<<"CONFIG Vars should be set up"<<std::endl;
        std::cout<<"Main Device IP = "<<CONFIG::SDR_IP_TX<<std::endl;
        if(!CONFIG::checkAllConfigsValid()){
            return -1;
        }
    }
    else{
        return -1;
    }
    std::cout<<"Config is all valid and setup"<<std::endl;
    return 0;
}


int UHD_SAFE_MAIN(int argc, char *argv[]) {
    uhd::set_thread_priority_safe();
    // run setup
    if (setup(argc,argv)!=0){
        return EXIT_FAILURE;
    }



    // Create the args for the tx and rx usrp
    uhd::device_addr_t tx_usrp_args("addr="+CONFIG::SDR_IP_TX);
    uhd::device_addr_t rx_usrp_args("addr="+CONFIG::SDR_IP_RX);

    // Instantiate a tx and rx multi usrp object
    uhd::usrp::multi_usrp::sptr tx_usrp = uhd::usrp::multi_usrp::make(tx_usrp_args);
    uhd::usrp::multi_usrp::sptr rx_usrp = uhd::usrp::multi_usrp::make(rx_usrp_args);
    std::cout<<"\nMULTI USRP OBJECT CREATED WITH IP ADDRESSES";


    // Set the clock and time sources for the tx and rx usrp devices
    
    // tx_usrp->set_clock_source(CONFIG::REF_CLOCK);
    // tx_usrp->set_time_source("external");
    
    
    
    tx_usrp->set_sync_source(uhd::device_addr_t("clock_source=internal,time_source=none"));
    rx_usrp->set_sync_source(uhd::device_addr_t("clock_source=mimo,time_source=mimo"));
    // rx_usrp->set_clock_source(CONFIG::RX_CLOCK);
    // rx_usrp->set_time_source("mimo");
    std::cout<<"\nREF CLOCK SET AND RX CLOCK SET";

    


    // On the next pps, set the time spec of the tx and rx usrp to 0.0
    //tx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
    //rx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
    //std::cout<<"\nTime on master: "<<tx_usrp->get_time_last_pps().get_frac_secs();
    //std::cout<<"\nTime on slave: "<<rx_usrp->get_time_last_pps().get_frac_secs()<<"\n\n";

    // Switch statement to get the device mode and setup devices accordingly -> mostly main for now
    switch (CONFIG::device_mode)
    {
    case CONFIG::USRP_MODE::TX_ONLY_MODE:
        TX::setupTransmitter(tx_usrp);
        break;
    case CONFIG::USRP_MODE::RX_ONLY_MODE:
        RX::setupReceiever(rx_usrp);
        break;
    case CONFIG::USRP_MODE::TX_AND_RX_MODE:
        TX::setupTransmitter(tx_usrp);
        RX::setupReceiever(rx_usrp);
        break;
    case CONFIG::USRP_MODE::RUN_MAIN:
        TX::setupTransmitter(tx_usrp);
        RX::setupReceiever(rx_usrp);
        break;
    default:
        std::cout<<"Hit default case, mode not set correctly"<<std::endl;
        break;
    }



    std::string filename = "../../../masters_large_data/transmitted_data/transmit.dat";
    std::vector<std::complex<double>> transmitVector = readComplexDataFromFile(filename);


    // Create receive vector
    std::vector<std::complex<double>> received_data;
    received_data.reserve(CONFIG::NUM_SAMPS);


    for (int i = 1; i < 21; i++) {
        auto capture_number = std::to_string(i);


        tx_usrp->set_time_now(uhd::time_spec_t(0.0));
        //////////// Global variables //////////
        auto time_now = tx_usrp->get_time_now();
        std::cout<<"\nCapture "<<capture_number<<"\n";

        
        isSetupComplete.store(true);



        std::thread transmit_thread([&]() {
            //tx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
            transmit_vector(tx_usrp, transmitVector, time_now, 0.5);
        });


        std::thread receive_thread([&]() {
            // Don't need this because this device is the slave device
            //rx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
            received_data = receive_vector(rx_usrp,CONFIG::NUM_SAMPS,time_now, 0.5);
        });


        transmit_thread.join();
        receive_thread.join();


        saveComplexDataToFile("../../../masters_large_data/received_data/multi_receive/raw_captures/receive"+capture_number+".dat",received_data);
        
    }

    return EXIT_SUCCESS;
}

    