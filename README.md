# 📱 Projeto SMS – Flutter + Python

Este projeto implementa um sistema de monitoramento distribuído, onde um dispositivo Android atua como um nó sensor, enviando dados para um servidor central em Python via socket TCP.

- **Backend**: Servidor em Python
- **Frontend**: Aplicação mobile

---


## Visão Geral do Projeto  

### O sistema é composto por duas partes:  

**Frontend (Flutter / Android)**  
Responsável por coletar dados do dispositivo:  
1- 🔋 Nível de bateria  
2- 📍 Coordenadas GPS (Latitude e Longitude)  
**Backend (Python)**  
Responsável por:  
1- Receber os dados via socket TCP  
2- Processar e exibir no console  
3- Armazenar logs com timestamp



## 🚀 Pré-requisitos

Antes de começar, você precisa ter instalado na sua máquina:

- Python 3.x  
- Flutter SDK  

---

## 📂 Estrutura do Projeto

```
project-root/
│
├── backend/     # Servidor Python
│   └── server.py
│
├── frontend/    # Aplicação Flutter
│
└── README.md
```

---

## ⚙️ Como executar o projeto

### 🔧 Backend (Python)

1. Acesse a pasta do backend:

```bash
cd backend
```

2. Execute o servidor:

```bash
python server.py
```

✅ O servidor será iniciado e ficará aguardando conexões.

---

### 📱 Frontend (Flutter)

1. Acesse a pasta do frontend:

```bash
cd frontend
```

2. Execute o aplicativo:

```bash
flutter run
```

📌 Certifique-se de que você possui um dispositivo/emulador conectado.

---

## 🔗 Comunicação entre Frontend e Backend

- Verifique se o backend está rodando antes de iniciar o frontend  
- Caso esteja usando emulador ou celular físico, configure corretamente o **IP do servidor** no app Flutter  


---

## 🛠️ Dicas úteis

- Para listar dispositivos Flutter:
```bash
flutter devices
```

- Para limpar build:
```bash
flutter clean
```

- Para instalar dependências:
```bash
flutter pub get
```

---

