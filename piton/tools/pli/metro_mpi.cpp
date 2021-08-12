#include <iostream>
#include <mpi.h>

using namespace std;

unsigned long long message_async;
MPI_Status status_async;
MPI_Request request_async;

const int nitems=2;
int          blocklengths[2] = {1,1};
MPI_Datatype types[2] = {MPI_UNSIGNED_SHORT, MPI_UNSIGNED_LONG_LONG};
MPI_Datatype mpi_data_type;
MPI_Aint     offsets[2];



typedef struct {
    unsigned short valid;
    unsigned long long data;
} mpi_data_t;

extern "C" void initialize(){
    MPI_Init(NULL, NULL);
    cout << "initializing" << endl;
    
    // Initialize the struct data&valid
    offsets[0] = offsetof(mpi_data_t, valid);
    offsets[1] = offsetof(mpi_data_t, data);

    MPI_Type_create_struct(nitems, blocklengths, offsets, types, &mpi_data_type);
    MPI_Type_commit(&mpi_data_type);

}

// MPI Yummy functions
extern "C" unsigned short mpi_receive_yummy(int origin, int flag){
    //cout << "mpi_receive_yummy origin: " << origin << " flag: " << flag << endl;
    unsigned short message;
    int message_len = 1;
    MPI_Status status;
    //cout << "[DPI CPP] Block Receive YUMMY from rank: " << origin << endl << std::flush;
    MPI_Recv(&message, message_len, MPI_UNSIGNED_SHORT, origin, flag, MPI_COMM_WORLD, &status);
    if (short(message)) {
        cout << "[DPI CPP] Yummy received: " << std::hex << (short)message << endl << std::flush;
    }
    return message;
}

extern "C" void mpi_send_yummy(unsigned short message, int dest, int rank, int flag){
    //cout << "mpi_send_yummy message: " << message << " dest: " << dest << "flag: " << flag << endl;
    int message_len = 1;
    if (message) {
        cout << "[DPI CPP] Sending YUMMY " << std::hex << (int)message << " to " << dest << endl << std::flush;
    }
    MPI_Send(&message, message_len, MPI_UNSIGNED_SHORT, dest, flag, MPI_COMM_WORLD);
}

// MPI data&Valid functions
extern "C" void mpi_send_data(unsigned long long data, unsigned char valid, int dest, int rank, int flag){
    //cout << "mpi_send_data data: " << data << " valid: " << valid << " dest: " << dest <<  " flag: " << flag <<endl;
    int message_len = 1;
    mpi_data_t message;
    //cout << "valid: " << std::hex << valid << std::endl;
    message.valid = valid;
    message.data  = data;
    if (valid) {
        cout << flag << " [DPI CPP] Sending DATA valid: " << flag << " " << std::hex << (int)message.valid << " data: " << std::hex << message.data << " to " << dest << endl;
    }
    MPI_Send(&message, message_len, mpi_data_type, dest, flag, MPI_COMM_WORLD);
}

extern "C" unsigned long long mpi_receive_data(int origin, unsigned short* valid, int flag){
    //cout << "mpi_receive_data origin: " << origin << " flag: " << flag << endl;
    int message_len = 1;
    MPI_Status status;
    mpi_data_t message;
    //cout << flag << " [DPI CPP] Blocking Receive data rank: " << origin << endl << std::flush;
    MPI_Recv(&message, message_len, mpi_data_type, origin, flag, MPI_COMM_WORLD, &status);
    if (message.valid) {
        cout << flag << " [DPI CPP] Data Message received: " << (short) message.valid << " " << std::hex << message.data << endl << std::flush;
    }
    *valid = message.valid;
    return message.data;
}

extern "C" void barrier(){
    MPI_Barrier(MPI_COMM_WORLD);
    cout << "barrier" << endl;
}

extern "C" int getRank(){
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    return rank;
}

extern "C" int getSize(){
    int size;
    MPI_Comm_rank(MPI_COMM_WORLD, &size);
    return size;
}

extern "C" void finalize(){
    cout << "[DPI CPP] Finalizing" << endl;
    MPI_Finalize();
}

