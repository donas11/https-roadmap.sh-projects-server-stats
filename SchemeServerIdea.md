graph TD
    subgraph 🖥️ Servidores Remotos
        S1[💻 Server 1] 
        S2[💻 Server 2] 
        S3[💻 Server 3] 
    end

    subgraph 🐳 Docker Container
        C[📦 Ubuntu + ⏳ CronJob]
    end

    subgraph 🌐 Nginx Server
        N[🚀 Servidor Nginx]
    end

    C -->|📡 Conexión SSH/API| S1
    C -->|📡 Conexión SSH/API| S2
    C -->|📡 Conexión SSH/API| S3
    C -->|📤 Envío de Datos| N
