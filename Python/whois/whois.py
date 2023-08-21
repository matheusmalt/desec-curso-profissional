import socket
import os

os.system("clear")
print("Whois")
consulta = input("Host: ")
consulta = consulta + "\r\n"
consulta = bytes(consulta, "utf-8")
def iana():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("whois.iana.org", 43))
    sock.sendall(consulta)
    banner = sock.recv(1024)
    banner = banner.split()
    banner = banner[19]
    banner = banner.decode("utf-8")
    return banner

def main():
    host = iana()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((host, 43))
    sock.sendall(consulta)
    whois = sock.recv(1024)
    whois = whois.decode("utf-8")
    print(whois)

if __name__ == '__main__':
    main()