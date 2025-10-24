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



std::atomic<bool> isTXsetupComplete(false);
std::atomic<bool> isRXsetupComplete(false);

int capture_num;

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

    // Set additional key-value options
    stream_args.args["underflow_policy"] = "next_packet";

    // Setup tx streamer
    uhd::tx_streamer::sptr tx_stream = tx_usrp->get_tx_stream(stream_args);
    
    // Setup metadata
    uhd::tx_metadata_t md;
    md.has_time_spec = true;
    md.end_of_burst = false;
    md.time_spec = uhd::time_spec_t(secondsInFuture);
    md.start_of_burst = true;

    // Get buffer sizes
    size_t maxTransmitSize=tx_stream->get_max_num_samps();
    size_t fullBufferLength=buffers.size();

    // Set atmoic boolean true to indicate complete setup
    isTXsetupComplete.store(true);

    // Transmit data with timed commands
    while (!isRXsetupComplete) {

    }

    if(fullBufferLength<=maxTransmitSize){
        std::vector<std::complex<double>*> pBuffs(1,&buffers.front());
        tx_stream->send(pBuffs,buffers.size(),md,0.1);
        md.end_of_burst=true;
        tx_stream->send("",0,md, 0.1);
        return;
    }else{
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
            md.has_time_spec=false;
            md.start_of_burst=false;
        }
        md.end_of_burst=true;
        tx_stream->send("",0,md,0.1);
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

    // Set additional key-value options

    stream_args.args["underflow_policy"] = "next_burst";           // Drop on overflow (if supported)



    uhd::rx_streamer::sptr rx_stream = rx_usrp->get_rx_stream(stream_args);

    uhd::stream_cmd_t stream_cmd = uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS;
    stream_cmd.stream_now = true;
    stream_cmd.time_spec = uhd::time_spec_t(secondsInFuture-secondsInFuture);
    rx_usrp->issue_stream_cmd(stream_cmd);


    uhd::rx_metadata_t rxMetaData;
    rxMetaData.has_time_spec = true;
    rxMetaData.end_of_burst = false;
    rxMetaData.time_spec = uhd::time_spec_t(secondsInFuture-secondsInFuture);
    rxMetaData.start_of_burst = true;


    size_t samps_per_buff=rx_stream->get_max_num_samps();

    // create totalVector
    std::vector<std::complex<double>> entireSample;
    entireSample.reserve(numSamples);

    // allocate buffers to receive with samples (one buffer per channel)
    std::vector<std::complex<double>> sampleBuffer;
    sampleBuffer.reserve(samps_per_buff);


    // creating a pointer to sample buffer
    std::complex<double>* psampleBuffer = &sampleBuffer[0];


    // uhd::stream_cmd_t stream_cmd=uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS;
    // // // stream_cmd.num_samps  = numSamples;
    // stream_cmd.stream_now = true;
    // // stream_cmd.time_spec  = uhd::time_spec_t(time_now + secondsInFuture - 0.03);
    // rx_stream->issue_stream_cmd(stream_cmd);


    // 
    size_t numSamplesReceived=0;
    
    isRXsetupComplete.store(true);

    while (!isTXsetupComplete) {

    }
        

    while (numSamplesReceived<numSamples){
        double samplesForThisBlock=numSamples-numSamplesReceived;
        if (samplesForThisBlock>samps_per_buff){
            samplesForThisBlock=samps_per_buff;
        }
            
        size_t numNewSamples=rx_stream->recv(psampleBuffer,samplesForThisBlock,rxMetaData,0.1,true);

        //append received data to rest of buffer
        entireSample.insert(entireSample.begin()+numSamplesReceived, sampleBuffer.begin(), sampleBuffer.begin()+numNewSamples);
        //increment num samples receieved
        numSamplesReceived+=numNewSamples;
        rxMetaData.has_time_spec=false; //dont want subsequent packets to wait




        if (rxMetaData.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE) {
            std::cerr << "[RX ERROR] Code: " << rxMetaData.strerror() << std::endl;

            if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) {
                std::cerr << "Timeout while streaming — no samples received in time.\n";
            } else if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_OVERFLOW) {
                std::cerr << "Overflow — samples dropped. Consider lowering rate or increasing buffer size.\n";
            } else if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_LATE_COMMAND) {
                std::cerr << "Late command — command missed scheduling deadline.\n";
            } else if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_BROKEN_CHAIN) {
                std::cerr << "Broken chain — data stream was disrupted.\n";
            } else if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_BAD_PACKET) {
                std::cerr << "Bad packet — corrupted data detected.\n";
            } else if (rxMetaData.error_code == uhd::rx_metadata_t::ERROR_CODE_ALIGNMENT) {
                std::cerr << "Alignment error — misalignment in stream timing.\n";
            } else {
                std::cerr << "Unknown or unhandled error code.\n";
            }

        }


    }

    // stream_cmd.stream_now = false;
    // rx_usrp->issue_stream_cmd(stream_cmd);
    //std::cout<<"Time of last received sample: "<<rxMetaData.time_spec.get_full_secs() + rxMetaData.time_spec.get_frac_secs()<<"\n";
    // std::cout<<rxMetaData.to_pp_string()<<"\n";
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
    if (argc != 3) {
        std::cout << "Usage: " << argv[0] << " <filename>" << std::endl;
        return -1; // return error code
    }
    else{
        filepath=argv[1];
        std::cout<<"Config file path:"<<filepath<<std::endl;

        capture_num=std::stoi(argv[2]);
        std::cout<<"lower:"<<capture_num<<std::endl;
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

    // Ridiculously important statement that giets rid of weird noise in beginning of record
    //tx_usrp->set_tx_dc_offset(1.0);
    //rx_usrp->set_rx_dc_offset(1.0);

    tx_usrp->set_sync_source(uhd::device_addr_t("clock_source=internal,time_source=none"));
    rx_usrp->set_sync_source(uhd::device_addr_t("clock_source=mimo,time_source=mimo"));


    // tx_usrp->set_time_now(uhd::time_spec_t(0.0));
    // rx_usrp->set_time_now(uhd::time_spec_t(0.0));



/////////////////////////////////////////////////////////////////////
////////////////////// TRANSMIT SECTION /////////////////////////////
/////////////////////////////////////////////////////////////////////




    // // Vector for transmit data
    // std::vector<std::complex<float>> transmitVector(CONFIG::NUM_SAMPS);

    // // Parameters for the cosine wave
    // float frequency = 10000.0;     // Frequency of the cosine wave in Hz
    // float sampleRate = CONFIG::TX_RATE;  // Sampling rate in Hz
    // float amplitude = 0.3;     // Amplitude of the cosine wave

    // // Fill the vector with real-valued cosine wave values
    // for (int i = 0; i < CONFIG::NUM_SAMPS; ++i) {
    //     float time = i / sampleRate;  // Time for the current sample
    //     float realValue = amplitude * std::cos(2 * M_PI * frequency * time);
    //     //float realValue = amplitude * math.cos(2 * M_PI * frequency * time);
        
    //     // Set the complex value with real part as the cosine wave and imaginary part as 0
    //     transmitVector[i] = std::complex<float>(realValue, realValue);
    // }


    std::string filename = "../../../masters_large_data/transmitted_data/transmit.dat";
    std::vector<std::complex<double>> transmitVector = readComplexDataFromFile(filename);

    // // Output the data
    // for (const auto& sample : transmitVector) {
    //     std::cout << sample << std::endl;
    // }



/////////////////////////////////////////////////////////////////////
////////////////////// TRANSMIT SECTION /////////////////////////////
/////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////
////////////////////// RECEIVE SECTION //////////////////////////////
/////////////////////////////////////////////////////////////////////

    // Create receive vector
    std::vector<std::complex<double>> received_data;
    received_data.reserve(CONFIG::NUM_SAMPS);


/////////////////////////////////////////////////////////////////////
////////////////////// RECEIVE SECTION //////////////////////////////
/////////////////////////////////////////////////////////////////////


    // tx_usrp->set_time_now(uhd::time_spec_t(0.0));
    //////////// Global variables //////////
    auto time_now = tx_usrp->get_time_now();
    // std::cout<<"\nTime now: "<<time_now.get_full_secs() + time_now.get_frac_secs()<<"\n";


/////////////////////////////////////////////////////////////////////
////////////////////// THREAD SECTION ///////////////////////////////
/////////////////////////////////////////////////////////////////////




    std::thread transmit_thread([&]() {
        tx_usrp->set_time_now(uhd::time_spec_t(0.0));
        transmit_vector(tx_usrp, transmitVector, time_now, 0.1);
    });


    std::thread receive_thread([&]() {
        // Don't need this because this device is the slave device
        //rx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
        received_data = receive_vector(rx_usrp,CONFIG::NUM_SAMPS,time_now, 0.1);
    });



/////////////////////////////////////////////////////////////////////
////////////////////// THREAD SECTION ///////////////////////////////
/////////////////////////////////////////////////////////////////////


    transmit_thread.join();
    receive_thread.join();




    // std::cout<<"\n\nFrac time of scheduled command: "<<time_now.get_full_secs() + time_now.get_frac_secs() + 1.0;
    // std::cout<<"\nFrac time of receive first sample: "<<rxMetaData.time_spec.get_full_secs() + rxMetaData.time_spec.get_frac_secs();
    // std::cout<<"\nFrac time of transmit first sample: "<<txMetaData.time_spec.get_full_secs() + txMetaData.time_spec.get_frac_secs();
    // std::cout<<"\n"<<rxMetaData.to_pp_string(false);

    auto cap_num = std::to_string(capture_num);
    saveComplexDataToFile("../../../masters_large_data/final_testing/range_testing/raw_captures/receive"+cap_num+".dat",received_data);


    return EXIT_SUCCESS;
}

    