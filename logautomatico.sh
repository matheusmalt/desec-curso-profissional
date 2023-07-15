#!/bin/bash
# Autor: Matheus E L Malta
# Descrição: Este script Bash é um menu interativo para análise de logs. Ele oferece várias opções para analisar diferentes aspectos dos logs, como endereços IP, diretórios acessados e User Agents
# Curso: Pentest Profissional Desec
# Projeto Concluido
# Função para exibir o menu
exibir_menu() {
    echo "          _____           _______                   _____                    _____          
         /\    \         /::\    \                 /\    \                  /\    \         
        /::\____\       /::::\    \               /::\    \                /::\    \        
       /:::/    /      /::::::\    \             /::::\    \              /::::\    \       
      /:::/    /      /::::::::\    \           /::::::\    \            /::::::\    \      
     /:::/    /      /:::/~~\:::\    \         /:::/\:::\    \          /:::/\:::\    \     
    /:::/    /      /:::/    \:::\    \       /:::/  \:::\    \        /:::/__\:::\    \    
   /:::/    /      /:::/    / \:::\    \     /:::/    \:::\    \       \:::\   \:::\    \   
  /:::/    /      /:::/____/   \:::\____\   /:::/    / \:::\    \    ___\:::\   \:::\    \  
 /:::/    /      |:::|    |     |:::|    | /:::/    /   \:::\ ___\  /\   \:::\   \:::\    \ 
/:::/____/       |:::|____|     |:::|    |/:::/____/  ___\:::|    |/::\   \:::\   \:::\____\
\:::\    \        \:::\    \   /:::/    / \:::\    \ /\  /:::|____|\:::\   \:::\   \::/    /
 \:::\    \        \:::\    \ /:::/    /   \:::\    /::\ \::/    /  \:::\   \:::\   \/____/ 
  \:::\    \        \:::\    /:::/    /     \:::\   \:::\ \/____/    \:::\   \:::\    \     
   \:::\    \        \:::\__/:::/    /       \:::\   \:::\____\       \:::\   \:::\____\    
    \:::\    \        \::::::::/    /         \:::\  /:::/    /        \:::\  /:::/    /    
     \:::\    \        \::::::/    /           \:::\/:::/    /          \:::\/:::/    /     
      \:::\    \        \::::/    /             \::::::/    /            \::::::/    /      
       \:::\____\        \::/____/               \::::/    /              \::::/    /       
        \::/    /         ~~                      \::/____/                \::/    /        
         \/____/                                                            \/____/         
                                                                                            "
    echo "===== MENU ====="
    echo "1. Analisar endereços IP"
    echo "2. Analisar diretórios acessados"
    echo "3. Analisar User Agents"
    echo "4. Análise completa"
    echo "0. Sair"
    echo "================"
    echo
}

# Função para analisar endereços IP
analisar_enderecos_ip() {
    # Filtra os endereços IP e conta a ocorrência de cada um
    ip_addresses=$(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$logfile" | sort | uniq -c | sort -rn)

    # Contar o número de endereços IP únicos
    count=$(echo "$ip_addresses" | wc -l)

    # Exibir o resultado
    echo "Número de endereços IP únicos no log: $count"
    echo
    echo "Endereços IP e suas ocorrências (em ordem decrescente):"
    echo "$ip_addresses"
    echo
}

# Função para analisar diretórios acessados
analisar_diretorios() {
    # Array associativo para armazenar os IPs por diretório
    declare -A directories

    # Extrai os diretórios e IPs do arquivo de log
    while IFS=' ' read -r -a line; do
        directory="${line[6]}"
        ip="${line[0]}"

        # Filtra endereços IP duplicados
        if [[ ! "${directories[$directory]}" =~ $ip ]]; then
            directories["$directory"]+=" $ip"
        fi
    done < <(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ \S+ \S+ \S+ \S+ \S+ \S+' "$logfile")

    # Exibe os IPs para cada diretório
    echo "IPs que acessaram cada diretório:"
    for directory in "${!directories[@]}"; do
        ips="${directories[$directory]}"
        echo "Diretório: $directory"
        echo "IPs: $ips"
        echo
    done
}

# Função para analisar User Agents
analisar_user_agents() {
    # Extrai os User Agents do arquivo de log
    user_agents=$(awk -F'"' '{print $6}' "$logfile" | sort -u)

    # Exibe os User Agents de forma ordenada e não duplicada
    echo "User Agents presentes no log:"
    echo "$user_agents"
    echo
}

# Função para análise completa
analisar_completo() {
    analisar_enderecos_ip
    analisar_diretorios
    analisar_user_agents
}

# Função para salvar as informações em um arquivo
salvar_em_arquivo() {
    read -p "Digite o nome do arquivo para salvar as informações: " filename
    echo
    analisar_completo > "$filename"
    echo "As informações foram salvas no arquivo: $filename"
    echo
}

sair() {
  echo "Opção inválida. Fechando programa."
  exit 0
}
# Verifica se o arquivo de log foi passado como argumento
if [ -z "$1" ]; then
    clear
    read -p "Digite o nome do arquivo de log a ser analisado: " logfile
    echo
else
    logfile="$1"
fi

# Verifica se o arquivo existe
if [ ! -f "$logfile" ]; then
    echo "O arquivo $logfile não existe."
    exit 1
fi

# Loop principal do menu
opcao=""
while [ "$opcao" != "0" ]; do
    exibir_menu
    read -p "Digite a opção desejada: " opcao
    echo

    case "$opcao" in
        "1") analisar_enderecos_ip ;;
        "2") analisar_diretorios ;;
        "3") analisar_user_agents ;;
        "4") analisar_completo ;;
        "0") echo "Encerrando o programa. Até logo!" ;;
        *) sair;;
    esac

    echo

    # Pergunta se o usuário deseja salvar as informações em um arquivo
    read -p "Deseja salvar as informações em um arquivo? (S/N): " salvar
    echo

    if [ "$salvar" = "S" ] || [ "$salvar" = "s" ]; then
        salvar_em_arquivo
    fi
done
