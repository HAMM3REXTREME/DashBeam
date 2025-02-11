import socket
import time
import json

def record_packets(filename, listen_port=4444):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", listen_port))
    print(f"Listening for UDP packets on port {listen_port}...")
    
    packets = []
    start_time = time.time()
    
    try:
        while True:
            data, addr = sock.recvfrom(65535)
            timestamp = time.time() - start_time
            packets.append((timestamp, data.hex()))
            print(f"Received packet from {addr} at {timestamp:.6f} sec")
    except KeyboardInterrupt:
        print("Recording stopped.")
    finally:
        with open(filename, "w") as f:
            json.dump(packets, f)
        print(f"Packets saved to {filename}")

def playback_packets(filename, target_ip="0.0.0.0", send_port=4444):
    with open(filename, "r") as f:
        packets = json.load(f)
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    start_time = time.time()
    
    for timestamp, data_hex in packets:
        sleep_time = timestamp - (time.time() - start_time)
        if sleep_time > 0:
            time.sleep(sleep_time)
        data = bytes.fromhex(data_hex)
        sock.sendto(data, (target_ip, send_port))
        print(f"Replayed packet to {(target_ip, send_port)} at {timestamp:.6f} sec")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python script.py <record|playback> <filename>")
        sys.exit(1)
    
    mode = sys.argv[1]
    filename = sys.argv[2]
    
    if mode == "record":
        record_packets(filename)
    elif mode == "playback":
        playback_packets(filename)
    else:
        print("Invalid mode. Use 'record' or 'playback'.")
