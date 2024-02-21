import serial

def listen_to_serial_port(port, baudrate, logfile):
    
    ser = serial.Serial(port, baudrate)

    
    with open(logfile, 'a') as log_file:
        while True:
            
            data = ser.readline().decode().strip()  

            # Write data to log file
            log_file.write(data + '\n')
            log_file.flush()  

if __name__ == "__main__":
    
    com_port = 'COM1'  # Replace 'COM1' with your COM port
    baudrate = 9600  # Adjust baudrate if needed

    
    log_file_name = 'serial_log.txt'  # Adjust log file name as needed

    # Start listening to the serial port
    try:
        print(f"Listening to {com_port}...")
        listen_to_serial_port(com_port, baudrate, log_file_name)
    except serial.SerialException as e:
        print(f"Error: {e}")