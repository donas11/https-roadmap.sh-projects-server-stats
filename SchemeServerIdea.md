graph TD
    A[🖥️ Servidor Principal] -->|🐳 Docker (CronJob) | B[(📦 Ubuntu Container)]
    A -->|🐳 Docker| C[(📦 Nginx Container)]
    C -->|🌍 Servicio Web| D[🌐 Cliente Navegador]
    

    subgraph Docker Containers
        B
        C
    end