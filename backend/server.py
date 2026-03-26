import socket
import threading
from datetime import datetime

HOST = "0.0.0.0"
PORT = 5000
LOG_FILE = "leituras.txt"


def save_log(data: str):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {data}\n"
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line)
    return timestamp


def handle_client(conn, addr):
    print(f"\n📱 Conexão recebida de {addr[0]}:{addr[1]}")
    try:
        raw_data = b""
        while True:
            chunk = conn.recv(1024)
            if not chunk:
                break
            raw_data += chunk

        if raw_data:
            message = raw_data.decode("utf-8").strip()
            parts = message.split("\n")

            if len(parts) == 3:
                battery, lat, lon = parts
                log_line = f"bateria={battery.strip()}% | lat={lat.strip()} | lon={lon.strip()} | ip={addr[0]}"
                timestamp = save_log(log_line)

                print("─" * 50)
                print(f"  Dispositivo : {addr[0]}")
                print(f"  Recebido em : {timestamp}")
                print(f"  Bateria     : {battery.strip()}%")
                print(f"  Latitude    : {lat.strip()}")
                print(f"  Longitude   : {lon.strip()}")
                print("─" * 50)
            else:
                timestamp = save_log(f"raw={message} | ip={addr[0]}")
                print(f"⚠️  Formato inesperado de {addr[0]}: {message!r}")
        else:
            print(f"⚠️  Conexão encerrada sem dados de {addr[0]}")

    except Exception as e:
        print(f"❌ Erro ao processar cliente {addr}: {e}")
    finally:
        conn.close()


def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(10)

    print("=" * 50)
    print("   🖥️  Servidor de Monitoramento Pervasivo")
    print("=" * 50)
    print(f"  Endereço : {HOST}  |  Porta : {PORT}")
    print(f"  Log      : {LOG_FILE}")
    print("=" * 50)
    print("Aguardando dados dos sensores...\n")

    try:
        while True:
            conn, addr = server.accept()
            thread = threading.Thread(
                target=handle_client, args=(conn, addr), daemon=True
            )
            thread.start()
    except KeyboardInterrupt:
        print("\n\n🛑 Servidor encerrado pelo usuário.")
    finally:
        server.close()


if __name__ == "__main__":
    start_server()
