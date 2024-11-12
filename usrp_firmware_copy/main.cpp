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
    uhd::tx_streamer::sptr tx_stream = tx_usrp->get_tx_stream(stream_args);
        
    uhd::tx_metadata_t md;
    md.has_time_spec = true;
    md.end_of_burst = false;
    md.time_spec = uhd::time_spec_t(time_now + secondsInFuture);
    md.start_of_burst = false;

    size_t maxTransmitSize=tx_stream->get_max_num_samps(); //not entirely sure where this comes from
    //std::cout<<"Max Transmit Buffer Size: "<<maxTransmitSize<<"\n";
    size_t fullBufferLength=buffers.size();

    if(fullBufferLength<=maxTransmitSize){
        std::vector<std::complex<double>*> pBuffs(1,&buffers.front());
        tx_stream->send(pBuffs,buffers.size(),md,10.0);
        md.end_of_burst=true;
        tx_stream->send("",0,md,10.0);
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
            tx_stream->send(pBuffs,smallbuffer.size(),md,10.0);
            numSent+=smallBufferSize;
            md.has_time_spec=false; //dont want subsequent packets to wait
            md.start_of_burst=false;
        }
        md.end_of_burst=true;
        tx_stream->send("",0,md,10.0);
        std::cout<<"Time of first transmitted sample: "<<md.time_spec.get_full_secs() + md.time_spec.get_frac_secs()<<"\n";
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
    // these should be constants
    std::string cpu_format="fc64"; // function of doubles
    std::string wire_format="sc16"; // https://files.ettus.com/manual/structuhd_1_1stream__args__t.html#a0ba0e946d2f83f7ac085f4f4e2ce9578
        
    // create a receive streamer
    uhd::stream_args_t stream_args(cpu_format, wire_format);
    uhd::rx_streamer::sptr rx_stream = rx_usrp->get_rx_stream(stream_args);
    size_t samps_per_buff=rx_stream->get_max_num_samps();

    // create totalVector
    std::vector<std::complex<double>> entireSample;
    entireSample.reserve(numSamples);

    // allocate buffers to receive with samples (one buffer per channel)
    std::vector<std::complex<double>> sampleBuffer(samps_per_buff);

    // creating a pointer to sample buffer
    std::complex<double>* psampleBuffer = &sampleBuffer[0];


    // setup streaming
    uhd::stream_cmd_t stream_cmd=uhd::stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE;
    stream_cmd.num_samps  = numSamples;
    stream_cmd.stream_now = false;
    stream_cmd.time_spec  = uhd::time_spec_t(time_now + secondsInFuture);
    rx_stream->issue_stream_cmd(stream_cmd);


    // 
    size_t numSamplesReceived=0;
    uhd::rx_metadata_t rxMetaData;
        

    while (numSamplesReceived<numSamples){
        double samplesForThisBlock=numSamples-numSamplesReceived;
        if (samplesForThisBlock>samps_per_buff){
            samplesForThisBlock=samps_per_buff;
        }
            
        size_t numNewSamples=rx_stream->recv(psampleBuffer,samplesForThisBlock,rxMetaData,10.0);

        //append received data to rest of buffer
        entireSample.insert(entireSample.begin()+numSamplesReceived, sampleBuffer.begin(), sampleBuffer.begin()+numNewSamples);
        //increment num samples receieved
        numSamplesReceived+=numNewSamples;
    }
    std::cout<<"Time of first received sample: "<<rxMetaData.time_spec.get_full_secs() + rxMetaData.time_spec.get_frac_secs()<<"\n";
    std::cout<<"Error code on receive: "<<rxMetaData.error_code<<"\n";
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
    
    
    
    tx_usrp->set_sync_source(uhd::device_addr_t("clock_source=internal,time_source=external"));
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

    // Ridiculously important statement that giets rid of weird noise in beginning of record
    //tx_usrp->set_tx_dc_offset(1.0);
    //rx_usrp->set_rx_dc_offset(1.0);



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


    std::string filename = "../../transmitted_data/transmit.dat";
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


/////////////////////////////////////////////////////////////////////
////////////////////// RECEIVE SECTION //////////////////////////////
/////////////////////////////////////////////////////////////////////


    tx_usrp->set_time_now(uhd::time_spec_t(0.0));
    //////////// Global variables //////////
    auto time_now = tx_usrp->get_time_now();
    std::cout<<"\nTime now: "<<time_now.get_full_secs() + time_now.get_frac_secs()<<"\n";


/////////////////////////////////////////////////////////////////////
////////////////////// THREAD SECTION ///////////////////////////////
/////////////////////////////////////////////////////////////////////

    isSetupComplete.store(true);

    std::thread transmit_thread([&]() {
        while (!isSetupComplete.load()) {
            // Busy-wait until setup is complete (could use sleep for more efficiency)
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        tx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
        transmit_vector(tx_usrp, transmitVector, time_now, 1.0);
    });

    std::thread receive_thread([&]() {
        while (!isSetupComplete.load()) {
            // Busy-wait until setup is complete (could use sleep for more efficiency)
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        rx_usrp->set_time_unknown_pps(uhd::time_spec_t(0.0));
        received_data = receive_vector(rx_usrp,CONFIG::NUM_SAMPS,time_now,1.0);
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

    saveComplexDataToFile("../../received_data/receive.dat",received_data);


    return EXIT_SUCCESS;


    // std::vector<std::complex<double>> receivedVector(CONFIG::NUM_SAMPS);


    // uhd::stream_args_t st_args("fc32", "sc16");
    // auto rx_stream = usrp->get_rx_stream(st_args);
    // uhd::rx_metadata_t md{};
    // // Figure out the current time
    // auto time_now = usrp->get_time_now();
    // // Craft timed command
    // uhd::stream_cmd_t stream_cmd(uhd::stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE);
    // stream_cmd.num_samps  = CONFIG::NUM_SAMPS;
    // stream_cmd.stream_now = false; // Enable timed streaming
    // stream_cmd.time_spec = time_now + 1.0; // Start 1s in the future
    // rx_stream->issue_stream_cmd(stream_cmd);
    // // We assume buffers etc. have been allocated
    // const double timeout = 2.0; // We need to wait at least 1 seconds before samples arrive
    // int num_recvd = rx_stream->recv(receivedVector, rx_stream->get_max_num_samps(), md, timeout);
    // // The first sample in 'buffs' will be captured at the requested time. Also,
    // // the metadata object (md) will most likely contain a timestamp which then will
    // // match that in the stream command.


    // std::cout<<"\n\nNumber of samples received: "<<num_recvd<<"\n";




    // int tickRate = 10;
    // long long prevTick = usrp->get_time_now().to_ticks(tickRate);

    // while (1) {
    //     if (usrp->get_time_now().to_ticks(tickRate) > prevTick) {
    //         std::cout<<"\nTime Now: "<<usrp->get_time_now().to_ticks(tickRate)<<"\n";
    //         prevTick = usrp->get_time_now().to_ticks(tickRate);    

    //     }
    // }

    
    



    // std::cout<<"\nTime Sources Availible: ";
    // for (std::string i: usrp->get_time_sources(0))
    //     std::cout << i << ' ';
    // std::cout<<"\nTime Source Chosen: "<<CONFIG::REF_CLOCK<<"\n";

    // std::cout<<"Setting Time Source To: "<<CONFIG::REF_CLOCK<<"\n";
    // usrp->set_time_source(CONFIG::REF_CLOCK);
    // std::cout<<"Done\n";


    // while (usrp->get_mboard_sensor("gps_locked").value == "false") {

    // }
    // std::cout<<"\n GPS Lock Success!\n";

    // std::cout<<"\n"<<usrp->get_mboard_sensor("gps_gprmc").value<<"\n";



    // while (1) {
    //     std::cout<<"\r"<<usrp->get_time_now(0).get_tick_count(100);
    // }


    // return EXIT_SUCCESS;








//     //! Create Global Vars
//     std::vector<std::complex<double>> testVector(CONFIG::NUM_SAMPS, std::complex<double>(0.8,0.0));
//     std::string SFCWErr;
//     IQ_3D entireDataset;
//     IQ_2D allRangeSweeps;
//     std::string experimentName = storage::generateExperimentTitle();
//     std::cout<<"EXPERIMENT NAME= "<<experimentName<<"\n";
//     storage::createEmptyH5CommitDataTypes(CONFIG::OUTPUT_FILE);



// ///////////////// Import previously created waveform /////////////////////////////
// // Open the .dat file in binary mode
//     std::ifstream file("murray_cw.dat", std::ios::binary);
//     if (!file) {
//         std::cerr << "Failed to open the file!" << std::endl;
//         return 1;
//     }

//     // Read the file content into a buffer
//     std::vector<double> buffer;

//     // Move to the end of the file to determine its size
//     file.seekg(0, std::ios::end);
//     size_t fileSize = file.tellg();
//     file.seekg(0, std::ios::beg);

//     // Calculate the number of doubles (real + imaginary)
//     size_t numDoubles = fileSize / sizeof(double);

//     // Resize the buffer to hold the data
//     buffer.resize(numDoubles);

//     // Read the data from the file into the buffer
//     file.read(reinterpret_cast<char*>(buffer.data()), fileSize);
//     file.close();

//     // Check if the number of doubles is even (each complex number has 2 doubles: real + imaginary)
//     if (numDoubles % 2 != 0) {
//         std::cerr << "Invalid data: The number of elements should be even." << std::endl;
//         return 1;
//     }

//     // Create a vector to store the complex numbers
//     std::vector<std::complex<double>> complexData;
//     complexData.reserve(numDoubles / 2);

//     // Interleave the real and imaginary parts into the complex array
//     for (size_t i = 0; i < numDoubles; i += 2) {
//         std::complex<double> complexValue(buffer[i], buffer[i + 1]);
//         complexData.push_back(complexValue);
//     }


// ///////////////// Import previously created waveform /////////////////////////////








//     // // create a sine wave in the real to send
//     // const int size = 10000; // Length of the array
//     // const double frequency = 200.0; // Frequency of the sine wave
//     // const double samplingRate = 10000.0; // Sampling rate
//     // std::vector<std::complex<double>> complexArray(size);

//     // for (int i = 0; i < size; ++i) {
//     //     double t = i / samplingRate; // Time variable
//     //     double realPart = std::sin(2 * M_PI * frequency * t); // Sine wave as the real part
//     //     //double realPart = (std::sin(2 * M_PI * frequency * t) >= 0) ? 1.0 : -1.0;
//     //     testVector[i] = std::complex<double>(realPart, 0.0); // Imaginary part is zero
//     // }

//     // //! set up storage

//     switch (CONFIG::TEST_TYPE)
//     {
//     case CONFIG::TEST_TYPES::TRANSMIT_SINGLE_FREQ:
//         tests::transmitSingleFreq(tx_usrp);
//         break;
//     case CONFIG::TEST_TYPES::RECEIVE_SINGLE_FREQ:
//         std::cout<<"Receiver Set Up. Capturing samples now"<<std::endl;
//         tests::captureSingleFreqToFile(rx_usrp,"double",CONFIG::NUM_SAMPS,CONFIG::OUTPUT_FILE,1.5);
//         break;
//     case CONFIG::TEST_TYPES::LOOPBACK:
//         std::cout<<"Trying to do a loopback test"<<"\n";
//         tests::transmitAndReceiveToH5(usrp,complexData,CONFIG::OUTPUT_FILE,"received",false,1.5);
//         storage::dumpComplexVectortoHDF(complexData,CONFIG::OUTPUT_FILE,"transmit");
//         break;
//     case CONFIG::TEST_TYPES::INVALID:
//         std::cout<<"invalid test type, shutting down"<<std::endl;
//         return EXIT_FAILURE;
//         break;
//     case CONFIG::TEST_TYPES::LOOPBACK_SINGLE_DOWNMIX:
//         std::cout<<"Doing a Loopback with Downmix"<<std::endl;
//         tests::transmitReceiveDownmixToH5(usrp,testVector,CONFIG::OUTPUT_FILE,1.5);
//         break;
//     case CONFIG::TEST_TYPES::SFCW:
//         std::cout<<"\n Performing SFCW Test Now:\n";

//         //! Set up SFCW Pameters
//         if(!DSP::SFCW::setSFCWParameters(&SFCWErr)){
//             std::cerr<<SFCWErr;
//             return EXIT_FAILURE;
//         }

//         //!  Set up Storage
//         storage::createEmptyH5CommitDataTypes(experimentName);
        

//         //! run Sweeps
//         if(CONFIG::SFCW_NUM_SWEEPS<=0){
//             //tests::SFCW::performSweepsTilStopSignal();
//             std::cerr<<"Indefinite Sweeps not implemented yet"<<std::endl;
//             return EXIT_FAILURE;
//         }else{
//             std::cout<<"Starting Sweeps:\n";
//             bool testSuccess= tests::SFCW::performNSweepsAndStore( usrp ,CONFIG::SFCW_NUM_SWEEPS);
//             //storage::testWritingAndReadingMatWithDummyData();
            
//         }



//         break;
//     default:
//         break;
//     }
    
    

//     std::cout<<"Reached End Of main()"<<std::endl;
//     return EXIT_SUCCESS;
}






