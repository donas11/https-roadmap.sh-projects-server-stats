# Organización idea de probarlo en Terraform

```mermaid
graph TD;
    subgraph Servidor["🖥️ Servidores"]
        S1["💻 Ubuntu"];
        S2["💻 Alpine"];
    end

    subgraph Scripts[" 📝 Scripts"]
        F1["📄 server-stats.sh "];
        F2["📄 server-statsv2.sh "];
    end

    subgraph Persist_volumen_IN[" 📂 PV"]
        I1["📄 server-stats.sh "];
        I2["📄 server-statsv2.sh "];
    end

        subgraph Persist_volumen_out[" 📂 PV"]
        O["📄 stats.html "];
    end

    subgraph Nginx_Server["🌐 Servidor Nginx"]
        N["🚀 Nginx"];
    end;

    F1 -->|📋Copy| S1 
    S1 -->|⏳Ejecuta script| O
    O -->|💻 Muestra script.local:32993/stats.html |N

    F1 -->|📋Copy| S2 
    S2 -->|⏳Ejecuta script ❌| O
    O -->|💻 Muestra script.local:32993/stats.html |N

    F2 -->|📋Copy| S1 
    S1 -->|⏳Ejecuta script| O
    O -->|💻 Muestra script.local:32993/stats.html |N

    F2 -->|📋Copy| S2 
    S2 -->|⏳Ejecuta script| O
    O -->|💻 Muestra script.local:32993/stats.html |N


```

La idea principal es ejecutar el script en Ubuntu y Alpine con la versión 1 no funciona en BusyBox por eso se crea la versión 2 mejorada