# Organización idea de probarlo en Terraform

```mermaid
graph TD;
    subgraph Servidor["🖥️ Servidores"]
        S1["💻 Ubuntu"];
        S2["💻 Alpine"];
    end

    subgraph Scripts["📝Scripts (config Map) "]
        subgraph Persist_volumen_IN["📂PV"]
            F1["📄server-stats.sh "];
            F2["📄server-statsv2.sh "];
        end
    end
        subgraph Persist_volumen_out["📂PV"]
        O["📄stats.html "];
    end

    subgraph Nginx_Server["🌐 Servidor Nginx"]
        N["🚀 Nginx"];
    end

     subgraph Navegador["💻  Resultado"]
        E["💻 Navegador"];
    end;

    F1 -->|📋Copy| S1 
    S1 -->|⏳Ejecuta scriptv1| O

    F1 -->|📋Copy| S2 
    S2 -->|⏳Ejecuta scriptv1 ❌| O

    F2 -->|📋Copy| S1 
    S1 -->|⏳Ejecuta scriptv2| O
    

    F2 -->|📋Copy| S2 
    S2 -->|⏳Ejecuta scriptv2| O
    


    O -->|💻 Muestra| N
    N -->|🔗 script.local:32993/stats.html|E



```

La idea principal es ejecutar el script en Ubuntu y Alpine con la versión 1 no funciona en BusyBox por eso se crea la versión 2 mejorada

